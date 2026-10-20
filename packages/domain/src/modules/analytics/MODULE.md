# Module: `analytics`

Product analytics event ingestion (partitioned table for Metabase).

| | |
|---|---|
| Build week (blueprint §43) | 4 |
| Coverage target (§44) | 70% |
| Founder approval on every change | No (normal review) |

## Owns (tables, in `packages/db/prisma/schema/analytics.prisma`)
- AnalyticsEvent (partitioned)

## Responsibilities
- Event ingestion
- no personal data in event payloads

## May depend on (public `index.ts` only)
Nothing. This module is a leaf.

## Publishes domain events
None yet.

## Layout
```
analytics/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/analytics/` (domain-model.md, logical-design.md) once its first bolt starts.
