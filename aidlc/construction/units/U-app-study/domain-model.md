# Domain model: U-app-study (Phase 1 part: Study Map + lessons + Listen Mode)

Status: draft (Phase 1, BOLT-0004) · T1

Feature folders: `dart/hm_features/lib/src/study_map`, `src/lessons`, plus the Phase 1 tabs (`today`, `play`, `squad`, `profile`).

## Ubiquitous language
- **Study Map**: subjects (islands) with topics (lamps) for the main exam (§5.1, §10.6).
- **Lamp rings**: Lit (solid circle, Flame Orange), Steady (4 segments, Peacock Teal), Gold (outer octagon, Temple Gold).
  Phase 1: all unlit (D-2026-10-20-14).
- **Lesson**: clean reading view of `bodyMarkdown`, textbook references, source citation (§10.6).
- **Listen Mode**: the phone's text-to-speech reads the lesson, works offline (§19.3 Q27).
- **Lite Mode**: static list instead of the island map (§10.8).

## Entities / value objects
| Name | Fields | Source |
|---|---|---|
| `StudyMapView` | examCode, subjects[name, topics[id, name, hasLesson, `HmLampState`, examCodes]] , totalTopics | `GET /v1/exams/{code}/study-map` |
| `LessonView` | title, blocks (parsed markdown), readingMinutes, textbookRefs, citation + url | `GET /v1/topics/{id}/lesson` |
| `MyExams` | mainCode, others | `GET /v1/me/exams` |
| `MeInfo` | email, nickname, calmMode, liteMode, roles, deletionScheduledFor | `GET /v1/me` |

## Invariants
1. Subjects and topics are shown in `order`.
2. Each lamp's semantics label names the topic and all three rings.
3. A topic without a lesson cannot be opened (shows "Lesson coming soon").
4. Listen reads the lesson text without markdown symbols; Stop always stops speech.
5. Delete account explains the 7-day grace period before the code is sent.

## Firewall impact
None.
