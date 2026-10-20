# Module: `exams`

Exams, notifications, eligibility rules, vacancies, cutoffs.

| | |
|---|---|
| Build week (blueprint §43) | 1 |
| Coverage target (§44) | 70% |
| Founder approval on every change | **Yes** (money / personal data / game fairness) |

## Owns (tables, in `packages/db/prisma/schema/exams.prisma`)
- Exam
- Notification
- EligibilityRule
- Vacancy
- Cutoff

## Responsibilities
- Eligibility engine (age relaxations, qualification, community, PSTM)
- exam pages
- Exam Alerts source data (human-checked)
- changedetection webhook intake

## May depend on (public `index.ts` only)
- `syllabus`

## Publishes domain events
- `exams.notification_published`
- `exams.date_changed`

## Layout
```
exams/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/exams/` (domain-model.md, logical-design.md) once its first bolt starts.
