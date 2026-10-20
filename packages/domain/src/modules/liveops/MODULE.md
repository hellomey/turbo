# Module: `liveops`

Events, seasons schedule, feature flags, emergency switch.

| | |
|---|---|
| Build week (blueprint §43) | 4 |
| Coverage target (§44) | 70% |
| Founder approval on every change | **Yes** (money / personal data / game fairness) |

## Owns (tables, in `packages/db/prisma/schema/liveops.prisma`)
- LiveEvent
- FeatureFlag
- EmergencySwitch

## Responsibilities
- Event calendar (Notification Night, Answer Key Day, State Mock Sunday...)
- feature flags
- pause-games / pause-store switch (needs 2FA)

## May depend on (public `index.ts` only)
- `audit`

## Publishes domain events
- `liveops.switch_changed`

## Layout
```
liveops/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/liveops/` (domain-model.md, logical-design.md) once its first bolt starts.
