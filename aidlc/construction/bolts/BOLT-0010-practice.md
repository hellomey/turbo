# BOLT-0010: practice + content routes: sessions, free daily limit, mistakes, drills, PYQ Vault, reports, packs

| | |
|---|---|
| Unit | U-practice (+ Phase 2 `content` routes) |
| Stories | INT-002-S06, S07, S08, S09, S18 (practice_answer sync) |
| Risk tier | T1 (limit logic 90% coverage; S07 limit-sheet copy is T2: compliance + founder) |
| Agent | backend |
| Branch / PR | `bolt/BOLT-0010-practice` · (no commit, per conductor) |
| Status | in review |

## Plan
- Goal: the 9 routes of `@heymey/contracts` `routes-study.ts` "practice + PYQ Vault + content" end to end, and the
  `practice_answer` kind in `POST /v1/sync/study-actions` (API composition, U-mastery logical design "syncStudyActions").
- Design: `aidlc/construction/units/U-practice/{domain-model,logical-design}.md`; numbers from
  `packages/domain/src/modules/practice/domain/config.ts` (PROVISIONAL, D-2026-10-22-17..20).
- Files: `packages/domain/src/modules/practice/**`; additive public API in `content` (practice questions, PYQ, reports,
  packs) and `billing` (Phase 2 entitlement stub = free); `apps/api/src/http/practice/**`, content controller for
  reports/packs; additive lines in app.module.ts, tokens.ts, domain-error.filter.ts, mastery sync dispatcher.
- Contract changes: none.
- Tests first: domain rules (limit, IST reset 23:59 -> 00:00 with FakeClock, offline clamp, mistake loop, PYQ locking),
  use cases with fakes, Testcontainers (40 parallel answers -> exactly 30 counted, replay, PYQ cursor, locked years), HTTP.

## Result
- **What changed**
  - Domain `packages/domain/src/modules/practice/`: `domain/limit.ts` (counted modes, IST reset, offline clamp, decideCount,
    usage), `domain/mistakes.ts` (14-day tally, drill due only when Pro), `domain/pyq.ts` (latest-2-years unlock, keyset cursor,
    locked items without text); `application/{ports,practice-service}.ts` (startSession, answer, acceptOfflineAnswer, usage,
    mistakes, drills, searchPyqs, pyqFacets); `infrastructure/prisma-practice-repository.ts` (ONE transaction per answer:
    `INSERT .. ON CONFLICT DO NOTHING` + `SELECT .. FOR UPDATE` on `PracticeDayCounter(userId, istDay)`, then answer insert,
    counter bump, tally, drill, session close; unique `PracticeAnswer.id` = clientActionId); `index.ts` (`createPracticeModule`).
  - Additive public API, no new module dependency: content `createPracticeContent` / `practiceContent` / `gradeWithKey`
    (`application/practice-content.ts`, `infrastructure/prisma-practice-content-store.ts`: scope, CSPRNG pick, version-answered
    keys, PYQ years/page/subjects, reports, packs); billing `createEntitlementStub` (Phase 2: everyone Free).
  - API: `apps/api/src/http/practice/` (controller + http-module; also hosts `apps/api/src/http/content/questions.controller.ts`
    for reports + packs, pack lock by entitlement via API composition). Tokens PRACTICE_API, PRACTICE_CONTENT_API, ENTITLEMENTS.
    HTTP statuses added: PRACTICE_SESSION_CLOSED 409, QUESTION_NOT_FOUND 404 (PRO_REQUIRED 403 and PRACTICE_DAILY_LIMIT 429 already present).
  - Sync: `POST /v1/sync/study-actions` dispatches `practice_answer` to `PracticeApi.syncAnswer` (mastery controller, API
    composition per U-mastery logical design); no longer FEATURE_PAUSED. `plan_item_status` still FEATURE_PAUSED (BOLT-0012).
- **Evidence** (2026-10-22, local)
  - Unit: `practice.spec.ts` 19 passed (domain total 443 passed in 21 files).
  - Integration (Testcontainers): domain `practice.int.spec.ts` 7 passed (40 parallel answers -> exactly 30 stored + counted,
    10 PRACTICE_DAILY_LIMIT, limit sheet flagged once); api `practice.int.spec.ts` 6 passed (40 parallel HTTP answers -> 30 x 200,
    10 x 429, one `showLimitSheet: true`). `pnpm test:integration` green: api 65/65 (9 files), domain 55/55 (8 files).
  - Coverage (practice + new content/billing files, unit + integration): statements 96.34%, branches 87.27%, functions 98.43%,
    lines 98.37%. Limit logic `practice/domain/limit.ts`: 100%.
  - Contract test: no practice/content route missing; remaining 6 are BOLT-0012 plan routes.
  - Lint + typecheck clean for my files in domain and api. Not mine: `plan/domain/rules.ts` lint (no-useless-assignment) and
    `pnpm boundaries` cycle `exams/application/plan-targets.ts <-> ports.ts` (BOLT-0012).
- **Design notes (architect / founder)**
  1. PRACTICE_DAILY_LIMIT stays **429** (existing mapping), not 403 as the logical design says. Error details carry
     `usage`, `showLimitSheet` (true only on the first refusal of the IST day, §13) and `showProPriceLine: false`.
  2. Offline answers are clamped to [now - 7 d, now] and still count on that day (inv. 5); over that day's limit -> `study_log_only`
     + `PRACTICE_DAILY_LIMIT`. Unlike mastery, there is no "too old" rejection.
  3. Free PYQ practice sessions only draw from unlocked years. A drill session for a Free user is `PRO_REQUIRED` (403).
  4. Seed: SEED-marked practice questions for the 25 seed topics were not added (`packages/db/prisma/seed` is architect-owned);
     tests seed their own SEED rows. Follow-up for architect / content.
  5. `practice.answered` is published through the injected EventPublisher (no-op in the API today, like mastery).
- **Follow-ups**: question seed (above); limit-sheet copy compliance review (S07, T2); readiness/plan consumers of `practice.answered`.
