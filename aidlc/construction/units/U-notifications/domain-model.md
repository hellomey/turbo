# Domain model: U-notifications

Status: draft (BOLT-0008, architect) · awaiting G-D · numbers PROVISIONAL (D-2026-10-22-31 … -33)

Blueprint: §6, §9.10, §17.1 steps 8 and 11, §19.8 Q78, §36. INT-002 S16, S17 (send side).

## Ubiquitous language
- **Alert categories**: study, exam (Exam Alerts), offer (opt-in + consent), system.
- **Daily budget**: max 3 non-exam alerts per IST day. **Quiet hours**: IST window with no non-exam alerts; Exam Alerts are held.
- **Send log**: every send decision, including drops.

## Aggregates
| Aggregate | Tables |
|---|---|
| Device push token | `PushToken` |
| AlertPreference | `AlertPreference` |
| SendDecision | `SendLog` |

## Invariants
1. 4th non-exam alert in an IST day → `dropped_budget` (logged, not sent). Exam Alerts never count.
2. Non-exam alert inside quiet hours → not sent (`held_quiet` for study reminders only if still relevant, else dropped); Exam Alerts held until quiet hours end.
3. Offer alerts only when `offers = true` AND the latest `users` consent for offers is granted; else `dropped_no_consent`.
4. Active Exam Hall attempt → `dropped_exam_hall` (the worker composition passes `hasActiveAttempt`).
5. Morning dimming alert only when the mastery dimming count > 0; text from real numbers ("4 Polity lamps are dimming").
6. `dedupeKey` unique: the same logical alert is decided once.
7. Tokens are per device; logout removes that device's token; account deletion removes all.
8. `dailyLimit` ≤ 3 always (server clamps). Offers can't be set true without consent (400).
9. `senderMode = log_only` until Firebase/APNs exist (D-…-33).

## Domain events consumed (via worker composition root, no new dependency)
`exams.notification_published` → followers (exams API) → exam alerts; `mastery` dimming summary → morning alert;
Sunday Report stored → report alert; `users.deleted` → delete tokens.

## Firewall
None. Offers never contain fake urgency (§13; compliance reviews templates).
