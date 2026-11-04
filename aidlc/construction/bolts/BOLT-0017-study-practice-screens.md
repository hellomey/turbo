# BOLT-0017: Study app screens (lamp states, Lit/recall/relight/Gold checks, relight queue, practice, mistakes, PYQ Vault, limit sheet)

| | |
|---|---|
| Unit | U-app-study |
| Stories | INT-002-S01, S02, S03, S04, S06, S07, S08, S09 (app side), S18 (sync triggers in the app shell) |
| Risk tier | T1; the free-limit sheet is T2 copy (compliance review + founder approval before merge) |
| Agent | flutter-ui |
| Branch / PR | `bolt/BOLT-0017-study-practice-screens` · not opened (no commits requested) |
| Status | in review |

## Plan
- Goal: the Phase 2 study screens in `dart/hm_features` over the mastery and practice routes (BOLT-0009/0010) and the
  BOLT-0016 outbox.
- Acceptance criteria (blueprint §5.1, §10.6 Practice/recall, §10.7, §10.8, §10.9, §11, §13, §19.4 Q31-Q38, §19.9 Q82, §39;
  D-2026-10-22-19, -20):
  - Lamp states in words on the Study Map (Lit / Steady n of 4 / Gold / Dimming / Dim); rings differ by shape (§10.9).
  - Lesson "I've finished" step records `lesson_complete` in the outbox, then the 3-question Lit check (S01).
  - Recall and Gold checks (S02, S04). Gold is online only and never queued (U-app-shell invariant 5).
  - Relight queue with minutes per lamp (S03).
  - Practice: one question per screen, 48 dp options, instant feedback with explanation and source; "Report" control (S06).
  - Mistake review (why mine was wrong, why the answer is right, which lamp to relight); concept drill locked for Free (S08).
  - PYQ Vault with year/subject/difficulty filters; locked years marked "Pro" before tap (S09, §19.9 Q82).
  - Free-limit sheet: the limit message + "Not now", no price line, no fake urgency, at most once per IST day (S07, §13).
  - Local first (§39): every practice answer, Lit/recall/relight result is written to the outbox before any network call;
    "Will sync when online" and "Couldn't save" states; sync triggers started by the app shell.
- Files: `dart/hm_features/lib/src/{practice,pyq_vault,study_map,lessons}/**`, `dart/hm_core/lib/src/net/hm_api.dart`
  (add mastery + practice calls only), `dart/hm_data` (outbox: mark an entry sent after a direct online success),
  `apps/mobile/lib/src/{router,shell}.dart`, tests + goldens in `dart/hm_features/test`.
- Contract changes: none. The generated `hm_api` models are not used for check/practice results because of the
  nullable-required codegen issue noted in BOLT-0016 (e.g. `CheckResult.rankUp` is nullable in the contract but
  required in the generated Dart); JSON is mapped into feature view models instead.
- Tests first: domain mappers + lamp words; controllers (outbox first, offline fallback, limit sheet once a day,
  Gold not queued); widgets (labels, Not now, no price, Pro markers); goldens dark/light/high-contrast/Calm/200% text.

## Result (2026-10-23)
- What changed
  - `hm_features/practice`: domain models + display rules (`lampWords`, `shouldShowLimitSheet`, `StudyCopy`, `goldTimeLeft`);
    `ApiPracticeRepository` (hand-mapped JSON, see Plan); `StudyRecorder` (outbox first, then online with the same
    client UUID as Idempotency-Key; network failure keeps it queued; server refusal or `PRACTICE_DAILY_LIMIT` removes it;
    Gold never queued); `PracticeController`, `CheckController`, `SyncStatusController`; screens `PracticeScreen`,
    `CheckScreen` (lesson step, Lit/recall/relight/Gold, server-offset Gold countdown), `RelightQueueScreen`,
    `MistakesScreen` (drill locked for Free), `LimitSheet` (message + "Not now", no price, no urgency, once per IST day),
    `WillSyncNote`, `CouldNotSaveNote`, `SyncStatusBar`, `TierChip`.
  - `hm_features/pyq_vault`: repository, filter providers, `PyqVaultScreen` (year/subject/difficulty; locked years show
    "Pro" before tap and hide "Practise these").
  - `study_map`: Lite list shows lamp state in words; `StudyActionsRow` (Relight first, then Practise, Mistakes, PYQ Vault).
  - `lessons`: "I've finished" → Lit check (records `lesson_complete`, nudges sync).
  - `hm_core` `HmApi`: mastery + practice + PYQ + question report calls (additive). `hm_data` `OutboxRepository.markHandled`.
  - `apps/mobile`: routes `/check/:topicId/:kind`, `/relight`, `/practice/:examCode`, `/mistakes`, `/pyq/:examCode`;
    `AppShell` starts the BOLT-0016 sync triggers and shows the outbox note.
  - Renamed to `PracticeMistakeView` to avoid a clash with BOLT-0019's `MistakeView`.
- Lamp sheet (2026-10-23, coordinator follow-up): `StudyMapTab(onStartCheck:)` opens a lamp sheet from
  `GET /v1/me/topic-states` `nextCheck` (`HmApi.listMyTopicStates`, `nextChecksProvider`, rule `topicActions`):
  "Start recall" when recall is due, "Try Gold" when Lit or above (not Gold yet), "Relight" when dimming; Gold disabled
  offline with "Gold needs a connection…". 5 new tests; hm_features suite 162 pass.
- Evidence (2026-10-23)
  - `node tools/flutter-test-all.mjs`: all packages pass (hm_features 110 incl. 23 new practice tests + 17 new goldens).
  - Goldens `test/goldens/study_*`: practice, relight, mistakes, pyq, limit_sheet in dark/light/high-contrast; practice 200% text;
    Study Map Lite with lamp states at 200% text in high contrast.
  - `flutter build apk --debug` in apps/mobile: built.
  - `pnpm --filter @heymey/dart lint`: **fails only on `dart format`** of files owned by a parallel bolt
    (`alerts/*`, `profile_tab.dart`, `today_tab.dart`) and an unused import in `plan_test.dart`; every BOLT-0017 file is
    formatted and analyzer-clean. Re-run after that bolt formats its files.
  - `graphify update .` run.
- Follow-ups
  - hm_design: `HmPrimaryButton`/`HmSecondaryButton` Semantics are not containers and `Card` merges children, so buttons in
    a row/card merge into one screen-reader node. Worked around locally (`Semantics(container: true)`, buttons outside cards);
    fix in hm_design in a later bolt (golden-neutral, may change semantics tests).
  - Generated `CheckResult.fromJson` still asserts/force-unwraps `rankUp` (nullable in the contract) after the template
    change: hm_api not regenerated or template not covering nullable `$ref`. Hand mapping kept until fixed.
  - Calm Mode Today placement of Relight is BOLT-0018. Lite: no feedback animations are used.
  - Compliance + founder review of limit-sheet copy (T2, D-2026-10-22-19).
