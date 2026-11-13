import { createCipheriv, createDecipheriv, createHash, randomBytes, randomInt, timingSafeEqual } from "node:crypto";
import argon2 from "argon2";
import { SignJWT, importPKCS8, importSPKI, jwtVerify, type CryptoKey } from "jose";
import { generate, generateSecret, generateURI } from "otplib";
import { ROLES, type Role } from "@heymey/contracts";
import { AUTH_POLICY } from "../domain/policy.js";
import type { AccessContext, AuthCrypto, ChallengeClaims, OtpHasher, SecretBox, TokenService, TotpService } from "../application/ports.js";

/** argon2id with the server pepper as argon2 `secret` (§38). Moderate cost: codes live 10 minutes and allow 5 tries. */
export class Argon2OtpHasher implements OtpHasher {
  private readonly secret: Buffer;

  constructor(pepper: string) {
    this.secret = Buffer.from(pepper, "utf8");
  }

  hash(code: string): Promise<string> {
    return argon2.hash(code, { type: argon2.argon2id, secret: this.secret, memoryCost: 19_456, timeCost: 2, parallelism: 1 });
  }

  async verify(hash: string, code: string): Promise<boolean> {
    try {
      return await argon2.verify(hash, code, { secret: this.secret });
    } catch {
      return false;
    }
  }
}

export const nodeAuthCrypto: AuthCrypto = {
  otpCode: () => String(randomInt(0, 1_000_000)).padStart(6, "0"),
  opaqueToken: () => randomBytes(32).toString("base64url"),
  sha256: (v) => createHash("sha256").update(v, "utf8").digest("hex"),
  equals: (a, b) => {
    const x = Buffer.from(a, "utf8");
    const y = Buffer.from(b, "utf8");
    return x.length === y.length && timingSafeEqual(x, y);
  },
};

/**
 * AES-256-GCM: "v2.<iv>.<tag>.<ciphertext>" (base64url) with the owner id as additional authenticated data (SEC-L6):
 * a ciphertext copied to another user's row does not open. Key = 32 bytes, base64.
 *
 * Backward compatibility: "v1." values (sealed before BOLT-0007, no AAD; local dev data only) still open once and are
 * reported as `legacy` so the caller re-seals them as v2 after the next successful verify. A v1 value cannot be
 * forged from a v2 one without the key, so once every row is v2 the binding cannot be downgraded.
 */
export class AesGcmSecretBox implements SecretBox {
  private readonly key: Buffer;

  constructor(keyBase64: string) {
    this.key = Buffer.from(keyBase64, "base64");
    if (this.key.length !== 32) throw new Error("TOTP_ENC_KEY must be 32 bytes");
  }

  seal(plain: string, aad: string): string {
    const iv = randomBytes(12);
    const cipher = createCipheriv("aes-256-gcm", this.key, iv, { authTagLength: 16 });
    cipher.setAAD(Buffer.from(aad, "utf8"));
    const ct = Buffer.concat([cipher.update(plain, "utf8"), cipher.final()]);
    return ["v2", iv.toString("base64url"), cipher.getAuthTag().toString("base64url"), ct.toString("base64url")].join(".");
  }

  open(sealed: string, aad: string): { plain: string; legacy: boolean } {
    const [v, iv, tag, ct] = sealed.split(".");
    if ((v !== "v1" && v !== "v2") || !iv || !tag || ct === undefined) throw new Error("bad sealed secret");
    const decipher = createDecipheriv("aes-256-gcm", this.key, Buffer.from(iv, "base64url"), { authTagLength: 16 });
    if (v === "v2") decipher.setAAD(Buffer.from(aad, "utf8"));
    decipher.setAuthTag(Buffer.from(tag, "base64url"));
    const plain = Buffer.concat([decipher.update(Buffer.from(ct, "base64url")), decipher.final()]).toString("utf8");
    return { plain, legacy: v === "v1" };
  }
}

export const otplibTotp: TotpService = {
  generateSecret: () => generateSecret(),
  uri: (label, secret) => generateURI({ issuer: "HeyMey Desk", label, secret }),
  codeAt: (secret, epochSeconds) => generate({ secret, epoch: epochSeconds }),
};

