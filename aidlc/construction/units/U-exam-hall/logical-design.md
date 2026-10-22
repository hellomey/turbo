# Logical design: U-exam-hall

Status: draft (BOLT-0008) · awaiting G-D · implemented by BOLT-0011 (backend). Also implements `GET /v1/exams/{code}/structure` and the SEED catalogue rows (ADR-0013).

## Use cases
| Use case | Trigger | Ports | Idempotency | Auth |
|---|---|---|---|---|
| listMocks | `GET /v1/mocks?examCode` | MockRepo, BillingApi, Clock | — | user |
| startAttempt | `POST /v1/mocks/{id}/attempts` | MockRepo, ExamsApi.paperForMock, ContentApi (questions), AllowanceRepo, BillingApi, Clock | Idempotency-Key; resume rule | user 20/h |
| getAttempt | `GET /v1/mock-attempts/{id}` | AttemptRepo, Clock | — | owner only |
| saveAnswers | `PUT /v1/mock-attempts/{id}/answers` | AttemptRepo, Clock | Idempotency-Key; last write wins | owner 1200/h |
| submit | `POST /v1/mock-attempts/{id}/submit` | AttemptRepo, ExamsApi (scheme), ContentApi (keys), Clock, EventPublisher | Idempotency-Key; single submit | owner |
| report / history | `GET .../report`, `GET /v1/me/mock-attempts` | AttemptRepo, BillingApi | — | owner |
| stateMockInfo | `GET /v1/state-mock-sunday?examCode` | MockRepo, Clock | — | optional |
| statewideRank | `GET /v1/mocks/{id}/statewide-rank` | RankRepo | — | user |
| examStructure (exams) | `GET /v1/exams/{code}/structure` | exams repo | — | public |
| expireAttempts | worker `exam-hall.expire` every 5 min | AttemptRepo, scoring | job window | system |
| publishRanks | worker `exam-hall.publish-ranks` every 10 min (acts at `rankPublishAt`) | AttemptRepo, RankRepo | mockId (insert once) | system |

New dependency `exams` (ADR-0012). `pnpm boundaries` passes.

## Contract
`src/http/exam-hall.ts`, `exams.ts` (Marks, Paper, Stage, Structure, AttemptCycle). Errors: MOCK_NOT_FOUND, MOCK_NOT_OPEN,
MOCK_CLOSED, MOCK_MONTHLY_LIMIT, MOCK_DEADLINE_PASSED, MOCK_ALREADY_SUBMITTED, PAPER_TYPE_NOT_SUPPORTED, RANK_NOT_READY.
Phase 1 `ExamDetail.pattern` stays (non-breaking); new clients read `/structure`.

## Data
`exam-hall.prisma`: `Mock`, `MockAttempt` (exact score `scoreNum/scoreDen`, `schemeVersion`, `istMonth`, `ranked`),
`MockAnswer` (PK attempt+question), `MockAllowanceUse` (PK user+month), `MockRank`. `exams.prisma`: catalogue (ADR-0013).
Expand-only. Index `MockAttempt[mockId, ranked, status]` for the rank job.

## Background work (registry additions, devops/backend in BOLT-0011)
- `exam-hall.expire` `*/5 * * * *` — auto-submit expired attempts.
- `exam-hall.publish-ranks` `*/10 * * * *` — ranks for mocks past `rankPublishAt`, once.

## Client
Exam Hall: no game styling, sounds, animations, haptics, alerts (§9.10). Answers saved locally first, sent in batches
(`PUT answers`) every change/10 s; resume from `GET attempt` with server remaining time. Starting needs a connection (D-…-24).

## Flags and LiveOps
`EXAM_HALL_CONFIG`; State Mock dates/times are `Mock` rows (data, Ops). Pattern data in `exams` (human-checked).

## Failure modes
| Failure | Behaviour | User sees |
|---|---|---|
| App killed | resume via GET | same question, server time left |
| Network lost mid-mock | local saves, flush later; after deadline+grace ignored | "Time is up. Answers saved before the end time are kept." |
| 2nd free mock | 409 MOCK_MONTHLY_LIMIT | message + "Not now" |
| Unverified scheme in production | not served (status draft) | mock not listed |
| Descriptive paper | 409 PAPER_TYPE_NOT_SUPPORTED | "This type of paper is coming later." |

## NFR
p95 ≤ 300 ms; save answers ≤ 100 ms server. State Mock Sunday: smoke concurrency test only (k6 in Phase 4).

## Test plan (coverage ≥ 90 %)
| Level | Cases |
|---|---|
| Domain unit | invariants 1–14; fraction scoring table tests (no negative marking, 1/3, 1/4, sectional limits, attempt-any-N, qualifying-only); TEST-FAMILY fixture |
| Integration | allowance race (2 parallel starts → 1), resume, late saves, expire job, rank job once, ties |
| API | all routes, owner-only access (403 for another user's attempt) |
