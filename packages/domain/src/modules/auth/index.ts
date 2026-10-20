/**
 * Public API of the `auth` module. Email OTP login, sessions, refresh-token rotation, device binding, Desk TOTP,
 * account deletion confirmation (blueprint §15, §18, §37, §38).
 * Export use cases and types only. Never export repositories or Prisma models.
 */
import type { PrismaClient } from "@heymey/db";
import type { Clock } from "../../shared/clock.js";
import type { Actor, RateLimiter } from "../../shared/ports.js";
import type { AuditApi } from "../audit/index.js";
import type { UsersApi } from "../users/index.js";
import * as svc from "./application/auth-service.js";
import type {
  AccessContext,
  AuthCrypto,
  AuthRepositories,
  OneTimeTokenStore,
  OtpHasher,
  OtpMailer,
  RevokeReason,
  RoleDirectory,
  SecretBox,
  TokenService,
  TotpService,
} from "./application/ports.js";
import { AesGcmSecretBox, Argon2OtpHasher, JoseTokenService, nodeAuthCrypto, otplibTotp } from "./infrastructure/crypto.js";
import { jobQueueOtpMailer, type JobQueueLike } from "./infrastructure/job-queue-mailer.js";
import { createPrismaAuthRepositories } from "./infrastructure/prisma-auth-repositories.js";

export const AuthModule = { name: "auth" } as const;

export type {
  AccessContext,
  AuthRepositories,
  ChallengeClaims,
  OneTimeTokenStore,
  OtpMailer,
  RoleDirectory,
  RevokeReason,
  OtpRecord,
  SessionRecord,
  DeviceRecord,
  RefreshTokenRecord,
  TwoFactorRecord,
} from "./application/ports.js";
export type { RequestOtpInput, VerifyOtpInput, TokenPairView, SessionGrantedView, OtpVerifyView } from "./application/auth-service.js";
export { AUTH_POLICY, composeOtpEmail, isDisposableEmail, normalizeEmail } from "./domain/policy.js";
export { jobQueueOtpMailer, OTP_EMAIL_QUEUE, type JobQueueLike } from "./infrastructure/job-queue-mailer.js";

export interface AuthConfig {
  jwtPrivateKeyPem: string;
  jwtPublicKeyPem: string;
  jwtIssuer: string;
  otpPepper: string;
  /** base64, 32 bytes */
  totpEncKey: string;
}

export interface AuthModuleDeps {
  prisma?: PrismaClient;
  /** Unit tests pass in-memory repositories instead of Prisma. */
  repositories?: AuthRepositories;
  users: UsersApi;
  roles: RoleDirectory;
  audit: AuditApi;
  clock: Clock;
  rateLimiter: RateLimiter;
  /** Where OTP emails go: a JobQueue (`email.otp`) or a custom mailer. */
  jobQueue?: JobQueueLike;
  mailer?: OtpMailer;
  /** Single-use Desk challenges (SEC-H2): Valkey in the API, in-memory in unit tests. Must be shared by all replicas. */
  oneTimeTokens: OneTimeTokenStore;
  config: AuthConfig;
  /** Overrides for tests. */
  hasher?: OtpHasher;
  tokens?: TokenService;
  secretBox?: SecretBox;
  totp?: TotpService;
  crypto?: AuthCrypto;
}

export interface AuthApi {
  requestOtp(input: svc.RequestOtpInput): Promise<{ resendAfterSeconds: number }>;
  verifyOtp(input: svc.VerifyOtpInput): Promise<svc.OtpVerifyView>;
  refresh(refreshToken: string, actor: Actor): Promise<svc.TokenPairView>;
  logout(auth: AccessContext): Promise<{ ok: true }>;
  logoutAll(userId: string, actor: Actor): Promise<{ ok: true }>;
  /** `actor` is recorded in the audit log (ip, requestId); the user comes from the challenge. */
  enrollDeskTotp(challengeToken: string, actor?: Actor): Promise<{ otpauthUri: string; secret: string }>;
  verifyDeskTotp(challengeToken: string, code: string, actor: Actor): Promise<svc.SessionGrantedView>;
  deleteAccount(userId: string, code: string, actor: Actor): Promise<{ deletionScheduledFor: string }>;
  /** Returns null for any invalid, expired or revoked token. Never throws. */
  verifyAccessToken(token: string): Promise<AccessContext | null>;
  revokeAllForUser(userId: string, reason: RevokeReason, actor: Actor): Promise<number>;
  /** Erasure (SEC-M3, §38.7): delete every OTP row for this email. Returns how many. */
  purgeOtpCodesFor(email: string): Promise<number>;
  /** Scheduled GC (SEC-M3): delete OTP rows created before `olderThan`. Returns how many. */
  purgeExpiredOtpCodes(olderThan: Date): Promise<number>;
}

