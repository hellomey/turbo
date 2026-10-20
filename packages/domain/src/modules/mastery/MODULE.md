# Module: `mastery`

Lit/Steady/Gold rings, dimming schedule, relight, Career Ladder rank.

| | |
|---|---|
| Build week (blueprint §43) | 2 |
| Coverage target (§44) | 90% |
| Founder approval on every change | No (normal review) |

## Owns (tables, in `packages/db/prisma/schema/mastery.prisma`)
- UserTopicState

## Responsibilities
- Ring transitions (Lit -> Steady via 1/3/7/21-day recalls -> Gold at 80% timed)
- dimming + relight scheduler
- rank computed ONLY from lamps

## May depend on (public `index.ts` only)
- `syllabus`
- `content`

## Publishes domain events
- `mastery.lamp_changed`
- `mastery.rank_up`

## Layout
```
mastery/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/mastery/` (domain-model.md, logical-design.md) once its first bolt starts.
