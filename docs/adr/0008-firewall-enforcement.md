# ADR-0008: How the money/game firewall is enforced

| | |
|---|---|
| Status | accepted |
| Date | 2026-10-20 |
| Deciders | founder, architect agent |
| Blueprint | §5.3, §18, §26.2 rule 3, §30 |

## Context
The firewall keeps HeyMey an online social game rather than a banned online money game. Its tests "can never be deleted".

## Decision
Four layers:
1. **Code**: `economy/domain/firewall.ts` (currencies, money-backed set, allowed reward kinds, Sparks sources, earned cap).
2. **Tests**: `packages/domain/test/firewall/` with IDs FW-001… in `MANIFEST.json`. `tools/check-firewall.mjs` fails CI if an ID
   loses its test, a test is skipped/focused, or an ID is removed compared with `main`.
3. **Structure**: dependency-cruiser forbids `games` → `billing`/`marketplace`/Sparks code; FW-008 scans the games module for
   entitlement/Pro references; game limits are a frozen constant (FW-009).
4. **People**: CODEOWNERS requires the founder on `economy`, `billing`, `games`, the firewall tests and this ADR.

## Consequences
Weakening the firewall needs a visible, reviewed change to several files. New money/game features add FW tests.
