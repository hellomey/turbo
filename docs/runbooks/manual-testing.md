# Manual testing: run HeyMey on the Android emulator

For the founder and testers. Phase 1 (sign-in, onboarding, Study Map, lessons) and Phase 2 (lamps, practice, PYQ Vault,
Exam Hall, readiness, notifications) run locally on your PC. No real emails are sent: every code lands in Mailpit.

## 1. Start everything (once per day)

Open a terminal in `D:\hellomey\turbo` and run, in order:

```bash
# 1. Docker Desktop must be running (whale icon in the tray).
pnpm infra:up                  # Postgres, Valkey, S3, Mailpit
pnpm db:migrate && pnpm db:seed
pnpm dev                       # API :4567, worker, Desk :4569, marketing :4570. Leave this terminal open.
```

In a second terminal:

```bash
# 2. Start the emulator: Android Studio > Device Manager > "Medium Phone API 37.0" > Play.
cd apps/mobile
flutter run -d emulator-5554   # first build takes ~3 minutes
```

The emulator reaches your PC's API at `http://10.0.2.2:4567` automatically.
Open **http://localhost:4585** in your browser: this is the Mailpit inbox where every sign-in code arrives.

Hot reload while the app runs: press `r` in the `flutter run` terminal. Full restart: `R`. Quit: `q`.

## 2. Test accounts

Any email works for a new learner. These exist already:

| Email | Role | Use it for |
|---|---|---|
| `aspirant@heymey.app` | Learner | the normal app |
| `ops@heymey.app` | OPS staff | HeyMey Desk (http://localhost:4569), approving Exam Alerts |
| `admin@heymey.app` | Admin | HeyMey Desk |

Desk needs an authenticator app (Google Authenticator, Microsoft Authenticator) for the second step.

## 3. How to use the app (what to test)

1. **Sign in.** Pick your exam(s) and check eligibility, then enter your email. Open Mailpit, copy the 6-digit code,
   and type it in. Tick "Run my HeyMey account" on the consent screen (the other boxes are optional).
2. **Today.** This is your day: the plan card, lamps due for review, and the "Open Exam Hall" button.
3. **Study Map.** Every topic is a lamp. Open a topic, read or *Listen* to the lesson, tap *Done*, then pass the
   3-question check (2 of 3 right) to **light** the lamp.
4. **Recall.** The lamp comes back after 1, 3, 7 and 21 days. Pass each recall to make it **Steady**. Miss it and the
   lamp dims; the **Relight** queue (5 questions, 4 right) brings it back. A **Gold** check (15 questions in 15
   minutes, 80%) is the top ring.
5. **Practice.** 30 free questions a day (resets at 12 AM IST). On the 31st you see the limit sheet with "Not now".
   Wrong answers go to **Mistakes**. **PYQ Vault** has previous-year questions; the latest 2 years are free.
6. **Exam Hall.** Mock tests with a server timer. Close the app mid-test and open it again: you resume where you
   were. Submit, then open the report. Free users get 1 full mock a month. **State Mock Sunday** runs on the 1st
   and 3rd Sunday at 10:00 IST.
7. **Readiness.** Coverage and Memory bars per exam; the **Sunday Report** arrives at 08:00 IST.
8. **Offline.** Switch the emulator to airplane mode and keep studying. You see "Will sync when online". Turn the
   network back on and the actions sync.
9. **Settings.** Calm Mode (hides ranks and boards), dark/light/high contrast, large text, quiet hours.

### Testing day-based features without waiting

Lamps dim and reports run on schedules. To test them now, ask the developer to run the worker jobs once
(`mastery.dimming`, `readiness.sunday-report`). Changing the emulator's clock does **not** work, because time
comes from the server, which is the point.

## 4. Placeholder data (do not report as bugs)

- Exam patterns, mocks and questions are **SEED** placeholders marked "verify". They are not real exam facts.
- Push notifications are only logged; Firebase and APNs are not set up yet.
- Pro features show as locked and there is no buy button. Billing comes in Phase 3.

## 5. Reporting a bug

Note the screen, what you did, what you expected and what happened, plus a screenshot (emulator side panel, camera
icon). Errors in the app show a short code, for example `PRACTICE_DAILY_LIMIT`. Include it.

## 6. Stop

`q` in the `flutter run` terminal, `Ctrl+C` in the `pnpm dev` terminal, then `pnpm infra:down` (your data is kept).
