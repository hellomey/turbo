# Module: `audit`

Append-only audit log of every staff and system action.

| | |
|---|---|
| Build week (blueprint §43) | 1 |
| Coverage target (§44) | 90% |
| Founder approval on every change | **Yes** (money / personal data / game fairness) |

## Owns (tables, in `packages/db/prisma/schema/audit.prisma`)
- AuditLog

## Responsibilities
- Record every staff action, approval and money/data change
- never updated or deleted

## May depend on (public `index.ts` only)
Nothing. This module is a leaf.

## Publishes domain events
None yet.

## Layout
```
audit/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/audit/` (domain-model.md, logical-design.md) once its first bolt starts.
