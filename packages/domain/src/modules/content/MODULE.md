# Module: `content`

Lessons, questions, versions, sources, explanations, corrections, reports.

| | |
|---|---|
| Build week (blueprint §43) | 1 |
| Coverage target (§44) | 70% |
| Founder approval on every change | No (normal review) |

## Owns (tables, in `packages/db/prisma/schema/content.prisma`)
- Lesson
- Question
- QuestionVersion
- Source
- Explanation
- Correction
- Report

## Responsibilities
- Content serving + versioned packs
- every item cites a source
- public Correction Log
- report -> fix -> notify loop
- pg_trgm duplicate detection

## May depend on (public `index.ts` only)
- `syllabus`
- `ai`

## Publishes domain events
- `content.corrected`
- `content.pack_published`

## Layout
```
content/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/content/` (domain-model.md, logical-design.md) once its first bolt starts.
