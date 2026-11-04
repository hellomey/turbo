# BOLT-0020 QA review: INT-002 Phase 2 (bolts 0008–0019, 0021–0022)

Reviewer: `qa` · Date: 2026-11-04 · Blueprint §26.1, §43 (Week 2), §44, §45, §39

**Verdict: pass with findings** (two checks blocked because Docker Desktop's engine was not running. Re-run them before G-C.)

## Runs

| Run | Result |
|---|---|
| `pnpm verify` | ports, docs, firewall and boundaries pass. `turbo lint typecheck test --continue`: 37/39. **Fails**: `@heymey/dart#codegen` (Docker not running) and `@heymey/domain#test` (Q-1) |
| `pnpm test:integration` | **Blocked**: `//./pipe/dockerDesktopLinuxEngine` is missing and Testcontainers cannot start (9/9 domain int files are skipped) |
| `flutter test` per member | hm_design 26, hm_core 21, hm_data 28, hm_features 173, hm_desk 4, mobile 2, desk 1: **all pass**. hm_api and hm_games have no tests |

## Coverage (domain unit run, v8; Prisma adapters are covered only by integration)

| Module | Lines | Branches | Target |
|---|---|---|---|
| exam-hall (application + domain, before) | 98.9 | 86.0 | 90 |
| **exam-hall (application + domain, after the new tests)** | **100** | **95.4** | 90 ✅ |
| mastery (whole module, unit only) | 82.7 | 79.5 | 90: application/domain ≥ 85% branches; the gap is the Prisma adapters and needs the integration run |
| practice / plan / readiness / notifications / exams / syllabus / users | 74.5 / 87.3 / 89.8 / 70.9 / 74.3 / 62.2 / 75.4 | 72.1 / 79.4 / 84.3 / 83.7 / 68.8 / 66.7 / 65.1 | 70: syllabus and users are below on unit only. Confirm with the integration run |

Added `packages/domain/test/modules/exam-hall.branches.spec.ts` (5 tests). It covers the lost finish race (no duplicate event, saves past grace ignored), expire batching at 200 plus the no-progress stop, rank lookups (no publish time, before publish, unranked user → NOT_FOUND), report mistakes with a missing key or no why-wrong text, and the Prisma factory branch.

## Checklist

- **§43 Week-2 7-day fake-clock test**: present and passing. `packages/domain/test/modules/mastery.acceptance.spec.ts` ("study, skip 3 days, return: light → dim → relight").
- **Offline §39**: tested. `dart/hm_data/test/outbox_test.dart` and `pack_and_store_test.dart` cover order, dedup and rejected items. Exam-hall cases cover offline last-write-wins by `clientAt`, late and ignored saves, and the resume race. Feature fakes cover practice and plan offline.
- **Concurrency**: tests exist for all three, but they were **not run** (Docker). 30-a-day: `packages/domain/test/modules/practice.int.spec.ts:68` and `apps/api/test/integration/practice.int.spec.ts:115`. Notification budget: `apps/api/test/integration/notifications.int.spec.ts:268`. Mock starts: `packages/domain/test/modules/exam-hall.int.spec.ts:119,126`.
- **Goldens**: light, dark and high contrast exist for most screens. Gaps are in Q-3.
- **Story traceability**: only S03, S10, S12 and S16 are named by ID in tests. By behaviour, every story has some test except **S06 (practice/recall session as a story-level flow; no test is named for it)**. S05 (Career Ladder) and S13 (Final Stretch) each have only 1–2 tests. See Q-4.

## Findings

| Id | Sev | Where | Finding | Owner |
|---|---|---|---|---|
| Q-1 | High (blocks verify) | `packages/domain/src/modules/audit/index.ts` (uncommitted change) vs `packages/domain/test/modules/audit.spec.ts` "public API is write-only" | The in-flight change adds `recordIn` to the audit API, and the guard test expects only `record`. Earlier today the suite was green at 444/444. Either update the guard to allow `recordIn` (it is still write-only) or drop the method. | backend / security (whoever is editing audit) |
| Q-2 | Medium | `packages/domain/src/modules/exam-hall/application/attempts.ts:111-113` | The in-loop `ignored` branch can only be reached when a concurrent closer wins the finish race (`settle` already expires the attempt past grace). It is now covered by the race test. Confirm that this is intended, or simplify it. | backend |
| Q-3 | Medium | `dart/hm_features/test/goldens/` | Missing goldens: **200% text** for alert_settings, exam_alerts, eligibility_result, exam_hall_list/omr/report_locked, my_plan, study_mistakes/pyq/relight, study_limit_sheet and sunday_report. **High contrast** for eligibility_result. **Calm** exists only for today and exam_hall_list. No Desk goldens. | flutter-ui |
| Q-4 | Low | tests across the repo | Acceptance-criterion test names rarely cite the story ID (16 of 20 stories are not cited). S06 has no story-level test. Add `INT-002-Sxx` to the test names so the gate can trace them. | backend, flutter-ui |
| Q-5 | Blocker for G-C (environment) | — | Integration suite, concurrency tests, Prisma-adapter coverage and `dart` codegen check were not run because Docker was down. Re-run `pnpm test:integration` and `pnpm verify` with Docker up before G-C. | conductor / devops |
