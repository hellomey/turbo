/* eslint-disable @typescript-eslint/no-non-null-assertion -- tests assert presence right after creating the row */
import { createCipheriv, randomBytes, randomUUID } from "node:crypto";
import { describe, expect, it } from "vitest";
import { generate } from "otplib";
import { AUTH_POLICY, composeOtpEmail, createOtpMaintenance, isDisposableEmail, normalizeEmail } from "../../src/modules/auth/index.js";
import { JoseTokenService } from "../../src/modules/auth/infrastructure/crypto.js";
import { ACTOR, identityHarness } from "./auth.fakes.js";

const EMAIL = "Asha.Kumar@Example.com ";
const NORM = "asha.kumar@example.com";

async function signIn(h: ReturnType<typeof identityHarness>, deviceId = randomUUID(), email = EMAIL) {
  await h.auth.requestOtp({ email, purpose: "login" });
  const res = await h.auth.verifyOtp({ email, code: h.lastCode(normalizeEmail(email)), deviceId, platform: "android", client: "app" });
  if (res.kind !== "session") throw new Error("expected session");
  return { ...res, deviceId };
}

const wrong = (code: string) => (code === "000000" ? "111111" : "000000");

describe("auth: email rules", () => {
  it("normalises email (trim + lower-case)", () => {
    expect(normalizeEmail("  A@B.Com ")).toBe("a@b.com");
  });

  it("blocks disposable domains incl. sub-domains", async () => {
    const h = identityHarness();
    expect(isDisposableEmail("x@mailinator.com")).toBe(true);
    expect(isDisposableEmail("x@eu.mailinator.com")).toBe(true);
    expect(isDisposableEmail("x@gmail.com")).toBe(false);
    await expect(h.auth.requestOtp({ email: "x@Mailinator.com", purpose: "login" })).rejects.toMatchObject({ code: "EMAIL_NOT_ALLOWED" });
    expect(h.mailbox).toHaveLength(0);
  });

  it("composes plain-text emails without links", () => {
    const login = composeOtpEmail("login", "482913");
    expect(login.subject).toBe("Your HeyMey code");
    expect(login.text).toBe("Your HeyMey code is 482913. It expires in 10 minutes. Never share this code with anyone. If you did not ask for this, ignore this email.");
    const del = composeOtpEmail("delete_account", "482913");
    expect(del.text).toContain("confirms deleting your HeyMey account");
    expect(del.text).not.toMatch(/https?:|www\./);
  });
});

describe("auth: OTP request", () => {
  it("always answers resendAfterSeconds 60 and queues one email with the normalised address and a hashed code", async () => {
    const h = identityHarness();
    expect(await h.auth.requestOtp({ email: EMAIL, purpose: "login" })).toEqual({ resendAfterSeconds: 60 });
    expect(h.mailbox).toHaveLength(1);
    const mail = h.mailbox[0]!;
    expect(mail).toMatchObject({ to: NORM, purpose: "login" });
    expect(mail.code).toMatch(/^\d{6}$/);
    const stored = [...h.mem.otps.values()][0]!;
    expect(stored.id).toBe(mail.otpId);
    expect(stored.codeHash).not.toContain(mail.code);
    expect(stored.codeHash.startsWith("$argon2id$")).toBe(true);
    expect(stored.expiresAt.getTime() - h.clock.now().getTime()).toBe(10 * 60_000);
  });

  it("answers the same for an existing account (never reveals existence)", async () => {
    const h = identityHarness();
    await signIn(h);
    h.clock.advanceMinutes(11);
    expect(await h.auth.requestOtp({ email: EMAIL, purpose: "login" })).toEqual({ resendAfterSeconds: 60 });
  });

  it("allows 3 requests per email per 10 minutes, then RATE_LIMITED with retryAfterSeconds", async () => {
    const h = identityHarness();
    for (let i = 0; i < 3; i++) await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
    await expect(h.auth.requestOtp({ email: NORM, purpose: "login" })).rejects.toMatchObject({
      code: "RATE_LIMITED",
      details: { retryAfterSeconds: 600 },
    });
    h.clock.advanceMinutes(10);
    await expect(h.auth.requestOtp({ email: EMAIL, purpose: "login" })).resolves.toEqual({ resendAfterSeconds: 60 });
  });

  it("delete_account codes need a signed-in caller with the same email", async () => {
    const h = identityHarness();
    await expect(h.auth.requestOtp({ email: EMAIL, purpose: "delete_account" })).rejects.toMatchObject({ code: "FORBIDDEN" });
    await signIn(h);
    const user = (await h.users.findByEmail(NORM))!;
    await expect(h.auth.requestOtp({ email: "other@example.com", purpose: "delete_account", callerUserId: user.id })).rejects.toMatchObject({ code: "FORBIDDEN" });
    await expect(h.auth.requestOtp({ email: EMAIL, purpose: "delete_account", callerUserId: user.id })).resolves.toEqual({ resendAfterSeconds: 60 });
    expect(h.mailbox.at(-1)).toMatchObject({ purpose: "delete_account", to: NORM });
  });
});

