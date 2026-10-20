# INT-002: Week 2 Core study loop

| | |
|---|---|
| Status | draft (elaborate after INT-001 passes G-I) |
| Blueprint | §5.1, §6, §11, §17.3, §19.2–19.6, §39, §43 week 2 |
| Risk tier | T1 (mastery and exam-hall at 90% coverage) |

## Why
"A user can study for a week offline/online, and lamps light, dim, and relight correctly" (§43 week 2).

## Scope (to elaborate into stories)
- `mastery`: ring transitions, 1→3→7→21-day recall ladder, dimming scheduler, relight, Revision Shield, rank from lamps only
- `practice`: sessions, 30/day free limit (IST day), mistake loop
- `exam-hall`: OMR + CBT, resume, negative marking, State Mock Sunday, scoring and reports
- `plan`: My Plan, Today Card, kind auto-rebalance, Final Stretch
- `readiness`: four evidence bars, trends, Sunday Report
- `notifications`: FCM/APNs, 3-a-day budget, quiet hours; changedetection webhook → Exam Alerts (human-checked)
- App: Today, practice/recall, PYQ Vault, Exam Hall, Readiness Meter, My Plan, Exam Alerts, offline packs + outbox sync, Calm Mode, Lite Mode

## Units
U-mastery, U-practice, U-exam-hall, U-plan, U-readiness, U-notifications, U-app-today, U-app-study, U-app-exam-hall
