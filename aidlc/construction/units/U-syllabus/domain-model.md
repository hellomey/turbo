# Domain model: U-syllabus

Status: draft

## Ubiquitous language
- **Study Map**: an exam's subjects (areas) and topics (**lamps**) (§3, §5.1).
- **Shared lamp**: one topic tagged for several exams; `examCodes` lists every published exam it belongs to.
- **Ring**: Lit / Steady / Gold. Phase 1 always serves an unlit ring (D-2026-10-20-14).
- **Textbook ref**: TN State Board book, class, chapter, pages (§19.3 Q22).
- **Glossary**: tap-to-see meanings of exam terms (§10.2).

## Aggregates and entities
| Aggregate | Entities / value objects | Owning module | Table(s) |
|---|---|---|---|
| Subject | Subject, Topic (stable UUID), TopicExamTag, TextbookRef | syllabus | Subject, Topic, TopicExamTag, TextbookRef |
| Glossary | GlossaryTerm | syllabus | GlossaryTerm |

## Invariants (unit tests in `packages/domain/test/modules/syllabus.spec.ts`)
1. Topic ids are stable (from `content/syllabus/*.yaml`); never generated at seed time.
2. Study Map subjects are ordered by `order`, topics by `order`; only topics tagged with the requested exam appear.
3. A topic's `examCodes` = every *published* exam tagged on it, sorted.
4. `ring` = `{lit:false, steadyLevel:0, gold:false, dim:"bright"}` in Phase 1.
5. `hasLesson` comes from the content module. syllabus never imports exams or content: the API passes two small ports
   (`publishedExamCodes`, `topicsWithLesson`) into the use case.
6. Glossary: with `q` → case-insensitive contains match, ≤ 20 results ordered by term; without `q` → first 50 by term.

## State machines
None.

## Domain events
None.

## Rules that touch the money/game firewall (T2)
None.

## Open questions
- Textbook chapter numbers in the seed YAML are placeholders, to be verified by the content track (B).
