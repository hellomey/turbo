# BOLT-0007: Security fixes from BOLT-0006 review (SEC-H2, SEC-M1, SEC-M3, SEC-M4 interim, SEC-L6)

| | |
|---|---|
| Unit | U-auth, U-users (+ worker queues owned by auth/users) |
| Stories | INT-001 (sign-in, Desk second factor, deletion) |
| Risk tier | T2 (security, personal data). Founder approves the merge |
| Agent | backend (identity) |
| Branch / PR | `bolt/BOLT-0007-security-fixes` · not committed yet |
| Status | in review (API integration run blocked: Docker daemon down) |

## Plan
Findings come from `BOLT-0006-reviews.md` § Security review. Blueprint §15 (Desk second factor), §18 (OTP abuse), §23 (DPDP), §37, §38, §38.7.
Contracts, Prisma schema and migration (`TOTP_LOCKED`, `TwoFactor.failedAttempts/lockedUntil`) were done by the architect.

## Result
- **SEC-H2**: the challenge JWT now has a `jti` and a port `OneTimeTokenStore.consume(jti, ttl)`. The API backs it with Valkey (`SET auth:jti:<jti> 1 EX ttl NX`, `valkeyOneTimeTokens` in `apps/api/src/http/auth/auth.http-module.ts`). Verify consumes the challenge BEFORE it compares the code, so each challenge allows exactly one guess, including concurrent ones. Enroll does not consume it. After 5 consecutive wrong codes the user's TOTP is locked for 15 minutes (atomic `UPDATE ... RETURNING`). While locked, every verify or enroll returns `TOTP_LOCKED` with `retryAfterSeconds`, even with the right code. A successful verify resets the counter. Audit events: `auth.desk_totp_failed` (records `failedAttempts` only, never the code), `auth.desk_totp_locked` and `auth.desk_signin`.
- **SEC-M1**: `OtpRepository.reserveAttempt` runs one conditional `UPDATE "OtpCode" ... WHERE attempts < 5 AND usedAt IS NULL AND lockedAt IS NULL AND expiresAt > $now RETURNING attempts` before the argon2 compare. If no attempt is reserved, the result is OTP_EXPIRED or OTP_LOCKED. The 5th reserved wrong attempt locks the code.
- **SEC-M3**: auth gains `purgeOtpCodesFor(email)` and `purgeExpiredOtpCodes(olderThan)` (in `AuthApi` and in `createOtpMaintenance` for the worker). `users.eraseDueAccounts({ beforeErase })` calls the hook while the real email is still stored, and the worker purges OTP rows there. `erase` runs one interactive transaction: it updates the user only `where { id, deletedAt: null, deletionRequestedAt <= cutoff }`; if that matches 0 rows, it skips everything. New queue `auth.otp-gc` (owner auth, cron `45 * * * *`) deletes rows older than 24 h.
- **SEC-M4 (interim, D-2026-10-20-20 still open for the founder)**: the identity seed throws when `HEYMEY_ENV=production`. Enroll never replaces a pending secret younger than 10 minutes (FORBIDDEN) and never replaces a confirmed one. Every enroll is audited (`auth.desk_totp_enroll_started` / `auth.desk_totp_enroll_refused`, with ip and requestId).
- **SEC-L6**: secrets are sealed as `v2.` with AES-GCM and AAD = userId. Legacy `v1.` rows (no AAD, dev data only) still open, are flagged `legacy`, and are re-sealed as v2 after the next successful verify. A v1 value cannot be produced from a v2 value without the key, so the binding cannot be downgraded. If a secret cannot be opened, the result is TOTP_INVALID and the event `auth.desk_totp_secret_unreadable` is audited.
- Security spec: SEC-H2 and SEC-M1 are switched from `it.fails` to `it` (SEC-H1 and SEC-M2 had already been switched by the conductor). The SEC-H2 loop now expects `CHALLENGE_EXPIRED` after the first wrong guess, because the challenge is single-use. Added an HTTP lockout test (429 TOTP_LOCKED).

### Evidence (2026-10-22)
- domain: typecheck and lint clean. Unit tests: 250 passed. Integration (Postgres): 31 passed.
- worker: typecheck and lint clean, 8 passed. api: typecheck and lint clean, unit 10 passed.
- `pnpm boundaries`: no violations. `pnpm firewall:check`: 9 permanent tests present. Packages build: 8/8.
- **Not run**: `pnpm --filter @heymey/api test:integration`. The Docker daemon went down during the bolt ("Could not find a working container runtime strategy"), so the flipped SEC-H2/SEC-M1 API tests are unproven over HTTP. Their logic is proven by the domain Postgres integration tests.

### Follow-ups
- Re-run the API integration suite once Docker is back.
- The founder decides the enrollment ceremony (D-2026-10-20-20, SEC-M4).
- `graphify update .` failed: permission denied on the graphify executable.

## Infra section (devops, 2026-10-22; restored after accidental overwrite)

- **SEC-H1**: Caddy `client_ip_headers CF-Connecting-IP` behind Cloudflare `trusted_proxies` (IPv4+IPv6); every `reverse_proxy` sets `header_up X-Forwarded-For {client_ip}`; realtime sticky uses `client_ip_hash`; `TRUST_PROXY_HOPS: "1"` for api/realtime/worker/scheduler; opt-in `CF_ONLY_ORIGIN=1` DOCKER-USER firewall in `provision.sh`. Proven: spoofed XFF replaced by CF-Connecting-IP at the upstream.
- **SEC-L1**: `ops_only` on `client_ip`; `@deskAdmin` matches bare paths; `staging-api`/`staging-rt` behind `staging_only` (allowlist or `X-HeyMey-Staging-Key` ≥ 32 chars).
- **SEC-M2 (infra)**: Valkey `--requirepass` from `${VALKEY_PASSWORD:?}`, authenticated healthcheck, password in `VALKEY_URL`; maxmemory 3gb prod / 384mb staging.
- **SEC-L3**: `.dockerignore` excludes env files, keys, age files; migrator runs as `USER node`.
- **SEC-L4**: workflows `permissions: contents: read`, all actions SHA-pinned, ssh steps pin `VPS_HOST_FINGERPRINT`; fixed nonexistent osv-scanner tag (v2.7.0).
- **SEC-L9**: removed stray `infra/docker/desk.Caddyfile;C` and `infra/caddy/Caddyfile;C`.
- Validation: `docker compose config -q` (all stacks), `caddy validate` (both Caddyfiles), `pnpm ports:check`, `pnpm infra:up` healthy.
- Residual (low): other containers on `heymey-edge` can reach api directly; follow-up: Caddy-only network.

## Result (conductor, 2026-10-22)

`pnpm verify` 39/39 tasks; `pnpm test:integration` 11/11 tasks (api 4 files, domain 4 files, all green, zero `it.fails` left);
Flutter tests all passed; `graphify update .` done. Also fixed: `tools/dart-api-codegen.mjs` deleted `dart/hm_api` when Docker
was down (now checks Docker first); contracts lint (`sensitiveResponse` exported as `x-heymey-sensitive-response`);
API integration tests now run with `TRUST_PROXY_HOPS=1` like production.
