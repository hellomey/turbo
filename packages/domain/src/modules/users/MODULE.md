# Module: `users`

Profile, settings, privacy controls, DPDP consent, data export and deletion.

| | |
|---|---|
| Build week (blueprint §43) | 1 |
| Coverage target (§44) | 70% |
| Founder approval on every change | **Yes** (money / personal data / game fairness) |

## Owns (tables, in `packages/db/prisma/schema/users.prisma`)
- User
- Consent
- PrivacySettings

## Responsibilities
- Profile + nickname
- privacy controls
- DPDP consent records
- export and delete (7-day grace)
- Calm/Lite mode preferences

## May depend on (public `index.ts` only)
- `audit`

## Publishes domain events
- `users.created`
- `users.deletion_requested`
- `users.deleted`

## Layout
```
users/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/users/` (domain-model.md, logical-design.md) once its first bolt starts.
