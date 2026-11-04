import type { OtpVerifyResponse, SessionGranted, TokenPair, z } from "@heymey/contracts";
import type { Clock } from "../../../shared/clock.js";
import { DomainError } from "../../../shared/errors.js";
import type { Actor, RateLimiter } from "../../../shared/ports.js";
import type { AuditApi } from "../../audit/index.js";
import type { UsersApi } from "../../users/index.js";
import {
  AUTH_POLICY,
  candidateSteps,
  hasDeskRole,
  isDisposableEmail,
  normalizeEmail,
  otpStatus,
  totpLocked,
  totpRetryAfterSeconds,
  type Purpose,
} from "../domain/policy.js";
import type {
  AccessContext,
  AuthCrypto,
  AuthRepositories,
  ChallengeClaims,
  OneTimeTokenStore,
  OtpHasher,
  OtpMailer,
  OtpRecord,
  RevokeReason,
  RoleDirectory,
  SecretBox,
  TokenService,
  TotpService,
} from "./ports.js";

export type TokenPairView = z.infer<typeof TokenPair>;
export type SessionGrantedView = z.infer<typeof SessionGranted>;
export type OtpVerifyView = z.infer<typeof OtpVerifyResponse>;

export interface AuthDeps {
  repos: AuthRepositories;
  users: UsersApi;
  roles: RoleDirectory;
  audit: AuditApi;
  clock: Clock;
  rateLimiter: RateLimiter;
  mailer: OtpMailer;
  hasher: OtpHasher;
  tokens: TokenService;
  secretBox: SecretBox;
  totp: TotpService;
  crypto: AuthCrypto;
  /** Single-use Desk challenges (SEC-H2). */
  oneTimeTokens: OneTimeTokenStore;
}

const SYSTEM: Actor = { userId: null, role: "SYSTEM" };
const VISITOR: Actor = { userId: null, role: "VISITOR" };

// ---------------------------------------------------------------- OTP request (§38 step 1)

export interface RequestOtpInput {
  email: string;
  purpose: Purpose;
  /** The signed-in caller, if any (required for `delete_account`). */
  callerUserId?: string | null;
  ip?: string | null;
}

export async function requestOtp(d: AuthDeps, input: RequestOtpInput): Promise<{ resendAfterSeconds: number }> {
  const email = normalizeEmail(input.email);
  if (isDisposableEmail(email)) throw new DomainError("EMAIL_NOT_ALLOWED");

  if (input.purpose === "delete_account") {
    const caller = input.callerUserId ? await d.users.getById(input.callerUserId) : null;
    if (!caller || caller.deletedAt || caller.email !== email) throw new DomainError("FORBIDDEN");
  }

  const rl = await d.rateLimiter.hit(
    `otp:email:${d.crypto.sha256(email)}`,
    AUTH_POLICY.otpPerEmailLimit,
    AUTH_POLICY.otpPerEmailWindowSeconds,
  );
  if (!rl.allowed) throw new DomainError("RATE_LIMITED", { retryAfterSeconds: rl.retryAfterSeconds });

  const now = d.clock.now();
  const code = d.crypto.otpCode();
  const { id } = await d.repos.otps.create({
    email,
    purpose: input.purpose,
    codeHash: await d.hasher.hash(code),
    expiresAt: new Date(now.getTime() + AUTH_POLICY.otpTtlMs),
    requestIp: input.ip ?? null,
    at: now,
  });
  await d.mailer.send({ otpId: id, to: email, code, purpose: input.purpose });
  // Same answer whether or not the email has an account (§38).
  return { resendAfterSeconds: AUTH_POLICY.resendAfterSeconds };
}

/** Throws OTP_EXPIRED or OTP_LOCKED for a code that cannot be tried any more (locks it if it is maxed out). */
async function refuseUntryable(d: AuthDeps, otp: OtpRecord | null, now: Date): Promise<never> {
  const status = otpStatus(otp, now);
  if (status === "expired" || !otp) throw new DomainError("OTP_EXPIRED");
  if (!otp.lockedAt) await d.repos.otps.lock(otp.id, now);
  throw new DomainError("OTP_LOCKED");
}

