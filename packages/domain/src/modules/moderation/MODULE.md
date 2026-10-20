# Module: `moderation`

Reports, cases, sanctions, chat filter, self-harm protocol.

| | |
|---|---|
| Build week (blueprint §43) | 4 |
| Coverage target (§44) | 70% |
| Founder approval on every change | **Yes** (money / personal data / game fairness) |

## Owns (tables, in `packages/db/prisma/schema/moderation.prisma`)
- ModerationCase
- Sanction
- Appeal

## Responsibilities
- Report queue
- warn/mute/ban + appeals
- self-harm alerts first (helpline + human follow-up)
- AI pre-sorting, human decides

## May depend on (public `index.ts` only)
- `users`
- `ai`
- `audit`

## Publishes domain events
- `moderation.sanction_applied`

## Layout
```
moderation/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/moderation/` (domain-model.md, logical-design.md) once its first bolt starts.
