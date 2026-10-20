# ADR-0007: Dart pub workspace; Desk features in a separate hm_desk package

| | |
|---|---|
| Status | accepted |
| Date | 2026-10-20 |
| Deciders | founder, architect agent |
| Blueprint | §35 |

## Context
§35 lists `hm_features` with `desk_*` features inside, and also says "Desk-only code is never included in the mobile app build".

## Decision
- Root `pubspec.yaml` is a **pub workspace** (one resolution, one lockfile) for `apps/mobile`, `apps/desk` and `dart/hm_*`.
- Desk features live in **`dart/hm_desk`**, which `apps/mobile` never depends on (documented in its pubspec, checked in review).
  Staff quick actions for the phone live in `hm_features/staff_quick_actions`.

## Consequences
The guarantee is structural (no dependency), not dependent on tree-shaking.