/**
 * Checks `code` against the latest code. Throws OTP_EXPIRED / OTP_LOCKED / OTP_INVALID; does NOT mark it used.
 * §38 "max 5 tries per code" holds under concurrency (SEC-M1): every try first RESERVES an attempt with one atomic
 * conditional update, and only a caller holding a reservation runs the (slow) argon2 compare.
 */
async function checkCode(d: AuthDeps, email: string, purpose: Purpose, code: string): Promise<OtpRecord> {
  const otp = await d.repos.otps.latest(email, purpose);
  const now = d.clock.now();
  if (!otp || otpStatus(otp, now) !== "ok") return refuseUntryable(d, otp, now);

  const attempt = await d.repos.otps.reserveAttempt(otp.id, now, AUTH_POLICY.otpMaxAttempts);
  if (attempt === null) {
    // Someone else used, locked or exhausted it between our read and the reservation.
    // A newer code replaced it -> OTP_EXPIRED; otherwise OTP_EXPIRED (used) or OTP_LOCKED (no tries left).
    const fresh = await d.repos.otps.latest(email, purpose);
    return refuseUntryable(d, fresh?.id === otp.id ? fresh : null, now);
  }
  if (!(await d.hasher.verify(otp.codeHash, code))) {
    if (attempt >= AUTH_POLICY.otpMaxAttempts) {
      await d.repos.otps.lock(otp.id, now);
      throw new DomainError("OTP_LOCKED");
    }
    throw new DomainError("OTP_INVALID", { attemptsLeft: AUTH_POLICY.otpMaxAttempts - attempt });
  }
  return otp;
}

async function consume(d: AuthDeps, otp: OtpRecord): Promise<void> {
  if (!(await d.repos.otps.markUsed(otp.id, d.clock.now()))) throw new DomainError("OTP_EXPIRED");
}

// ---------------------------------------------------------------- OTP verify (§38 step 3, §15 Desk)

export interface VerifyOtpInput {
  email: string;
  code: string;
  deviceId: string;
  platform: "android" | "ios" | "web";
  client: "app" | "desk";
}

export async function verifyOtp(d: AuthDeps, input: VerifyOtpInput): Promise<OtpVerifyView> {
  const email = normalizeEmail(input.email);
  const otp = await checkCode(d, email, "login", input.code);

  const existing = await d.users.findByEmail(email);
  const device = await d.repos.devices.find(input.deviceId);
  if (device && device.userId !== existing?.id) {
    // One device, one account (§18). The code stays unused so the user can retry from their own device.
    throw new DomainError("VALIDATION_FAILED", { field: "deviceId", reason: "device belongs to another account" });
  }
  await consume(d, otp);
  const now = d.clock.now();

  if (input.client === "desk") {
    if (!existing || existing.deletedAt) throw new DomainError("DESK_NOT_ALLOWED");
    if (!hasDeskRole(await d.roles.rolesOf(existing.id))) throw new DomainError("DESK_NOT_ALLOWED");
    await d.repos.devices.upsert({ id: input.deviceId, userId: existing.id, platform: input.platform, at: now });
    const tf = await d.repos.twoFactors.find(existing.id);
    const challengeToken = await d.tokens.signChallenge({ userId: existing.id, deviceId: input.deviceId }, now);
    return { kind: "desk_2fa", challengeToken, totpEnrolled: Boolean(tf?.confirmedAt) };
  }

  const { user, created } = existing ? { user: existing, created: false } : await d.users.findOrCreateByEmail(email);
  if (created) await d.roles.grant({ userId: user.id, role: "ASPIRANT", actor: SYSTEM });
  const deletionCancelled = created ? false : await d.users.cancelDeletion(user.id);
  await d.repos.devices.upsert({ id: input.deviceId, userId: user.id, platform: input.platform, at: now });
  const tokens = await issueSession(d, user.id, input.deviceId, false);
  return { kind: "session", tokens, isNewUser: created, deletionCancelled };
}

// ---------------------------------------------------------------- sessions (§37, D-2026-10-20-11)

