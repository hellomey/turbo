# Module: `institutions`

Institution licences, seats, batch analytics.

| | |
|---|---|
| Build week (blueprint §43) | 4 |
| Coverage target (§44) | 70% |
| Founder approval on every change | No (normal review) |

## Owns (tables, in `packages/db/prisma/schema/institutions.prisma`)
- Institution
- Seat
- Batch

## Responsibilities
- Seat activation after invoice
- student invites
- private institution league
- batch-level analytics only (students opt in to individual visibility)

## May depend on (public `index.ts` only)
- `users`
- `exam-hall`
- `readiness`
- `audit`

## Publishes domain events
None yet.

## Layout
```
institutions/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/institutions/` (domain-model.md, logical-design.md) once its first bolt starts.
