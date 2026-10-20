/* eslint-disable @typescript-eslint/no-non-null-assertion -- tests assert presence right after creating the row */
// Integration: identity modules (auth, users, roles) with their Prisma adapters on REAL PostgreSQL (blueprint §44).
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { generate } from "otplib";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { FakeClock, startPostgres, type StartedDb } from "@heymey/testing";
import { createAuditModule } from "../../src/modules/audit/index.js";
import { AUTH_POLICY, createAuthModule, createOtpMaintenance, createSessionRevoker, type AuthApi } from "../../src/modules/auth/index.js";
import { JoseTokenService } from "../../src/modules/auth/infrastructure/crypto.js";
import { createRolesModule, type RolesApi } from "../../src/modules/roles/index.js";
import { createUsersModule, type UsersApi } from "../../src/modules/users/index.js";
import { ACTOR, MemOneTimeTokens, MemRateLimiter, testKeys } from "./auth.fakes.js";

let db: StartedDb;
let prisma: PrismaClient;
let auth: AuthApi;
let users: UsersApi;
let roles: RolesApi;
const clock = new FakeClock("2026-10-20T06:00:00.000Z");
const mailbox: { to: string; code: string; otpId: string }[] = [];
const codeFor = (to: string) => [...mailbox].reverse().find((m) => m.to === to)!.code;
const keys = testKeys();
const challenges = new JoseTokenService({ privateKeyPem: keys.jwtPrivateKeyPem, publicKeyPem: keys.jwtPublicKeyPem, issuer: keys.jwtIssuer });
/** A fresh Desk challenge, as if the user passed the email step again (that step is rate-limited). */
async function mint(userId: string): Promise<string> {
  const device = await prisma.device.create({ data: { id: randomUUID(), userId, platform: "web" } }); // the OTP step binds it
  return challenges.signChallenge({ userId, deviceId: device.id }, clock.now());
}
const step = () => Math.floor(clock.now().getTime() / 1000);

beforeAll(async () => {
  db = await startPostgres();
  prisma = createPrismaClient(db.url);
  const audit = createAuditModule({ prisma });
  roles = createRolesModule({ prisma, audit });
  users = createUsersModule({ prisma, audit, clock, roles });
  auth = createAuthModule({
    prisma,
    users,
    roles,
    audit,
    clock,
    rateLimiter: new MemRateLimiter(clock),
    mailer: { send: async (m) => void mailbox.push(m) },
    oneTimeTokens: new MemOneTimeTokens(clock),
    config: keys,
  });
});

afterAll(async () => {
  await prisma?.$disconnect();
  await db?.stop();
});

async function signIn(email: string, deviceId = randomUUID()) {
  await auth.requestOtp({ email, purpose: "login", ip: "10.0.0.1" });
  const res = await auth.verifyOtp({ email, code: codeFor(email.trim().toLowerCase()), deviceId, platform: "android", client: "app" });
  if (res.kind !== "session") throw new Error("expected session");
  return { ...res, deviceId };
}