describe("auth: OTP verify", () => {
  it("creates a new user with ASPIRANT, binds the device and issues a session", async () => {
    const h = identityHarness();
    const res = await signIn(h);
    expect(res.isNewUser).toBe(true);
    expect(res.deletionCancelled).toBe(false);
    const user = (await h.users.findByEmail(NORM))!;
    expect(await h.roles.rolesOf(user.id)).toEqual(["ASPIRANT"]);
    expect(h.mem.devices.get(res.deviceId)).toMatchObject({ userId: user.id, platform: "android" });
    expect(h.auditRows.map((a) => a.action)).toContain("role.grant");
    const session = [...h.mem.sessions.values()][0]!;
    expect(session.expiresAt.getTime() - h.clock.now().getTime()).toBe(60 * 24 * 3600_000);
    expect(new Date(res.tokens.accessTokenExpiresAt).getTime() - h.clock.now().getTime()).toBe(15 * 60_000);
    const ctx = await h.auth.verifyAccessToken(res.tokens.accessToken);
    expect(ctx).toEqual({ userId: user.id, sessionId: session.id, roles: ["ASPIRANT"], isDesk: false, deviceId: session.deviceId });
  });

  it("second sign-in is not a new user and does not grant again", async () => {
    const h = identityHarness();
    const first = await signIn(h);
    h.clock.advanceMinutes(11);
    const second = await signIn(h, first.deviceId);
    expect(second.isNewUser).toBe(false);
    expect(h.roleRepo.rows).toHaveLength(1);
  });

  it("no code at all -> OTP_EXPIRED", async () => {
    const h = identityHarness();
    await expect(h.auth.verifyOtp({ email: EMAIL, code: "123456", deviceId: randomUUID(), platform: "ios", client: "app" })).rejects.toMatchObject({ code: "OTP_EXPIRED" });
  });

  it("a code is valid until just before 10 minutes and expired at exactly 10 minutes", async () => {
    const h = identityHarness();
    await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
    const code = h.lastCode();
    h.clock.advance(10 * 60_000);
    await expect(h.auth.verifyOtp({ email: EMAIL, code, deviceId: randomUUID(), platform: "ios", client: "app" })).rejects.toMatchObject({ code: "OTP_EXPIRED" });

    const h2 = identityHarness();
    await h2.auth.requestOtp({ email: EMAIL, purpose: "login" });
    h2.clock.advance(10 * 60_000 - 1);
    await expect(h2.auth.verifyOtp({ email: EMAIL, code: h2.lastCode(), deviceId: randomUUID(), platform: "ios", client: "app" })).resolves.toMatchObject({ kind: "session" });
  });

  it("wrong codes count attempts; the 5th wrong locks; then even the right code is OTP_LOCKED", async () => {
    const h = identityHarness();
    await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
    const code = h.lastCode();
    const v = (c: string) => h.auth.verifyOtp({ email: EMAIL, code: c, deviceId: randomUUID(), platform: "ios", client: "app" });
    for (let i = 1; i <= 4; i++) await expect(v(wrong(code))).rejects.toMatchObject({ code: "OTP_INVALID", details: { attemptsLeft: 5 - i } });
    await expect(v(wrong(code))).rejects.toMatchObject({ code: "OTP_LOCKED" });
    expect([...h.mem.otps.values()][0]!.lockedAt).not.toBeNull();
    await expect(v(code)).rejects.toMatchObject({ code: "OTP_LOCKED" });
  });

  it("SEC-M1: 25 concurrent wrong guesses: exactly 5 attempts are reserved and evaluated, the rest are OTP_LOCKED", async () => {
    const h = identityHarness();
    await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
    const code = h.lastCode();
    const results = await Promise.allSettled(
      Array.from({ length: 25 }, () => h.auth.verifyOtp({ email: EMAIL, code: wrong(code), deviceId: randomUUID(), platform: "ios", client: "app" })),
    );
    const codes = results.map((r) => (r.status === "rejected" ? (r.reason as { code: string }).code : "OK"));
    expect(codes.filter((c) => c === "OTP_INVALID")).toHaveLength(4);
    expect(codes.filter((c) => c === "OTP_LOCKED")).toHaveLength(21);
    const otp = [...h.mem.otps.values()][0]!;
    expect(otp.attempts).toBe(5);
    expect(otp.lockedAt).not.toBeNull();
    await expect(h.auth.verifyOtp({ email: EMAIL, code, deviceId: randomUUID(), platform: "ios", client: "app" })).rejects.toMatchObject({ code: "OTP_LOCKED" });
  });

  it("SEC-M1: when the reservation is refused (code used / replaced meanwhile) the answer is OTP_EXPIRED, never a compare", async () => {
    const h = identityHarness();
    await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
    const code = h.lastCode();
    const otps = h.mem.repos.otps;
    const original = otps.reserveAttempt.bind(otps);
    // Someone else uses the code between our read and our reservation.
    otps.reserveAttempt = async (id, now, max) => {
      await otps.markUsed(id, now);
      return original(id, now, max);
    };
    await expect(h.auth.verifyOtp({ email: EMAIL, code, deviceId: randomUUID(), platform: "ios", client: "app" })).rejects.toMatchObject({ code: "OTP_EXPIRED" });
    // A newer code replaced it between the read and the reservation.
    await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
    otps.reserveAttempt = async () => {
      otps.reserveAttempt = original;
      await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
      return null;
    };
    await expect(h.auth.verifyOtp({ email: EMAIL, code: h.lastCode(), deviceId: randomUUID(), platform: "ios", client: "app" })).rejects.toMatchObject({ code: "OTP_EXPIRED" });
    // The row was locked meanwhile -> OTP_LOCKED.
    h.clock.advanceMinutes(11);
    await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
    otps.reserveAttempt = async (id, at) => {
      otps.reserveAttempt = original;
      await otps.lock(id, at);
      return null;
    };
    await expect(h.auth.verifyOtp({ email: EMAIL, code: h.lastCode(), deviceId: randomUUID(), platform: "ios", client: "app" })).rejects.toMatchObject({ code: "OTP_LOCKED" });
  });

  it("a locked code that was not marked yet is locked on the next try", async () => {
    const h = identityHarness();
    await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
    const otp = [...h.mem.otps.values()][0]!;
    otp.attempts = 5;
    await expect(h.auth.verifyOtp({ email: EMAIL, code: h.lastCode(), deviceId: randomUUID(), platform: "ios", client: "app" })).rejects.toMatchObject({ code: "OTP_LOCKED" });
    expect(otp.lockedAt).not.toBeNull();
  });

  it("a code works once; only the latest code counts", async () => {
    const h = identityHarness();
    await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
    const old = h.lastCode();
    await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
    const latest = h.lastCode();
    const deviceId = randomUUID();
    if (old !== latest) {
      await expect(h.auth.verifyOtp({ email: EMAIL, code: old, deviceId, platform: "ios", client: "app" })).rejects.toMatchObject({ code: "OTP_INVALID" });
    }
    await h.auth.verifyOtp({ email: EMAIL, code: latest, deviceId, platform: "ios", client: "app" });
    await expect(h.auth.verifyOtp({ email: EMAIL, code: latest, deviceId, platform: "ios", client: "app" })).rejects.toMatchObject({ code: "OTP_EXPIRED" });
  });

  it("a device bound to another user -> VALIDATION_FAILED and the code stays usable", async () => {
    const h = identityHarness();
    const a = await signIn(h, randomUUID(), "a@example.com");
    await h.auth.requestOtp({ email: "b@example.com", purpose: "login" });
    const code = h.lastCode("b@example.com");
    await expect(h.auth.verifyOtp({ email: "b@example.com", code, deviceId: a.deviceId, platform: "ios", client: "app" })).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
    await expect(h.auth.verifyOtp({ email: "b@example.com", code, deviceId: randomUUID(), platform: "ios", client: "app" })).resolves.toMatchObject({ kind: "session" });
  });

  it("signing in during the deletion grace period cancels the deletion", async () => {
    const h = identityHarness();
    const s = await signIn(h);
    const user = (await h.users.findByEmail(NORM))!;
    await h.users.requestDeletion(user.id, ACTOR);
    h.clock.advanceDays(3);
    const again = await signIn(h, s.deviceId);
    expect(again.deletionCancelled).toBe(true);
    expect((await h.users.getById(user.id))!.deletionRequestedAt).toBeNull();
  });
});

