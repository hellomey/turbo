# Logical design: U-practice

Status: draft (BOLT-0008) · awaiting G-D · implemented by BOLT-0010 (backend). Includes the Phase 2 `content` routes (questions, reports, packs).

## Use cases
| Use case | Trigger | Ports | Idempotency | Auth |
|---|---|---|---|---|
| startSession | `POST /v1/practice/sessions` | ContentApi (pick questions), BillingApi (entitlement), SessionRepo, Clock | Idempotency-Key | user 120/h |
| answer | `POST /v1/practice/sessions/{id}/answers` | ContentApi (grade), AnswerRepo + CounterRepo (one tx), BillingApi, Clock, EventPublisher | Idempotency-Key + clientActionId | user 600/h |
| acceptOfflineAnswer | sync dispatcher (`practice_answer`) | same | clientActionId | user |
| usage | `GET /v1/me/practice/usage` | CounterRepo, BillingApi, Clock | — | user |
| mistakes | `GET /v1/me/mistakes` | AnswerRepo, ContentApi | — | user |
| drills | `GET /v1/me/drills` | DrillRepo, BillingApi | — | user |
| searchPyqs / facets | `GET /v1/pyq`, `/v1/pyq/facets` | ContentApi (PYQ query, cursor), BillingApi | — | user 600/h |
| reportQuestion (content) | `POST /v1/questions/{id}/reports` | content ReportRepo | Idempotency-Key | user 30/h |
| listPacks (content) | `GET /v1/content/packs` | content PackRepo, BillingApi (via composition) | — | user |

Dependencies: `content`, `mastery`, `billing` (already declared). `billing` is the Phase 2 stub: `entitlementOf(userId)` → `free`.

## Contract
Files `src/http/practice.ts`, `questions.ts`. Routes listed above. Errors: PRACTICE_DAILY_LIMIT (403, existing code),
PRACTICE_SESSION_CLOSED (409), QUESTION_NOT_FOUND / TOPIC_NOT_FOUND (404), PRO_REQUIRED (403; drills start).
Non-breaking.

## Data
`practice.prisma`: `PracticeSession`, `PracticeAnswer` (id = clientActionId), `PracticeDayCounter`, `MistakeTally`,
`ConceptDrill`. `content.prisma`: `Question` (+ `kind` R3, `language` R5, PYQ facts), `QuestionVersion`, `Source`,
`Correction`, `QuestionReport`, `ContentPack`. Expand-only migration. Indexes: `PracticeAnswer[userId, istDay]`,
`Question[pyqExamCode, pyqYear, status]`, `Question[topicId, status, difficulty]`.
Seed (BOLT-0010): SEED-marked original questions for the 25 seed topics; no real PYQ text without a source and verification.

## Background work
None new (drill creation is inline in `answer`).

## Client
Answer saved to Drift instantly, outbox `practice_answer`; online path calls the answers route directly. Limit sheet
from `PracticeUsage.limitSheetShownToday`. Packs: Wi-Fi only by default, SHA-256 checked, mismatch discards. Lite Mode: no animations on feedback.

## Flags and LiveOps
`PRACTICE_CONFIG` (`packages/domain/src/modules/practice/domain/config.ts`). `showProPriceLine: false` until Phase 3.

## Failure modes
| Failure | Behaviour | User sees |
|---|---|---|
| 31st counted answer | 403 PRACTICE_DAILY_LIMIT | "You've used today's free questions. More open tomorrow at 12 AM." + "Not now" |
| Question retired mid-session | grade against answered version | normal result + affected note |
| Pack checksum mismatch | discard, retry later | "Download didn't finish. We'll try again on Wi-Fi." |
| Counter row contention | row lock, short tx | nothing |

## Non-functional
PYQ search p95 ≤ 300 ms (index on exam/year; cursor = (year, id)). Answer p95 ≤ 150 ms server.

## Test plan (≥ 70 %)
| Level | Cases |
|---|---|
| Domain unit | invariants 1–13; IST 23:59 → 00:00 reset with FakeClock; clamping of offline days |
| Integration | 30 parallel answers + 1 → exactly 30 stored; replay; PYQ cursor pages; locked years |
| API | each route incl. 401/400/403 codes |
| Compliance | limit sheet copy review (T2) |
