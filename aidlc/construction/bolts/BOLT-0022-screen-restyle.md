# BOLT-0022: Restyle every app screen on design system v2

| | |
|---|---|
| Unit | U-design-system, U-app-shell, U-app-study, U-plan app, U-readiness app, U-notifications app, U-app-exam-hall (polish only), Desk sign-in |
| Stories | Founder request 2026-10-23 (premium, gamified, Duolingo-like); follow-up of BOLT-0021 |
| Risk tier | T1 (UI only; no logic, routes, API calls, outbox or copy meaning changed) |
| Agent | flutter-ui |
| Branch / PR | `bolt/BOLT-0022-screen-restyle` · not committed (conductor asked for no commits) |
| Status | in review |

## Plan
- New hm_design building blocks: `HmStepHeader` (progress header), `HmSectionTitle`, `HmIconBadge`, `HmHeroCard`,
  `HmSkeletonList`; six new code-drawn illustrations (welcome, shield, bell, book, chart, trophy); `HmEmptyView.kind`.
- Restyle screens with hm_design components, spacing tokens, illustrations, skeleton loading, warm empty states (§10.1, §10.2).
- Progress header on onboarding (8 steps) and on check/practice question flows.
- `HmCelebration` on lamp lit, Gold earned and rank up (§5.1, §5.2, §10.4); off in Calm/Lite/reduce motion (§10.7, §10.8)
  and never in the Exam Hall (`HmPlain`, §10.6).
- Goldens load real Nunito via `flutter_test_config.dart`.

## Result
**What changed**
- `dart/hm_design`: `lib/src/widgets/layout.dart` (new widgets above), `illustrations.dart` (6 new kinds),
  `views.dart` (`HmEmptyView.kind`), `progress.dart` (`animate` flag), `lib/testing.dart` (`loadHmTestFonts()`, test-only).
- `flutter_test_config.dart` in hm_features, hm_desk, apps/mobile, apps/desk loads Nunito + Material icons.
- Onboarding: step header with back button, illustrations, answer sections in cards, `ChoiceBox` for exams and consent
  (nothing pre-ticked, unchanged), softer error box.
- Today: bigger header, rank bar in a card, skeleton loading, illustrated error, section titles; rank-up celebration
  when the server's level grows. Today Card restyled.
- Checks: step header, illustrated lesson step, skeleton loading, bigger lamp result, rank card; celebrations for
  Lit (lit check), Gold (gold check) and rank up.
- Practice: step header, illustrated session-done and limit states; limit sheet illustrated, still only the limit
  and "Not now" (no price, no timer, no urgency).
- Study Map: islands with icon badge and a "lamps lit" progress bar, larger lamps. Lite list unchanged.
- Lesson, eligibility result, My Plan (empty state, rest day), Readiness, Sunday Reports / Exam Alerts / Relight
  empty states, Profile (avatar card, settings section, icon badges), Desk sign-in (3-step header).
- All screen-level `HmLoadingView`s in hm_features now `HmSkeletonList`. Exam Hall untouched beyond what
  `HmPlain` already gives (no celebration, no motion).

**Evidence (2026-11-01)**
- `pnpm --filter @heymey/dart lint`: exit 0 (hm_api keeps its 2 generated warnings).
- `flutter test` per member: hm_design 26, hm_core 21, hm_data 28, hm_features 170, hm_desk 4, apps/mobile 2, apps/desk 1, all green. Goldens regenerated with `--update-goldens` and now render Nunito.
- `flutter build apk --debug` (apps/mobile): built. `graphify update .`: run.

**Notes**
- Readiness header illustration and carded bars were dropped: the existing test expects both locked Pro bars in
  the first viewport.
- Celebration titles ("Lamp lit!", "Gold earned!", "New rank!", "Level N!") are new short copy; compliance may review.
