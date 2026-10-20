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
