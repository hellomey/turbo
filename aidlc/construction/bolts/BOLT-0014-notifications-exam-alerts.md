# BOLT-0014: Notifications (tokens, budget, quiet hours, sender) + Exam Alerts (webhook intake, Desk approval)

| | |
|---|---|
| Unit | U-notifications, U-exams (Exam Alerts extension) |
| Stories | INT-002-S16, INT-002-S17 |
| Risk tier | T2 (S17: official data correctness, public webhook) |
| Agent | backend |
| Branch / PR | `bolt/BOLT-0014-notifications-exam-alerts` · (no commit: conductor opens the PR) |
| Status | in review (2026-10-22) |

## Plan
- Goal: the 9 routes below end to end, the `push.send` / exam-alert fan-out / held-release workers, blueprint §6, §9.10,
  §17.1 step 11, §17.5, §19.1 Q7, §19.8 Q78, §20.2, §36. Decisions D-2026-10-22-31 (quiet hours, held Exam Alerts),
  -32 (Desk API, OPS/ADMIN, audited), -33 (sender `log_only`).
  - `POST/DELETE /v1/me/push-tokens`, `GET/PUT /v1/me/alert-settings` (notifications)
  - `GET /v1/me/exam-alerts`, `POST /v1/webhooks/changedetection`, `GET /v1/desk/exam-changes`,
    `POST /v1/desk/exam-changes/{changeId}/approve|reject` (exams)
- Files: `packages/domain/src/modules/notifications/**`, new Exam Alert files in `packages/domain/src/modules/exams/**`
  (+ additive lines in its `index.ts`), `apps/api/src/http/notifications/**`, `apps/api/src/http/exams/exam-alerts.*`,
  `apps/worker/src/processors/notifications-*.ts`. Shared, additive only: `app.module.ts`, `tokens.ts`,
  `domain-error.filter.ts`, `env.ts`, `packages/config/src/env.ts`, `tools/dev-env.mjs`, `infra/secrets/.env.example`,
  `apps/api/test/contract.spec.ts`, `apps/api/test/support/env.ts`, worker registry/index/main.
- Contract changes: none (BOLT-0008 already defined routes, schemas and error codes).
- Event wiring (no new module dependency): approve publishes `exams.notification_published` through an
  `EventPublisher` port; the API adapter enqueues job `notifications.exam-alert` (jobId = alertId); the worker
  composition root calls `exams.followersOf(examCode)` then `notifications.enqueueExamAlert(...)`.
- Tests first: notifications policy (budget at exactly 3, quiet hours crossing midnight, offers consent, exam hall,
  held Exam Alerts), exam-change rules; API integration (all 9 routes) + webhook security (bad secret 401, replay 409).

## Result
**What changed**
- `notifications` module: `domain/policy.ts` (IST minute, quiet-hours window crossing midnight, `decideSend`: Exam Hall
  → opt-out/consent → quiet hours (Exam Alerts `held_quiet`) → budget 3/IST day, Exam Alerts never counted, clamp ≤ 3);
  `application/` (tokens, settings, enqueue with dedupeKey, send, releaseHeld, forgetUser); `infrastructure/` Prisma
  repos (budget decision under a per-user `pg_advisory_xact_lock`) + `LogOnlyPushSender` (D-2026-10-22-33, logs ids only).
- `exams` Exam Alerts slice (new files, plus additive exports in `index.ts`): webhook intake (secret checked before the
  body, SHA-256 + `timingSafeEqual`), list/approve/reject (status-guarded single transaction: alert + change +
  optional attempt-cycle stage date), my alerts (confirm line), `followersOf`.
- API: `http/notifications/*` and `http/exams/exam-alerts.*`. OPS/ADMIN check + audit (`exam_change.approve|reject`)
  happen in the controller. Events go out as BullMQ jobs: `notifications.exam-alert` (jobId `exam-alert-<alertId>`)
  and `exams.date-changed`. Webhook refusals log the request id and a hashed IP, never the secret or the body.
  `domain-error.filter.ts` additions: WEBHOOK_UNAUTHORIZED 401, WEBHOOK_REPLAYED 409, EXAM_CHANGE_ALREADY_REVIEWED 409.
- Env: `CHANGEDETECTION_WEBHOOK_SECRET` (min 32) as `webhookEnv` in `packages/config`, used by the API env, `tools/dev-env.mjs`
  and the test env. It was already in `infra/secrets/.env.example` from BOLT-0015. Header: `x-heymey-webhook-secret`.
- Worker: processors `push.send`, `notifications.exam-alert` (fan-out in the composition root, so no new module dependency),
  `notifications.release-held` (`*/15`, IST). Registry also gets `exams.date-changed` (owner plan, no processor yet).
  `users.deletion` now also removes push tokens.
- `contract.spec.ts`: added `/v1/webhooks/changedetection` to the allow-list for routes without an Idempotency-Key, with a comment.

**Evidence (2026-10-22, local, Docker)**
- `pnpm test:integration`: api 5 files / 50 tests passed (new `notifications.int.spec.ts`: 8 tests: tokens, settings, webhook
  bad secret 401 + nothing stored, replay 409 + one row, 60/min rate limit 429, REVIEWER 403, OPS approve → 1 alert + job +
  audit, second approve 409, reject, ADMIN, follower fan-out dedupe, 10 concurrent alerts → exactly 3 queued); domain 4 files / 31 passed.
- Unit: `notifications.spec.ts` 19, `exam-alerts.spec.ts` 10, worker 13 (5 new). Coverage of the new use-case and domain
  files: exams/application/exam-alerts.ts 94% statements, exams/domain/exam-alerts.ts 100%, notifications/domain/policy.ts 100%;
  the notifications module is 63% from unit tests alone, and the Prisma adapters are covered by the integration suite.
- `pnpm verify`: everything from this bolt is green. The remaining red belongs to other bolts: the contract test lists
  plan/practice/readiness/pyq/packs routes with no controller yet; the domain lint error is in
  `test/modules/exam-hall.fakes.ts:125` (BOLT-0011); the domain typecheck error is in `syllabus.spec.ts` (`topicById`);
  the dart test failed with "No workspace packages matching dart/hm_api" while codegen was rewriting hm_api.

**Follow-ups**
- No transactional outbox table exists. If enqueueing the job fails after approve commits, the alert exists but is not
  fanned out. Architect: add an outbox table, or a sweep that re-publishes alerts that have no SendLog rows.
- Statuses `dropped_quiet` and `dropped_opted_out` were added to the free-text `SendLog.status` (architect: update the schema comment).
- Logout removing the device token (invariant 7) needs a hook in `auth` (other unit). The client can call DELETE today.
- The morning dimming alert (`notifications.morning`) waits for the mastery public API (BOLT-0009).
- The `hasActiveExamHallAttempt` port is wired as "false" until exam-hall exposes it (BOLT-0011).
- The design says 400 for offers without consent, but the existing filter maps CONSENT_REQUIRED to 422. Kept 422; the architect should confirm.
- Founder/devops: put `CHANGEDETECTION_WEBHOOK_SECRET` into the SOPS staging/production env (the API now refuses to boot without it).
- Reviews needed (T2): security (webhook), compliance (alert copy has the confirm line), founder.
