# Module: `marketplace`

Creators, creator items, publishers, books, orders, payouts with TDS.

| | |
|---|---|
| Build week (blueprint §43) | 4 |
| Coverage target (§44) | 90% |
| Founder approval on every change | **Yes** (money / personal data / game fairness) |

## Owns (tables, in `packages/db/prisma/schema/marketplace.prisma`)
- Creator
- CreatorItem
- Payout
- Publisher
- Book
- BookOrder

## Responsibilities
- Creator Studio listings (review before listing)
- publisher catalogue + orders
- 70% net revenue share
- monthly payouts with TDS
- editorial-only Recommended tags

## May depend on (public `index.ts` only)
- `content`
- `billing`
- `audit`

## Publishes domain events
None yet.

## Layout
```
marketplace/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/marketplace/` (domain-model.md, logical-design.md) once its first bolt starts.
