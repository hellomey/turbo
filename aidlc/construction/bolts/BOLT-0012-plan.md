# BOLT-0012: plan (My Plan, Today Card, rebalance, Final Stretch)

| | |
|---|---|
| Unit | U-plan (+ small additive change in U-exams: `attemptCycles`, plan targets; U-syllabus: topic priority) |
| Stories | INT-002-S12, INT-002-S13, R1, R2 |
| Risk tier | T1 (no money, no personal data beyond user id, no game) |
| Agent | backend |
| Branch / PR | `bolt/BOLT-0012-plan` · (no commits in this run, per conductor) |
| Status | in review (2026-10-23) |

## Plan
- Blueprint: §6, §7, §10.5, §10.6 Today, §10.7 Calm, §17.1 step 9, §17.3, §19.2 Q11–Q20, §19.10 Q93–Q97, §39.
- Design: `aidlc/construction/units/U-plan/domain-model.md`, `logical-design.md`. Numbers: `PLAN_CONFIG` (D-2026-10-22-25…28, provisional).
- Routes: GET /v1/me/today, GET/PUT /v1/me/plan, GET /v1/me/plan/days, POST /v1/me/plan/items/{itemId}/status, POST /v1/me/plan/rebalance.
- Also: `UserExamsBody.attemptCycles` stored by `exams`; `plan_item_status` offline sync kind; worker `plan.rebalance` + `exams.date-changed`.
- Tests first: domain invariants 1–11 with FakeClock; Testcontainers integration (domain + API).

## Result
- Routes (6): GET /v1/me/today, GET/PUT /v1/me/plan, GET /v1/me/plan/days, POST /v1/me/plan/items/{itemId}/status, POST /v1/me/plan/rebalance. The contract test lists none of them as missing.
- plan module: domain/days.ts (IST day math), domain/rules.ts (stretch phases, mix + balance dial, 60/40 + 15 multi-exam shares, buildDay, missed days, Today Card), application/plan-service.ts, infrastructure/prisma-plan-repository.ts, and index.ts (PlanApi, planPortsFrom).
- exams: PUT /v1/me/exams `attemptCycles` is now stored (UserExamChoice.attemptCycleId) and checked against the exam's cycles; new public `planTargets`; domain/cycle.ts (nextStageDate, pickCycle). syllabus: TopicRow.priorities (TopicExamTag.priority).
- Offline sync: `plan_item_status` is routed to PlanApi.syncAction (accepted once per clientActionId; older than 7 days = study_log_only).
- Worker: plan.rebalance (02:30 IST) and exams.date-changed are implemented.
- domain-error.filter: PLAN_NOT_FOUND = 404.
- Evidence: unit tests domain 444/444 (plan.spec 48), worker 20/20, api 10/10; integration domain 60/60 (9 files), api 69/69 (10 files); lint, typecheck and boundaries are clean; firewall has 12 permanent tests. Plan coverage from unit tests alone is 86.2% statements (the Prisma adapter is covered by the integration tests).
- Decisions (provisional, for the architect): rolling 14-day horizon, topped up by Today; rebalance runs at most once per IST day unless the user asks; when the starter path has no lamp left, the day falls back to the normal mix; item sizes are in PLAN_CONFIG.itemMinutes; mastery's sync test now expects plan_item_status with an unknown item to return rejected NOT_FOUND.
- Follow-ups: the plan.rebalanced -> welcome-back push is not wired (event published, no consumer); Final Stretch checklist content (D-2026-10-22-26).
