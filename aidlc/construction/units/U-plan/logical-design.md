# Logical design: U-plan

Status: draft (BOLT-0008) · awaiting G-D · implemented by BOLT-0012 (backend)

## Use cases
| Use case | Trigger | Ports | Idempotency | Auth |
|---|---|---|---|---|
| putPlan | `PUT /v1/me/plan` | PlanRepo, ExamsApi (my exams + attempt cycles + dates), SyllabusApi (topics, priority), MasteryApi (states), Clock | Idempotency-Key | user 30/h |
| getPlan / days | `GET /v1/me/plan`, `/v1/me/plan/days` (≤ 62 days) | PlanRepo | — | user |
| today | `GET /v1/me/today` | PlanRepo, MasteryApi (rank, relight queue), Clock | — | user |
| updateItem | `POST /v1/me/plan/items/{id}/status` | PlanRepo, StudyLogRepo | Idempotency-Key | owner 300/h |
| rebalance | `POST /v1/me/plan/rebalance`; worker `plan.rebalance` 02:30 IST | PlanRepo, MasteryApi, ExamsApi, Clock | job = istDay+userId | user 10/h / system |
| onDateChanged | event `exams.date_changed` (worker) | PlanRepo, ExamsApi | event id | system |
| logStudy | sync dispatcher (lesson_complete, old actions), mastery events via composition | StudyLogRepo | clientActionId unique | system |

Dependencies: `syllabus`, `mastery`, `exams` (declared). No new ones.

## Contract
`src/http/plan.ts`: `Plan`, `PlanExam` (+ `attemptCycleId`), `PlanItem`, `PlanDays`, `TodayScreen`. Errors: PLAN_NOT_FOUND.
`UserExamsBody.attemptCycles` (optional, additive) lets the app choose cycles (implemented by BOLT-0012 in `exams`).

## Data
`plan.prisma`: `Plan`, `PlanExam`, `PlanItem`, `StudyLog` (append-only). `syllabus.prisma`: `TopicExamTag.priority`.
`exams.prisma`: `UserExamChoice.attemptCycleId`. Expand-only. Items generated for a rolling 14-day horizon (retention: 180 days).

## Background work
`plan.rebalance` (exists, `30 2 * * *` IST); `plan.date-changed` (event-driven, new, BOLT-0012).

## Client
Plan + items in Drift; item status via outbox `plan_item_status`. Today from cache when offline. Calm Mode Today:
Today Card, Study, Relight only. Q22: no check-in/lucky-game tiles.

## Flags
`PLAN_CONFIG`. Final Stretch checklist content = content items (D-…-26).

## Failure modes
| Failure | Behaviour | User sees |
|---|---|---|
| No plan | 404 PLAN_NOT_FOUND; Today `hasPlan=false` | "Set up your plan first." |
| No exam date | days left null → normal phase, no stretch | plan without countdown |
| Date change | rebuild future days | "Your exam date changed. We updated your plan." |

## NFR
Today p95 ≤ 200 ms (one plan read + mastery summary cache).

## Test plan (≥ 70 %)
Domain: invariants 1–11 with FakeClock (weekday/weekend, phase boundaries 91/90/61/60/31/30/8/7). Integration: rebalance
idempotent per day; date change; API routes.
