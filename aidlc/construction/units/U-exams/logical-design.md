# Logical design: U-exams

Status: draft

## Use cases (application layer)
| Use case | Trigger (route / event / job) | Ports used | Idempotency key | Authorisation (role) |
|---|---|---|---|---|
| listExams | `GET /v1/exams` | ExamsRepository | — | public |
| getExam | `GET /v1/exams/{code}` | ExamsRepository | — | public |
| checkEligibility | `POST /v1/eligibility/check` (200) | ExamsRepository, Clock | — (pure, nothing stored) | public, 60 / 10 min per IP |
| getMyExams | `GET /v1/me/exams` | ExamsRepository | — | user |
| setMyExams | `PUT /v1/me/exams` (200) | ExamsRepository (one transaction) | Idempotency-Key (platform) | user |
| publishedCodes | Study Map composition (API) | ExamsRepository | — | — |

Engine: `domain/eligibility.ts` (pure). Validation: `domain/my-exams.ts`.

## Contract changes (@heymey/contracts)
None. Implements the BOLT-0001 contract exactly. Errors: EXAM_NOT_FOUND (404), UNDER_18 (422), VALIDATION_FAILED (400).

## Data
No schema change. Reads Exam + EligibilityRule (latest published version per exam); writes UserExamChoice
(`deleteMany` + `createMany` inside `$transaction`).

## Background work
None.

## Client (Flutter)
Eligibility works before sign-in (nothing to sync). My exams needs a connection in Phase 1.

## Flags and LiveOps
None. Eligibility rules are data.

## Failure modes
| Failure | Behaviour | User sees (simple English) |
|---|---|---|
| Under 18 | 422 UNDER_18 | "HeyMey is for 18+. See you on your 18th birthday." |
| Unknown / unpublished exam | 404 EXAM_NOT_FOUND | "We couldn't find that exam." |
| Bad answers / bad choice | 400 VALIDATION_FAILED | "Some details are not right. Please check and try again." |
| Malformed rule JSON in DB | exam skipped from the check, error logged by the repository | (exam not listed) |

## Non-functional budget
p95 ≤ 300 ms: eligibility reads all published exams + their published rules in one query (tens of rows).

## Observability
Default request logs only. Date of birth is never logged.

## Test plan
| Level | Cases | Tool |
|---|---|---|
| Domain unit | invariants 1-10 (age boundaries, IST midnight, communities, relaxations, qualifications, degree subject, PSTM, ranking, published-only) | Vitest + FakeClock |
| Integration | repository on real Postgres; seeder twice; API e2e (list/detail/404, eligibility 200/422/400, my-exams) | Vitest + Testcontainers |

## Bolts
- BOLT-0003: everything above, with U-syllabus and U-content.


---

## Phase 2 extension (BOLT-0008) · draft, awaiting G-D · BOLT-0011 (structure + SEED catalogue), BOLT-0012 (attempt-cycle choice), BOLT-0014 (alerts)

### Use cases
| Use case | Trigger | Ports | Idempotency | Auth |
|---|---|---|---|---|
| examStructure | `GET /v1/exams/{code}/structure` | ExamsRepository | — | public |
| paperForMock (public API) | exam-hall | ExamsRepository (cached) | — | — |
| setMyExams + cycles | `PUT /v1/me/exams` (optional `attemptCycles`) | ExamsRepository | Idempotency-Key | user |
| receiveSiteChange | `POST /v1/webhooks/changedetection` | ChangeRepo, secret from env | (watchUuid, changeId) unique; no Idempotency-Key (machine caller) | public + shared secret, 60/min/IP |
| listChanges | `GET /v1/desk/exam-changes` | ChangeRepo | — | desk + OPS/ADMIN |
| approve / reject | `POST /v1/desk/exam-changes/{id}/approve|reject` | ChangeRepo, AlertRepo, AuditApi, EventPublisher (tx + outbox) | Idempotency-Key + status guard | desk + OPS/ADMIN |
| myExamAlerts | `GET /v1/me/exam-alerts` | AlertRepo + my exam choices | — | user |
| followersOf(examCode) | worker composition | ExamsRepository | — | — |

Approvals are audited, but `audit` is **not** added to `exams.dependsOn`: the API
composition root writes the audit entry around approve/reject (as `roles` does for grants) — no new dependency.

### Contract
`src/http/exams.ts` additions: `Marks`, `PaperType`, `MarkingSection`, `MarkingScheme`, `ExamPaper`, `ExamStage`,
`ExamAttemptCycle`, `ExamStructure`, `ExamAlert(Page)`, `SiteChangeWebhookBody`, `SiteChangeAck`, `ExamChange(Page)`,
`ApproveExamChangeBody`, `RejectExamChangeBody`, `UserExamsBody.attemptCycles` (optional). Errors: WEBHOOK_UNAUTHORIZED,
WEBHOOK_REPLAYED, EXAM_CHANGE_ALREADY_REVIEWED. The webhook is the second `idempotent: false` write: BOLT-0014 adds
`/v1/webhooks/changedetection` to the allow-list in `apps/api/test/contract.spec.ts` (dedupe is by payload key).
Non-breaking: Phase 1 `ExamDetail.pattern` stays.

### Data
`exams.prisma` (ADR-0013) + `ExamWatchChange`, `ExamAlert`; `Exam.familyId`, `UserExamChoice.attemptCycleId` nullable.
Backfill (BOLT-0011 seed, local/staging): families `tnpsc`, `ssc`; one stage/paper/scheme per seed exam from the Phase 1
flat columns, all `SEED - verify`. Contract step (drop flat columns) not before a later /v1-safe window.

### Background work
`exams.watch-change` (exists) is not needed for intake (synchronous store); repurposed in BOLT-0014 to notify Ops of new pending changes (email).

### Failure modes
| Failure | Behaviour | Ops/user sees |
|---|---|---|
| Bad secret | 401, logged with IP hash | — |
| Replay | 409 | — |
| Approve twice | 409 EXAM_CHANGE_ALREADY_REVIEWED | "This change was already reviewed." |

### Security / compliance (T2)
Security review: secret length ≥ 32, constant-time compare, rate limit, no URL fetch from webhook body (SSRF), body size cap 64 KB.
Compliance: alert copy includes the confirm line; no alert without human approval.

### Test plan
Unit: invariants 1–10 (Phase 2 list in domain model). Integration: webhook 202/401/409, approve → one alert + event + audit, reject, desk role 403 for REVIEWER.
