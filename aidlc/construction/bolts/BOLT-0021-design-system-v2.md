# BOLT-0021: Design system v2: premium, gamified foundation in hm_design

| | |
|---|---|
| Unit | U-design-system (+ light rewiring in U-app-shell, U-app-study, U-app-exam-hall, U-plan app) |
| Stories | Founder request 2026-10-23 ("current UI is bad"; Duolingo-like, friendly, bright, rewarding; strong light and dark) |
| Risk tier | T1 (UI only; no money, personal data or server code) |
| Agent | flutter-ui |
| Branch / PR | `bolt/BOLT-0021-design-system-v2` · not committed (conductor asked for no commits) |
| Status | in review |

## Plan
- One token source (`HmPalette` ThemeExtension) with full light, dark and high-contrast palettes; type scale,
  spacing, radius, elevation and motion tokens (§10.3, §10.4).
- Bundled rounded font (Nunito, SIL OFL), no runtime fetching.
- Gamified components (§10.1, §10.6): chunky 3D-press buttons, cards, shine progress bar, lamp badges
  (Unlit, Lit, Steady 1–4, Dimming, Dim, Gold; §5.1), XP/rank chips (§5.2), celebration overlay ≤ 1.2 s,
  answer tile, bottom nav, empty/error illustrations drawn in code, skeleton loader.
- Calm Mode / Lite Mode / reduce-motion switch celebrations and decorative motion off (§10.7, §10.8);
  `HmPlain` keeps the Exam Hall flat and celebration-free (§10.6). 48 dp targets, labels, 200% text (§10.9).
- Rewire apps/mobile, apps/desk, hm_features, hm_desk with drop-in swaps only; no business logic changes.
- Tests first: WCAG AA contrast test for every text/background pair, component tests, gallery goldens.

## Result
**What changed**
- `dart/hm_design/lib/src/tokens.dart`: `HmPalette` (light/dark/highContrast + `contrastPairs`, `contrast()`),
  `context.hm`, `HmSpace`, `HmRadius`, `HmElevation`, `HmMotion` (press, fast, progress, shine, celebration 1.2 s),
  `HmSizes`, `HmFonts` (Nunito), `HmModes` (calm/lite InheritedWidget). `HmColors` kept as brand constants.
- `theme.dart`: every theme built from the palette (`HmTheme.fromPalette`); Nunito type scale (heavy headings,
  bold labels); themed buttons, inputs, chips, nav, sheets, dialogs, snack bars, switches.
- Fonts: `dart/hm_design/assets/fonts/Nunito-{Regular,SemiBold,Bold,ExtraBold,Black}.ttf` + `OFL.txt`, declared
  in hm_design's pubspec (family `packages/hm_design/Nunito`).
- New widgets: `HmChunkyButton` (+ `HmPrimaryButton` tones primary/gold/danger, `HmSecondaryButton`,
  `HmGhostButton`), `HmPlain`, `HmCard` (3D edge, press sink), `HmProgressBar` (gloss + one-shot shine),
  `HmLampStatus` + `HmLampBadge`, palette-aware `LampPainter` with glow, `HmXpChip`, `HmRankChip`,
  `HmCelebration.show` / `HmCelebrationView` (confetti burst, tap to skip, auto-close 1.2 s),
  `HmAnswerTile` (tick/cross icons + spoken state), `HmBottomNav`, `HmIllustration` (diya, unplugged diya,
  hourglass), `HmEmptyView`, `HmSkeleton`; `HmErrorView` / `HmComingSoon` now use illustrations.
- Rewiring: mobile `HmModes` from `meProvider.calmMode` + `liteModeProvider`; mobile shell uses `HmBottomNav`;
  Exam Hall screens wrapped in `HmPlain`; practice options use `HmAnswerTile`; rank bar and readiness bars use
  `HmProgressBar` and palette gold/steady; hard-coded `HmColors` in features replaced by `context.hm`.
  Desk picks up the new themes through `HmTheme` unchanged.

**Evidence (2026-10-23)**
- `pnpm --filter @heymey/dart lint`: exit 0 (format + `flutter analyze` clean; hm_api has 2 generated non-fatal warnings).
- `flutter test`: hm_design 26/26, hm_features 170/170 (goldens regenerated with `--update-goldens`), hm_core 21,
  hm_data 28, hm_desk 4, apps/mobile 2, apps/desk 1 (hm_games and hm_api have no tests).
- `flutter build apk --debug` in apps/mobile: built.
- New goldens: `dart/hm_design/test/goldens/gallery_{light,dark,high_contrast}.png` (real Nunito + Material icons).
- Contrast test `dart/hm_design/test/components_test.dart` checks 18 palette pairs per theme + Material scheme pairs, all ≥ 4.5:1.

**Decisions to log (founder approval needed; conductor to add to `aidlc/decisions.md`)**
1. UI font changes from Plus Jakarta Sans / Sora (§10.4) to **Nunito** (rounded, OFL), per the founder's brief.
   Neither old font was ever bundled. Noto Sans Tamil rule unchanged.
2. **Primary action colour is Peacock Teal**; Temple Gold becomes the reward colour (lamps, Gold, ranks, XP).
   §10.3 lists Temple Gold as primary. The brief asked for a vivid primary plus a separate reward gold.
3. Dark background moves from `#0F1230` to a richer `#100D2B` with violet surface levels; light keeps Ivory `#FFF8EC`.
4. Celebrations are 1.2 s (inside the §10.4 1.5 s limit).

**Follow-ups**
- BOLT-0022 (next): restyle Phase 2 screens (Today hero, Study Map islands, check/practice flow with
  `HmCelebration` on lamp lit / Gold / rank-up, Profile) and use `HmSkeleton` for list loading.
- Feature goldens still render with the test font (Ahem); load Nunito in `hm_features/test/support` if wanted.
- Rive animations (§10.4) are still a later bolt; celebrations are code-drawn for now.
