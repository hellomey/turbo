# BOLT-0006: Phase 1 reviews

| | |
|---|---|
| Reviews | security, compliance, qa |
| Covers | BOLT-0002, 0003, 0004, 0005 |

## Compliance review

Reviewer: `compliance` agent (read-only; recorded by conductor). **Verdict: changes required** (C1-C5).

Passed: error messages simple English; no Tamil script in interface code; OTP email plain text, transactional, no links;
nothing pre-ticked and profile saved only after consent; eligibility disclaimer + official links, no selection promises;
seed refuses production and is marked SEED; the four seeded lessons' facts check out; marketing has no fake urgency.

| ID | Finding | Owner | Fix |
|---|---|---|---|
| C1 | Consent screen says "You can change optional choices later in Profile" but Profile has no consent controls (DPDP: withdraw as easily as given) | flutter-ui | Add "Your data choices" in Profile (switches → `POST /v1/me/consents`) + Privacy/Terms/Grievance links |
| C2 | Required consent text omits DOB, qualification, community, special categories (sensitive) | backend identity (`users/domain/rules.ts`) | List every field and purpose; bump notice to `2026-10-v2` |
| C3 | Consent screen lacks rights/grievance/privacy link; "Agree and continue" reads as agreeing to everything | flutter-ui | Add rights + grievance line + privacy link; button "Save my choices and continue" |
| C4 | Privacy Policy (`apps/marketing/src/content/legal.ts`) contradicts the app's data use and purposes | **founder + lawyer** | Rewrite to match notice v2, field by field |
| C5 | Grievance officer not named, no postal address; Community Guidelines + Game Rules pages missing; README/APP_URL still heymey.in | **founder** (name/address), devops (strings) | Name + address from founder; pages before launch |

Minor (non-blocking): M1 CONSENT_REQUIRED wording · M2 PURCHASE_NOT_VERIFIED promise · M3 PRACTICE_DAILY_LIMIT reset time ·
M4 split product_research · M5 institution sharing asks again at join · M6 empty eligibility result blames the user ·
M7 confirm line shown twice · M8 share text sounds official · M9 seed textbook refs shown as fact · M10 independence line
misses SSC · M11 meta description promises Tamil/TET/SET · M12 refund page vague window · M13 "Never share this code" in OTP email.

## Security review

Reviewer: security agent, 2026-10-20. Scope: BOLT-0002 identity (auth, users, roles, audit, HTTP adapters, worker),
API platform (guard, rate limits, idempotency, error filter, CORS), contract `routes/auth/users`, Prisma identity schema,
infra (`.dockerignore`, `infra/docker`, `infra/compose`, Caddyfile, workflows), `tools/dev-env.mjs`, `.claude/settings.json`.
Checked against blueprint §15, §16, §18, §23, §37, §38 and OWASP ASVS v4 (V2 auth, V3 session, V4 access, V7 logging, V8 data).

**Verdict: REQUEST CHANGES.** SEC-H1 and SEC-H2 block G-C. SEC-M1 to SEC-M4 should land in this bolt (at the latest
before staging holds real users). Lows can be follow-ups.

Evidence: new `apps/api/test/integration/security.int.spec.ts` (real Postgres + Valkey). Each test asserts the SECURE
behaviour and is marked `it.fails`; all 4 were confirmed failing as plain `it` for the stated reason (SEC-H1: 11th and
12th OTP requests from one client got 200; SEC-H2: correct TOTP accepted after 40 wrong guesses on one challenge; SEC-M1:
16 guesses evaluated on one code; SEC-M2: TOTP seed found in `idem:*`). When a fix lands, flip the test to `it`.
`pnpm --filter @heymey/api test:integration`: 24 passed + 4 expected-fail. `pnpm --filter @heymey/domain test`: 212 passed.

### High

