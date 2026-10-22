# Logical design: U-readiness

Status: draft (BOLT-0008) · awaiting G-D · implemented by BOLT-0013 (backend)

## Use cases
| Use case | Trigger | Ports | Idempotency | Auth |
|---|---|---|---|---|
| meter | `GET /v1/me/readiness?examCode` | MasteryApi (coverage by exam), PracticeApi (accuracy, speed), ExamHallApi (last mocks), BillingApi, SnapshotRepo, Clock | — | user |
| trend | `GET /v1/me/readiness/trend` | SnapshotRepo, BillingApi | — | user (Pro) |
| reports | `GET /v1/me/sunday-reports`, `/{id}` | ReportRepo | — | owner |
| buildSundayReports | worker `readiness.sunday-report` `0 8 * * 0` IST | above + ReportRepo | (userId, weekStart) unique | system |
| snapshotNightly | worker `readiness.snapshot` `15 1 * * *` IST (new) | above | (user, exam, day) | system |

Sending the report push: the worker composition root calls `notifications` after the report is stored (readiness does
not depend on notifications). `billing` read goes through the composition root (readiness `dependsOn` unchanged: mastery, practice, exam-hall).

## Contract
`src/http/readiness.ts`. Errors: PRO_REQUIRED, REPORT_NOT_FOUND. Non-breaking.

## Data
`readiness.prisma`: `ReadinessSnapshot` (PK user+exam+day), `SundayReport` (unique user+week). Retention: snapshots 400 days.

## Background work
`readiness.sunday-report` moves to `0 8 * * 0` (D-…-30); new `readiness.snapshot` nightly. Batches of 500 users active in the last 14 days.

## Client
Meter cached in Drift; shows "updated <time>" offline. No overall percentage widget exists.

## Flags
`READINESS_CONFIG`.

## Failure modes
| Failure | Behaviour | User sees |
|---|---|---|
| No evidence | bars null, label not_yet | "Light a few lamps to see your readiness." |
| Report job partial | per-user idempotent, rerun safe | nothing |

## Test plan (≥ 70 %)
Domain: invariants 1–9, label boundary tables. Integration: weekly job twice → one report per user. API: free vs Pro (stubbed entitlement), no-percentage assertion.
