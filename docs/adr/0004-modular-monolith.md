# ADR-0004: Modular monolith with enforced module ownership

| | |
|---|---|
| Status | accepted |
| Date | 2026-10-20 |
| Deciders | founder, architect agent |
| Blueprint | §34.8, §36 |

## Context
24 business modules (§36) shared by three processes (api, realtime, worker). "Each backend module owns its tables and
exposes services, and no module reads another module's tables directly" (§34.8). Later we may split processes across VPSs (§25).

## Decision
- `@heymey/domain` holds framework-free modules: `domain/` (pure rules) → `application/` (use cases over ports) → `infrastructure/` (adapters).
- Public API = `index.ts`. `module.json` declares `dependsOn`; **dependency-cruiser** fails CI on any other import,
  on deep imports, on cycles, on DB access outside `infrastructure/`, and on impure `domain/` code.
- Each module's tables live in its own `packages/db/prisma/schema/<module>.prisma`; **no Prisma relations across files**.
- Cross-module reactions use domain events, not table reads.
- Adding a dependency or a module requires an ADR.

## Consequences
Slightly more ceremony for cross-module features; in exchange agents cannot silently couple modules, and any module can
later move behind a network boundary.
