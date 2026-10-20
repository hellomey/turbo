# BOLT-0002: Identity: email OTP, sessions, Desk TOTP, deletion, users, roles, OTP email worker

| | |
|---|---|
| Unit | U-auth, U-users, U-roles |
| Stories | INT-001-S02, S03, S06, S07 |
| Risk tier | T2 (auth, personal data) |
| Agent | backend (identity track) |
| Branch / PR | `bolt/BOLT-0002-identity` · not opened (agent does not commit) |
| Status | in review (code complete, all local checks green; not committed, PR not opened) |

## Plan
- Goal: §38 email OTP sign-in end to end, rotating refresh tokens with family revocation, Desk TOTP second factor,
  account deletion with 7-day grace, `Me` + profile (18+ on IST date) + DPDP consents, roles, OTP email + deletion jobs.
- Files: `packages/domain/src/modules/{auth,users,roles}/**`, `apps/api/src/http/{auth,users,roles}/**`, `apps/worker/src/**`,
  `packages/db/prisma/seed/identity.ts`, tests in the owned test paths, design docs in `aidlc/construction/units/U-{auth,users,roles}/`.
- Contract changes: none (BOLT-0001 contract implemented as is).
- Tests first: domain invariants from the three domain models (FakeClock + in-memory fakes); repository integration on real
  Postgres; API end to end on real Postgres + Valkey; worker processors with fakes.

## Result (filled when the PR is ready)

### What changed
- `packages/domain/src/modules/roles`: `createRolesModule` → `rolesOf` (contract order), `grant` (idempotent, advisory-locked,
  audited `role.grant`), `canUseDesk`.
- `packages/domain/src/modules/users`: `createUsersModule` → Me, settings patch, profile (18+ on today's IST date, else
  `UNDER_18` and nothing stored), consent notice `2026-10-v1` + append-only consents (latest per purpose), deletion
  request/cancel (7-day grace), `eraseDueAccounts` (email → `deleted+<id>@invalid.heymey.app`, profile + consents deleted,
  `deletedAt`, audited `users.erased`). Roles reach `Me` through a structural `RolesReader` port (no new module dependency).
- `packages/domain/src/modules/auth`: `createAuthModule` → OTP request (normalise, disposable list, 3/email/10 min,
  argon2id + pepper, 10-min expiry, `email.otp` job with jobId = OTP id, always `{resendAfterSeconds: 60}`), OTP verify
  (latest code only, lock on 5th wrong, single use, device bound to one user, ASPIRANT on creation, cancels pending
  deletion, App session 60 d / Desk challenge 5 min), EdDSA access tokens (15 min, session checked on verify),
  rotating refresh tokens with family revocation on reuse (`token_reuse`, audited), logout / logout-all, Desk TOTP
  (AES-256-GCM secret, ±1 step drift, one use per step, `auth.desk_totp_enrolled` audited, Desk session 12 h),
  delete-account. Roles reached through a structural `RoleDirectory` port. `createSessionRevoker` for the worker.
  Crypto (argon2, jose, otplib, AES) lives in `infrastructure/` behind ports.
- `apps/api/src/http/{auth,users,roles}`: controllers for all 14 identity routes; `AUTH_API`, `USERS_API`, `ROLES_API`
  and the real `ACCESS_TOKEN_VERIFIER` (replaces the reject-all placeholder).
- `apps/worker`: `email.otp` processor (Nodemailer, plain text) and daily `users.deletion` processor; BullMQ Workers only
  for these two queues; scheduler upserts the `users.deletion` job scheduler (`0 3 * * *`, Asia/Kolkata). Registry unchanged.
- `packages/db/prisma/seed/identity.ts`: admin (ADMIN), ops (OPS), aspirant (ASPIRANT) @heymey.app, idempotent.

### Evidence (local, 2026-10-20)
- `pnpm turbo run build --filter=./packages/*`: 8/8 tasks successful.
- `@heymey/domain`: typecheck ✔, lint ✔, test 161/161 (identity: auth 33, users 10, roles 4), test:integration 20/20
  (identity `auth.int.spec.ts` 8, real Postgres).
- `@heymey/api`: typecheck ✔, lint ✔, test 3/3 (contract test fully green: no missing or extra routes),
  test:integration 24/24 (identity `test/integration/identity.int.spec.ts` 10, real Postgres + Valkey).
- `@heymey/worker`: typecheck ✔, lint ✔, test 7/7.
- `pnpm boundaries`: no violations. `pnpm firewall:check`: 9 permanent tests present.
- `pnpm --filter @heymey/db seed`: `seed identity: 3 users (3 new), 3 roles granted`; second run `0 new, 0 roles granted`.
- Live smoke: worker against local Valkey + Mailpit delivered "Your HeyMey code is 482913. It expires in 10 minutes. ...".
- Coverage: **not measured** (`@vitest/coverage-v8` is not installed; adding it is a package.json change outside this bolt).

### Deviations from the brief (and why)
- The 5th wrong code answers `OTP_LOCKED` (not `OTP_INVALID`), matching INT-001-S02 "Given 5 wrong codes, Then ... OTP_LOCKED".
- Only the newest code for email + purpose counts (a used newest code = `OTP_EXPIRED`), so an older unused code cannot be used.
- Confirmed delete-account also revokes all sessions (reason `deleted`); signing in within 7 days cancels (Q-A1 in U-auth domain model).
- Desk sign-in does not cancel a pending deletion (`deletionCancelled: false` per contract); only app sign-in does.
- The worker's `users.deletion` processor calls two use cases (users erase + auth session revoker), because users may not depend on auth.

### Follow-ups
- Add `@vitest/coverage-v8` (devops/architect) and measure auth ≥ 90%.
- Desk challenge tokens are not single-use (bounded by 5 min + TOTP step replay protection); consider a jti store.
- Disposable-domain list is a small built-in list; move to data when Ops needs to edit it.
- Security + compliance review (BOLT-0006); founder G-D/G-C approval (T2).

## Security review (BOLT-0006, 2026-10-20)
Request changes. See [BOLT-0006-reviews.md](BOLT-0006-reviews.md) section Security review: SEC-H1 (trustProxy / XFF), SEC-H2 (TOTP failure limit),
SEC-M1 (atomic OTP attempts), SEC-M2 (secrets in idempotency store, Valkey auth), SEC-M3 (erasure of otp_codes + race),
SEC-M4 (TOTP enrollment ceremony, founder question; identity seed prod guard). Demonstrating tests: `apps/api/test/integration/security.int.spec.ts` (`it.fails`).
