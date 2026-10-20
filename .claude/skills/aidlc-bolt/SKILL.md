---
name: aidlc-bolt
description: Run one AIDLC bolt in the HeyMey repo - plan, contract, failing tests, implementation, verification, record - ending in one PR. Use when asked to implement, build, fix or code something that belongs to a unit.
---

# AIDLC bolt: plan → contract → tests → build → verify → record

Precondition: the unit passed G-D (T0 work excepted). If not, stop and run `aidlc-design` first.

0. **Orient with the graph**: `graphify query "<what this bolt touches>"` and `graphify explain "<key symbol>"`
   before reading files; read only the lines the graph points to.
1. **Plan**: next BOLT id from `aidlc/construction/bolts/`. Copy `aidlc/templates/bolt.md`. Fill unit, stories,
   tier, expected files (inside the unit's modules/features only), contract changes, the tests to write first.
   Branch `bolt/BOLT-xxxx-<slug>`. Add the bolt to `aidlc/state.md` as `building`.
2. **Contract** (if any API/socket change): edit `packages/contracts`, run `pnpm codegen`, commit generated files.
3. **Tests first**: failing tests named after the acceptance criteria. Domain → integration → widget/golden.
   Money/games: add FW tests (`packages/domain/test/firewall/`, IDs in `MANIFEST.json`).
4. **Build** in the owning layers: `domain/` pure rules, `application/` use cases, `infrastructure/` adapters,
   thin controller/screen. Follow the nested `AGENTS.md` of each folder.
5. **Verify**: `pnpm test:integration` (real Postgres/Valkey) and `pnpm verify` (ports, firewall, boundaries, lint, typecheck, tests) and, for Flutter,
   `flutter analyze` + `node tools/flutter-test-all.mjs`. Fix until green. Never skip or delete a failing test to pass.
6. **Record**: fill the bolt's Result (what changed, evidence, follow-ups). Open the PR with the traceability line
   (`§ → INT → story → unit → BOLT`), tier, and the DoD checklist from `AGENTS.md` §7. Request reviews:
   `qa`; plus `security` + `compliance` for T2. Set the bolt to `in review` in `aidlc/state.md`.
7. Run `graphify update .` so the next agent sees your changes in the graph.
8. Commit message: `type(scope): summary [BOLT-xxxx]`. Never merge to `main` yourself.
