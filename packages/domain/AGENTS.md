# AGENTS.md: packages/domain (business modules)

Owners: `backend` per module; `architect` owns every `module.json`. Root rules apply.

- 24 modules from blueprint §36 in `src/modules/<name>/`. Read the module's `MODULE.md` before changing it.
- Layers: `domain/` pure rules (no I/O, no framework, no Prisma) → `application/` use cases over ports → `infrastructure/` adapters (only place that imports `@heymey/db`).
- Public API = `index.ts`. Other modules and apps import only that, and only if listed in your `module.json` `dependsOn`. `pnpm boundaries` enforces it.
- Shared kernel in `src/shared/`: `Clock`, `istDayKey`, `DomainError`, ports. Inject the clock; never `Date.now()`.
- **Firewall**: `modules/economy/domain/firewall.ts` + `test/firewall/` (FW-001…). Add tests and IDs to `MANIFEST.json`; never delete, skip or weaken. Changes need founder approval.
- New module: `pnpm gen:module` + ADR (skill `new-module`).