**SEC-H1. Per-IP rate limits are bypassable by a spoofed `X-Forwarded-For`.**
`apps/api/src/bootstrap.ts:15` (`trustProxy: true`), `infra/caddy/Caddyfile:5-7,39`, `apps/api/src/platform/platform.guard.ts:86`.
With `trustProxy: true` Fastify trusts every hop and `req.ip` is the LEFT-MOST XFF entry. Cloudflare appends to a
client-supplied XFF and Caddy (Cloudflare ranges are `trusted_proxies`) keeps it, so `req.ip` is whatever the client
writes. Every per-IP limit (§38 10 OTP/IP/hour, verify 30/h, TOTP 20/h, default 300/min) is void, and the spoofed value
is stored in `otp_codes.requestIp` and in audit `actor.ip`. Impact: OTP mail bombing (with plus-aliases), and it
enables SEC-H2. Fix: in Caddy, `servers { trusted_proxies static <CF ranges>; client_ip_headers CF-Connecting-IP }`
and in each `reverse_proxy` add `header_up X-Forwarded-For {client_ip}` (overwrite with one value). In Fastify set
`trustProxy` to the edge network only (the `heymey-edge` subnet, or hop count `1`), never `true`. Firewall the origin
to Cloudflare ranges. Key IPv6 clients by /64 in the limiter (one host owns 2^64 addresses). Flip SEC-H1 in the spec.

**SEC-H2. Desk TOTP second factor has no failure limit (brute-forceable).**
`packages/domain/src/modules/auth/application/auth-service.ts:256-271`, `auth/domain/policy.ts:162-175`, contract `routes.ts:95`.
`verifyDeskTotp` accepts unlimited wrong codes per challenge and per user; the only brake is 20/IP/hour (void via
SEC-H1, and per-address for IPv6 anyway). The challenge lives 5 min and 3 steps are accepted, so an attacker who
controls a staff mailbox (the exact threat the §15 second factor exists for) gets about 3 in 10^6 per try at server
speed, and can mint 3 new challenges per 10 min. Failed attempts are not audited.
Fix: per-user failure counter on `two_factors` (`failedAttempts`, `lockedUntil`): 5 wrong codes -> TOTP locked 15 min
(new code `TOTP_LOCKED`, 429) and the challenge dead; make the challenge single-use with a `jti` (the BOLT-0002
follow-up), which also bounds attempts per challenge; audit `auth.desk_totp_failed` and `auth.desk_signin`. Add domain
tests with FakeClock and flip SEC-H2.

### Medium

**SEC-M1. OTP 5-try limit is racy: concurrent guesses are all evaluated.**
`auth-service.ts:85-101`, `auth/infrastructure/prisma-auth-repositories.ts:38-41`. `otpStatus` is read, then the slow
argon2 compare runs, then `attempts` is incremented without a guard, so N parallel requests all pass the check (16 of
25 evaluated in the test). §38 "max 5 tries per code" is not enforced. Fix: reserve the attempt atomically BEFORE
comparing: `UPDATE otp_codes SET attempts = attempts + 1 WHERE id = $1 AND attempts < 5 AND used_at IS NULL AND
locked_at IS NULL AND expires_at > now() RETURNING attempts`; 0 rows -> `OTP_LOCKED` / `OTP_EXPIRED`; then compare;
on success `markUsed`; lock when the reserved attempt is the 5th and wrong. Flip SEC-M1.

**SEC-M2. Secrets kept in plaintext in Valkey (idempotency bodies, OTP jobs); Valkey has no auth and persists to disk.**
`apps/api/src/platform/idempotency.interceptor.ts:243`, `apps/api/src/platform/valkey.ts:187-190`,
`infra/compose/compose.yml:132`, `apps/api/src/platform/infra.module.ts:28-29`. Every idempotent response is stored for
24 h verbatim: `/auth/desk/totp/enroll` stores the TOTP seed (defeating the AES-256-GCM at-rest encryption),
`/auth/otp/verify` and `/auth/refresh` store live refresh tokens (the DB stores only SHA-256). OTP job data (`to`,
plaintext `code`) is kept 24 h when a job fails. Valkey runs without `requirepass`, with `appendonly yes`, published on
127.0.0.1. Fix: for auth routes do not store bodies; store `{hash, status}` only and answer a replay with 409
(these use cases are single-use anyway), or encrypt stored bodies with a server key; enable Valkey `requirepass`/ACL
and pass the password in `VALKEY_URL` (see SEC-L2); `removeOnFail: { age: 600 }` for `email.otp`. Flip SEC-M2.