describe("auth: access tokens", () => {
  it("rejects garbage, wrong issuer key, expired tokens and revoked sessions (never throws)", async () => {
    const h = identityHarness();
    const s = await signIn(h);
    expect(await h.auth.verifyAccessToken("not-a-jwt")).toBeNull();
    expect(await h.auth.verifyAccessToken("")).toBeNull();
    const other = identityHarness();
    const foreign = await signIn(other);
    expect(await h.auth.verifyAccessToken(foreign.tokens.accessToken)).toBeNull();

    h.clock.advanceMinutes(14);
    expect(await h.auth.verifyAccessToken(s.tokens.accessToken)).not.toBeNull();
    h.clock.advanceMinutes(1);
    expect(await h.auth.verifyAccessToken(s.tokens.accessToken)).toBeNull();

    const s2 = await signIn(h, s.deviceId);
    const ctx = (await h.auth.verifyAccessToken(s2.tokens.accessToken))!;
    await h.auth.logout(ctx);
    expect(await h.auth.verifyAccessToken(s2.tokens.accessToken)).toBeNull();
  });

  it("a desk challenge token is not an access token", async () => {
    const h = identityHarness();
    const { challengeToken } = await deskChallenge(h);
    expect(await h.auth.verifyAccessToken(challengeToken)).toBeNull();
  });
});

