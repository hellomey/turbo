# Module: `squads`

Squads, members, Squad Battles, Help Requests, chat, Squad Goal.

| | |
|---|---|
| Build week (blueprint §43) | 3 |
| Coverage target (§44) | 70% |
| Founder approval on every change | No (normal review) |

## Owns (tables, in `packages/db/prisma/schema/squads.prisma`)
- Squad
- SquadMember
- SquadBattle
- BattleAttempt
- HelpRequest
- ChatMessage
- SquadGoal

## Responsibilities
- Roles (Captain..Member)
- battle matching + flags
- Help Requests with reputation
- chat with phone/link filter
- captains never see private scores

## May depend on (public `index.ts` only)
- `content`
- `economy`
- `moderation`

## Publishes domain events
- `squads.battle_finished`

## Layout
```
squads/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/squads/` (domain-model.md, logical-design.md) once its first bolt starts.