**SEC-M3. Account erasure is incomplete and racy (§38.7, §23 DPDP).**
`packages/domain/src/modules/users/infrastructure/prisma-users.ts:111-120`, `packages/db/prisma/schema/auth.prisma:4-17`.
(a) `otp_codes` rows keep the plaintext email and request IP forever (no GC, not erased), so an erased user's email
survives. (b) `erase` does not re-check `deletionRequestedAt`: a user who signs in (cancels) between `dueForErasure`
and `erase` is erased anyway, profile and consents included. Fix: (a) auth exposes a purge of `otp_codes` by email,
called by the `users.deletion` processor before the email is replaced, plus a scheduled GC of `otp_codes` older than
24 h; (b) run the user update first with `where: { id, deletedAt: null, deletionRequestedAt: { lte: cutoff } }` in an
interactive transaction and skip the deletes when it matched 0 rows. Add an integration test for both.

**SEC-M4. Desk TOTP enrollment is trust-on-first-use; the staff seed has no production guard.**
`auth-service.ts:247-254`, `packages/db/prisma/seed/identity.ts:7-35` (compare the guard in `catalog.ts:425`). Anyone
holding the mailbox of a not-yet-enrolled Desk user (seeded `admin@heymey.app`, any newly granted staff) can enroll their
own authenticator, and calling enroll again overwrites a pending secret (racing the real user). Fix: refuse the identity
seed when `HEYMEY_ENV=production`; require an enrollment grant (a one-time enrollment token issued by an admin and
audited, or enrollment only within N hours of the role grant) before enroll works; audit enroll calls; email the user
when a TOTP is enrolled. **Open question for the founder (§26.2, aidlc/README §6): which enrollment ceremony for
staff and partners?**

### Low

- **SEC-L1** `infra/caddy/Caddyfile:20-23,34,94-96`: `ops_only` matches `remote_ip`; behind Cloudflare that is the CF
  edge IP, so the allowlist blocks everyone or works only for DNS-only hosts. If switched to `client_ip`, use it only
  with `client_ip_headers CF-Connecting-IP` (default XFF parsing is left-most, so spoofable). The `@deskAdmin` matcher
  `/v1/desk/admin/*` misses the bare `/v1/desk/admin`; list both forms. `staging-api` is public without an allowlist:
  acceptable only while staging never holds real data.
