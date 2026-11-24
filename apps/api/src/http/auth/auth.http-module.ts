import { Global, Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import type { AuditApi } from "@heymey/domain/modules/audit";
import { createAuthModule, type AuthApi } from "@heymey/domain/modules/auth";
import type { RolesApi } from "@heymey/domain/modules/roles";
import type { UsersApi } from "@heymey/domain/modules/users";
import type { Clock, RateLimiter } from "@heymey/domain/shared";
import type { ApiEnv } from "../../platform/env.js";
import { httpOtpMailer } from "../../platform/mailer.js";
import { pgOneTimeTokens } from "../../platform/pg-stores.js";
import type { AccessTokenVerifier } from "../../platform/request-context.js";
import {
  ACCESS_TOKEN_VERIFIER,
  AUDIT_API,
  AUTH_API,
  CLOCK,
  ENV,
  PRISMA,
  RATE_LIMITER,
  ROLES_API,
  USERS_API,
} from "../../platform/tokens.js";
import { AuthController } from "./auth.controller.js";

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
      inject: [ENV, PRISMA, USERS_API, ROLES_API, AUDIT_API, CLOCK, RATE_LIMITER],
      useFactory: (
        env: ApiEnv,
        prisma: PrismaClient,
        users: UsersApi,
        roles: RolesApi,
        audit: AuditApi,
        clock: Clock,
        rateLimiter: RateLimiter,
      ): AuthApi =>
        createAuthModule({
          prisma,
          users,
          roles,
          audit,
          clock,
          rateLimiter,
          mailer: httpOtpMailer(env),
          oneTimeTokens: pgOneTimeTokens(prisma),
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
