import type { Role } from "@heymey/contracts";
import type { Actor } from "../../../shared/ports.js";
import type { Purpose } from "../domain/policy.js";

/** Who is calling, from a valid access token. Same shape as the API's AuthContext. */
export interface AccessContext {
  userId: string;
  sessionId: string;
  roles: Role[];
  isDesk: boolean;
}

export interface OtpRecord {
  id: string;
  email: string;
  purpose: Purpose;
  codeHash: string;
  attempts: number;
  expiresAt: Date;
  usedAt: Date | null;
  lockedAt: Date | null;
  createdAt: Date;
}

export interface OtpRepository {
  create(input: { email: string; purpose: Purpose; codeHash: string; expiresAt: Date; requestIp: string | null; at: Date }): Promise<{ id: string }>;
  /** The newest code for email + purpose, used or not. */
  latest(email: string, purpose: Purpose): Promise<OtpRecord | null>;
  /**
   * Atomically reserves one attempt BEFORE the code is compared (SEC-M1): adds 1 to `attempts` only if the code is
   * unused, unlocked, not expired at `now` and has fewer than `max` attempts. Returns the attempt number this caller
   * reserved, or null when no attempt is left (the caller then reports OTP_EXPIRED / OTP_LOCKED).
   */
  reserveAttempt(id: string, now: Date, max: number): Promise<number | null>;
  lock(id: string, at: Date): Promise<void>;
  /** Marks the code used if it is still unused. False if someone else used it first. */
  markUsed(id: string, at: Date): Promise<boolean>;
  /** Deletes every code sent to this (normalised) email. Returns how many (SEC-M3, §38.7 erasure). */
  purgeByEmail(email: string): Promise<number>;
  /** Deletes codes created before `before` (scheduled GC, SEC-M3). Returns how many. */
  purgeCreatedBefore(before: Date): Promise<number>;
}

export interface DeviceRecord {
  id: string;
  userId: string;
  platform: string;
}

export interface DeviceRepository {
  find(id: string): Promise<DeviceRecord | null>;
  upsert(input: { id: string; userId: string; platform: string; at: Date }): Promise<void>;
}

export interface SessionRecord {
  id: string;
  userId: string;
  deviceId: string;
  isDesk: boolean;
  expiresAt: Date;
  revokedAt: Date | null;
  revokedReason: string | null;
}

export type RevokeReason = "logout" | "logout_all" | "token_reuse" | "deleted" | "expired";

export interface SessionRepository {
  create(input: { userId: string; deviceId: string; isDesk: boolean; expiresAt: Date; at: Date }): Promise<SessionRecord>;
  findById(id: string): Promise<SessionRecord | null>;
  touch(id: string, at: Date): Promise<void>;
  /** Revokes if active. True if this call revoked it. */
  revoke(id: string, reason: RevokeReason, at: Date): Promise<boolean>;
  /** Revokes every active session of the user. Returns how many. */
  revokeAllForUser(userId: string, reason: RevokeReason, at: Date): Promise<number>;
}

export interface RefreshTokenRecord {
  id: string;
  sessionId: string;
  expiresAt: Date;
  usedAt: Date | null;
}

export interface RefreshTokenRepository {
  create(input: { sessionId: string; tokenHash: string; expiresAt: Date; at: Date }): Promise<void>;
  findByHash(tokenHash: string): Promise<RefreshTokenRecord | null>;
  /** Marks used if unused. False if it was already used (reuse / race). */
  markUsed(id: string, at: Date): Promise<boolean>;
}

export interface TwoFactorRecord {
  userId: string;
  secretEnc: string;
  confirmedAt: Date | null;
  lastUsedStep: number | null;
  /** Wrong codes since the last success or lock (SEC-H2). */
  failedAttempts: number;
  /** While in the future, every verify is TOTP_LOCKED, even with the right code (SEC-H2). */
  lockedUntil: Date | null;
  /** When the current (pending or confirmed) secret was stored. */
  createdAt: Date;
}

