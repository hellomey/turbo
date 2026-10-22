# Domain model: U-practice

Status: draft (BOLT-0008, architect) · awaiting G-D · numbers PROVISIONAL (D-2026-10-22-17 … -20)

Blueprint: §10.6 Practice, §11, §13, §19.4 Q31–Q38, §19.6 Q60, §36, §37, §39. INT-002 S06–S09; S07 copy is T2.

## Ubiquitous language
- **Practice session**: a server-picked set of questions (modes: practice, pyq, mistakes, drill).
- **Counted answer**: an answer in `practice` or `pyq` mode; counts toward the free 30 a day (IST).
- **Limit sheet**: the §13 message with "Not now", shown at most once per IST day.
- **Mistake**: a wrong answer; **concept drill**: a set made after repeated mistakes on one lamp (Pro).
- **PYQ Vault**: previous-year questions filtered by exam, year, subject, topic, difficulty.

## Aggregates and entities
| Aggregate | Entities | Module | Tables |
|---|---|---|---|
| PracticeSession | questionIds, mode, filters | practice | `PracticeSession` |
| Answer | graded answer, keyed by clientActionId | practice | `PracticeAnswer` |
| DailyUsage | counted, limitSheetShown per IST day | practice | `PracticeDayCounter` |
| MistakeLoop | MistakeTally, ConceptDrill | practice | `MistakeTally`, `ConceptDrill` |
| Question (read) | via `content` public API | content | `Question`, `QuestionVersion` |

## Invariants
1. A free user's 31st counted answer on an IST day is refused with `PRACTICE_DAILY_LIMIT`; nothing is stored.
2. The day key is `istDayKey(serverNow)` online; the phone clock never changes the count.
3. The counter increments in the same transaction as the answer insert, under a row lock (no race past 30).
4. Uncounted modes (mistakes, drill) and checks/mocks (other modules) never touch the counter.
5. Offline answers: day = IST day of clientAt clamped to [now − 7 d, now]; over that day's limit → `studyLogOnly`, no error.
6. Each `clientActionId` is stored once; a replay returns the stored grade.
7. Grading is on the server against the question version answered; the correct answer is sent only in the result.
8. Wrong answer → result names the lamp (`topicId`) to relight; weak topics are returned.
9. Mistake loop: 3 wrong on one lamp within 14 days → one open drill (no duplicate while open) — only when entitled (Pro).
10. PYQ: free users get full items only for the latest 2 exam years held for that exam; older items `locked` with no stem text.
11. Tamil-language paper questions carry `language: ta`; interface strings stay English (R5).
12. Limit sheet flag is set once per IST day; it never blocks lessons, relights or mocks.
13. Entitlement comes only from `billing` public API (Phase 2 stub = free).

## State machines
```
session: open --size reached or new session--> closed
drill: open --all answered--> done
```

## Domain events
| Event | When | Payload | Consumed by |
|---|---|---|---|
| `practice.answered` | answer stored | userId, topicId, correct, mode, istDay | readiness (via worker), plan (Today progress) |

## Firewall
No currency. Pro gives no game advantage: practice is study, not a game (§5.3 rule 4 unaffected). No FW tests added.

## Open questions
D-2026-10-22-17 … -20 (founder to confirm). Limit sheet text: compliance + founder (T2).
