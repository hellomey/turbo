# Logical design: U-mastery

Status: draft (BOLT-0008) · awaiting G-D · implemented by BOLT-0009 (backend)

## Use cases (application layer)
| Use case | Trigger | Ports used | Idempotency key | Authorisation |
|---|---|---|---|---|
| getSummary(userId, examCodes) | `GET /v1/me/mastery` | StateRepo, SyllabusApi (topic ids per exam), ExamsApi via composition (my exams, family titles) | — | user |
| listStates(userId, examCode, since) | `GET /v1/me/topic-states` | StateRepo, SyllabusApi | — | user |
| relightQueue(userId, examCodes) | `GET /v1/me/relight-queue` | StateRepo, SyllabusApi, ContentApi (has published content) | — | user |
| completeLesson | `POST /v1/topics/{topicId}/lesson-complete` | StateRepo, SyllabusApi, Clock | Idempotency-Key (platform) | user |
| startCheck | `POST /v1/topics/{topicId}/checks` | StateRepo, CheckRepo, ContentApi (pick questions), Clock, CSPRNG | Idempotency-Key | user, 120/h |
| submitCheck | `POST /v1/checks/{checkId}/submit` | CheckRepo, ContentApi (grade), StateRepo (tx, rowVersion), Clock, EventPublisher | Idempotency-Key + checkId single-submit | user, 120/h |
| syncStudyActions (dispatcher) | `POST /v1/sync/study-actions` | mastery + PracticeApi (0010) + PlanApi (0012) via API composition, SyncReceipt | per action `clientActionId`; batch Idempotency-Key | user, 120/h |
| runDimming(window) | worker `mastery.dimming` every 15 min | StateRepo (batched, `[dimState, dimSince]` / `nextDueAt` index), Clock | job id = window start | system |
| recomputeRank(userId) | after any ring change | StateRepo, RankRepo | — | system |

Composition: the API controller resolves the user's exam codes from `exams` (as BOLT-0003 does for the Study Map), so
`mastery` keeps `dependsOn: [syllabus, content]`. No new dependency.

## Contract changes (@heymey/contracts) — `src/http/mastery.ts`, `sync.ts`, `routes-study.ts`
- `GET /v1/me/mastery` → `MasterySummary`
- `GET /v1/me/topic-states?examCode&since&cursor&limit` → `TopicStatePage`
- `GET /v1/me/relight-queue` → `RelightQueue`
- `POST /v1/topics/{topicId}/lesson-complete` `LessonCompleteBody` → `TopicState` (TOPIC_NOT_FOUND)
- `POST /v1/topics/{topicId}/checks` `StartCheckBody` → 201 `TopicCheck` (CHECK_NOT_AVAILABLE, GOLD_DAILY_LIMIT, TOPIC_NOT_FOUND)
- `POST /v1/checks/{checkId}/submit` `SubmitCheckBody` → `CheckResult` (CHECK_ALREADY_SUBMITTED, CHECK_EXPIRED)
- `POST /v1/sync/study-actions` `SyncBatchBody` → `SyncBatchResult` (per-action `SYNC_ACTION_TOO_OLD` as `study_log_only`)
- `LampRing` (Phase 1) unchanged; Study Map now fills it. Breaking? **No** (new routes, new error codes only).

## Data
- `mastery.prisma`: `UserTopicState` + `lessonCompletedAt`, `steadyEarnedAt`, `dimSince`, `lastCheckAt`, `rowVersion`
  (all nullable/defaulted); new `TopicCheck`, `RingEvent` (append-only), `UserRank`; enums `CheckKind`, `ActionSource`.
- Migration `20261022061048_phase2_core_study`: expand only (no drops/renames). Safe for the live Phase 1 app, which never reads these.
- Indexes: `[userId, updatedAt]` (incremental sync), `[dimState, dimSince]` + `[nextDueAt]` (scheduler).
- Retention: `RingEvent` kept for the account's life; erased on account deletion (users.deleted → worker).

## Background work
`mastery.dimming` (exists in registry, `*/15 * * * *` IST): batches of 1 000 rows, `updateMany` guarded by state +
`rowVersion`; emits `mastery.lamp_changed`. Metric: lamps dimmed / steady lost per run.

## Client (Flutter)
Drift keeps topic states; Lit/recall/relight checks work offline from packs (answers in pack) and go to the outbox as
`topic_check`; the server re-grades and returns authoritative `topicStates` which replace local rings (§39). Gold
needs a connection. Rank-up screen shows `note`. Lite Mode: static map.

## Flags and LiveOps
All numbers in `packages/domain/src/modules/mastery/domain/config.ts` (`MASTERY_CONFIG.version` stored on checks/rank).
Rank titles are data on `ExamFamily.rankTitles`.

## Failure modes
| Failure | Behaviour | User sees |
|---|---|---|
| Check before its step | 409 CHECK_NOT_AVAILABLE | "This check is not open yet. Finish the step before it first." |
| Gold answers late | counted wrong, `lateAnswersIgnored` | result screen shows the count |
| Double submit | 409 CHECK_ALREADY_SUBMITTED / idempotent replay | same result |
| Scheduler and user write race | rowVersion retry (3x) | nothing |
| No questions for a topic | 409 CHECK_NOT_AVAILABLE + log | as above |
| Sync action > 7 days | `study_log_only` | "Saved as study history. Rings only change for the last 7 days." |

## Non-functional budget
p95 ≤ 300 ms; summary uses one grouped count query per user; topic-states page ≤ 500 rows.

## Observability
Counters: checks started/passed per kind, dimming run rows, steady_lost, sync actions per status. Logs carry no answers text.

## Test plan (coverage ≥ 90 %, §44)
| Level | Cases | Tool |
|---|---|---|
| Domain unit | invariants 1–17, ladder table tests, IST midnight edges, FakeClock | Vitest |
| Acceptance | **7-day fake-clock run**: study, skip 3 days, return → golden light/dim/relight timeline (§43 done-when) | Vitest + FakeClock |
| Integration | repos on real Postgres, scheduler idempotency, rowVersion race, sync accept-once | Testcontainers |
| API | each route: 401, validation, idempotent replay, error codes | supertest |
| Firewall | FW-020…022 | packages/domain/test/firewall |
