# BOLT-0009: mastery: rings, recall ladder, dimming + relight, Career Ladder, offline sync

| | |
|---|---|
| Unit | U-mastery |
| Stories | INT-002-S01, S02, S03, S04, S05, S18 (server side) |
| Risk tier | T1 (90% coverage) |
| Agent | backend |
| Branch / PR | `bolt/BOLT-0009-mastery` · (no commit, per conductor) |
| Status | building |

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
(filled at the end of the bolt)
