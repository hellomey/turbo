# Logical design: U-app-study (Phase 1 part) + Phase 1 tabs

Status: draft (Phase 1, BOLT-0004)

## Use cases
| Use case | Route | Idempotency key | Auth |
|---|---|---|---|
| Main exam | `GET /v1/me/exams` | — | user |
| Study Map | `GET /v1/exams/{code}/study-map` | — | optional |
| Lesson | `GET /v1/topics/{topicId}/lesson` | — | optional |
| Profile | `GET /v1/me`; `PATCH /v1/me {calmMode}` | fresh UUID on PATCH | user |
| Log out / all devices | `POST /v1/auth/logout`, `POST /v1/auth/logout-all` | fresh UUID | user |
| Delete account | `POST /v1/auth/otp/request {purpose: delete_account}` → `POST /v1/auth/delete-account {code}` | fresh UUID | user |

## Contract changes
None.

## Client
- `study_map`: `StudyRepository` (+ API impl), `mainExamProvider`, `studyMapProvider(code)`, `StudyMapBody`
  (island cards with `Lamp`s; Lite Mode list), `StudyMapTab`.
- `lessons`: `lessonProvider(topicId)`, `MarkdownBlocks` (headings, paragraphs, bullets, bold), `TtsPort`
  (`FlutterTtsPort` over `flutter_tts`; fake in tests), `LessonScreen` with Listen / Stop.
- `today`: one card "Open your Study Map". `play`, `squad`: calm "Coming soon" states.
- `profile`: `ProfileRepository`, `meProvider`, Calm Mode switch, Log out, Log out of all devices, Delete account
  screen (explains the 7-day grace period, sends the code, takes the 6-digit code).
- Offline (§39): Listen works offline (device TTS). Downloaded lesson packs come with `hm_data` content packs (Phase 2).
- Free/Pro lesson gating is Phase 3 (D-2026-10-20-13).

## Failure modes
| Failure | User sees |
|---|---|
| No main exam yet | "Pick your main exam to see your Study Map." |
| `LESSON_NOT_FOUND` | "This lesson is not ready yet." (server message) |
| TTS unavailable | "Listen is not available on this phone." |

## Test plan
Widget: map renders subjects + lamps from a fake map (and Lite list); lesson renders headings/bullets/refs/citation and
Listen calls the fake TTS, Stop stops it; profile shows email, Calm Mode toggle calls the repository, Log out clears.