- **SEC-L2** `apps/api/src/platform/infra.module.ts:16-18`: `bullJobQueue` drops the Valkey password from the URL (the
  worker's `bullConnection` keeps it). Once Valkey auth is on (SEC-M2), OTP mail silently stops. Reuse `bullConnection`.
- **SEC-L3** `.dockerignore:24-25`: `*.pem` / `*.age` match only the repo root; use `**/*.pem`, `**/*.age`, `**/*.key`.
  `infra/docker/server.Dockerfile:79-81`: the migrator stage runs as root with full sources; add `USER node`.
- **SEC-L4** `.github/workflows/ci.yml`: no top-level `permissions: { contents: read }`; third-party actions pinned by
  tag, not commit SHA; `deploy.yml:49-54,70-75` `appleboy/ssh-action` has no `fingerprint` (host key not verified).
- **SEC-L5** `apps/api/src/platform/domain-error.filter.ts:59`: logs raw stacks of unknown errors; Prisma errors can
  carry query values (emails). Log error name + Prisma code + requestId; send detail to GlitchTip with PII scrubbing.
- **SEC-L6** `auth/infrastructure/crypto.ts:50-63`: AES-GCM seal has no AAD; bind the ciphertext to the user
  (AAD = userId) so a DB writer cannot swap TOTP secrets between users.
- **SEC-L7** `.claude/settings.json`: deny rules cover `Read` only; a recursive `grep` through Bash scans `./.env`
  (seen during this review: listed as a match, contents not printed). Add Bash deny patterns for `.env` and secrets.
- **SEC-L8** `auth-service.ts:222-234`: roles ride in the access JWT and are not re-read; a role revocation takes up
  to 15 min. Document it, or re-read roles for `desk` routes when role revoke lands.
- **SEC-L9** Stray directory `infra/docker/desk.Caddyfile;C` (Windows artefact): delete it.

### Verified OK (no change needed)
OTP from `crypto.randomInt` (CSPRNG); argon2id with the pepper as the argon2 `secret`; 10-min expiry; 3/email/10 min
keyed by SHA-256 of the normalised email; same response and code path for new vs existing emails on `otp/request`
(no enumeration; verify-side differences need a valid code); EdDSA pinned, `iss`/`aud`/`exp` checked, access and
challenge tokens separated by audience, live session + `isDesk` checked on every request; refresh rotation with atomic
`markUsed`, reuse -> session revoked + audited; TOTP step replay protection atomic (`acceptStep`); aspirants refused at
OTP verify and again at the TOTP step; delete-account needs the same-email caller + OTP and revokes all sessions; the
guard enforces the contract `auth` level on every route (unknown route -> 404), `desk` = Desk session + Desk role;
idempotency scoped by user/IP + route + body hash, so no cross-user replay without the secret body; the error envelope
leaks nothing for unknown errors; worker logs and audit entries never contain emails, codes or tokens; CORS is an
explicit origin list without credentials; the runtime image is non-root and digest-pinned; data ports bind 127.0.0.1,
only 80/443 are public; secrets via SOPS, `.env.example` has placeholders only; `tools/dev-env.mjs` writes
git-ignored local keys only. Not run here: Semgrep, osv-scanner, gitleaks (not installed locally; CI job exists).

## QA review

Reviewer: qa agent, 2026-10-20. Scope: backend of BOLT-0002/0003 against INT-001 S01-S07, blueprint §17.1, §34, §37, §38, §44.
Tests only were added; no production code, contract, Prisma, Dart or infra was changed.

### 1. Coverage (§44), combined unit + integration, `packages/domain`, v8, statements

The measured gaps were a **measurement artefact**: `include: ["src/modules/**"]` also counts each `module.json`
(9 "statements", 0% unless something imports it). Source code was already above target. The coverage config the
conductor uses should be `include: ["src/modules/**/*.ts"]` (finding Q-3). A manifest test now imports every
`module.json`, so both ways of measuring pass.

| Module | Target | Before (incl. module.json) | After (incl. module.json) | Before (code only) | After (code only) | Branches after |
|---|---|---|---|---|---|---|
| audit | 90 | 69.0% (20/29) | **100%** (29/29) | 100% | 100% | 100% |
| auth | 90 | 92.2% | 96.7% | 95.0% | 96.6% | 90.1% |
| users | 70 | 89.5% | 95.8% | 95.5% | 95.5% | 83.3% |
| roles | 90 (manifest) | 76.3% | 100% | 100% | 100% | 100% |
| exams | 70 | 93.9% | 99.4% | 99.4% | 99.4% | 93.3% |
| syllabus | 70 | 82.7% | 100% | 100% | 100% | 93.8% |
| content | 70 | 67.7% (21/31) | **100%** (31/31) | 95.5% | 100% | 100% |

### 2. Traceability INT-001 to tests

| Criterion | Tests |
|---|---|
| S01 under 18: message; nothing stored on server | `eligibility.spec.ts` "under 18 (invariant 1)", "uses the Asia/Kolkata date" (FakeClock); `api/catalog.spec.ts` "under 18 today (IST) -> 422 UNDER_18"; **new** `api/my-exams.int.spec.ts` "an under-18 check and an adult check write no rows on the server". Phone side: Flutter (BOLT-0004). |
| S01 "eligible for N exams", official link, "Always confirm..." | `eligibility.spec.ts` "result shape (invariant 9)", "fit ranking"; `api/catalog.spec.ts` "200 with eligible and not-eligible lists". "Top 5" is a UI cut (Flutter). |
| S01 community relaxation applied with reason | `eligibility.spec.ts` "age on the rule's age-as-on date", "relaxations (invariant 3)" |
| S01 rules are data, published only, human check | `eligibility.spec.ts` "published only (invariant 7)"; `exams.int.spec.ts` "latest PUBLISHED rule"; `syllabus.int.spec.ts` "marks every exam as seed data and never as human-verified" |
| §17.1 step 4 main exam + up to 2 | `exams.spec.ts` "validateExamChoice", "my exams"; `exams.int.spec.ts` "replaced atomically"; **new** `api/my-exams.int.spec.ts` (5 HTTP tests with a real OTP session) |
| S02 always 200 + email text queued | `auth.spec.ts` "always answers resendAfterSeconds 60...", "answers the same for an existing account", "composes plain-text emails"; `worker/processors.spec.ts` "sends the plain-text login code email"; `api/identity.int.spec.ts` "OTP request: 200, queued once"; **new** `auth.crypto.spec.ts` "jobQueueOtpMailer ... jobId = OTP id" |
| S02 3/email/10 min, 10/IP/hour, Retry-After | `auth.spec.ts` "allows 3 requests per email per 10 minutes" (FakeClock); `api/identity.int.spec.ts` "per-IP limit", "per-email limit" |
| S02 disposable -> EMAIL_NOT_ALLOWED | `auth.spec.ts` "blocks disposable domains incl. sub-domains"; `api/identity.int.spec.ts` |
| S02 5 wrong -> OTP_LOCKED; argon2id + pepper; constant time | `auth.spec.ts` "the 5th wrong locks"; `auth.int.spec.ts` "OTP rows are hashed, attempts counted and locked at 5"; **new** `auth.crypto.spec.ts` "Argon2OtpHasher" (pepper matters, salt, malformed hash) and "equals: constant-time compare" |
| S02 10-minute expiry | `auth.spec.ts` "valid until just before 10 minutes and expired at exactly 10 minutes" (FakeClock) |
| S02 15-min JWT, 60-day refresh bound to device, resend 60 s | `auth.spec.ts` "creates a new user ... binds the device" (15 min, 60 days); **new** `auth.crypto.spec.ts` "access tokens live exactly 15 minutes" (real jose); resend timer is app-side (Flutter) |
| S02 refresh reuse revokes family | `auth.spec.ts` "re-using an old refresh token revokes the whole family", "concurrent second use"; `auth.int.spec.ts`; `api/identity.int.spec.ts` |
| S03 consent, separate choices, notice version | `users.spec.ts` "users: consent (DPDP)"; `auth.int.spec.ts` "consents (latest per purpose)"; `api/identity.int.spec.ts` "PATCH /v1/me, PUT profile, consents". "Nothing pre-ticked" is UI (Flutter). |
| S04 Study Map, shared lamps | `syllabus.spec.ts`, `syllabus.int.spec.ts`, `api/catalog.spec.ts` "study map". Lite Mode, ring visuals: Flutter. |
| S05 lessons, textbook ref, published only | `content.spec.ts`, `syllabus.int.spec.ts` lesson tests (+2 new), `api/catalog.spec.ts` "lessons". TTS/offline: Flutter. |
| S06 Desk OTP + TOTP, aspirants refused | `auth.spec.ts` "Desk sign-in (TOTP)"; `auth.int.spec.ts`; `api/identity.int.spec.ts` "Desk: aspirant refused"; **new** `auth.crypto.spec.ts` RFC 6238 vector, AES-GCM secret box |
| S07 Idempotency-Key on every write | `api/contract.spec.ts` "every state-changing route requires an Idempotency-Key"; `api/identity.int.spec.ts`; **new** `api/my-exams.int.spec.ts` "same key + same body twice -> one effect", "different body -> IDEMPOTENCY_KEY_REUSED", "scoped per user" |
| S07 error envelope, stable code, simple English | `api/catalog.spec.ts`; **new** `api/my-exams.int.spec.ts` "errors use the envelope with the contract message" |
| S07 X-Min-App-Version on every response | `api/identity.int.spec.ts` (GET /v1/me only); **new** `my-exams.int.spec.ts` success + handler errors; guard errors: `it.fails` (finding Q-2) |
| S07 per-user and per-IP rate limits in Valkey | per-IP: `api/identity.int.spec.ts`; per-user: **new** `my-exams.int.spec.ts` "per-user rate limits ... follow the user across IPs" |
| Audit (§15, §36) | `audit.spec.ts` (+38 cases), `audit.int.spec.ts` (+4) |
| S08 staging live | not testable in unit/integration; devops (BOLT-0005) |

Criteria with no backend test (not testable here): S01 "nothing stored on the phone", top-5 cut, S03 "nothing
pre-ticked", S04 Lite Mode, S05 Listen Mode/offline, app resend timer (all Flutter, BOLT-0004); S08 (ops); §32 OTP
delivery < 30 s (monitoring). Refresh "bound to device" is checked only indirectly (the session row has deviceId); the
refresh call carries no device id, so nothing is checked at refresh time. Flagged for the auth owner, not a defect.

### 3. Findings (for owning agents; not fixed by qa)

- **Q-1 (audit, medium, T2 personal data).** `validateAuditEntry` checks top-level keys of before/after only; nested
  personal data (`{ user: { email } }`) and look-alike keys (`phone`, `dob`, `emailAddress`) are written to the audit log
  (§30). Placeholder: `audit.spec.ts` `it.todo(... Q-1)`. Also: AuditLog is append-only by convention only; there is
  no DB trigger or REVOKE UPDATE/DELETE (MODULE.md says "never updated or deleted"). Suggest a migration-level guard.
- **Q-2 (platform-api, medium, §37 / S07).** Responses rejected in `PlatformGuard` (401 UNAUTHENTICATED, 429
  RATE_LIMITED, 403 DESK_*) carry no `X-Min-App-Version` and no `X-Request-Id`, because `AppVersionInterceptor` runs
  after guards. An outdated, signed-out app never sees "Update needed". Proven by
  `apps/api/test/integration/my-exams.int.spec.ts` `it.fails("guard-rejected responses (401, 429) also carry ...")`.
  Fix idea: set the headers in a Fastify `onRequest`/`onSend` hook; then turn `it.fails` into `it`.
- **Q-3 (conductor, low).** Coverage `include` should be `src/modules/**/*.ts`; JSON manifests distort module totals.
- **Q-4 (exams, info).** `PUT /v1/me/exams` returns `others` in the API's own order, not the order sent. The contract
  does not define an order; state it in the contract if the app relies on it.
- **Q-5 (dart/devops, outside qa).** `pnpm verify` fails only in `@heymey/dart#lint`: `dart format --set-exit-if-changed`
  reports 71 unformatted files, all in the generated `dart/hm_api` (codegen output is not formatted). Owner: flutter-ui/devops.

### 4. Tests added

- `packages/domain/test/modules/module-manifests.spec.ts` (new, 8): manifest invariants, §44 coverage floors, acyclic dependsOn, single table owner.
- `packages/domain/test/modules/auth.crypto.spec.ts` (new, 19): real argon2id + pepper, constant-time equals, AES-GCM, TOTP RFC vector, jose EdDSA TTL/issuer/key, OTP mailer jobId.
- `packages/domain/test/modules/audit.spec.ts` (+38, 1 todo), `audit.int.spec.ts` (+4), `content.spec.ts` (+4), `syllabus.int.spec.ts` (+2 content repository cases).
- `apps/api/test/integration/my-exams.int.spec.ts` (new, 12 + 1 `it.fails`): signed-in GET/PUT /v1/me/exams, idempotency replay/reuse/per-user scope, envelope, X-Min-App-Version, per-user rate limit, eligibility stores nothing.
- `apps/api/test/integration/catalog.spec.ts`: stale comment updated (no behaviour change).

### 5. Suite results (2026-10-20)

| Command | Result |
|---|---|
| `pnpm --filter @heymey/domain test` | 11 files, 231 passed, 1 todo |
| `pnpm --filter @heymey/domain test:integration` | 4 files, 26 passed |
| `pnpm --filter @heymey/api test` | 1 file, 3 passed |
| `pnpm --filter @heymey/api test:integration` | 4 files, 36 passed, 5 expected-fail (4 security findings + Q-2) |
| `pnpm --filter @heymey/worker test` | 1 file, 7 passed |
| `pnpm verify` | ports, docs, firewall (9 permanent tests), boundaries pass; 37/39 turbo tasks pass; fails only in `@heymey/dart#lint` (Q-5) |

### Verdict

**Pass with findings** for the backend of BOLT-0002/0003: coverage targets met, every backend-testable INT-001
criterion is traced to a test. Q-1 and Q-2 should be fixed before G-C (T2 personal data and a §37 guarantee); Q-5 blocks
a green `pnpm verify` and belongs to the Dart track.
