# BOLT-0011: Exam Hall (OMR/CBT mocks, State Mock Sunday) + exam-structure catalogue

| | |
|---|---|
| Unit | U-exam-hall, U-exams (Phase 2: structure + SEED catalogue) |
| Stories | INT-002-S10, INT-002-S11 (R1, R4, R6) |
| Risk tier | T1 (study data; no money). Exam patterns are SEED placeholders: "SEED - verify". |
| Agent | backend |
| Branch / PR | `bolt/BOLT-0011-exam-hall` (working tree shared with BOLT-0009/0014; conductor commits) |
| Status | building |

## Plan
Blueprint: §9.9, §9.10, §10.6, §11, §13, §18, §19.4 Q36-Q38, §19.8 Q76, §34.1, §37, §39. ADR-0012, ADR-0013.
Design: `aidlc/construction/units/U-exam-hall/*`, U-exams Phase 2 section. Config: `exam-hall/domain/config.ts`.

Routes (contract from BOLT-0008, no contract change):
`GET /v1/exams/{code}/structure`, `GET /v1/mocks`, `POST /v1/mocks/{mockId}/attempts`, `GET /v1/mock-attempts/{id}`,
`PUT /v1/mock-attempts/{id}/answers`, `POST /v1/mock-attempts/{id}/submit`, `GET /v1/mock-attempts/{id}/report`,
`GET /v1/me/mock-attempts`, `GET /v1/state-mock-sunday`, `GET /v1/mocks/{mockId}/statewide-rank`.

Files:
- `packages/domain/src/modules/exam-hall/**` (domain: fractions, scoring, timer/window rules, ranking; application; prisma adapters)
- `packages/domain/src/modules/exams/**` additive: structure use case + `paperForMock` public API
- `packages/domain/src/modules/content/**` additive, read-only: `questionsForMock(ids)` (raised below)
- `apps/api/src/http/exam-hall/**`, `apps/api/src/http/exams/` (structure route), `domain-error.filter.ts` statuses
- `apps/worker`: `exam-hall.expire`, `exam-hall.publish-ranks`
- `packages/db/prisma/seed/exam-hall.ts`: SEED catalogue (families, stages, papers, schemes) + one placeholder mock

Tests first: domain invariants 1-14 (unit, FakeClock), TEST-FAMILY fixture, integration (allowance race, resume,
late saves, expire job, rank job once, ties), API (all routes, owner-only 404).

## Result
(filled at the end)