async function issueSession(d: AuthDeps, userId: string, deviceId: string, isDesk: boolean): Promise<TokenPairView> {
  const now = d.clock.now();
  const ttl = isDesk ? AUTH_POLICY.deskSessionTtlMs : AUTH_POLICY.appSessionTtlMs;
  const session = await d.repos.sessions.create({ userId, deviceId, isDesk, expiresAt: new Date(now.getTime() + ttl), at: now });
  return issueTokens(d, session.id, userId, isDesk, session.expiresAt, now);
}

async function issueTokens(
  d: AuthDeps,
  sessionId: string,
  userId: string,
  isDesk: boolean,
  sessionExpiresAt: Date,
  now: Date,
): Promise<TokenPairView> {
  const refreshToken = d.crypto.opaqueToken();
  await d.repos.refreshTokens.create({ sessionId, tokenHash: d.crypto.sha256(refreshToken), expiresAt: sessionExpiresAt, at: now });
  const roles = await d.roles.rolesOf(userId);
  const access = await d.tokens.signAccess({ userId, sessionId, roles, isDesk }, now);
  return { accessToken: access.token, refreshToken, accessTokenExpiresAt: access.expiresAt.toISOString() };
}

async function revokeAndAudit(d: AuthDeps, sessionId: string, userId: string, reason: RevokeReason, actor: Actor): Promise<void> {
  if (await d.repos.sessions.revoke(sessionId, reason, d.clock.now())) {
    await d.audit.record({ actor, action: "auth.session_revoked", target: `session:${sessionId}`, after: { reason, userId } });
  }
}

/** Rotate on every use; a used token presented again revokes the whole family (§37). */
export async function refresh(d: AuthDeps, refreshToken: string, actor: Actor): Promise<TokenPairView> {
  const rec = await d.repos.refreshTokens.findByHash(d.crypto.sha256(refreshToken));
  if (!rec) throw new DomainError("SESSION_REVOKED");
  const session = await d.repos.sessions.findById(rec.sessionId);
  if (!session) throw new DomainError("SESSION_REVOKED");
  const now = d.clock.now();

  if (rec.usedAt) {
    await revokeAndAudit(d, session.id, session.userId, "token_reuse", actor);
    throw new DomainError("SESSION_REVOKED");
  }
  if (session.revokedAt || session.expiresAt <= now || rec.expiresAt <= now) throw new DomainError("SESSION_REVOKED");
  if (!(await d.repos.refreshTokens.markUsed(rec.id, now))) {
    await revokeAndAudit(d, session.id, session.userId, "token_reuse", actor);
    throw new DomainError("SESSION_REVOKED");
  }
  await d.repos.sessions.touch(session.id, now);
  return issueTokens(d, session.id, session.userId, session.isDesk, session.expiresAt, now);
}

export async function logout(d: AuthDeps, auth: AccessContext): Promise<{ ok: true }> {
  await d.repos.sessions.revoke(auth.sessionId, "logout", d.clock.now());
  return { ok: true };
}

export async function logoutAll(d: AuthDeps, userId: string, actor: Actor): Promise<{ ok: true }> {
  await revokeAllForUser(d, userId, "logout_all", actor);
  return { ok: true };
}

export async function revokeAllForUser(
  d: Pick<AuthDeps, "repos" | "audit" | "clock">,
  userId: string,
  reason: RevokeReason,
  actor: Actor,
): Promise<number> {
  const count = await d.repos.sessions.revokeAllForUser(userId, reason, d.clock.now());
  if (count > 0) await d.audit.record({ actor, action: "auth.session_revoked", target: `user:${userId}`, after: { reason, count } });
  return count;
}

/** For PlatformGuard: signature, issuer, audience, expiry AND a live session. Never throws. */
export async function verifyAccessToken(d: AuthDeps, token: string): Promise<AccessContext | null> {
  try {
    const now = d.clock.now();
    const ctx = await d.tokens.verifyAccess(token, now);
    if (!ctx) return null;
    const session = await d.repos.sessions.findById(ctx.sessionId);
    if (!session || session.revokedAt || session.expiresAt <= now || session.userId !== ctx.userId) return null;
    if (session.isDesk !== ctx.isDesk) return null;
    return { ...ctx, deviceId: session.deviceId }; // SEC-P2-L1: the device this session is bound to
  } catch {
    return null;
  }
}

