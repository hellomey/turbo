# BOLT-0013: readiness: Readiness Meter, trends, Sunday Report (template text)

| | |
|---|---|
| Unit | U-readiness |
| Stories | INT-002-S14, INT-002-S15 (server side) |
| Risk tier | T1 (70% coverage) |
| Agent | backend |
| Branch / PR | `bolt/BOLT-0013-readiness` · (no commit, per conductor) |
| Status | in review |

## Plan
- Goal: the 4 readiness routes declared in `@heymey/contracts` (BOLT-0008) end to end, the `readiness.sunday-report`
  worker job (moved to `0 8 * * 0` IST, D-2026-10-22-30), labels per D-2026-10-22-29 (TN-only, Q27).
- Design: `aidlc/construction/units/U-readiness/{domain-model,logical-design}.md`; numbers from `READINESS_CONFIG`.
- Files: `packages/domain/src/modules/readiness/**`, `apps/api/src/http/readiness/**`, `apps/worker/src/processors/readiness.ts`,
  additive lines in shared files (app.module.ts, tokens.ts, domain-error.filter.ts, worker registry/index/main).
- Reads other modules only through public APIs: mastery (summary, topicStates + additive `createMasteryActivity`),
  exam-hall (history, report). Practice (BOLT-0010, in parallel) and billing (Phase 3) enter as ports filled by the composition root.
- Contract changes: none.
- Tests first: domain invariants 1–9 (label boundary tables, no overall percentage, copy test), Testcontainers repo +
  job-twice idempotency, HTTP free vs Pro.

## Result
- **What changed**
  - Domain `packages/domain/src/modules/readiness/`: `domain/meter.ts` (bars, floor-rounded percents, top-down labels,
    full-mocks badge, template suggestions, free-tier locking), `domain/report.ts` (IST Monday week, short/full report body,
    `FORBIDDEN_REPORT_WORDS`), `application/{ports,meter,reports}.ts`, `infrastructure/prisma-readiness-repository.ts`,
    `index.ts` (`createReadinessModule`, `NO_PRACTICE_EVIDENCE`, `READINESS_FREE_FOR_EVERYONE`). Config gained
    `labelledConductingBodies` (TNPSC, TNUSRB, TRB: Q27 TN-only), `mockHistoryScan`, `sundayReport.activeWithinDays/batchSize`, `snapshotRetentionDays`.
  - Additive public API in mastery (readiness already `dependsOn` mastery): `createMasteryActivity` →
    `activeUserIds` (users with RingEvent in a window, keyset) and `weekCounts` (lit / recall_pass / gold / relight in a window),
    new file `mastery/infrastructure/prisma-mastery-activity.ts`. Read-only.
  - API `apps/api/src/http/readiness/` (controller + http-module; exam facts from the exams public API in the composition
    root); `READINESS_API` token; app.module registration; `PRO_REQUIRED: 403` in domain-error.filter.ts (REPORT_NOT_FOUND 404 already there).
  - Worker: `processors/readiness.ts`; registry cron `0 6 * * 0` → `0 8 * * 0` (concurrency 1). The scheduler upserts with
    `tz: BUSINESS_TIMEZONE` (Asia/Kolkata), so this is 08:00 IST. Added to IMPLEMENTED_QUEUES. After each new report the
    worker queues a `study` push via notifications (`templateKey readiness.sunday_report`, dedupe `sunday-report:<id>`).
- **Evidence** (2026-10-22, local)
  - Unit: domain readiness 30 passed (domain total 441); worker 18 passed (readiness 2).
  - Integration (Testcontainers): domain `readiness.int.spec.ts` 4 passed (domain total 55); api `readiness.int.spec.ts` 3 passed
    (api total 65). `pnpm test:integration` green (11/11 tasks).
  - Contract test: no readiness route listed any more; only the 6 plan routes of BOLT-0012 remain.
  - Coverage readiness module: unit only 89.82% stmts / 84.3% branches / 89.78% lines; integration only 76.22% stmts (repository
    + mastery activity covered there). Target 70% met.
  - Lint + typecheck clean for domain, api, worker in my files. Red, not from this bolt: lint in `content/infrastructure/prisma-practice-content-store.ts`
    (BOLT-0010) and `plan/domain/rules.ts` (BOLT-0012); boundaries violation `exams/application/ports.ts → plan-targets.ts` (BOLT-0012).
- **Design notes for architect / founder (not blocking)**
  1. Invariant 9 says non-TN exams show bars *without* a label, but `ReadinessLabel` is not nullable. Implemented: label `not_yet` +
     suggestion "Labels for this exam come later. Your bars are real." Architect: make `label` nullable (non-breaking for readers?) or confirm.
  2. Practice (Speed bar, answers/accuracy/study minutes in the report) comes through the `PracticeStats` port; until BOLT-0010
     exposes stats the composition roots pass `NO_PRACTICE_EVIDENCE` (bars null, report counts 0). Wire in a follow-up.
  3. Billing: `READINESS_FREE_FOR_EVERYONE`, so trend is PRO_REQUIRED (403) for everyone and every report is `short` until Phase 3.
  4. "Active user" = any mastery RingEvent in the last 14 days (no other module exposes activity yet).
  5. Snapshots are written when the meter is read; the nightly `readiness.snapshot` job from the logical design is not built
     (trend days without a read are absent). Follow-up bolt.
  6. Memory counts lamps that are Steady and not `dim` (a `dimming` lamp still counts). Confirm.
  7. If the push enqueue fails after a report is stored, the rerun does not re-send (report exists): counted as `failed`.
- **Follow-ups**: nightly snapshot job + 400-day retention GC; practice stats wiring after BOLT-0010; billing entitlements (Phase 3);
  nullable label for non-TN exams (architect).
