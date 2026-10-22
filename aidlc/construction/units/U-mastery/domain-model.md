# Domain model: U-mastery

Status: draft (BOLT-0008, architect) · awaiting G-D · numbers PROVISIONAL (D-2026-10-22-10 … -16)

Blueprint: §5.1, §5.2, §5.3 rule 4, §18 clock row, §34.1, §37, §39. INT-002 S01–S05, S18 (server side), R1, R6.

## Ubiquitous language
- **Lamp**: one syllabus topic (`syllabus.Topic`). Shared lamps across exams are one lamp (§5.1).
- **Ring**: Lit (learned), Steady (remembered; `steadyLevel` 0–4), Gold (exam-ready).
- **Check**: a server-issued question set: Lit check, recall, relight, Gold set. The server picks the questions and owns any deadline.
- **Recall ladder**: passed recalls at +1, +3, +7, +21 IST days; then maintenance every 30 days.
- **Dimming / dim**: overdue lamp fades; after the overdue limit it is dim and the Steady ring is lost (history stays).
- **Relight**: a short check on a dimming/dim lamp; a pass counts as a passed recall.
- **Lamp points / XP**: Lit 10, Steady step 5 each, Gold 20. XP is not a currency (D-…-16).
- **Career Ladder rank**: level 1–11 from XP as a percent of max over the user's syllabus; titles per exam family.

## Aggregates and entities
| Aggregate | Entities / value objects | Owning module | Table(s) |
|---|---|---|---|
| LampState (user, topic) | rings, nextDueAt, dimState, dimSince, lessonCompletedAt, rowVersion | mastery | `UserTopicState` |
| TopicCheck | questionIds, passMark, issuedAt, deadlineAt, result | mastery | `TopicCheck` |
| RingHistory | RingEvent (append-only) | mastery | `RingEvent` |
| Rank (cache) | level, xp, configVersion | mastery | `UserRank` |

## Invariants (each becomes a unit test)
1. Every ring time (`litAt`, `goldAt`, `steadyEarnedAt`, `dimSince`) is server `Clock` time; client time never sets them.
2. A Lit check can start only after `lessonCompletedAt`; pass needs ≥ `litCheck.passMark` of `litCheck.questions`.
3. A failed Lit check leaves the lamp unlit and writes a `lit_fail` RingEvent (study log).
4. The same check submitted twice (same Idempotency-Key or same checkId) changes the lamp once.
5. After Lit: `nextDueAt` = lit IST day + 1 day. After passed recall at level n: level n+1 (max 4), next gap per ladder; at 4, +30 days.
6. A recall submitted before `nextDueAt` never advances the ladder.
7. Failed recall: level − 1 (min 0), due again in 1 day; a Lit lamp never becomes unlit by a recall.
8. Dimming job: `now ≥ nextDueAt` → `dimming` (dimSince = nextDueAt); `now ≥ nextDueAt + 7 d` → `dim`, steadyLevel → 0, `steady_lost` event; Gold untouched.
9. Running the dimming job twice for the same window changes no lamp twice (guard on `dimState` + `rowVersion`).
10. Relight pass on dimming/dim lamp → bright, behaves as a passed recall; fail → state unchanged + event.
11. Gold needs Lit; pass ≥ 80 % of answers received by `deadlineAt + lateGraceSeconds`; late answers count as wrong; ≤ 2 attempts per lamp per IST day; Gold never removed.
12. Rank and XP are pure functions of ring counts and lamp count only (no entitlement, purchase or Sparks input).
13. Shared lamp across exams is one row; counted once in the union, and in each exam's `byExam` count.
14. Offline (`offline_sync`) actions older than 7 days at sync → `study_log_only` event, no ring change. Gold never offline.
15. Offline check answers are re-graded on the server from the question bank; client grading is ignored.
16. Each `clientActionId` is accepted once (unique on `RingEvent.clientActionId` + platform `SyncReceipt`).
17. Relight queue only lists lamps the user can open (Phase 2 stub: all topics with published content; §11 rule wired with billing in Phase 3).

## State machines
```
unlit --lesson_complete--> lesson_done --lit check pass--> lit(level 0, bright)
lesson_done --lit check fail--> lesson_done
lit/steady(n) --recall pass (now >= due)--> steady(min(n+1,4))        [steadyEarnedAt on first]
steady(n) --recall fail--> steady(max(n-1,0))
bright --now >= nextDueAt [job]--> dimming --now >= nextDueAt+7d [job]--> dim (steadyLevel=0, steady_lost)
dimming|dim --relight pass--> bright (as passed recall) ; --relight fail--> unchanged
any lit --gold pass--> +gold (permanent)
```

## Domain events
| Event | Published when | Payload | Consumed by |
|---|---|---|---|
| `mastery.lamp_changed` | any ring/dim change | userId, topicId, ring, source | plan (Today refresh), readiness (snapshot) via worker composition |
| `mastery.rank_up` | level increases | userId, from, to | app (rank-up screen via response), notifications (Phase 3 optional) |

## Rules that touch the money/game firewall
Rank/XP from lamps only (§5.3 rule 4). New tests for BOLT-0009 (qa/backend add in `packages/domain/test/firewall/`):
- FW-020 rank function signature accepts only ring counts; Pro entitlement does not change rank.
- FW-021 XP has no ledger and no conversion path to Points/Sparks.
- FW-022 offline-synced actions never produce ranked rewards (only study progress).

## Open questions
All provisional numbers: D-2026-10-22-10 … -16 (founder to confirm). Rank titles for non-TN families: INT-006 Q5.
