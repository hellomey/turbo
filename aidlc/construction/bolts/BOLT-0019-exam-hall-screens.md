# BOLT-0019: Exam Hall app screens (mock list, start, OMR/CBT, resume, submit, report, State Mock Sunday)

| | |
|---|---|
| Unit | U-app-exam-hall |
| Stories | INT-002-S10, INT-002-S11 (app side; readiness S14/S15 screens come in a later bolt) |
| Risk tier | T1 (report lock copy touches an offer: compliance review before merge) |
| Agent | flutter-ui |
| Branch / PR | `bolt/BOLT-0019-exam-hall-screens` · not opened (no commits requested) |
| Status | in review |

## Plan
- Goal: the Exam Hall in `dart/hm_features/lib/src/exam_hall` over the exam-hall routes that already work on the server
  (BOLT-0011), the generated `hm_api` models, and the BOLT-0016 local database.
- Acceptance criteria (INT-002-S10/S11, blueprint §10.6 Exam Hall, §9.10, §19.8 Q76, §13, §39, D-2026-10-22-19/22/23/24):
  - Mock list with Free/Pro shown before tap (§19.9 Q82); monthly allowance line.
  - Starting needs a connection (D-2026-10-22-24); the server issues start time and deadline (§34.1).
  - Answer mode (OMR bubble sheet / CBT palette with mark-for-review) comes from the paper's answer mode in
    `GET /v1/exams/{code}/structure`, not from the exam name (S10 change 2026-10-22). `written`/descriptive is refused.
  - Countdown = server `deadlineAt` minus (local clock + server offset from `serverNow`); never a local timer as truth.
  - Answers are written to the phone first (hm_data `mock_answers`), then sent with `PUT answers`; failed sends stay queued.
  - Resume after the app is killed: active attempt id is kept on the phone; `GET attempt` restores answers and time.
  - Submit asks for confirmation; time up submits on the server side (the app shows the line from the logical design).
  - Report: score, sections, mistakes. Full report locked for Free users with "Not now", no price line (D-2026-10-22-19).
  - State Mock Sunday card (§9.9, D-2026-10-22-23).
  - Exam Hall: no game styling, sounds, animations, haptics or alerts (§10.6, §9.10).
- Files: `dart/hm_features/lib/src/exam_hall/**`, `dart/hm_core/lib/src/net/hm_api.dart` (exam-hall routes),
  `dart/hm_data` (mock answer store), `apps/mobile/lib/src/router.dart` (routes), tests + goldens in `dart/hm_features/test`.
- Contract changes: none.
- Tests first: domain (countdown, answer mode), controller (local-first save, queue, resume, submit), widgets
  (labels, Not now, no price), goldens dark/light/high-contrast + 200% text.

## Result
- What changed:
  - `dart/hm_features/lib/src/exam_hall/` domain (models, server-offset countdown, answer mode from paper, State Mock phases,
    copy), data (`ApiExamHallRepository` parsing generated `hm_api` models), application (`ExamHallController`: start needs
    connection, local-first save + queue + 10 s retry, resume, single submit with stable key, report), presentation
    (mock list + State Mock Sunday card, start screen with "Not now", OMR sheet, CBT with palette + mark-for-review,
    submit confirmation, report with blurred locked preview + "Not now", no price line). No transitions/sounds/haptics.
  - `hm_core` `HmApi`: exam-hall routes. `hm_data`: schema v2 (`mock_answers`, `kv`), `MockAnswerStore` (Drift + memory),
    `mockAnswerStoreProvider`. `TodayTab` "Open Exam Hall"; mobile route `/exam-hall`.
- Evidence: `exam_hall_test.dart` 21 tests, `exam_hall_golden_test.dart` 14 goldens (list/CBT/OMR/locked report x
  dark/light/high contrast, list Calm, CBT 200%), `hm_data/test/mock_answer_store_test.dart`. `node tools/flutter-test-all.mjs`
  exit 0; `flutter build apk --debug` built. `pnpm --filter @heymey/dart lint`: exit 1 only because BOLT-0017's in-progress
  `practice/**` files are not yet `dart format`ted; BOLT-0019 files format clean and analyze clean (earlier full run: no issues).
- Follow-ups: compliance review of the locked-report copy (T1 offer text); readiness screens (S14/S15) in a later bolt;
  mistakes linked to lamps need topic names from the report; Lite Mode needs no change (no animations here).
- Decisions: none new (uses D-2026-10-22-19/22/23/24).
