# Architecture decision records

Lasting decisions. Template: `aidlc/templates/adr.md`. Small decisions go to `aidlc/decisions.md`.

| ADR | Decision |
|---|---|
| [0001](0001-monorepo-turborepo-pnpm.md) | One monorepo: Turborepo + pnpm, plus a Dart pub workspace |
| [0002](0002-port-allocation.md) | One port series starting at 4567 |
| [0003](0003-marketing-site-nextjs.md) | The Next.js marketing site replaces the planned static apps/site |
| [0004](0004-modular-monolith.md) | Modular monolith with enforced module ownership |
| [0005](0005-aidlc.md) | AIDLC is the development lifecycle |
| [0006](0006-contract-first.md) | Contract-first: Zod → OpenAPI 3.1 → Dart client |
| [0007](0007-dart-workspace-and-hm-desk.md) | Dart pub workspace; Desk features in a separate hm_desk package |
| [0008](0008-firewall-enforcement.md) | How the money/game firewall is enforced |
| [0009](0009-typescript-6-swc.md) | TypeScript 6.0 for type-checking, SWC for Nest builds |
| [0010](0010-compose-stacks.md) | Compose stacks: app (prod + staging), edge, monitoring |
| [0011](0011-graphify-knowledge-graph.md) | Graphify knowledge graph for agent navigation |