describe("auth: refresh rotation", () => {
  it("rotates on every use; the new pair works", async () => {
    const h = identityHarness();
    const s = await signIn(h);
    h.clock.advanceMinutes(20);
    const next = await h.auth.refresh(s.tokens.refreshToken, ACTOR);
    expect(next.refreshToken).not.toBe(s.tokens.refreshToken);
    expect(await h.auth.verifyAccessToken(next.accessToken)).not.toBeNull();
    const third = await h.auth.refresh(next.refreshToken, ACTOR);
    expect(third.refreshToken).not.toBe(next.refreshToken);
  });

  it("re-using an old refresh token revokes the whole family (audited)", async () => {
    const h = identityHarness();
    const s = await signIn(h);
    const next = await h.auth.refresh(s.tokens.refreshToken, ACTOR);
    await expect(h.auth.refresh(s.tokens.refreshToken, ACTOR)).rejects.toMatchObject({ code: "SESSION_REVOKED" });
    await expect(h.auth.refresh(next.refreshToken, ACTOR)).rejects.toMatchObject({ code: "SESSION_REVOKED" });
    expect(await h.auth.verifyAccessToken(next.accessToken)).toBeNull();
    const session = [...h.mem.sessions.values()][0]!;
    expect(session.revokedReason).toBe("token_reuse");
    const audit = h.auditRows.find((a) => a.action === "auth.session_revoked")!;
    expect(audit.after).toMatchObject({ reason: "token_reuse" });
    expect(JSON.stringify(audit)).not.toContain(s.tokens.refreshToken);
  });

  it("a concurrent second use of the same token is treated as reuse", async () => {
    const h = identityHarness();
    const s = await signIn(h);
    const tok = [...h.mem.tokens.values()][0]!;
    const realMark = h.mem.repos.refreshTokens.markUsed;
    h.mem.repos.refreshTokens.markUsed = async () => false;
    await expect(h.auth.refresh(s.tokens.refreshToken, ACTOR)).rejects.toMatchObject({ code: "SESSION_REVOKED" });
    h.mem.repos.refreshTokens.markUsed = realMark;
    expect(tok).toBeDefined();
    expect([...h.mem.sessions.values()][0]!.revokedReason).toBe("token_reuse");
  });

  it("unknown token, expired session and revoked session -> SESSION_REVOKED", async () => {
    const h = identityHarness();
    await expect(h.auth.refresh("x".repeat(43), ACTOR)).rejects.toMatchObject({ code: "SESSION_REVOKED" });
    const s = await signIn(h);
    h.clock.advanceDays(60);
    await expect(h.auth.refresh(s.tokens.refreshToken, ACTOR)).rejects.toMatchObject({ code: "SESSION_REVOKED" });

    const h2 = identityHarness();
    const s2 = await signIn(h2);
    await h2.auth.logout((await h2.auth.verifyAccessToken(s2.tokens.accessToken))!);
    await expect(h2.auth.refresh(s2.tokens.refreshToken, ACTOR)).rejects.toMatchObject({ code: "SESSION_REVOKED" });
  });

  it("an orphan token whose session is missing -> SESSION_REVOKED", async () => {
    const h = identityHarness();
    const s = await signIn(h);
    h.mem.sessions.clear();
    await expect(h.auth.refresh(s.tokens.refreshToken, ACTOR)).rejects.toMatchObject({ code: "SESSION_REVOKED" });
  });

  it("logout-all revokes every session of the user and audits it", async () => {
    const h = identityHarness();
    const a = await signIn(h);
    h.clock.advanceMinutes(11);
    const b = await signIn(h, a.deviceId);
    const ctx = (await h.auth.verifyAccessToken(b.tokens.accessToken))!;
    expect(await h.auth.logoutAll(ctx.userId, ACTOR)).toEqual({ ok: true });
    expect(await h.auth.verifyAccessToken(a.tokens.accessToken)).toBeNull();
    expect(await h.auth.verifyAccessToken(b.tokens.accessToken)).toBeNull();
    expect(h.auditRows.find((x) => x.action === "auth.session_revoked")!.after).toEqual({ reason: "logout_all", count: 2 });
    // nothing left: no second audit row
    await h.auth.logoutAll(ctx.userId, ACTOR);
    expect(h.auditRows.filter((x) => x.action === "auth.session_revoked")).toHaveLength(1);
  });
});

async function makeStaff(h: ReturnType<typeof identityHarness>, email = "ops@heymey.app") {
  const { user } = await h.users.findOrCreateByEmail(email);
  await h.roles.grant({ userId: user.id, role: "OPS", actor: ACTOR });
  return user;
}

async function deskChallenge(h: ReturnType<typeof identityHarness>, email = "ops@heymey.app", deviceId = randomUUID()) {
  if (!(await h.users.findByEmail(email))) await makeStaff(h, email);
  await h.auth.requestOtp({ email, purpose: "login" });
  const res = await h.auth.verifyOtp({ email, code: h.lastCode(email), deviceId, platform: "web", client: "desk" });
  if (res.kind !== "desk_2fa") throw new Error("expected desk challenge");
  return { ...res, deviceId };
}

/**
 * A fresh challenge signed with the harness keys, as if the user passed the email OTP again (the email step is
 * rate-limited to 3 per 10 minutes, so lockout tests mint challenges directly).
 */
async function mintChallenge(h: ReturnType<typeof identityHarness>, userId: string, deviceId = randomUUID()) {
  const tokens = new JoseTokenService({ privateKeyPem: h.config.jwtPrivateKeyPem, publicKeyPem: h.config.jwtPublicKeyPem, issuer: h.config.jwtIssuer });
  return tokens.signChallenge({ userId, deviceId }, h.clock.now());
}

