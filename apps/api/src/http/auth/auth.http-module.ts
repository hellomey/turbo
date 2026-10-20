import { Global, Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import type { AuditApi } from "@heymey/domain/modules/audit";
import type { Redis } from "ioredis";
import { createAuthModule, type AuthApi, type OneTimeTokenStore } from "@heymey/domain/modules/auth";
import type { RolesApi } from "@heymey/domain/modules/roles";
import type { UsersApi } from "@heymey/domain/modules/users";
import type { Clock, RateLimiter } from "@heymey/domain/shared";
import type { ApiEnv } from "../../platform/env.js";
import type { JobQueue } from "../../platform/infra.module.js";
import type { AccessTokenVerifier } from "../../platform/request-context.js";
import {
  ACCESS_TOKEN_VERIFIER,
  AUDIT_API,
  AUTH_API,
  CLOCK,
  ENV,
  JOB_QUEUE,
  PRISMA,
  RATE_LIMITER,
  ROLES_API,
  USERS_API,
  VALKEY,
} from "../../platform/tokens.js";
import { AuthController } from "./auth.controller.js";

/**
 * Single-use Desk challenges (SEC-H2) shared by every API replica: `SET auth:jti:<jti> 1 EX <ttl> NX` succeeds only
 * for the first caller. Fails closed: a Valkey error rejects the request (no second factor without the mark).
 */
export function valkeyOneTimeTokens(valkey: Pick<Redis, "set">): OneTimeTokenStore {
  return {
    async consume(jti, ttlSeconds) {
      const res = await valkey.set(`auth:jti:${jti}`, "1", "EX", Math.max(1, Math.ceil(ttlSeconds)), "NX");
      return res === "OK";
    },
  };
}

/**
 * HTTP adapter for the `auth` module. Owner: backend (identity track).
 * Scope: OTP, sessions, refresh, logout, Desk TOTP, delete-account. Provides AUTH_API and ACCESS_TOKEN_VERIFIER
 * (used by PlatformGuard on every request). The roles API fills auth's RoleDirectory port.
 */
@Global()
@Module({
  controllers: [AuthController],
  providers: [
    {
      provide: AUTH_API,
      inject: [ENV, PRISMA, USERS_API, ROLES_API, AUDIT_API, CLOCK, RATE_LIMITER, JOB_QUEUE, VALKEY],
      useFactory: (
        env: ApiEnv,
        prisma: PrismaClient,
        users: UsersApi,
        roles: RolesApi,
        audit: AuditApi,
        clock: Clock,
        rateLimiter: RateLimiter,
        jobQueue: JobQueue,
        valkey: Redis,
      ): AuthApi =>
        createAuthModule({
          prisma,
          users,
          roles,
          audit,
          clock,
          rateLimiter,
          jobQueue,
          oneTimeTokens: valkeyOneTimeTokens(valkey),
          config: {
            jwtPrivateKeyPem: env.JWT_PRIVATE_KEY,
            jwtPublicKeyPem: env.JWT_PUBLIC_KEY,
            jwtIssuer: env.JWT_ISSUER,
            otpPepper: env.OTP_PEPPER,
            totpEncKey: env.TOTP_ENC_KEY,
          },
        }),
    },
    {
      provide: ACCESS_TOKEN_VERIFIER,
      inject: [AUTH_API],
      useFactory: (auth: AuthApi): AccessTokenVerifier => ({ verify: (token) => auth.verifyAccessToken(token) }),
    },
  ],
  exports: [AUTH_API, ACCESS_TOKEN_VERIFIER],
})
export class AuthHttpModule {}
