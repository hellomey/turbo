# Logical design: U-content

Status: draft

## Use cases (application layer)
| Use case | Trigger | Ports used | Idempotency key | Authorisation |
|---|---|---|---|---|
| getLesson | `GET /v1/topics/{topicId}/lesson` | LessonRepository, SyllabusApi.textbookRefs | — | optional |
| topicsWithPublishedLesson | Study Map composition (`hasLesson`) | LessonRepository | — | — |

## Contract changes
None. Error: LESSON_NOT_FOUND (404).

## Data
No schema change. The seed writes 4 original lessons (version 1, published), keyed by (topicId, version).

## Background work
None. Content packs arrive in Phase 2.

## Client (Flutter)
The lesson is cached for offline reading; Listen Mode uses device TTS.

## Flags and LiveOps
None.

## Failure modes
| Failure | Behaviour | User sees |
|---|---|---|
| No published lesson | 404 LESSON_NOT_FOUND | "This lesson is not ready yet." |

## Non-functional budget
Two indexed queries (`Lesson(topicId, status)`, `TextbookRef(topicId)`).

## Observability
Default request logs.

## Test plan
| Level | Cases | Tool |
|---|---|---|
| Domain unit | latest published wins, not found, textbook refs attached, lesson flags | Vitest with fakes |
| Integration | repository on real Postgres; API e2e lesson + 404 | Testcontainers |
