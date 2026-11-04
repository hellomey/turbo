# BOLT-0018: Plan, Today, rank bar, Readiness, Sunday Report and Exam Alerts app screens

| | |
|---|---|
| Unit | U-plan, U-readiness, U-notifications (app side) |
| Stories | INT-002-S12, S13 (stretch chip only), S14, S15, S16, S17 (list only), S19, S20 |
| Risk tier | T1 (offers opt-in is consent-gated on the server; no paywall on these screens) |
| Agent | flutter-ui |
| Branch / PR | `bolt/BOLT-0018-plan-readiness-alerts-screens` · not opened (no commits requested) |
| Status | in review |

## Plan
- Goal: the last Phase 2 app screens over routes that already work on the server (BOLT-0009/0010/0014 era):
  - Today (§10.6 Today, S12): rank badge + XP bar (Career Ladder) at the top, one Today Card (plan item) with one primary
    action, "Relight N · M min", pocket sessions 5/10/15 min, welcome-back line, Final Stretch chip. The Study Map card
    and the Exam Hall button stay (the Exam Hall button is not removed).
  - My Plan (S12): 14 days from the server's IST day, item status (pending / done / skipped / moved), mark Done/Skip
    through the hm_data outbox (`plan_item_status`, §39), "Rebalance my plan" (online, Idempotency-Key §34.3).
  - Readiness Meter (S14, §19.5 Q46): label + Coverage and Memory bars with evidence; Exam performance and Speed shown
    locked as Pro (no paywall, no price). No overall percentage anywhere.
  - Sunday Report list + detail (S15): short (free) / full (Pro); text comes from the server only.
  - Exam Alerts list (S17) with "Open official notice" + the server's confirm line; alert settings (S16): study
    reminders, exam alerts, offers (opt-in), quiet hours, alerts per day (0–3). Settings change needs a connection.
  - Push token registration behind `PushTokenSource`; Firebase is not set up, so `NoopPushTokenSource` (no token, no call).
  - Calm Mode (§10.7, S19): Today shows Today Card, Study, Relight only (rank bar and pocket sessions hidden).
    Lite Mode (§10.8, S20): no animation on these screens (plain progress bars, no transitions).
- Files: `dart/hm_features/lib/src/{plan,readiness,alerts,today,profile}`, `dart/hm_core/lib/src/net/hm_api.dart`
  (append routes), `apps/mobile/lib/src/{router,shell}.dart` (append routes/registration), tests + goldens.
- Contract changes: none. `dart/hm_api` not edited.
- Tests first: domain (rank progress, status override, labels), controller (outbox write + override, rebalance,
  settings save), widgets (Calm Today, locked bars, alerts), goldens (dark/light/high contrast, Calm, 200% text).

## Result (filled when the PR is ready)
- What changed
  - `dart/hm_core/lib/src/net/hm_api.dart`: appended plan (today, days, rebalance), readiness (meter, Sunday
    Reports), alerts (exam alerts, alert settings, push token register/delete) calls. Nothing else touched.
  - `dart/hm_features/lib/src/plan/**` (new layers): models, `ApiPlanRepository`, `PlanController` (mark → hm_data
    outbox `plan_item_status` + local override + sync nudge; rebalance with Idempotency-Key), `todayViewProvider`,
    `planDaysViewProvider` (14 days from the server's IST day), `MyPlanScreen`, `PlanCard`, `RankBar`.
  - `dart/hm_features/lib/src/readiness/**`: `ReadinessScreen` (label + Coverage/Memory bars with evidence, Lit/Steady/Gold
    detail, Exam performance/Speed locked "Pro", no overall %), `SundayReportListScreen`, `SundayReportScreen`.
  - `dart/hm_features/lib/src/alerts/**`: `ExamAlertsScreen` (official link + confirm line, "Show older alerts"),
    `AlertSettingsScreen` (exam alerts, study reminders, offers opt-in, 0–3 per day, quiet hours, morning time; saved at
    once, restored on failure), `PushTokenSource` + `NoopPushTokenSource` + `PushRegistrar`.
  - `today_tab.dart`: `TodayTab` is now a ConsumerWidget over a layout-only `TodayBody`; the Study Map card and the
    Exam Hall button stay (keys unchanged). Plan section appears only when `onStartItem` is wired (keeps Phase 1 callers).
  - `profile_tab.dart`: optional links to Readiness, Sunday Reports, Exam Alerts, Alert settings.
  - `apps/mobile`: routes `/plan`, `/readiness`, `/reports`, `/reports/:id`, `/alerts`, `/alert-settings`;
    `planItemRoute()` maps a Today Card item to lesson/check/relight/practice/PYQ/Exam Hall/mistakes; the shell calls
    the push registrar (no-op).
- Evidence: `test/plan_test.dart` (26 tests: domain, outbox write, 14-day window, rebalance key, Today normal/Calm,
  My Plan, readiness locked bars, reports, alerts, settings failure, push no-op, 200% text on 7 screens);
  `test/plan_golden_test.dart` (21 goldens: today, my_plan, readiness, sunday_report, exam_alerts, alert_settings ×
  dark/light/high contrast + today_calm, today_large_text, readiness_large_text). `flutter analyze` clean;
  `node tools/flutter-test-all.mjs` green; `flutter build apk --debug` built; `graphify update .` run.
  `pnpm --filter @heymey/dart lint` fails only on `dart format` of BOLT-0017's `practice_providers.dart` and
  `study_rules.dart` (in-progress parallel bolt; not edited here).
- Decisions (bolt-local, no founder question):
  - Calm Mode Today keeps the Exam Hall button (it is study, not competition, and Calm users would otherwise have no
    way in); rank bar, pocket sessions, Final Stretch chip and My Plan link are hidden. Calm also bumps Today's text
    ×1.15 (§10.7 "bigger text").
  - Lite Mode: these screens have no animations (static progress bars, no transitions), so Lite needs no branch.
  - Locked readiness bars show a "Pro" badge with no tap and no price, so there is no paywall here (§19.9 Q82).
  - Pocket-session buttons open the Study Map until a pocket-session screen exists.
- Follow-ups
  - Offline cache of Today / plan / meter in Drift ("Today from cache when offline", U-plan client; "updated <time>"
    offline, U-readiness client) needs new Drift tables: new bolt.
  - Plan setup / edit screen (`PUT /v1/me/plan`) for `hasPlan=false` users: new bolt.
  - Readiness trend (Pro) screen; Firebase/APNs adapter for `PushTokenSource`; delete push token on logout.
  - Compliance review of the alert settings copy (offers opt-in) in BOLT-0020.
- Addendum 2026-10-23 (conductor request: unblock founder testing, new users had no plan)
  - Plan setup screen `/plan-setup` over `PUT /v1/me/plan` (`PutPlanBody`: weekday/weekend minutes as preset chips,
    pocket 5/10/15, balance dial −2..+2) plus attempt cycle per chosen exam from `GET /v1/exams/{code}/structure`
    (non-closed cycles), saved first via `PUT /v1/me/exams` `attemptCycles`. Idempotency-Key reused on retry of the
    same body; failure shows "message (CODE)".
  - Opens once straight after onboarding (`planSetupPendingProvider`, router redirect) and from Today's
    "Set up your plan" button when `hasPlan=false`.
  - The contract has no "study days" field; weekday vs weekend minutes cover it (no contract change).
  - Tests `test/plan_setup_test.dart` (save order + key, error code, Today button) + goldens `plan_setup_{dark,light,
    high_contrast,large_text}.png`. Lint clean; hm_features 170 tests and apps/mobile tests pass.
