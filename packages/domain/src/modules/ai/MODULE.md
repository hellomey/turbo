# Module: `ai`

AI tasks, model routes, usage and budgets (via @heymey/ai-gateway).

| | |
|---|---|
| Build week (blueprint §43) | 3 |
| Coverage target (§44) | 70% |
| Founder approval on every change | No (normal review) |

## Owns (tables, in `packages/db/prisma/schema/ai.prisma`)
- AiTask
- AiModelRoute
- AiUsage

## Responsibilities
- Doubt help (Free 3/month, Pro 30/day)
- explanation generation once per question
- independent verification on a different model family
- moderation
- budget alerts 50/80/100%

## May depend on (public `index.ts` only)
Nothing. This module is a leaf.

## Publishes domain events
None yet.

## Layout
```
ai/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/ai/` (domain-model.md, logical-design.md) once its first bolt starts.
