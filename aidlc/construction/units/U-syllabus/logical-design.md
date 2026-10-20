# Logical design: U-syllabus

Status: draft

## Use cases (application layer)
| Use case | Trigger | Ports used | Idempotency key | Authorisation |
|---|---|---|---|---|
| getStudyMap | `GET /v1/exams/{code}/study-map` | SyllabusRepository + per-call ports `publishedExamCodes()` (exams) and `topicsWithLesson(ids)` (content) | — | optional |
| searchGlossary | `GET /v1/glossary?q=` | SyllabusRepository | — | public |
| textbookRefs | content.getLesson | SyllabusRepository | — | — |

## Contract changes
None. Error: EXAM_NOT_FOUND when the exam is not published.

## Data
No schema change. Seed: `packages/db/prisma/seed/catalog.ts` reads `content/syllabus/*.yaml` (subjects → topics with
stable ids, `shared_with`, textbook refs) and upserts.

## Background work
None.

## Client (Flutter)
The Study Map is cacheable; the app shows the cached map offline.

## Flags and LiveOps
None.

## Failure modes
| Failure | Behaviour | User sees |
|---|---|---|
| Exam not published | 404 EXAM_NOT_FOUND | "We couldn't find that exam." |

## Non-functional budget
One query for topics + tags, one for published exam codes, one for lesson flags. p95 ≤ 300 ms.

## Observability
Default request logs.

## Test plan
| Level | Cases | Tool |
|---|---|---|
| Domain unit | grouping/order, shared lamps filtered to published exams, unlit ring, hasLesson, glossary query building | Vitest with fakes |
| Integration | repository + seeder idempotency on real Postgres; API e2e study map + glossary | Testcontainers |
