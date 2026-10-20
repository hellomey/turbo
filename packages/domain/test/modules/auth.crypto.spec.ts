// QA (BOLT-0006): the REAL auth crypto adapters (no fakes). Blueprint §38 step 1 (OTP stored as an argon2id hash),
// step 3 (constant-time compare, 15-minute access JWT), §38.5 (Desk TOTP secret encrypted at rest), §18/§16 OTP abuse row
// ("Codes are stored hashed"). INT-001 S02, S06.
import { createCipheriv, generateKeyPairSync, randomBytes } from "node:crypto";
import { describe, expect, it } from "vitest";
import {
  AesGcmSecretBox,
  Argon2OtpHasher,
  JoseTokenService,
  nodeAuthCrypto,
  otplibTotp,
} from "../../src/modules/auth/infrastructure/crypto.js";
import { jobQueueOtpMailer, OTP_EMAIL_QUEUE } from "../../src/modules/auth/infrastructure/job-queue-mailer.js";

describe("Argon2OtpHasher (§38: codes stored hashed with argon2id + pepper)", () => {
  const hasher = new Argon2OtpHasher("pepper-one");

  it("stores an argon2id hash, never the code itself", async () => {
    const hash = await hasher.hash("482913");
    expect(hash.startsWith("$argon2id$")).toBe(true);
    expect(hash).not.toContain("482913");
  });

  it("verifies the right code and refuses a wrong one", async () => {
    const hash = await hasher.hash("482913");
    expect(await hasher.verify(hash, "482913")).toBe(true);
    expect(await hasher.verify(hash, "482914")).toBe(false);
  });

  it("the pepper is part of the hash: a different pepper cannot verify (DB leak alone is not enough)", async () => {
    const hash = await hasher.hash("482913");
    expect(await new Argon2OtpHasher("pepper-two").verify(hash, "482913")).toBe(false);
  });

  it("two hashes of the same code differ (random salt)", async () => {
    expect(await hasher.hash("000001")).not.toBe(await hasher.hash("000001"));
  });

  it("a malformed stored hash verifies as false instead of throwing", async () => {
    expect(await hasher.verify("not-a-hash", "482913")).toBe(false);
  });
});

