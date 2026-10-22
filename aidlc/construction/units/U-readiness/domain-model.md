# Domain model: U-readiness

Status: draft (BOLT-0008, architect) · awaiting G-D · numbers PROVISIONAL (D-2026-10-22-29, -30)

Blueprint: §11, §19.5 Q41–Q50, §19.10 Q100. INT-002 S14, S15, Q27.

## Ubiquitous language
- **Readiness Meter**: four evidence bars (Coverage, Memory, Exam performance, Speed) + a plain label.
- **Label**: Not yet / Building / Close / Mock-ready. **There is never one overall percentage.**
- **Sunday Report**: weekly study proof (short free, full Pro); never promises selection.

## Aggregates
| Aggregate | Tables |
|---|---|
| ReadinessSnapshot (user, exam, IST day) | `ReadinessSnapshot` |
| SundayReport (user, IST week) | `SundayReport` |

## Invariants
1. Coverage = Lit % of the exam's lamps (+ Steady %, Gold % detail). Memory = Steady-and-not-dim % of Lit lamps.
2. Exam performance = mean score % of the last 3 submitted mocks (scheme max); Speed = median seconds per question vs paper time per question.
3. Label rules top-down from `READINESS_CONFIG.labels`; a bar with no evidence never satisfies a threshold.
4. No field anywhere combines bars into one number (contract has none; test asserts response keys).
5. Free: Exam performance + Speed `locked: true, value: null`; label still from all server evidence.
6. Trends are Pro → PRO_REQUIRED for free users.
7. One snapshot per user/exam/IST day (upsert); one Sunday report per user per IST week (unique).
8. Report lines are templates from server data only; no "you will be selected" text (copy test).
9. Q27: Phase 2 label rules apply to TN exams only; other families show bars without a label until their wave.

## Domain events
None published. Consumes `mastery.lamp_changed`, `practice.answered`, `exam_hall.mock_submitted` (snapshot refresh, via worker).

## Firewall
None.
