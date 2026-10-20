# Module: `roles`

Role assignments and server-side permission checks.

| | |
|---|---|
| Build week (blueprint §43) | 1 |
| Coverage target (§44) | 90% |
| Founder approval on every change | **Yes** (money / personal data / game fairness) |

## Owns (tables, in `packages/db/prisma/schema/roles.prisma`)
- RoleAssignment

## Responsibilities
- Role guards for every request
- Desk access by role
- two-person approval records for money/data actions

## May depend on (public `index.ts` only)
- `audit`

## Publishes domain events
- `roles.granted`
- `roles.revoked`

## Layout
```
roles/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/roles/` (domain-model.md, logical-design.md) once its first bolt starts.
