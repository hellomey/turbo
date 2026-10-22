# BOLT-0014: Notifications (tokens, budget, quiet hours, sender) + Exam Alerts (webhook intake, Desk approval)

| | |
|---|---|
| Unit | U-notifications, U-exams (Exam Alerts extension) |
| Stories | INT-002-S16, INT-002-S17 |
| Risk tier | T2 (S17: official data correctness, public webhook) |
| Agent | backend |
| Branch / PR | `bolt/BOLT-0014-notifications-exam-alerts` · (no commit: conductor opens the PR) |
| Status | building |

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
(filled at the end)
