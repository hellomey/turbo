# Module: `plan`

My Plan, Today Card, auto-rebalance, Final Stretch.

| | |
|---|---|
| Build week (blueprint §43) | 2 |
| Coverage target (§44) | 70% |
| Founder approval on every change | No (normal review) |

## Owns (tables, in `packages/db/prisma/schema/plan.prisma`)
- Plan
- PlanItem
- StudyLog

## Responsibilities
- Plan from hours + exam date
- Today Card (one clear next action)
- kind auto-rebalance after missed days
- 90/60/30/7-day Final Stretch

## May depend on (public `index.ts` only)
- `syllabus`
- `mastery`
- `exams`

## Publishes domain events
- `plan.rebalanced`

## Layout
```
plan/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/plan/` (domain-model.md, logical-design.md) once its first bolt starts.
