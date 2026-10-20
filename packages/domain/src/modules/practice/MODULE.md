# Module: `practice`

Practice sessions, free daily limit, mistake loop.

| | |
|---|---|
| Build week (blueprint §43) | 2 |
| Coverage target (§44) | 70% |
| Founder approval on every change | No (normal review) |

## Owns (tables, in `packages/db/prisma/schema/practice.prisma`)
- PracticeAttempt
- Answer

## Responsibilities
- Practice + recall checks
- 30/day free limit (IST day)
- mistake loop drills
- offline answers accepted once by client UUID

## May depend on (public `index.ts` only)
- `content`
- `mastery`
- `billing`

## Publishes domain events
- `practice.answered`

## Layout
```
practice/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/practice/` (domain-model.md, logical-design.md) once its first bolt starts.
