# Logical design: U-auth

Status: draft (G-D)

## Use cases (application layer)
| Use case | Trigger | Ports used | Idempotency key | Authorisation |
|---|---|---|---|---|
| requestOtp | POST /v1/auth/otp/request | OtpRepository, OtpHasher, RateLimiter, OtpMailer, UsersApi, Clock | header | optional; `delete_account` needs a session for the same email |
| verifyOtp | POST /v1/auth/otp/verify | OtpRepository, OtpHasher, DeviceRepository, SessionRepository, RefreshTokenRepository, TokenService, UsersApi, RoleDirectory | header | public |
| refresh | POST /v1/auth/refresh | RefreshTokenRepository, SessionRepository, TokenService, RoleDirectory, Audit | header | public (the token is the credential) |
| logout / logoutAll | POST /v1/auth/logout, /logout-all | SessionRepository, Audit | header | user |
| enrollDeskTotp / verifyDeskTotp | POST /v1/auth/desk/totp/enroll, /verify | TwoFactorRepository, SecretBox, Totp, TokenService, Audit | header | public + challenge token |
| deleteAccount | POST /v1/auth/delete-account | OtpRepository, UsersApi, SessionRepository, Audit | header | user |
| verifyAccessToken | PlatformGuard (`ACCESS_TOKEN_VERIFIER`) | TokenService, SessionRepository | — | — |
| revokeAllForUser | worker `users.deletion` | SessionRepository, Audit | natural (already revoked → 0) | system |

`auth` depends on `users` + `audit` only (module.json). Roles are reached through a structural `RoleDirectory`
port that the API composition root fills with the `roles` API, so no new module dependency (no ADR needed).
Crypto (argon2id, jose, otplib, AES-GCM) sits in `infrastructure/` behind ports; `application/` stays framework-free.

## Contract changes
None. Implements the BOLT-0001 contract exactly (`packages/contracts/src/http/auth.ts`, `routes.ts`).

## Data
No schema change. Uses OtpCode, Device, Session, RefreshToken, TwoFactor as migrated in `phase1_init`.

## Background work
`email.otp` (owner auth, existing registry entry): job `{to, code, purpose}`, jobId = OtpCode id (no duplicate on client retry).
The worker builds the text with `composeOtpEmail` (auth module) and sends it via Nodemailer, plain text only.

## Client (Flutter)
Resend unlocks after `resendAfterSeconds`. Tokens in secure storage; refresh before expiry. Desk: challenge → enroll (QR) → verify.

## Flags and LiveOps
None in Phase 1.

## Failure modes
| Failure | Behaviour | User sees |
|---|---|---|
| SMTP down | job retried 5x with backoff | "Didn't get it? Check spam" + resend after 60 s |
| Valkey down | rate limiter fails → 500 | "Something went wrong. Please try again." |
| Refresh token reuse | session revoked, audited | "You were signed out. Please sign in again." |
| Challenge older than 5 min | CHALLENGE_EXPIRED | "Your sign-in took too long. Please start again." |

## Non-functional budget
argon2id (19 MiB, t=2) is tens of ms per hash; api p95 ≤ 300 ms. Access-token verification = signature + one primary-key session lookup.

## Observability
No personal data in logs. AuditLog actions: `auth.session_revoked`, `auth.desk_totp_enrolled`, `users.deletion_requested`, `users.erased`, `role.grant`.

## Test plan
| Level | Cases | Tool |
|---|---|---|
| Domain unit | invariants 1–14, expiry boundary, lock at 5, rate limit, reuse revokes family, TOTP replay | Vitest + FakeClock + in-memory fakes |
| Integration | Prisma repositories through the module; API end to end (OTP → session → me → refresh/reuse → Desk TOTP) | Testcontainers Postgres + Valkey |

## Bolts
- BOLT-0002 (identity track): all of the above.