// ---------------------------------------------------------------- Desk TOTP (§15, §38 step 5)

async function deskUser(d: AuthDeps, challengeToken: string) {
  const ch = await d.tokens.verifyChallenge(challengeToken, d.clock.now());
  if (!ch) throw new DomainError("CHALLENGE_EXPIRED");
  const user = await d.users.getById(ch.userId);
  if (!user || user.deletedAt) throw new DomainError("CHALLENGE_EXPIRED");
  if (!hasDeskRole(await d.roles.rolesOf(user.id))) throw new DomainError("DESK_NOT_ALLOWED");
  return { user, ch };
}

function refuseIfLocked(lockedUntil: Date | null, now: Date): void {
  if (lockedUntil && totpLocked(lockedUntil, now)) {
    throw new DomainError("TOTP_LOCKED", { retryAfterSeconds: totpRetryAfterSeconds(lockedUntil, now) });
  }
}

/** A challenge allows ONE code check (SEC-H2). The mark lives as long as the challenge could still verify. */
async function consumeChallenge(d: AuthDeps, ch: ChallengeClaims, now: Date): Promise<void> {
  const ttlSeconds = Math.max(1, Math.ceil((ch.expiresAt.getTime() - now.getTime()) / 1000));
  if (!(await d.oneTimeTokens.consume(ch.jti, ttlSeconds))) throw new DomainError("CHALLENGE_EXPIRED");
}

/**
 * First Desk sign-in: issue a pending authenticator secret (§15, §38 step 5). Does NOT consume the challenge (the
 * user verifies the first code with it). Interim rules until the enrollment ceremony is decided (SEC-M4,
 * D-2026-10-20-20): a confirmed authenticator is never replaced, a pending one younger than 10 minutes is not
 * replaced (so nobody can race the real user), and every call is audited.
 */
export async function enrollDeskTotp(
  d: AuthDeps,
  challengeToken: string,
  actor: Actor = VISITOR,
): Promise<{ otpauthUri: string; secret: string }> {
  const { user } = await deskUser(d, challengeToken);
  const now = d.clock.now();
  const who: Actor = { ...actor, userId: user.id };
  const target = `user:${user.id}`;
  const existing = await d.repos.twoFactors.find(user.id);
  refuseIfLocked(existing?.lockedUntil ?? null, now);
  if (existing?.confirmedAt) {
    await d.audit.record({ actor: who, action: "auth.desk_totp_enroll_refused", target, after: { reason: "already_set_up" } });
    throw new DomainError("FORBIDDEN", { reason: "authenticator already set up" });
  }
  const secret = d.totp.generateSecret();
  const replaceIfCreatedBefore = new Date(now.getTime() - AUTH_POLICY.totpPendingProtectMs);
  if (!(await d.repos.twoFactors.savePending(user.id, d.secretBox.seal(secret, user.id), now, replaceIfCreatedBefore))) {
    await d.audit.record({ actor: who, action: "auth.desk_totp_enroll_refused", target, after: { reason: "pending_recent" } });
    throw new DomainError("FORBIDDEN", { reason: "authenticator set-up already started; try again in 10 minutes" });
  }
  await d.audit.record({ actor: who, action: "auth.desk_totp_enroll_started", target });
  return { otpauthUri: d.totp.uri(user.email, secret), secret };
}

/**
 * Desk second factor (§15, §38 step 5). Brute-force limits (SEC-H2): the challenge is single-use (burnt before the
 * code is compared, so parallel guesses on one challenge are never evaluated), 5 consecutive wrong codes lock the
 * user's TOTP for 15 minutes (TOTP_LOCKED even for the right code), success resets the counter. Failures, locks and
 * sign-ins are audited (never the code).
 */