export interface TwoFactorRepository {
  find(userId: string): Promise<TwoFactorRecord | null>;
  /**
   * Stores a new, unconfirmed secret: creates the row, or replaces an UNCONFIRMED secret stored at or before
   * `replaceIfCreatedBefore` (SEC-M4: a fresh pending secret cannot be overwritten). False if nothing was stored.
   */
  savePending(userId: string, secretEnc: string, at: Date, replaceIfCreatedBefore: Date): Promise<boolean>;
  /**
   * Records `step` as used if it is newer than the last used step and the user is not locked at `at`; resets the
   * failure counter; confirms the enrolment if `confirm`.
   */
  acceptStep(userId: string, step: number, at: Date, confirm: boolean): Promise<boolean>;
  /**
   * Atomically counts one wrong code (SEC-H2). When the count reaches `max` the user is locked until `lockUntil` and
   * the counter restarts at 0. Returns the count including this failure and whether this call set the lock.
   */
  recordFailure(userId: string, max: number, lockUntil: Date): Promise<{ failedAttempts: number; locked: boolean }>;
  /** Replaces the sealed secret if it is still `expectedEnc` (re-seal of a legacy secret with AAD, SEC-L6). */
  reseal(userId: string, expectedEnc: string, secretEnc: string): Promise<void>;
}

export interface AuthRepositories {
  otps: OtpRepository;
  devices: DeviceRepository;
  sessions: SessionRepository;
  refreshTokens: RefreshTokenRepository;
  twoFactors: TwoFactorRepository;
}

/** argon2id + pepper in production. */
export interface OtpHasher {
  hash(code: string): Promise<string>;
  verify(hash: string, code: string): Promise<boolean>;
}

/** EdDSA JWTs (jose) in production. */
export interface TokenService {
  signAccess(ctx: AccessContext, now: Date): Promise<{ token: string; expiresAt: Date }>;
  verifyAccess(token: string, now: Date): Promise<AccessContext | null>;
  /** Desk 2-step challenge. Carries a random `jti` so it can be consumed once (SEC-H2). */
  signChallenge(input: { userId: string; deviceId: string }, now: Date): Promise<string>;
  verifyChallenge(token: string, now: Date): Promise<ChallengeClaims | null>;
}

export interface ChallengeClaims {
  userId: string;
  deviceId: string;
  jti: string;
  expiresAt: Date;
}

/**
 * Single-use marks for tokens (SEC-H2). Valkey `SET key 1 EX ttl NX` in production. `consume` resolves true only
 * for the first caller for a `jti`; the mark lives `ttlSeconds` (at least the token's remaining lifetime).
 */
export interface OneTimeTokenStore {
  consume(jti: string, ttlSeconds: number): Promise<boolean>;
}

/**
 * AES-256-GCM in production. `aad` (additional authenticated data; the userId for TOTP secrets) binds the ciphertext
 * to its owner, so a database writer cannot move a secret to another user (SEC-L6).
 */
export interface SecretBox {
  seal(plain: string, aad: string): string;
  /** `legacy` = sealed in the old format without AAD; the caller should re-seal it. Throws if it cannot be opened. */
  open(sealed: string, aad: string): { plain: string; legacy: boolean };
}

export interface TotpService {
  generateSecret(): string;
  uri(label: string, secret: string): string;
  /** The 6-digit code for the 30-s step starting at `epochSeconds`. */
  codeAt(secret: string, epochSeconds: number): Promise<string>;
}

/** CSPRNG + digests (node:crypto in production). */
export interface AuthCrypto {
  /** 6 digits from a CSPRNG. */
  otpCode(): string;
  /** Opaque 32-byte refresh token. */
  opaqueToken(): string;
  sha256(value: string): string;
  /** Constant-time string comparison. */
  equals(a: string, b: string): boolean;
}

/** Queues the OTP email (BullMQ `email.otp` in production). */
export interface OtpMailer {
  send(input: { otpId: string; to: string; code: string; purpose: Purpose }): Promise<void>;
}

/**
 * Structural port onto the `roles` module, filled by the composition root (auth does not import roles:
 * module.json allows users + audit only).
 */
export interface RoleDirectory {
  rolesOf(userId: string): Promise<Role[]>;
  grant(input: { userId: string; role: Role; actor: Actor }): Promise<unknown>;
}
