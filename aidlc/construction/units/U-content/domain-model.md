# Domain model: U-content

Status: draft

## Ubiquitous language
- **Lesson**: versioned reading for one topic (lamp), with a cited source and textbook refs (§10.6, §19.3).
- **Listen Mode**: the app reads `bodyMarkdown` aloud with the phone's TTS (no server work).

## Aggregates and entities
| Aggregate | Entities / value objects | Owning module | Table(s) |
|---|---|---|---|
| Lesson | Lesson (topicId, version, status, sourceCitation, sourceUrl) | content | Lesson |

## Invariants (unit tests in `packages/domain/test/modules/content.spec.ts`)
1. Only `status = published` lessons are served; the highest published version wins.
2. Every served lesson carries `source.citation` (§26.2 rule 5).
3. `textbookRefs` come from the syllabus module's public API (content → syllabus is declared in module.json).
4. No Pro gating in Phase 1 (D-2026-10-20-13).
5. No published lesson → LESSON_NOT_FOUND.

## State machines
```
draft -> in_review -> published -> superseded (when a new version is published)
```

## Domain events
None in Phase 1.

## Rules that touch the money/game firewall (T2)
None.

## Open questions
None.
