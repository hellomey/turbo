# Domain model: U-plan

Status: draft (BOLT-0008, architect) · awaiting G-D · numbers PROVISIONAL (D-2026-10-22-25 … -28)

Blueprint: §6, §7, §10.5, §10.6 Today, §10.7 Calm, §17.1 step 9, §17.3, §19.2 Q11–Q20, §19.10 Q93–Q97. INT-002 S12, S13, R2.

## Ubiquitous language
- **My Plan**: daily study items from weekday/weekend minutes and the exams' attempt cycles.
- **Attempt cycle**: the sitting the user prepares for; its next stage date drives days left (R2).
- **Today Card**: the single next action. **Pocket session**: 5/10/15 minutes.
- **Rebalance**: kind re-spread after missed days ("welcome back", never "streak lost").
- **Final Stretch**: phases d90/d60/d30/d7 by days left. **Critical topic**: `TopicExamTag.priority ≥ 2`.
- **Study log**: append-only record of study done (incl. offline > 7 days).

## Aggregates
| Aggregate | Entities | Tables |
|---|---|---|
| Plan | PlanExam (≤ 3), PlanItem, balance, stretch | `Plan`, `PlanExam`, `PlanItem` |
| StudyLog | entries | `StudyLog` |

## Invariants
1. One plan per user; ≤ 3 exams; exactly one priority 1 (the main exam from `exams`).
2. Daily minutes = weekday or weekend minutes by IST weekday; items of a day never exceed it by more than one item.
3. Mix by days left follows `PLAN_CONFIG.mixByDaysLeft` with the balance dial applied; nothing is hard-coded per exam (R1).
4. New user: a 7-day starter path for the main exam (lessons + Lit checks of the first lamps in syllabus order).
5. Today Card = first pending item of today by order; relight items come from `mastery` relight queue.
6. 2 missed plan days → rebalance moves pending past items forward (status `moved`); copy is kind; nothing says "streak lost".
7. `exams.date_changed` / cycle change → PlanExam date refreshed and future days rebuilt; done items never change.
8. Stretch phase = by nearest exam's days left: ≤90 d90, ≤60 d60, ≤30 d30 (no new topics unless critical), ≤7 d7 (lighter, checklist).
9. Shared lamps planned once across exams. Multi-exam budget per `PLAN_CONFIG.multiExam`.
10. Item status changes are idempotent; offline `plan_item_status` actions apply if the item still exists.
11. Calm Mode only changes what Today shows (Today Card, Study, Relight); plan data unchanged.

## State machine
```
PlanItem: pending --done--> done ; pending --skipped--> skipped ; pending --rebalance--> moved (+ new pending item)
```

## Domain events
| Event | When | Consumed by |
|---|---|---|
| `plan.rebalanced` | rebalance ran | notifications (optional welcome-back, via worker) |

## Firewall
None (no currency, no game).

## Open questions
D-2026-10-22-25 … -28.
