# Module: `economy`

Currencies with the money/game FIREWALL, cosmetics, check-in, seasons, Season Pass.

| | |
|---|---|
| Build week (blueprint §43) | 3 |
| Coverage target (§44) | 90% |
| Founder approval on every change | **Yes** (money / personal data / game fairness) |

## Owns (tables, in `packages/db/prisma/schema/economy.prisma`)
- SparksLedger
- PointsLedger
- TrophyLedger
- Cosmetic
- UserCosmetic
- CheckInTrack
- Season
- SeasonPassProgress

## Responsibilities
- Two append-only ledgers that never convert
- earned-Sparks cap 50/month
- check-in track that never resets
- Season Pass (cosmetic only)
- spending limits

## May depend on (public `index.ts` only)
- `audit`
- `liveops`

## Publishes domain events
- `economy.sparks_credited`
- `economy.points_awarded`

## Layout
```
economy/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/economy/` (domain-model.md, logical-design.md) once its first bolt starts.
