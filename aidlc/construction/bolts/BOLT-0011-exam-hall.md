# BOLT-0011: Exam Hall (OMR/CBT mocks, State Mock Sunday) + exam-structure catalogue

| | |
|---|---|
| Unit | U-exam-hall, U-exams (Phase 2: structure + SEED catalogue) |
| Stories | INT-002-S10, INT-002-S11 (R1, R4, R6) |
| Risk tier | T1 (study data; no money). Exam patterns are SEED placeholders: "SEED - verify". |
| Agent | backend |
| Branch / PR | `bolt/BOLT-0011-exam-hall` (working tree shared with BOLT-0009/0014; conductor commits) |
| Status | in review (2026-10-22) |

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
### What changed
- `exam-hall` module built: `domain/` (exact fractions, scoring per scheme section incl. "answer any N", window/deadline/grace
  rules, IST month, next 1st/3rd Sunday, ranking with shared ties + whole-number percentile), `application/` (list, start/resume,
  get, save answers, submit, report, history, State Mock info, statewide rank, expire job, publish-ranks job),
  `infrastructure/` (Prisma repo with per-(user, mock) advisory lock, allowance PK race guard, answer upsert where newer
  `clientAt` wins under a row lock, insert-once ranks; exams paper adapter).
- `exams` (additive): `createExamCatalogueModule` → `structure(code)`, `paperForMock(paperId, version)`; `domain/structure.ts`.
- `content` (additive, read-only, outside my unit, please review): `createQuestionReader` (latest published version + server-only key).
  BOLT-0009 later shares the same file.
- API: `apps/api/src/http/exam-hall/*`, `http/exams/exam-structure.controller.ts`; tokens `EXAM_HALL_API`, `EXAM_CATALOGUE_API`;
  `app.module.ts` import; `domain-error.filter.ts` statuses (MOCK_NOT_FOUND 404, MOCK_* / PAPER_TYPE_NOT_SUPPORTED / RANK_NOT_READY 409, REPORT_NOT_FOUND 404).
- Worker: `exam-hall.expire` (*/5) and `exam-hall.publish-ranks` (*/10) in registry, implemented list and `main.worker.ts`.
- Seed: `packages/db/prisma/seed/exam-hall.ts` (registered in `seed.ts`): families tnpsc/ssc, one stage/paper/scheme/section
  + attempt cycle per seed exam, all copied from the Phase 1 SEED rows and labelled "SEED - verify" (verifiedAt null →
  `verified: false`); one 10-question PLACEHOLDER mock per launch exam. No real exam facts were added.

### Evidence
- Unit: `exam-hall.spec.ts` 36, `exam-structure.spec.ts` 4, worker `exam-hall.spec.ts` 2 tests.
- Integration (Testcontainers): domain `exam-hall.int.spec.ts` 8 (TEST-FAMILY end to end, allowance race, resume race,
  late saves, expire job, rank job once + ties, descriptive refusal, seed idempotent); API `exam-hall.int.spec.ts` 3 (all 10 routes, owner-only 403, idempotency).
- `pnpm test:integration`: api 56/56, domain 44/44 passed. `pnpm verify`: all green except `contract.spec` "every contract route is
  implemented" which lists only other bolts' routes (practice, plan, readiness, pyq, content packs, reports).
- Coverage (unit + integration, BOLT-0011 files): exam-hall domain 100 % lines, application 98.8 % lines / 96.1 % stmts,
  infrastructure 98.8 % lines; overall 91.9 % lines, 89.3 % stmts, 83.5 % branches (incl. shared content files).

### Decisions / deviations (need architect or founder)
1. **Negative scores vs contract**: `Marks.numerator` is `min(0)`, but negative marking can make a total negative. The API
   sends `score` = 0/1 when negative and the exact signed value in `scoreDisplay`. Architect: allow signed numerators (or add `negative: boolean`).
2. **Report before submit**: contract says 409 "Not submitted" but there is no code; using `REPORT_NOT_FOUND` (404). Architect: add `MOCK_NOT_SUBMITTED`.
3. Another user's attempt → 403 FORBIDDEN (design test plan); unknown attempt → 404 NOT_FOUND.
4. `StartMockBody.mode` must equal the paper's mode, else 400 (mode comes from the paper, R4).
5. Answers are "late" if server time OR `clientAt` is after the deadline; ignored after deadline + 120 s grace.
6. A second attempt of the same State Mock is never ranked. Late joiners (after `lateJoinUntil`) practise unranked until `closesAt`.
7. Percentile = floor(100 × (N − rank + 1) / N) (share at or below you; top = 100).
8. Billing not built: everyone free (`FREE_FOR_EVERYONE`), full report locked. No event bus yet: API logs event type + ids;
   `exam_hall.mock_submitted` / `rank_published` payloads carry ids only. Mastery ring effects are left to mastery consuming the event.

### Follow-ups
- Track B: real, human-verified patterns for every exam (replace SEED rows). Ops: State Mock Sunday `Mock` rows.
- Branch/commit: shared working tree; conductor commits as `feat(exam-hall): ... [BOLT-0011]`.
