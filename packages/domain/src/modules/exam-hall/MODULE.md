# Module: `exam-hall`

OMR/CBT mocks, State Mock Sunday, scoring, reports.

| | |
|---|---|
| Build week (blueprint §43) | 2 |
| Coverage target (§44) | 90% |
| Founder approval on every change | No (normal review) |

## Owns (tables, in `packages/db/prisma/schema/exam-hall.prisma`)
- Mock
- MockAttempt
- MockAnswer

## Responsibilities
- Exam-accurate mocks (OMR + CBT)
- resume exactly
- negative marking
- State Mock Sunday statewide rank
- Retry Wrong Only
- Custom Test Builder

## May depend on (public `index.ts` only)
- `content`
- `mastery`
- `billing`

## Publishes domain events
- `exam_hall.mock_submitted`

## Layout
```
exam-hall/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/exam-hall/` (domain-model.md, logical-design.md) once its first bolt starts.