describe("auth: Desk sign-in (TOTP)", () => {
  it("aspirants and unknown emails are refused on the Desk", async () => {
    const h = identityHarness();
    await signIn(h);
    h.clock.advanceMinutes(11);
    await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
    await expect(h.auth.verifyOtp({ email: EMAIL, code: h.lastCode(), deviceId: randomUUID(), platform: "web", client: "desk" })).rejects.toMatchObject({ code: "DESK_NOT_ALLOWED" });
    await h.auth.requestOtp({ email: "nobody@example.com", purpose: "login" });
    await expect(h.auth.verifyOtp({ email: "nobody@example.com", code: h.lastCode("nobody@example.com"), deviceId: randomUUID(), platform: "web", client: "desk" })).rejects.toMatchObject({ code: "DESK_NOT_ALLOWED" });
    expect(await h.users.findByEmail("nobody@example.com")).toBeNull();
  });

  it("enroll -> verify creates a 12-hour Desk session; the challenge is single-use; replaying a used step is refused", async () => {
    const h = identityHarness();
    const ch = await deskChallenge(h);
    expect(ch.totpEnrolled).toBe(false);
    const { otpauthUri, secret } = await h.auth.enrollDeskTotp(ch.challengeToken, ACTOR);
    expect(otpauthUri).toMatch(/^otpauth:\/\/totp\//);
    expect(otpauthUri).toContain("HeyMey%20Desk");
    expect(decodeURIComponent(otpauthUri)).toContain("ops@heymey.app");
    const stored = [...h.mem.twoFactors.values()][0]!;
    expect(stored.secretEnc).not.toContain(secret);
    expect(stored.secretEnc.startsWith("v2.")).toBe(true);

    const epoch = Math.floor(h.clock.now().getTime() / 1000);
    const code = await generate({ secret, epoch });
    const res = await h.auth.verifyDeskTotp(ch.challengeToken, code, ACTOR);
    expect(res).toMatchObject({ kind: "session", isNewUser: false, deletionCancelled: false });
    const ctx = (await h.auth.verifyAccessToken(res.tokens.accessToken))!;
    expect(ctx).toMatchObject({ isDesk: true, roles: ["OPS"] });
    const session = h.mem.sessions.get(ctx.sessionId)!;
    expect(session.expiresAt.getTime() - h.clock.now().getTime()).toBe(12 * 3600_000);
    expect(h.auditRows.map((a) => a.action)).toEqual(
      expect.arrayContaining(["auth.desk_totp_enroll_started", "auth.desk_totp_enrolled", "auth.desk_signin"]),
    );

    // The challenge was consumed by the successful verify (SEC-H2).
    await expect(h.auth.verifyDeskTotp(ch.challengeToken, code, ACTOR)).rejects.toMatchObject({ code: "CHALLENGE_EXPIRED" });
    // Already confirmed: cannot enroll again.
    await expect(h.auth.enrollDeskTotp(ch.challengeToken, ACTOR)).rejects.toMatchObject({ code: "FORBIDDEN" });
    expect(h.auditRows.at(-1)).toMatchObject({ action: "auth.desk_totp_enroll_refused", after: { reason: "already_set_up" } });
    // Same code, same step, fresh challenge: replay refused.
    await expect(h.auth.verifyDeskTotp(await mintChallenge(h, ctx.userId), code, ACTOR)).rejects.toMatchObject({ code: "TOTP_INVALID" });
    // Next step works.
    h.clock.advance(30_000);
    const next = await generate({ secret, epoch: epoch + 30 });
    await expect(h.auth.verifyDeskTotp(await mintChallenge(h, ctx.userId), next, ACTOR)).resolves.toMatchObject({ kind: "session" });
  });

  it("second Desk sign-in reports totpEnrolled; not enrolled -> TOTP_INVALID (challenge kept); a wrong code burns the challenge", async () => {
    const h = identityHarness();
    const ch = await deskChallenge(h);
    await expect(h.auth.verifyDeskTotp(ch.challengeToken, "123456", ACTOR)).rejects.toMatchObject({ code: "TOTP_INVALID" });
    const { secret } = await h.auth.enrollDeskTotp(ch.challengeToken); // the challenge is still usable
    const code = await generate({ secret, epoch: Math.floor(h.clock.now().getTime() / 1000) });
    await expect(h.auth.verifyDeskTotp(ch.challengeToken, wrong(code), ACTOR)).rejects.toMatchObject({ code: "TOTP_INVALID", details: { attemptsLeft: 4 } });
    // The wrong code consumed the challenge: even the right code needs a new one.
    await expect(h.auth.verifyDeskTotp(ch.challengeToken, code, ACTOR)).rejects.toMatchObject({ code: "CHALLENGE_EXPIRED" });
    const user = (await h.users.findByEmail("ops@heymey.app"))!;
    await h.auth.verifyDeskTotp(await mintChallenge(h, user.id, ch.deviceId), code, ACTOR);
    h.clock.advanceMinutes(11);
    const again = await deskChallenge(h, "ops@heymey.app", ch.deviceId);
    expect(again.totpEnrolled).toBe(true);
  });

  it("accepts one step of clock drift but not two", async () => {
    const h = identityHarness();
    const ch = await deskChallenge(h);
    const { secret } = await h.auth.enrollDeskTotp(ch.challengeToken);
    const user = (await h.users.findByEmail("ops@heymey.app"))!;
    const epoch = Math.floor(h.clock.now().getTime() / 1000);
    await expect(h.auth.verifyDeskTotp(ch.challengeToken, await generate({ secret, epoch: epoch + 60 }), ACTOR)).rejects.toMatchObject({ code: "TOTP_INVALID" });
    await expect(h.auth.verifyDeskTotp(await mintChallenge(h, user.id), await generate({ secret, epoch: epoch - 30 }), ACTOR)).resolves.toMatchObject({ kind: "session" });
  });

  it("SEC-H2: 5 consecutive wrong codes lock the TOTP for 15 minutes; even the right code is TOTP_LOCKED; audited without the code", async () => {
    const h = identityHarness();
    const ch = await deskChallenge(h);
    const { secret } = await h.auth.enrollDeskTotp(ch.challengeToken);
    const user = (await h.users.findByEmail("ops@heymey.app"))!;
    const right = () => generate({ secret, epoch: Math.floor(h.clock.now().getTime() / 1000) });
    const bad = async () => wrong(await right());
    for (let i = 1; i <= 4; i++) {
      await expect(h.auth.verifyDeskTotp(await mintChallenge(h, user.id), await bad(), ACTOR)).rejects.toMatchObject({ code: "TOTP_INVALID", details: { attemptsLeft: 5 - i } });
    }
    await expect(h.auth.verifyDeskTotp(await mintChallenge(h, user.id), await bad(), ACTOR)).rejects.toMatchObject({ code: "TOTP_LOCKED", details: { retryAfterSeconds: 900 } });
    const tf = h.mem.twoFactors.get(user.id)!;
    expect(tf.lockedUntil?.getTime()).toBe(h.clock.now().getTime() + 15 * 60_000);

    // Locked: the right code is refused, the challenge is not even consumed, enroll is refused too.
    h.clock.advanceMinutes(14);
    const ch2 = await mintChallenge(h, user.id);
    await expect(h.auth.verifyDeskTotp(ch2, await right(), ACTOR)).rejects.toMatchObject({ code: "TOTP_LOCKED", details: { retryAfterSeconds: 60 } });
    await expect(h.auth.enrollDeskTotp(ch2, ACTOR)).rejects.toMatchObject({ code: "TOTP_LOCKED" });

    const failed = h.auditRows.filter((a) => a.action === "auth.desk_totp_failed");
    expect(failed.map((a) => a.after)).toEqual([1, 2, 3, 4, 5].map((n) => ({ failedAttempts: n })));
    expect(failed.every((a) => a.target === `user:${user.id}` && a.actor.userId === user.id)).toBe(true);
    expect(h.auditRows.filter((a) => a.action === "auth.desk_totp_locked")).toHaveLength(1);
    expect(JSON.stringify(h.auditRows)).not.toContain(await right());

    // After 15 minutes the same challenge works again (it was never consumed while locked).
    h.clock.advanceMinutes(1);
    await expect(h.auth.verifyDeskTotp(ch2, await right(), ACTOR)).resolves.toMatchObject({ kind: "session" });
    expect(h.mem.twoFactors.get(user.id)).toMatchObject({ failedAttempts: 0, lockedUntil: null });
  });

  it("SEC-H2: a success resets the failure counter (4 wrong, 1 right, 4 wrong is not a lock)", async () => {
    const h = identityHarness();
    const ch = await deskChallenge(h);
    const { secret } = await h.auth.enrollDeskTotp(ch.challengeToken);
    const user = (await h.users.findByEmail("ops@heymey.app"))!;
    const right = () => generate({ secret, epoch: Math.floor(h.clock.now().getTime() / 1000) });
    for (let i = 0; i < 4; i++) {
      await expect(h.auth.verifyDeskTotp(await mintChallenge(h, user.id), wrong(await right()), ACTOR)).rejects.toMatchObject({ code: "TOTP_INVALID" });
    }
    await h.auth.verifyDeskTotp(await mintChallenge(h, user.id), await right(), ACTOR);
    h.clock.advance(30_000);
    for (let i = 0; i < 4; i++) {
      await expect(h.auth.verifyDeskTotp(await mintChallenge(h, user.id), wrong(await right()), ACTOR)).rejects.toMatchObject({ code: "TOTP_INVALID" });
    }
    await expect(h.auth.verifyDeskTotp(await mintChallenge(h, user.id), await right(), ACTOR)).resolves.toMatchObject({ kind: "session" });
  });

  it("SEC-H2: parallel guesses on one challenge: exactly one is evaluated, the rest are CHALLENGE_EXPIRED", async () => {
    const h = identityHarness();
    const ch = await deskChallenge(h);
    const { secret } = await h.auth.enrollDeskTotp(ch.challengeToken);
    const code = await generate({ secret, epoch: Math.floor(h.clock.now().getTime() / 1000) });
    const guesses = Array.from({ length: 20 }, (_, i) => String(100_000 + i)).map((g) => (g === code ? "999999" : g));
    const results = await Promise.allSettled(guesses.map((g) => h.auth.verifyDeskTotp(ch.challengeToken, g, ACTOR)));
    const codes = results.map((r) => (r.status === "rejected" ? (r.reason as { code: string }).code : "OK"));
    expect(codes.filter((c) => c === "TOTP_INVALID")).toHaveLength(1);
    expect(codes.filter((c) => c === "CHALLENGE_EXPIRED")).toHaveLength(19);
  });

  it("SEC-M4: enroll never replaces a pending secret younger than 10 minutes; after that it may; every enroll is audited", async () => {
    const h = identityHarness();
    const ch = await deskChallenge(h);
    const first = await h.auth.enrollDeskTotp(ch.challengeToken, ACTOR);
    const user = (await h.users.findByEmail("ops@heymey.app"))!;
    h.clock.advanceMinutes(9);
    await expect(h.auth.enrollDeskTotp(await mintChallenge(h, user.id), ACTOR)).rejects.toMatchObject({ code: "FORBIDDEN" });
    expect(h.auditRows.at(-1)).toMatchObject({ action: "auth.desk_totp_enroll_refused", target: `user:${user.id}`, after: { reason: "pending_recent" } });
    // The real user's pending secret still works.
    const ok = await generate({ secret: first.secret, epoch: Math.floor(h.clock.now().getTime() / 1000) });
    await expect(h.auth.verifyDeskTotp(await mintChallenge(h, user.id), ok, ACTOR)).resolves.toMatchObject({ kind: "session" });

    // A staff member who never confirmed may restart set-up after 10 minutes.
    const other = await makeStaff(h, "ops2@heymey.app");
    await h.auth.enrollDeskTotp(await mintChallenge(h, other.id), ACTOR);
    h.clock.advanceMinutes(10);
    const second = await h.auth.enrollDeskTotp(await mintChallenge(h, other.id), ACTOR);
    const code = await generate({ secret: second.secret, epoch: Math.floor(h.clock.now().getTime() / 1000) });
    await expect(h.auth.verifyDeskTotp(await mintChallenge(h, other.id), code, ACTOR)).resolves.toMatchObject({ kind: "session" });
    const started = h.auditRows.filter((a) => a.action === "auth.desk_totp_enroll_started");
    expect(started.map((a) => a.target)).toEqual([`user:${user.id}`, `user:${other.id}`, `user:${other.id}`]);
    expect(started[0]!.actor).toMatchObject({ ip: ACTOR.ip, requestId: ACTOR.requestId, userId: user.id });
    expect(JSON.stringify(h.auditRows)).not.toContain(first.secret);
  });

  it("SEC-L6: a secret copied to another user's row is refused; a legacy v1 secret works once and is re-sealed as v2", async () => {
    const h = identityHarness();
    const ch = await deskChallenge(h);
    const { secret } = await h.auth.enrollDeskTotp(ch.challengeToken);
    const victim = (await h.users.findByEmail("ops@heymey.app"))!;
    const attacker = await makeStaff(h, "ops2@heymey.app");
    const now = () => Math.floor(h.clock.now().getTime() / 1000);
    // A database writer copies the victim's sealed secret into the attacker's row.
    h.mem.twoFactors.set(attacker.id, { ...h.mem.twoFactors.get(victim.id)!, userId: attacker.id });
    await expect(h.auth.verifyDeskTotp(await mintChallenge(h, attacker.id), await generate({ secret, epoch: now() }), ACTOR)).rejects.toMatchObject({ code: "TOTP_INVALID" });
    expect(h.auditRows.at(-1)).toMatchObject({ action: "auth.desk_totp_secret_unreadable", target: `user:${attacker.id}` });

    // Legacy row (sealed without AAD before BOLT-0007).
    const iv = randomBytes(12);
    const cipher = createCipheriv("aes-256-gcm", Buffer.from(h.config.totpEncKey, "base64"), iv);
    const ct = Buffer.concat([cipher.update(secret, "utf8"), cipher.final()]);
    const v1 = ["v1", iv.toString("base64url"), cipher.getAuthTag().toString("base64url"), ct.toString("base64url")].join(".");
    h.mem.twoFactors.get(victim.id)!.secretEnc = v1;
    await expect(h.auth.verifyDeskTotp(await mintChallenge(h, victim.id), await generate({ secret, epoch: now() }), ACTOR)).resolves.toMatchObject({ kind: "session" });
    const resealed = h.mem.twoFactors.get(victim.id)!.secretEnc;
    expect(resealed.startsWith("v2.")).toBe(true);
    h.clock.advance(30_000);
    await expect(h.auth.verifyDeskTotp(await mintChallenge(h, victim.id), await generate({ secret, epoch: now() }), ACTOR)).resolves.toMatchObject({ kind: "session" });
    expect(h.mem.twoFactors.get(victim.id)!.secretEnc).toBe(resealed);
  });

  it("challenge expires after 5 minutes; a garbage challenge is CHALLENGE_EXPIRED", async () => {
    const h = identityHarness();
    const ch = await deskChallenge(h);
    await expect(h.auth.enrollDeskTotp("nope")).rejects.toMatchObject({ code: "CHALLENGE_EXPIRED" });
    h.clock.advanceMinutes(5);
    await expect(h.auth.enrollDeskTotp(ch.challengeToken)).rejects.toMatchObject({ code: "CHALLENGE_EXPIRED" });
    await expect(h.auth.verifyDeskTotp(ch.challengeToken, "123456", ACTOR)).rejects.toMatchObject({ code: "CHALLENGE_EXPIRED" });
  });

  it("a staff member who lost the Desk role mid-flow is refused", async () => {
    const h = identityHarness();
    const ch = await deskChallenge(h);
    h.roleRepo.rows = [];
    await expect(h.auth.enrollDeskTotp(ch.challengeToken)).rejects.toMatchObject({ code: "DESK_NOT_ALLOWED" });
  });

  it("a Desk session refresh keeps the Desk flag", async () => {
    const h = identityHarness();
    const ch = await deskChallenge(h);
    const { secret } = await h.auth.enrollDeskTotp(ch.challengeToken);
    const res = await h.auth.verifyDeskTotp(ch.challengeToken, await generate({ secret, epoch: Math.floor(h.clock.now().getTime() / 1000) }), ACTOR);
    const next = await h.auth.refresh(res.tokens.refreshToken, ACTOR);
    expect(await h.auth.verifyAccessToken(next.accessToken)).toMatchObject({ isDesk: true });
    h.clock.advance(12 * 3600_000);
    await expect(h.auth.refresh(next.refreshToken, ACTOR)).rejects.toMatchObject({ code: "SESSION_REVOKED" });
  });
});

describe("auth: delete account (§38.7)", () => {
  it("needs a delete_account code; schedules deletion in 7 days, signs out everywhere, audits", async () => {
    const h = identityHarness();
    const s = await signIn(h);
    const ctx = (await h.auth.verifyAccessToken(s.tokens.accessToken))!;
    // A login code does not confirm deletion.
    await expect(h.auth.deleteAccount(ctx.userId, h.lastCode(), ACTOR)).rejects.toMatchObject({ code: "OTP_EXPIRED" });
    await h.auth.requestOtp({ email: EMAIL, purpose: "delete_account", callerUserId: ctx.userId });
    const code = h.lastCode();
    await expect(h.auth.deleteAccount(ctx.userId, wrong(code), ACTOR)).rejects.toMatchObject({ code: "OTP_INVALID" });
    const res = await h.auth.deleteAccount(ctx.userId, code, ACTOR);
    expect(new Date(res.deletionScheduledFor).getTime() - h.clock.now().getTime()).toBe(7 * 24 * 3600_000);
    expect(await h.auth.verifyAccessToken(s.tokens.accessToken)).toBeNull();
    const actions = h.auditRows.map((a) => a.action);
    expect(actions).toContain("users.deletion_requested");
    expect(actions).toContain("auth.session_revoked");
    expect(JSON.stringify(h.auditRows)).not.toContain(NORM);
    expect((await h.users.getMe(ctx.userId)).deletionScheduledFor).toBe(res.deletionScheduledFor);
  });

  it("an unknown caller -> UNAUTHENTICATED", async () => {
    const h = identityHarness();
    await expect(h.auth.deleteAccount(randomUUID(), "123456", ACTOR)).rejects.toMatchObject({ code: "UNAUTHENTICATED" });
  });
});

describe("auth: OTP data retention (SEC-M3, §38.7, §23)", () => {
  it("purgeOtpCodesFor deletes every code for the (normalised) email and nothing else", async () => {
    const h = identityHarness();
    await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
    await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
    await h.auth.requestOtp({ email: "other@example.com", purpose: "login" });
    expect(await h.auth.purgeOtpCodesFor(EMAIL)).toBe(2);
    expect([...h.mem.otps.values()].map((o) => o.email)).toEqual(["other@example.com"]);
    expect(await h.auth.purgeOtpCodesFor(EMAIL)).toBe(0);
  });

  it("purgeExpiredOtpCodes deletes codes created before the cut-off", async () => {
    const h = identityHarness();
    await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
    h.clock.advanceMinutes(25 * 60);
    await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
    const cutoff = new Date(h.clock.now().getTime() - AUTH_POLICY.otpRetentionMs);
    expect(await h.auth.purgeExpiredOtpCodes(cutoff)).toBe(1);
    expect(h.mem.otps.size).toBe(1);
  });

  it("createOtpMaintenance works on the OTP repository alone (the worker holds no signing keys)", async () => {
    const h = identityHarness();
    await h.auth.requestOtp({ email: EMAIL, purpose: "login" });
    const m = createOtpMaintenance({ repositories: { otps: h.mem.repos.otps } });
    expect(await m.purgeExpiredOtpCodes(h.clock.now())).toBe(0);
    expect(await m.purgeOtpCodesFor(NORM)).toBe(1);
  });
});
