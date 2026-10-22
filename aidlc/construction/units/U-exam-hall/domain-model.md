# Domain model: U-exam-hall

Status: draft (BOLT-0008, architect) · awaiting G-D · numbers PROVISIONAL (D-2026-10-22-21 … -24) · ADR-0012, ADR-0013

Blueprint: §9.9, §9.10, §10.6 Exam Hall, §11, §13, §18, §19.4 Q36–Q38, §19.8 Q76, §34.1, §39. INT-002 S10, S11, R1, R4, R6.

## Ubiquitous language
- **Mock**: a fixed question set built for one `Paper` and one `MarkingScheme` version (from `exams`).
- **Attempt**: one user's sitting of a mock with a server start time and deadline.
- **Answer mode**: from the paper: `objective_omr` (bubble sheet), `objective_cbt` (palette + mark for review), `descriptive` (refused in Phase 2).
- **Marking scheme**: sections with marks per correct and penalty per wrong as exact fractions.
- **State Mock Sunday**: a `state_mock_sunday` mock in a scheduled window; ranked among on-time takers (scope per family).
- **Allowance**: free users: 1 full mock per IST calendar month + every State Mock Sunday.

## Aggregates
| Aggregate | Entities | Tables |
|---|---|---|
| Mock | sections (question ids), window | `Mock` |
| MockAttempt | answers, status, score, ranked | `MockAttempt`, `MockAnswer` |
| Allowance | one row per user per IST month | `MockAllowanceUse` |
| Ranking | per mock per user | `MockRank` |

## Invariants (each a test)
1. Start/deadline are server time; deadline = start + scheme duration (State Mock: min(start + duration, opensAt + lateJoin + duration)).
2. Starting a mock on a `descriptive` paper → `PAPER_TYPE_NOT_SUPPORTED`. Mode comes from the paper, never the exam name (R1, R4).
3. Starting again while in progress returns the same attempt (resume), never a second one.
4. A free user's 2nd non-State full mock in an IST month → `MOCK_MONTHLY_LIMIT` (unique `MockAllowanceUse` guards races). Sectional mocks: free (not "full").
5. Answer saves: last write per question wins; saves arriving after deadline + grace are ignored; any save after the deadline sets `ranked = false`.
6. Score = Σ sections (correct × marksPerCorrect − wrong × penaltyPerWrong) as an exact fraction; unanswered = 0; "answer any N" counts the first N answered in paper order.
7. Two papers with different schemes score the same answers differently, each by its own scheme only (TEST-FAMILY fixture).
8. Attempts store `schemeVersion`; a new scheme version never rescoring old attempts.
9. Submitting twice returns the same report; expired attempts are auto-scored by the job.
10. State Mock: start before `opensAt` → `MOCK_NOT_OPEN`; after `lateJoinUntil` → allowed as unranked practice until `closesAt`, then `MOCK_CLOSED`.
11. Ranked only if started inside the live window, every answer saved on time and submitted (or auto-submitted) at deadline; offline-synced attempts never ranked.
12. Rank computed once at `rankPublishAt` by the server; ties share a rank; percentile is a whole number.
13. Free report: `fullReportLocked = true` (blurred preview); score, sections and mistakes are always shown.
14. Mistakes in the report link to lamps; ring effects only via `mastery` public API (Gold is earned only through Gold sets).

## State machine
```
(none) --start--> in_progress --submit--> submitted
in_progress --deadline passed [job or next read]--> expired(scored)
```

## Domain events
| Event | When | Consumed by |
|---|---|---|
| `exam_hall.mock_submitted` | submitted/expired | readiness (exam performance, speed), plan |
| `exam_hall.rank_published` | rank job done | notifications (via worker composition) |

## Firewall
Mocks are study, not games; mock packs bought with Sparks (Phase 3) must never affect rank (FW test planned with marketplace).
No new FW tests in Phase 2.

## Open questions
D-2026-10-22-21 … -24; verified Group 4/2/2A patterns (Track B).
