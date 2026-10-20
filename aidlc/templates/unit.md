# U-<name>: <one line>

Add a row to `aidlc/inception/units.md`; create `aidlc/construction/units/U-<name>/` when design starts.

| Field | Value |
|---|---|
| Intent(s) | INT-… |
| Backend module(s) | `packages/domain/src/modules/<m>` (owns tables in `packages/db/prisma/schema/<m>.prisma`) |
| App feature(s) | `dart/hm_features/lib/src/<f>` or `dart/hm_desk/lib/src/<f>` |
| Contract surface | routes / socket events added or changed in `@heymey/contracts` |
| Risk tier | T0 / T1 / T2 |
| Owning agent | backend / realtime / flutter-ui / game / ai-gateway / devops / content |
| Reviewers | qa (+ security, compliance for T2) |
| Depends on units | U-… |
| Coverage target | 90% (economy, billing, mastery, exam-hall, games, auth) / 70% |
