# Module: `readiness`

Readiness Meter, trends, Sunday Report (derived metrics).

| | |
|---|---|
| Build week (blueprint §43) | 2 |
| Coverage target (§44) | 70% |
| Founder approval on every change | No (normal review) |

## Owns (tables, in `packages/db/prisma/schema/readiness.prisma`)
- ReadinessSnapshot

## Responsibilities
- Four evidence bars (Coverage, Memory, Exam performance, Speed) - never one fake percentage
- 7/30/90-day trends
- Sunday Report

## May depend on (public `index.ts` only)
- `mastery`
- `practice`
- `exam-hall`

## Publishes domain events
None yet.

## Layout
```
readiness/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/readiness/` (domain-model.md, logical-design.md) once its first bolt starts.
