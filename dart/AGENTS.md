# AGENTS.md: dart/ (Flutter packages)

Owners: `flutter-ui` (hm_design, hm_core, hm_data, hm_features, hm_desk), `game` (hm_games). `hm_api` is GENERATED: never edit.

| Package | Purpose | May depend on |
|---|---|---|
| hm_design | tokens (§10.3), themes, core widgets, Rive loader | flutter only |
| hm_api | generated client from `@heymey/contracts` | — |
| hm_core | session/auth, networking, error envelope, flags, app-version gate, realtime client | hm_api |
| hm_data | Drift DB, outbox sync engine (§39), repositories, content packs | hm_api, hm_core |
| hm_games | Flame scenes (display only) | hm_design, hm_core |
| hm_features | aspirant features + staff quick actions | all above |
| hm_desk | Desk features (staff/partner) | hm_design, hm_core, hm_api |

- One Dart pub workspace (root `pubspec.yaml`): run `flutter pub get` at the repo root.
- Feature folder layers: `presentation/` → `application/` (Riverpod) → `domain/` → `data/`.
- `apps/mobile` never depends on `hm_desk`.
- Lint: `flutter analyze` (rules in `dart/analysis_options.yaml`). Tests: `node tools/flutter-test-all.mjs`. Goldens for every key screen.
