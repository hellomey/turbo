# Module: `notifications`

Push tokens, alert preferences, daily alert budget, quiet hours.

| | |
|---|---|
| Build week (blueprint §43) | 2 |
| Coverage target (§44) | 70% |
| Founder approval on every change | No (normal review) |

## Owns (tables, in `packages/db/prisma/schema/notifications.prisma`)
- PushToken
- AlertPreference
- SendLog

## Responsibilities
- FCM/APNs sending
- max 3 alerts/day (exam alerts separate)
- quiet hours
- offers opt-in only

## May depend on (public `index.ts` only)
- `users`
- `liveops`

## Publishes domain events
None yet.

## Layout
```
notifications/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/notifications/` (domain-model.md, logical-design.md) once its first bolt starts.