const API_AUDIENCE = "heymey-api";
const CHALLENGE_AUDIENCE = "heymey-desk-2fa";
const ALG = "EdDSA";

/** EdDSA (Ed25519) JWTs via jose (D-2026-10-20-11). Keys are imported lazily on first use. */
export class JoseTokenService implements TokenService {
  private keys?: Promise<{ priv: CryptoKey; pub: CryptoKey }>;

  constructor(private readonly cfg: { privateKeyPem: string; publicKeyPem: string; issuer: string }) {}

  private load() {
    this.keys ??= Promise.all([importPKCS8(this.cfg.privateKeyPem, ALG), importSPKI(this.cfg.publicKeyPem, ALG)]).then(
      ([priv, pub]) => ({ priv, pub }),
    );
    return this.keys;
  }

  async signAccess(ctx: AccessContext, now: Date): Promise<{ token: string; expiresAt: Date }> {
    const { priv } = await this.load();
    const iat = Math.floor(now.getTime() / 1000);
    const exp = iat + AUTH_POLICY.accessTokenTtlMs / 1000;
    const token = await new SignJWT({ sid: ctx.sessionId, roles: ctx.roles, desk: ctx.isDesk })
      .setProtectedHeader({ alg: ALG, typ: "JWT" })
      .setSubject(ctx.userId)
      .setIssuer(this.cfg.issuer)
      .setAudience(API_AUDIENCE)
      .setIssuedAt(iat)
      .setExpirationTime(exp)
      .sign(priv);
    return { token, expiresAt: new Date(exp * 1000) };
  }

  async verifyAccess(token: string, now: Date): Promise<AccessContext | null> {
    try {
      const { pub } = await this.load();
      const { payload } = await jwtVerify(token, pub, {
        issuer: this.cfg.issuer,
        audience: API_AUDIENCE,
        algorithms: [ALG],
        currentDate: now,
        requiredClaims: ["sub", "exp", "iat"],
      });
      const { sub, sid, roles, desk } = payload as { sub?: unknown; sid?: unknown; roles?: unknown; desk?: unknown };
      if (typeof sub !== "string" || typeof sid !== "string" || typeof desk !== "boolean" || !Array.isArray(roles)) return null;
      const valid = roles.filter((r): r is Role => typeof r === "string" && (ROLES as readonly string[]).includes(r));
      return { userId: sub, sessionId: sid, roles: valid, isDesk: desk };
    } catch {
      return null;
    }
  }

  async signChallenge(input: { userId: string; deviceId: string }, now: Date): Promise<string> {
    const { priv } = await this.load();
    const iat = Math.floor(now.getTime() / 1000);
    return new SignJWT({ purpose: "desk_2fa", deviceId: input.deviceId })
      .setProtectedHeader({ alg: ALG, typ: "JWT" })
      .setSubject(input.userId)
      .setIssuer(this.cfg.issuer)
      .setAudience(CHALLENGE_AUDIENCE)
      .setJti(randomBytes(16).toString("base64url")) // single use (SEC-H2)
      .setIssuedAt(iat)
      .setExpirationTime(iat + AUTH_POLICY.deskChallengeTtlMs / 1000)
      .sign(priv);
  }

  async verifyChallenge(token: string, now: Date): Promise<ChallengeClaims | null> {
    try {
      const { pub } = await this.load();
      const { payload } = await jwtVerify(token, pub, {
        issuer: this.cfg.issuer,
        audience: CHALLENGE_AUDIENCE,
        algorithms: [ALG],
        currentDate: now,
        requiredClaims: ["sub", "exp", "jti"],
      });
      const { sub, purpose, deviceId, jti, exp } = payload as { sub?: unknown; purpose?: unknown; deviceId?: unknown; jti?: unknown; exp?: unknown };
      if (purpose !== "desk_2fa" || typeof sub !== "string" || typeof deviceId !== "string") return null;
      if (typeof jti !== "string" || !jti || typeof exp !== "number") return null;
      return { userId: sub, deviceId, jti, expiresAt: new Date(exp * 1000) };
    } catch {
      return null;
    }
  }
}