export async function verifyDeskTotp(d: AuthDeps, challengeToken: string, code: string, actor: Actor): Promise<SessionGrantedView> {
  const { user, ch } = await deskUser(d, challengeToken);
  const who: Actor = { ...actor, userId: user.id };
  const target = `user:${user.id}`;
  const tf = await d.repos.twoFactors.find(user.id);
  if (!tf) throw new DomainError("TOTP_INVALID"); // nothing enrolled: nothing to guess; the user enrolls first
  const now = d.clock.now();
  refuseIfLocked(tf.lockedUntil, now);
  await consumeChallenge(d, ch, now);

  let opened: { plain: string; legacy: boolean };
  try {
    opened = d.secretBox.open(tf.secretEnc, user.id);
  } catch {
    // Tampered, swapped between users (AAD mismatch) or sealed with another key: never usable.
    await d.audit.record({ actor: who, action: "auth.desk_totp_secret_unreadable", target });
    throw new DomainError("TOTP_INVALID");
  }

  let matched: number | null = null;
  for (const step of candidateSteps(now)) {
    const expected = await d.totp.codeAt(opened.plain, step * AUTH_POLICY.totpStepSeconds);
    if (d.crypto.equals(expected, code)) matched = step;
  }
  const firstConfirm = !tf.confirmedAt;
  // Each 30-s step may be used once (replay protection); acceptStep re-checks step and lock atomically.
  const fresh = matched !== null && (tf.lastUsedStep === null || matched > tf.lastUsedStep);
  if (!fresh || !(await d.repos.twoFactors.acceptStep(user.id, matched as number, now, firstConfirm))) {
    const lockUntil = new Date(now.getTime() + AUTH_POLICY.totpLockMs);
    const r = await d.repos.twoFactors.recordFailure(user.id, AUTH_POLICY.totpMaxFailures, lockUntil);
    await d.audit.record({ actor: who, action: "auth.desk_totp_failed", target, after: { failedAttempts: r.failedAttempts } });
    if (r.locked) {
      await d.audit.record({ actor: who, action: "auth.desk_totp_locked", target, after: { lockedUntil: lockUntil.toISOString() } });
      throw new DomainError("TOTP_LOCKED", { retryAfterSeconds: totpRetryAfterSeconds(lockUntil, now) });
    }
    throw new DomainError("TOTP_INVALID", { attemptsLeft: AUTH_POLICY.totpMaxFailures - r.failedAttempts });
  }
  // SEC-L6: a secret sealed before AAD binding is re-sealed with the userId on its first successful use.
  if (opened.legacy) await d.repos.twoFactors.reseal(user.id, tf.secretEnc, d.secretBox.seal(opened.plain, user.id));
  if (firstConfirm) await d.audit.record({ actor: who, action: "auth.desk_totp_enrolled", target });
  const tokens = await issueSession(d, user.id, ch.deviceId, true);
  await d.audit.record({ actor: who, action: "auth.desk_signin", target, after: { deviceId: ch.deviceId } });
  return { kind: "session", tokens, isNewUser: false, deletionCancelled: false };
}

// ---------------------------------------------------------------- OTP data retention (SEC-M3, §38.7, §23)

/** Erasure: delete every OTP row (email + request IP) for this address. Called before the email is replaced. */
export function purgeOtpCodesFor(d: { repos: Pick<AuthRepositories, "otps"> }, email: string): Promise<number> {
  return d.repos.otps.purgeByEmail(normalizeEmail(email));
}

/** Scheduled GC (`auth.otp-gc`): delete OTP rows created before `olderThan`. */
export function purgeExpiredOtpCodes(d: { repos: Pick<AuthRepositories, "otps"> }, olderThan: Date): Promise<number> {
  return d.repos.otps.purgeCreatedBefore(olderThan);
}

// ---------------------------------------------------------------- delete account (§38 step 7)

export async function deleteAccount(d: AuthDeps, userId: string, code: string, actor: Actor): Promise<{ deletionScheduledFor: string }> {
  const user = await d.users.getById(userId);
  if (!user || user.deletedAt) throw new DomainError("UNAUTHENTICATED");
  const otp = await checkCode(d, user.email, "delete_account", code);
  await consume(d, otp);
  const scheduledFor = await d.users.requestDeletion(userId, actor);
  // Signed out everywhere; signing in again within 7 days cancels the deletion.
  await revokeAllForUser(d, userId, "deleted", actor);
  return { deletionScheduledFor: scheduledFor.toISOString() };
}