describe("identity (integration, Postgres)", () => {
  it("OTP rows are hashed, attempts counted and locked at 5", async () => {
    await auth.requestOtp({ email: "lock@example.com", purpose: "login", ip: "10.0.0.1" });
    const code = codeFor("lock@example.com");
    const bad = code === "000000" ? "111111" : "000000";
    for (let i = 0; i < 4; i++) {
      await expect(auth.verifyOtp({ email: "lock@example.com", code: bad, deviceId: randomUUID(), platform: "ios", client: "app" })).rejects.toMatchObject({ code: "OTP_INVALID" });
    }
    await expect(auth.verifyOtp({ email: "lock@example.com", code: bad, deviceId: randomUUID(), platform: "ios", client: "app" })).rejects.toMatchObject({ code: "OTP_LOCKED" });
    const row = await prisma.otpCode.findFirstOrThrow({ where: { email: "lock@example.com" } });
    expect(row).toMatchObject({ attempts: 5, requestIp: "10.0.0.1", purpose: "login" });
    expect(row.lockedAt).not.toBeNull();
    expect(row.codeHash).not.toContain(code);
    await expect(auth.verifyOtp({ email: "lock@example.com", code, deviceId: randomUUID(), platform: "ios", client: "app" })).rejects.toMatchObject({ code: "OTP_LOCKED" });
  });

  it("sign-in creates user + ASPIRANT role + device + session + hashed refresh token", async () => {
    const s = await signIn("New.User@Example.com");
    const user = await prisma.user.findUniqueOrThrow({ where: { email: "new.user@example.com" } });
    expect(s.isNewUser).toBe(true);
    expect(await prisma.roleAssignment.findMany({ where: { userId: user.id } })).toMatchObject([{ role: "ASPIRANT", grantedBy: user.id }]);
    expect(await prisma.device.findUniqueOrThrow({ where: { id: s.deviceId } })).toMatchObject({ userId: user.id, platform: "android" });
    const session = await prisma.session.findFirstOrThrow({ where: { userId: user.id } });
    expect(session.isDesk).toBe(false);
    const rt = await prisma.refreshToken.findFirstOrThrow({ where: { sessionId: session.id } });
    expect(rt.tokenHash).toMatch(/^[0-9a-f]{64}$/);
    expect(rt.tokenHash).not.toBe(s.tokens.refreshToken);
    expect(await auth.verifyAccessToken(s.tokens.accessToken)).toMatchObject({ userId: user.id, sessionId: session.id, isDesk: false });
  });

  it("refresh rotation and reuse revoke the family in the database", async () => {
    const s = await signIn("rotate@example.com");
    const next = await auth.refresh(s.tokens.refreshToken, ACTOR);
    await expect(auth.refresh(s.tokens.refreshToken, ACTOR)).rejects.toMatchObject({ code: "SESSION_REVOKED" });
    await expect(auth.refresh(next.refreshToken, ACTOR)).rejects.toMatchObject({ code: "SESSION_REVOKED" });
    const user = await prisma.user.findUniqueOrThrow({ where: { email: "rotate@example.com" } });
    const session = await prisma.session.findFirstOrThrow({ where: { userId: user.id } });
    expect(session.revokedReason).toBe("token_reuse");
    expect(await prisma.refreshToken.count({ where: { sessionId: session.id } })).toBe(2);
    const audit = await prisma.auditLog.findFirstOrThrow({ where: { action: "auth.session_revoked", target: `session:${session.id}` } });
    expect(audit.after).toMatchObject({ reason: "token_reuse", userId: user.id });
  });

  it("device bound to another user is refused", async () => {
    const a = await signIn("dev-a@example.com");
    await auth.requestOtp({ email: "dev-b@example.com", purpose: "login" });
    await expect(
      auth.verifyOtp({ email: "dev-b@example.com", code: codeFor("dev-b@example.com"), deviceId: a.deviceId, platform: "ios", client: "app" }),
    ).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
  });

  it("Desk: OPS user enrolls TOTP (encrypted, BigInt step) and gets a Desk session; replay refused", async () => {
    const { user } = await users.findOrCreateByEmail("ops@heymey.app");
    await roles.grant({ userId: user.id, role: "OPS", actor: ACTOR });
    expect(await roles.canUseDesk(user.id)).toBe(true);
    await auth.requestOtp({ email: "ops@heymey.app", purpose: "login" });
    const ch = await auth.verifyOtp({ email: "ops@heymey.app", code: codeFor("ops@heymey.app"), deviceId: randomUUID(), platform: "web", client: "desk" });
    if (ch.kind !== "desk_2fa") throw new Error("expected challenge");
    const { secret } = await auth.enrollDeskTotp(ch.challengeToken);
    const tf = await prisma.twoFactor.findUniqueOrThrow({ where: { userId: user.id } });
    expect(tf.secretEnc).not.toContain(secret);
    const code = await generate({ secret, epoch: Math.floor(clock.now().getTime() / 1000) });
    const res = await auth.verifyDeskTotp(ch.challengeToken, code, ACTOR);
    const ctx = await auth.verifyAccessToken(res.tokens.accessToken);
    expect(ctx).toMatchObject({ userId: user.id, isDesk: true, roles: ["OPS"] });
    const tf2 = await prisma.twoFactor.findUniqueOrThrow({ where: { userId: user.id } });
    expect(tf2.confirmedAt).not.toBeNull();
    expect(typeof tf2.lastUsedStep).toBe("bigint");
    expect(tf2.secretEnc.startsWith("v2.")).toBe(true);
    // Single-use challenge (SEC-H2); the same step on a fresh challenge is a replay.
    await expect(auth.verifyDeskTotp(ch.challengeToken, code, ACTOR)).rejects.toMatchObject({ code: "CHALLENGE_EXPIRED" });
    await expect(auth.verifyDeskTotp(await mint(user.id), code, ACTOR)).rejects.toMatchObject({ code: "TOTP_INVALID" });
    await expect(auth.enrollDeskTotp(ch.challengeToken)).rejects.toMatchObject({ code: "FORBIDDEN" });
  });

  it("SEC-M1: 25 concurrent wrong guesses on one code: Postgres reserves exactly 5 attempts", async () => {
    const email = "race@example.com";
    await auth.requestOtp({ email, purpose: "login" });
    const code = codeFor(email);
    const bad = code === "000000" ? "111111" : "000000";
    const results = await Promise.allSettled(
      Array.from({ length: 25 }, () => auth.verifyOtp({ email, code: bad, deviceId: randomUUID(), platform: "ios", client: "app" })),
    );
    const codes = results.map((r) => (r.status === "rejected" ? (r.reason as { code: string }).code : "OK"));
    expect(codes.filter((c) => c === "OTP_INVALID")).toHaveLength(4);
    expect(codes.filter((c) => c === "OTP_LOCKED")).toHaveLength(21);
    const row = await prisma.otpCode.findFirstOrThrow({ where: { email } });
    expect(row.attempts).toBe(5);
    expect(row.lockedAt).not.toBeNull();
    await expect(auth.verifyOtp({ email, code, deviceId: randomUUID(), platform: "ios", client: "app" })).rejects.toMatchObject({ code: "OTP_LOCKED" });
  });

  it("SEC-M1: an expired code is never reserved (the expiry check uses the clock passed in, in UTC)", async () => {
    const email = "late@example.com";
    await auth.requestOtp({ email, purpose: "login" });
    const code = codeFor(email);
    clock.advance(AUTH_POLICY.otpTtlMs - 1);
    await expect(auth.verifyOtp({ email, code, deviceId: randomUUID(), platform: "ios", client: "app" })).resolves.toMatchObject({ kind: "session" });
    expect((await prisma.otpCode.findFirstOrThrow({ where: { email } })).attempts).toBe(1);
    await auth.requestOtp({ email, purpose: "login" });
    const next = codeFor(email);
    clock.advance(AUTH_POLICY.otpTtlMs);
    await expect(auth.verifyOtp({ email, code: next, deviceId: randomUUID(), platform: "ios", client: "app" })).rejects.toMatchObject({ code: "OTP_EXPIRED" });
  });

  it("SEC-H2: TOTP failures are counted in Postgres; the 5th locks for 15 minutes; the right code is refused while locked; success resets", async () => {
    const { user } = await users.findOrCreateByEmail("ops-lock@heymey.app");
    await roles.grant({ userId: user.id, role: "OPS", actor: ACTOR });
    const { secret } = await auth.enrollDeskTotp(await mint(user.id), ACTOR);
    const right = () => generate({ secret, epoch: step() });
    const bad = async () => ((await right()) === "000000" ? "111111" : "000000");
    for (let i = 1; i <= 4; i++) {
      await expect(auth.verifyDeskTotp(await mint(user.id), await bad(), ACTOR)).rejects.toMatchObject({ code: "TOTP_INVALID", details: { attemptsLeft: 5 - i } });
    }
    expect(await prisma.twoFactor.findUniqueOrThrow({ where: { userId: user.id } })).toMatchObject({ failedAttempts: 4, lockedUntil: null });
    await expect(auth.verifyDeskTotp(await mint(user.id), await bad(), ACTOR)).rejects.toMatchObject({ code: "TOTP_LOCKED" });
    const locked = await prisma.twoFactor.findUniqueOrThrow({ where: { userId: user.id } });
    expect(locked.failedAttempts).toBe(0);
    expect(locked.lockedUntil?.getTime()).toBe(clock.now().getTime() + 15 * 60_000);
    await expect(auth.verifyDeskTotp(await mint(user.id), await right(), ACTOR)).rejects.toMatchObject({ code: "TOTP_LOCKED" });
    clock.advanceMinutes(15);
    await expect(auth.verifyDeskTotp(await mint(user.id), await right(), ACTOR)).resolves.toMatchObject({ kind: "session" });
    const ok = await prisma.twoFactor.findUniqueOrThrow({ where: { userId: user.id } });
    expect(ok).toMatchObject({ failedAttempts: 0, lockedUntil: null });
    expect(ok.confirmedAt).not.toBeNull();
    const actions = (await prisma.auditLog.findMany({ where: { target: `user:${user.id}` }, select: { action: true } })).map((a) => a.action);
    expect(actions.filter((a) => a === "auth.desk_totp_failed")).toHaveLength(5);
    expect(actions).toEqual(expect.arrayContaining(["auth.desk_totp_enroll_started", "auth.desk_totp_locked", "auth.desk_signin"]));
  });

  it("SEC-M4: a pending secret younger than 10 minutes is not replaced in Postgres; an older one is; a confirmed one never", async () => {
    const { user } = await users.findOrCreateByEmail("ops-enroll@heymey.app");
    await roles.grant({ userId: user.id, role: "OPS", actor: ACTOR });
    await auth.enrollDeskTotp(await mint(user.id), ACTOR);
    const first = (await prisma.twoFactor.findUniqueOrThrow({ where: { userId: user.id } })).secretEnc;
    clock.advanceMinutes(9);
    await expect(auth.enrollDeskTotp(await mint(user.id), ACTOR)).rejects.toMatchObject({ code: "FORBIDDEN" });
    expect((await prisma.twoFactor.findUniqueOrThrow({ where: { userId: user.id } })).secretEnc).toBe(first);
    clock.advanceMinutes(1);
    const { secret } = await auth.enrollDeskTotp(await mint(user.id), ACTOR);
    expect((await prisma.twoFactor.findUniqueOrThrow({ where: { userId: user.id } })).secretEnc).not.toBe(first);
    await auth.verifyDeskTotp(await mint(user.id), await generate({ secret, epoch: step() }), ACTOR);
    clock.advanceMinutes(30);
    await expect(auth.enrollDeskTotp(await mint(user.id), ACTOR)).rejects.toMatchObject({ code: "FORBIDDEN" });
  });

  it("SEC-M3: OTP rows are purged before erasure, old rows are garbage-collected, and a cancel between due and erase skips it", async () => {
    const otps = createOtpMaintenance({ prisma });
    const gone = await signIn("purge-me@example.com");
    const stay = await signIn("cancel-me@example.com");
    const goneId = (await auth.verifyAccessToken(gone.tokens.accessToken))!.userId;
    const stayId = (await auth.verifyAccessToken(stay.tokens.accessToken))!.userId;
    await users.putProfile(stayId, { dateOfBirth: "1995-05-05", qualification: "hsc", community: "SC", pstm: true, specialCategories: [] });
    await users.requestDeletion(goneId, ACTOR);
    await users.requestDeletion(stayId, ACTOR);
    clock.advanceDays(8);
    await auth.requestOtp({ email: "purge-me@example.com", purpose: "login" }); // a fresh row too
    const purged: number[] = [];
    const emailsAtHook: string[] = [];
    const erased = await users.eraseDueAccounts({
      beforeErase: async (u) => {
        emailsAtHook.push((await prisma.user.findUniqueOrThrow({ where: { id: u.id } })).email);
        purged.push(await otps.purgeOtpCodesFor(u.email));
        if (u.id === stayId) await users.cancelDeletion(stayId); // signs in meanwhile
      },
    });
    expect(emailsAtHook).toEqual(expect.arrayContaining(["purge-me@example.com", "cancel-me@example.com"])); // not yet replaced
    expect(erased).toContain(goneId);
    expect(erased).not.toContain(stayId);
    expect(await prisma.otpCode.count({ where: { email: "purge-me@example.com" } })).toBe(0);
    expect(Math.max(...purged)).toBeGreaterThanOrEqual(2);
    const kept = await prisma.user.findUniqueOrThrow({ where: { id: stayId } });
    expect(kept).toMatchObject({ email: "cancel-me@example.com", deletedAt: null, deletionRequestedAt: null });
    expect(await prisma.userProfile.count({ where: { userId: stayId } })).toBe(1);

    // GC: rows older than 24 h go, newer rows stay.
    await auth.requestOtp({ email: "fresh@example.com", purpose: "login" });
    const cutoff = new Date(clock.now().getTime() - AUTH_POLICY.otpRetentionMs);
    const before = await prisma.otpCode.count();
    const removed = await otps.purgeExpiredOtpCodes(cutoff);
    expect(removed).toBeGreaterThan(0);
    expect(await prisma.otpCode.count()).toBe(before - removed);
    expect(await prisma.otpCode.count({ where: { email: "fresh@example.com" } })).toBe(1);
    expect(await prisma.otpCode.count({ where: { createdAt: { lt: cutoff } } })).toBe(0);
  });


  it("users: settings, profile, consents (latest per purpose) on Postgres", async () => {
    const s = await signIn("me@example.com");
    const ctx = (await auth.verifyAccessToken(s.tokens.accessToken))!;
    await users.updateMe(ctx.userId, { nickname: "Me Too", district: "Chennai", liteMode: true });
    const me = await users.putProfile(ctx.userId, {
      dateOfBirth: "2000-02-29",
      qualification: "pg",
      degreeSubject: "History",
      community: "MBC_DNC",
      pstm: false,
      specialCategories: ["PWD"],
    });
    expect(me).toMatchObject({
      nickname: "Me Too",
      district: "Chennai",
      liteMode: true,
      roles: ["ASPIRANT"],
      profile: { dateOfBirth: "2000-02-29", qualification: "pg", degreeSubject: "History", community: "MBC_DNC", pstm: false, specialCategories: ["PWD"] },
    });
    await users.recordConsents(ctx.userId, { noticeVersion: "2026-10-v2", choices: [{ purpose: "core_service", granted: true }, { purpose: "product_research", granted: true }] });
    clock.advanceMinutes(1);
    const state = await users.recordConsents(ctx.userId, { noticeVersion: "2026-10-v2", choices: [{ purpose: "core_service", granted: true }, { purpose: "product_research", granted: false }] });
    expect(state.choices).toHaveLength(2);
    expect(state.choices.find((c) => c.purpose === "product_research")!.granted).toBe(false);
    expect(await prisma.consent.count({ where: { userId: ctx.userId } })).toBe(4);
  });

  it("deletion: request -> erase after 7 days -> sessions revoked by the revoker", async () => {
    const s = await signIn("bye@example.com");
    const ctx = (await auth.verifyAccessToken(s.tokens.accessToken))!;
    await users.putProfile(ctx.userId, { dateOfBirth: "1995-05-05", qualification: "hsc", community: "SC", pstm: true, specialCategories: [] });
    await auth.requestOtp({ email: "bye@example.com", purpose: "delete_account", callerUserId: ctx.userId });
    const { deletionScheduledFor } = await auth.deleteAccount(ctx.userId, codeFor("bye@example.com"), ACTOR);
    expect(new Date(deletionScheduledFor).getTime() - clock.now().getTime()).toBe(7 * 86_400_000);
    expect(await auth.verifyAccessToken(s.tokens.accessToken)).toBeNull();

    // Sign in on day 3 cancels, request again, then let it run out.
    clock.advanceDays(3);
    const again = await signIn("bye@example.com", s.deviceId);
    expect(again.deletionCancelled).toBe(true);
    await auth.requestOtp({ email: "bye@example.com", purpose: "delete_account", callerUserId: ctx.userId });
    await auth.deleteAccount(ctx.userId, codeFor("bye@example.com"), ACTOR);
    clock.advanceDays(7);
    const erased = await users.eraseDueAccounts();
    expect(erased).toContain(ctx.userId);
    const row = await prisma.user.findUniqueOrThrow({ where: { id: ctx.userId } });
    expect(row).toMatchObject({ email: `deleted+${ctx.userId}@invalid.heymey.app`, nickname: null, district: null });
    expect(row.deletedAt).not.toBeNull();
    expect(await prisma.userProfile.count({ where: { userId: ctx.userId } })).toBe(0);
    const revoker = createSessionRevoker({ prisma, audit: createAuditModule({ prisma }), clock });
    expect(await revoker.revokeAllForUser(ctx.userId, "deleted", { userId: null, role: "SYSTEM" })).toBe(0);
    expect(await prisma.session.count({ where: { userId: ctx.userId, revokedAt: null } })).toBe(0);
    expect(await users.eraseDueAccounts()).not.toContain(ctx.userId);
  });

  it("roles: concurrent identical grants create one row", async () => {
    const uid = randomUUID();
    const results = await Promise.all([1, 2, 3].map(() => roles.grant({ userId: uid, role: "REVIEWER", actor: ACTOR })));
    expect(results.filter(Boolean)).toHaveLength(1);
    expect(await prisma.roleAssignment.count({ where: { userId: uid } })).toBe(1);
    expect(await roles.rolesOf(uid)).toEqual(["REVIEWER"]);
  });
});