describe("nodeAuthCrypto", () => {
  it("OTP codes are always 6 digits (leading zeros kept)", () => {
    for (let i = 0; i < 500; i++) expect(nodeAuthCrypto.otpCode()).toMatch(/^\d{6}$/);
  });

  it("opaque refresh tokens are 32 random bytes, base64url, unique", () => {
    const a = nodeAuthCrypto.opaqueToken();
    expect(a).toMatch(/^[A-Za-z0-9_-]{43}$/);
    expect(nodeAuthCrypto.opaqueToken()).not.toBe(a);
  });

  it("sha256 is hex and deterministic (refresh tokens are stored hashed)", () => {
    expect(nodeAuthCrypto.sha256("abc")).toBe("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
  });

  it("equals: constant-time compare; different lengths are simply unequal", () => {
    expect(nodeAuthCrypto.equals("abc", "abc")).toBe(true);
    expect(nodeAuthCrypto.equals("abc", "abd")).toBe(false);
    expect(nodeAuthCrypto.equals("abc", "abcd")).toBe(false);
    expect(nodeAuthCrypto.equals("", "")).toBe(true);
  });
});

describe("AesGcmSecretBox (§38.5: Desk TOTP secrets encrypted at rest)", () => {
  const key = randomBytes(32).toString("base64");

  const alice = "0192f0c4-0000-7000-8000-00000000000a";
  const bob = "0192f0c4-0000-7000-8000-00000000000b";

  it("round-trips (v2, bound to the owner) and never contains the plain secret", () => {
    const box = new AesGcmSecretBox(key);
    const sealed = box.seal("JBSWY3DPEHPK3PXP", alice);
    expect(sealed.startsWith("v2.")).toBe(true);
    expect(sealed).not.toContain("JBSWY3DPEHPK3PXP");
    expect(box.open(sealed, alice)).toEqual({ plain: "JBSWY3DPEHPK3PXP", legacy: false });
  });

  it("SEC-L6: a secret moved to another user's row cannot be opened (userId is the AAD)", () => {
    const box = new AesGcmSecretBox(key);
    expect(() => box.open(box.seal("JBSWY3DPEHPK3PXP", alice), bob)).toThrow();
  });

  it("SEC-L6: a legacy v1 value (sealed without AAD) still opens once and is reported as legacy", () => {
    const iv = randomBytes(12);
    const cipher = createCipheriv("aes-256-gcm", Buffer.from(key, "base64"), iv);
    const ct = Buffer.concat([cipher.update("JBSWY3DPEHPK3PXP", "utf8"), cipher.final()]);
    const v1 = ["v1", iv.toString("base64url"), cipher.getAuthTag().toString("base64url"), ct.toString("base64url")].join(".");
    expect(new AesGcmSecretBox(key).open(v1, alice)).toEqual({ plain: "JBSWY3DPEHPK3PXP", legacy: true });
  });

  it("a wrong key or a tampered ciphertext cannot be opened", () => {
    const sealed = new AesGcmSecretBox(key).seal("secret", alice);
    expect(() => new AesGcmSecretBox(randomBytes(32).toString("base64")).open(sealed, alice)).toThrow();
    const [v, iv, tag, ct = ""] = sealed.split(".");
    const flipped = Buffer.from(ct, "base64url");
    flipped.writeUInt8(flipped.readUInt8(0) ^ 0xff, 0);
    expect(() => new AesGcmSecretBox(key).open([v, iv, tag, flipped.toString("base64url")].join("."), alice)).toThrow();
    // Downgrade: relabelling a v2 value as v1 (dropping the AAD) does not open either.
    expect(() => new AesGcmSecretBox(key).open(["v1", iv, tag, ct].join("."), alice)).toThrow();
  });

  it("refuses a key that is not 32 bytes and a value that is not v1/v2-sealed", () => {
    expect(() => new AesGcmSecretBox(randomBytes(16).toString("base64"))).toThrow(/32 bytes/);
    expect(() => new AesGcmSecretBox(key).open("v3.a.b.c", alice)).toThrow(/bad sealed secret/);
    expect(() => new AesGcmSecretBox(key).open("v1.only-two", alice)).toThrow(/bad sealed secret/);
  });
});

describe("otplibTotp (§38.5)", () => {
  it("issues an otpauth URI labelled HeyMey Desk and 6-digit codes that are stable within one 30 s step", async () => {
    const secret = otplibTotp.generateSecret();
    expect(otplibTotp.uri("ops@example.com", secret)).toMatch(/^otpauth:\/\/totp\/.*issuer=HeyMey(%20|\+)Desk/);
    const stepStart = 1_760_000_010; // divisible by 30
    const a = await otplibTotp.codeAt(secret, stepStart);
    expect(a).toMatch(/^\d{6}$/);
    expect(await otplibTotp.codeAt(secret, stepStart + 29)).toBe(a);
  });

  it("matches the RFC 6238 SHA-1 test vector (secret '12345678901234567890', T=59 -> 287082)", async () => {
    // Base32 of ASCII "12345678901234567890"; RFC 6238 Appendix B gives 94287082 for 8 digits -> 287082 for 6.
    expect(await otplibTotp.codeAt("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", 59)).toBe("287082");
  });
});

describe("JoseTokenService (EdDSA, D-2026-10-20-11)", () => {
  const pair = () => {
    const { privateKey, publicKey } = generateKeyPairSync("ed25519");
    return {
      privateKeyPem: privateKey.export({ type: "pkcs8", format: "pem" }).toString(),
      publicKeyPem: publicKey.export({ type: "spki", format: "pem" }).toString(),
    };
  };
  const keys = pair();
  const svc = new JoseTokenService({ ...keys, issuer: "http://localhost:4567" });
  const ctx = { userId: "0192f0c4-0000-7000-8000-000000000001", sessionId: "0192f0c4-0000-7000-8000-000000000002", roles: ["ASPIRANT" as const], isDesk: false };
  const now = new Date("2026-10-20T10:00:00.000Z");

  it("access tokens live exactly 15 minutes", async () => {
    const { token, expiresAt } = await svc.signAccess(ctx, now);
    expect(expiresAt.getTime() - now.getTime()).toBe(15 * 60_000);
    expect(await svc.verifyAccess(token, new Date(now.getTime() + 15 * 60_000 - 1000))).toEqual(ctx);
    expect(await svc.verifyAccess(token, new Date(now.getTime() + 15 * 60_000 + 1000))).toBeNull();
  });

  it("a token signed by another key or for another issuer is refused", async () => {
    const other = new JoseTokenService({ ...pair(), issuer: "http://localhost:4567" });
    expect(await svc.verifyAccess((await other.signAccess(ctx, now)).token, now)).toBeNull();
    const otherIssuer = new JoseTokenService({ ...keys, issuer: "https://evil.example" });
    expect(await svc.verifyAccess((await otherIssuer.signAccess(ctx, now)).token, now)).toBeNull();
  });

  it("unknown roles inside a token are dropped, never trusted", async () => {
    const { token } = await svc.signAccess({ ...ctx, roles: ["ASPIRANT", "SUPERUSER" as never] }, now);
    expect((await svc.verifyAccess(token, now))?.roles).toEqual(["ASPIRANT"]);
  });

  it("a Desk challenge is not an access token and vice versa", async () => {
    const challenge = await svc.signChallenge({ userId: ctx.userId, deviceId: "dev-1" }, now);
    expect(await svc.verifyAccess(challenge, now)).toBeNull();
    expect(await svc.verifyChallenge(challenge, now)).toMatchObject({ userId: ctx.userId, deviceId: "dev-1" });
    expect(await svc.verifyChallenge((await svc.signAccess(ctx, now)).token, now)).toBeNull();
    expect(await svc.verifyChallenge("garbage", now)).toBeNull();
  });

  it("SEC-H2: every challenge carries its own random jti and its expiry (5 minutes)", async () => {
    const a = await svc.verifyChallenge(await svc.signChallenge({ userId: ctx.userId, deviceId: "dev-1" }, now), now);
    const b = await svc.verifyChallenge(await svc.signChallenge({ userId: ctx.userId, deviceId: "dev-1" }, now), now);
    expect(a?.jti).toMatch(/^[\w-]{16,}$/);
    expect(a?.jti).not.toBe(b?.jti);
    expect(a?.expiresAt.getTime()).toBe(now.getTime() + 5 * 60_000);
  });
});

describe("jobQueueOtpMailer (§38 step 1: queue the email)", () => {
  it("queues email.otp with jobId = OTP id so a retried request never sends the same code twice", async () => {
    const added: unknown[] = [];
    const mailer = jobQueueOtpMailer({ add: async (...args) => void added.push(args) });
    await mailer.send({ otpId: "otp-1", to: "a@example.com", code: "123456", purpose: "login" });
    expect(OTP_EMAIL_QUEUE).toBe("email.otp");
    expect(added).toEqual([["email.otp", "send", { to: "a@example.com", code: "123456", purpose: "login" }, { jobId: "otp-1" }]]);
  });
});