export function createAuthModule(deps: AuthModuleDeps): AuthApi {
  const repos = deps.repositories ?? (deps.prisma ? createPrismaAuthRepositories(deps.prisma) : undefined);
  if (!repos) throw new Error("createAuthModule: pass prisma or repositories");
  const mailer = deps.mailer ?? (deps.jobQueue ? jobQueueOtpMailer(deps.jobQueue) : undefined);
  if (!mailer) throw new Error("createAuthModule: pass jobQueue or mailer");

  const d: svc.AuthDeps = {
    repos,
    users: deps.users,
    roles: deps.roles,
    audit: deps.audit,
    clock: deps.clock,
    rateLimiter: deps.rateLimiter,
    mailer,
    hasher: deps.hasher ?? new Argon2OtpHasher(deps.config.otpPepper),
    tokens:
      deps.tokens ??
      new JoseTokenService({
        privateKeyPem: deps.config.jwtPrivateKeyPem,
        publicKeyPem: deps.config.jwtPublicKeyPem,
        issuer: deps.config.jwtIssuer,
      }),
    secretBox: deps.secretBox ?? new AesGcmSecretBox(deps.config.totpEncKey),
    totp: deps.totp ?? otplibTotp,
    crypto: deps.crypto ?? nodeAuthCrypto,
    oneTimeTokens: deps.oneTimeTokens,
  };

  return {
    requestOtp: (input) => svc.requestOtp(d, input),
    verifyOtp: (input) => svc.verifyOtp(d, input),
    refresh: (token, actor) => svc.refresh(d, token, actor),
    logout: (auth) => svc.logout(d, auth),
    logoutAll: (userId, actor) => svc.logoutAll(d, userId, actor),
    enrollDeskTotp: (token, actor) => svc.enrollDeskTotp(d, token, actor),
    verifyDeskTotp: (token, code, actor) => svc.verifyDeskTotp(d, token, code, actor),
    deleteAccount: (userId, code, actor) => svc.deleteAccount(d, userId, code, actor),
    verifyAccessToken: (token) => svc.verifyAccessToken(d, token),
    revokeAllForUser: (userId, reason, actor) => svc.revokeAllForUser(d, userId, reason, actor),
    purgeOtpCodesFor: (email) => svc.purgeOtpCodesFor(d, email),
    purgeExpiredOtpCodes: (olderThan) => svc.purgeExpiredOtpCodes(d, olderThan),
  };
}

/**
 * Just the session revoker, for processes that must not hold signing keys (the worker's `users.deletion` job).
 */
export function createSessionRevoker(deps: { prisma: PrismaClient; audit: AuditApi; clock: Clock }): {
  revokeAllForUser(userId: string, reason: RevokeReason, actor: Actor): Promise<number>;
} {
  const repos = createPrismaAuthRepositories(deps.prisma);
  return { revokeAllForUser: (userId, reason, actor) => svc.revokeAllForUser({ repos, audit: deps.audit, clock: deps.clock }, userId, reason, actor) };
}

/** OTP data retention for the worker (no signing keys needed): erasure purge + the hourly `auth.otp-gc` (SEC-M3). */
export interface OtpMaintenance {
  purgeOtpCodesFor(email: string): Promise<number>;
  purgeExpiredOtpCodes(olderThan: Date): Promise<number>;
}

export function createOtpMaintenance(deps: { prisma: PrismaClient } | { repositories: Pick<AuthRepositories, "otps"> }): OtpMaintenance {
  const repos = "repositories" in deps ? deps.repositories : createPrismaAuthRepositories(deps.prisma);
  return {
    purgeOtpCodesFor: (email) => svc.purgeOtpCodesFor({ repos }, email),
    purgeExpiredOtpCodes: (olderThan) => svc.purgeExpiredOtpCodes({ repos }, olderThan),
  };
}
