---
name: new-module
description: Add a new backend domain module to HeyMey with the standard layout, module.json boundaries, Prisma file and ADR. Use only when an approved design needs a module that does not exist among the 24 in packages/domain/src/modules.
---

# New backend module

1. Confirm it is really new: the 24 modules in blueprint §36 cover most needs. Prefer extending an existing module.
2. Write an ADR from `aidlc/templates/adr.md` in `docs/adr/` explaining why, what it owns, and its dependencies. Founder approves.
3. Generate:
   ```bash
   pnpm gen:module <kebab-name> --summary "..." --owns "TableA,TableB" --does "x; y" \
     --depends "mod1,mod2" --week N --coverage 70 [--critical]
   ```
   This writes `packages/domain/src/modules/<name>/{module.json, MODULE.md, index.ts, domain/, application/, infrastructure/}`
   and `packages/db/prisma/schema/<name>.prisma`.
4. If other modules must call it, add it to their `module.json` `dependsOn` (covered by the same ADR).
5. Add a unit row to `aidlc/inception/units.md`.
6. `pnpm boundaries && pnpm --filter @heymey/domain typecheck` must pass.
