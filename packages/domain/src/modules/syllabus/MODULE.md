# Module: `syllabus`

Subjects, topics (lamps), textbook mapping, glossary.

| | |
|---|---|
| Build week (blueprint §43) | 1 |
| Coverage target (§44) | 70% |
| Founder approval on every change | No (normal review) |

## Owns (tables, in `packages/db/prisma/schema/syllabus.prisma`)
- Syllabus
- Subject
- Topic
- TopicExamTag
- TextbookRef
- Glossary

## Responsibilities
- Official syllabus -> Study Map
- shared lamps across exams
- State Board textbook map
- tap-to-see glossary

## May depend on (public `index.ts` only)
Nothing. This module is a leaf.

## Publishes domain events
None yet.

## Layout
```
syllabus/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/syllabus/` (domain-model.md, logical-design.md) once its first bolt starts.
