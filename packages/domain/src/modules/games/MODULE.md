# Module: `games`

Spin, Slot, Duel, Clue Poker, District Quest, Memory Pits, Tiger Trap; odds; leagues.

| | |
|---|---|
| Build week (blueprint §43) | 3 |
| Coverage target (§44) | 90% |
| Founder approval on every change | **Yes** (money / personal data / game fairness) |

## Owns (tables, in `packages/db/prisma/schema/games.prisma`)
- GameRoom
- GameResult
- OddsConfig (versioned)
- League
- Trophy

## Responsibilities
- Server-authoritative rooms
- CSPRNG spin/slot with versioned odds stored per outcome
- ranked cap 10/day for everyone
- games sleep 12-5 AM IST
- bots never give ranked trophies

## May depend on (public `index.ts` only)
- `content`
- `economy`
- `liveops`

## Publishes domain events
- `games.match_finished`

## Layout
```
games/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/games/` (domain-model.md, logical-design.md) once its first bolt starts.
