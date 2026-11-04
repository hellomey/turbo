# BOLT-0009: mastery: rings, recall ladder, dimming + relight, Career Ladder, offline sync

| | |
|---|---|
| Unit | U-mastery |
| Stories | INT-002-S01, S02, S03, S04, S05, S18 (server side) |
| Risk tier | T1 (90% coverage) |
| Agent | backend |
| Branch / PR | `bolt/BOLT-0009-mastery` · (no commit, per conductor) |
| Status | in review |

## Plan
- Goal: implement the 7 mastery routes declared in `@heymey/contracts` (BOLT-0008) end to end, the
  `mastery.dimming` worker + schedule, and the §43 7-day fake-clock acceptance test.
- Design: `aidlc/construction/units/U-mastery/{domain-model,logical-design}.md`; numbers from
  `packages/domain/src/modules/mastery/domain/config.ts` (PROVISIONAL, D-2026-10-22-10..16).
- Files: `packages/domain/src/modules/mastery/**`, `apps/api/src/http/mastery/**`, `apps/worker/src/processors/mastery-dimming.ts`,
  additive lines in shared files (app.module.ts, tokens.ts, domain-error.filter.ts, worker index/main).
- Additive public-API additions in other modules (no new dependency; mastery already `dependsOn: [syllabus, content]`):
  `syllabus.topicsForExam/topic`, `content.pickQuestions/gradeAnswers`.
- Contract changes: none.
- Tests first: domain invariants 1–17 (FakeClock), acceptance timeline, FW-020..022, Testcontainers repo + HTTP tests.

## Result
- **What changed**
  - Domain `packages/domain/src/modules/mastery/`: `domain/lamp.ts` (ring transitions, IST ladder, dimStep), `domain/check.ts`,
    `domain/rank.ts` (rank/XP pure from ring counts), `domain/dto.ts`; use cases `application/{read,study,sync,dimming,write-lamp}.ts`;
    `infrastructure/prisma-mastery-repository.ts` (one transaction per write, rowVersion guard, single-submit guard, unique
    clientActionId); `index.ts` (`createMasteryModule`, `createMasteryDimming`). Config gained `defaultRankTitles`, `checkTtlHours` (24),
    `dimmingBatch`, `writeRetries`.
  - Additive public API in other modules (no new dependency): syllabus `topicsForExam`, `topic` (+ repo `topicById`); content
    `createQuestionBank` (CSPRNG pick + server grading: `application/question-bank.ts`, `infrastructure/prisma-question-candidates.ts`,
    grading helpers appended to `domain/question.ts`).
  - API `apps/api/src/http/mastery/` (controller + http-module; user's exams via exams public API as LearnerPorts); `MASTERY_API` token;
    registered in app.module.ts; HTTP statuses: TOPIC_NOT_FOUND 404, CHECK_NOT_AVAILABLE 409, CHECK_ALREADY_SUBMITTED 409, CHECK_EXPIRED 409,
    GOLD_DAILY_LIMIT 429, SYNC_ACTION_TOO_OLD 422.
  - Worker: `processors/mastery-dimming.ts`; `mastery.dimming` added to IMPLEMENTED_QUEUES (scheduler upserts the existing */15 IST cron).
  - Firewall: FW-020, FW-021, FW-022 in `packages/domain/test/firewall/mastery-firewall.spec.ts`; MANIFEST updated.
- **Evidence** (2026-10-22, local)
  - Unit: domain 347 passed (mastery 24 unit + 1 acceptance + 3 firewall); worker 16 passed; api 9/10 (only contract.spec fails, listing
    19 routes of BOLT-0010/0012/0013 and content packs; no mastery route is missing).
  - Integration (Testcontainers): domain 44 passed (mastery.int 5), api 56 passed (mastery.int 3). `pnpm test:integration` green.
  - Coverage, mastery module + question bank, unit + integration: statements 97.88%, branches 93.37%, functions 99.12%, lines 98.76%.
  - `pnpm verify`: ports, docs, firewall (12 permanent tests), boundaries green; mastery lint/typecheck green. Red, not from this bolt:
    api contract test (other bolts' routes), `test/modules/exam-hall.fakes.ts` lint error (BOLT-0011), dart codegen/lint/test (hm_api workspace state).
  - §43 acceptance: `packages/domain/test/modules/mastery.acceptance.spec.ts` (study 2 lamps, recall, skip 3 days, return, relight one) matches the golden timeline.
- **Design notes for architect / founder (not blocking)**
  1. The dimming job dims a lamp at its due time, so "recall only on a bright lamp" would make recalls impossible once the 15-min job
     ran. Implemented: a due recall is also accepted while the lamp is *dimming* (pass = bright, like relight); a *dim* lamp needs a relight.
     Please confirm (domain-model invariants 7, 10).
  2. Rank titles: exams' public API does not expose `ExamFamily.rankTitles`; TN titles (§5.2) from config are used, `familyCode` null (R6 follow-up).
  3. Untimed checks expire after 24 h (CHECK_EXPIRED): PROVISIONAL, add to the D-2026-10-22-10..16 list.
  4. Sync: `practice_answer` / `plan_item_status` return `rejected` + FEATURE_PAUSED until BOLT-0010 / 0012; the app must keep those in
     its outbox (tell BOLT-0016). Platform `SyncReceipt` is not written; mastery's unique `RingEvent.clientActionId` is the accept-once guard.
  5. `GET /v1/me/topic-states` returns stored rows only (no row = unlit). Filling Study Map rings from mastery is a follow-up.
  6. Incident: I overwrote BOLT-0011's untracked `content/domain/question.ts` by mistake. I rebuilt it from its users (`QuestionReader`,
     `QuestionWithKey`, `QuestionKeyDto`, `QuestionSourceDto`, `sourceOf`); all tests pass, but BOLT-0011 should check it again.
- **Follow-ups**: rank titles per family (R6); Study Map rings from mastery; relight "can open" rule with billing (Phase 3).
