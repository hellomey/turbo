# INT-002: Phase 2 (Week 2) Core study loop

| | |
|---|---|
| Status | **elaborating** (spec done; architect to confirm units; ready for G-I once open questions are answered) |
| Blueprint | §43 week 2 (scope + done-when); §5.1, §5.2, §6, §9.9 (State Mock Sunday), §9.10, §10.5–§10.9, §11, §13, §17.1 step 9/11, §17.3, §17.5 (Ops, System), §18, §19.2, §19.4, §19.5, §19.6, §19.8, §19.10 Q93/Q97, §20.2 (changedetection), §22, §24, §34, §36, §37, §39, §44, §45 |
| Risk tier | **T1** overall; mastery + exam-hall at 90% coverage (§44). Stories touching paywall/limit copy (S04, S07) and Exam Alerts publishing (S12) are **T2** (offer text §13; official-data correctness §18) |
| Owner (conductor) | conductor |
| Founder approval (G-I) | _pending_ |
| Changed | 2026-10-22: exam-agnostic build rules R1–R7 and Q26–Q27 added (D-2026-10-22-01); blueprint §1a, §22, §36, §43 note apply |

## Why
"A user can study for a week offline/online, and lamps light, dim, and relight correctly" (§43 week 2, done-when).
This is the serious preparation core under the game layer (§2): rings that show real memory (§5.1), a plan with one
clear next action (§19.2 Q16), honest mocks (§10.6 Exam Hall) and an honest Readiness Meter with "no single fake
percentage" (§19.5 Q46).

## Scope
- **In (server, §43 wk 2):** `mastery` (rings, dimming, relight scheduler, rank from lamps), `practice` (sessions,
  30/day free limit, mistake loop), `exam-hall` (OMR + CBT + scoring, State Mock Sunday), `plan` (My Plan, Today Card,
  rebalance, Final Stretch), `readiness` (Readiness Meter, trends, Sunday Report), `notifications` (push, 3/day budget,
  quiet hours), changedetection webhook → Exam Alerts (human-checked).
- **In (app, §43 wk 2):** Today screen, practice/recall, PYQ Vault, Exam Hall, Readiness Meter, My Plan, Exam Alerts,
  offline packs + outbox sync, Calm Mode, Lite Mode.
- **Out (and where it goes):**
  - Check-in, lucky games, featured game, Revision Shield, 2× XP hour, Points, Sparks milestones → INT-003 (`economy`, `games`). The Today tiles for these are not built in Phase 2 (see Q22).
  - Real Pro / Exam Pass entitlements and purchase flows → INT-003 (`billing`). Phase 2 uses the `billing` public-API stub ("free" for everyone) per `units.md` note.
  - Squad items on Today, squad good-luck messages → INT-003.
  - Feature flags / emergency switch → INT-004 (`liveops` stub in Phase 2).
  - Desk review screens for Exam Alerts → INT-004 Desk (see Q17 for the Phase 2 stop-gap).
  - AI-written Sunday Report notes (§20.4 nightly batch) → needs `ai` (INT-003); see Q15.
  - Answer Key Day, cutoff history, Attempt Review, Exam Compare, Aptitude Path, Current Affairs, Library → not in §43 wk 2; later intents.
  - Pro-only items: life profiles, pace forecast (§19.2 Q14, Q19), Retry Wrong Only, Custom Test Builder (§19.4 Q39–40), trends + "Why did this change?" (§19.5 Q44, Q47) → see Q12 (build behind entitlement now or later).

## Exam-agnostic build rules (changed 2026-10-22, D-2026-10-22-01)
The founder widened the scope to all Indian competitive and professional exams (blueprint §1a). Phase 2 still ships
with Tamil Nadu data only, but is **built exam-agnostic**, so later waves (SSC/Banking/Railways, CA, CS, UPSC) need data
and content, not rewrites. These rules apply to every Phase 2 story and unit:
- **R1 Exam shape is data.** `exam-hall`, `plan`, `mastery`, `readiness` read exam family → exam → stage → paper →
  section, marking scheme (marks, negative marking, qualifying-only), time and answer mode from `exams`. No TNPSC
  constant in code (test: a fixture family "TEST-FAMILY" with a different scheme runs S10 end to end).
- **R2 Attempt cycles, not "the exam date".** Plans, Final Stretch, countdowns and the 7-day starter path target the
  aspirant's chosen **attempt cycle** and its next **stage** date (INT-006-S03).
- **R3 Question type is a field.** Phase 2 builds objective MCQ only, but `Question` carries a type so descriptive
  questions can be added later without a migration that breaks the live app (§42 rules).
- **R4 Answer modes.** Exam Hall builds OMR and CBT; the paper's answer-mode enum includes `descriptive`, which is
  refused with a stable error code in Phase 2 (INT-006-S02).
- **R5 Content language is per paper**, not "Tamil if Tamil Language paper" (blueprint §1 decision 3, changed).
- **R6 Rank titles and event scope are data.** Career Ladder titles are read per exam family; State Mock rank is
  "among takers of this exam" with a family scope (TN = statewide).
- **R7 Schema first.** BOLT-0008 includes the exam-family schema (architect ADR) before any Phase 2 module design.

## Stories

> Tiers per story. Every AC is written to become a test name. "Server time" = injected `Clock`, day boundaries in
> Asia/Kolkata (§37). All writes carry `Idempotency-Key`; offline study actions use the client UUID as key (§39).

### INT-002-S01: Light a lamp (Lit ring) — T1
As an aspirant, I want a lamp to light when I finish its lesson or mapped textbook pages and pass a 3-question check, so that my map shows what I have learned. [§5.1, §10.6 Lesson "Check yourself"]

- Given a topic with no rings, When I complete its lesson and pass the 3-question check, Then the server sets `lit_at` to server time and returns the new topic state with ring = Lit.
- Given I fail the 3-question check, When the result is recorded, Then the lamp stays unlit and the attempt is logged as a study log.
- Given the same check is submitted twice with the same idempotency key, When the server processes it, Then the lamp state changes once.
- Given a topic shared by two of my exams, When it lights, Then one lamp lights and it carries both exam colours. [§5.1]
- Given the phone clock is set forward, When I submit, Then `lit_at` uses server time. [§18 clock row]
- Pass threshold for the check: **open question Q1**.

### INT-002-S02: Remember a lamp (Steady ring via the recall ladder) — T1
As an aspirant, I want recall checks after 1, 3, 7 and 21 days, so that a Steady ring proves I remember the topic. [§5.1, §6 "Evening: recall checks", §19.6 Q51]

- Given a Lit lamp, When the server schedules recall, Then `next_due_at` = lit time + 1 day, then +3, +7, +21 after each passed recall (IST day logic).
- Given a recall is due, When I pass it, Then `steady_level` increases by one step and `next_due_at` moves to the next gap.
- Given I fail a recall, Then the outcome follows the rule in **Q2** (blueprint does not say whether the ladder resets).
- Given a recall check submitted before `next_due_at`, When the server checks it, Then it does not advance the ladder.
- When Steady counts as earned (first passed recall vs full ladder) and what happens after 21 days: **Q2**.

### INT-002-S03: Dimming and Relight — T1
As an aspirant, I want overdue lamps to dim and to relight them in 2–5 minutes, so that the map shows my real memory. [§5.1 Dimming, §4 "timers that bring you back", §17.5 System "lamp dimming schedule"]

- Given a lamp passes `next_due_at` by server time, When the dimming scheduler runs (worker), Then `dim_state` becomes dimming and the lamp flickers on the map.
- Given a lamp stays overdue beyond the limit in **Q3**, When the scheduler runs, Then the Steady ring is removed, and the ring history stays stored.
- Given a dimming lamp, When I complete a relight and pass, Then `dim_state` clears and the lamp is scheduled for its next recall.
- Given relight is offered, Then it is sized to take 2–5 minutes (question count: **Q5**).
- Given I can't open a topic (free limits, §11 "Relight: for topics you can open"), Then it is not in my relight queue. (Phase 2 stub: everyone can open free topics only; see Q12.)
- Given the scheduler runs twice for the same window, Then no lamp changes twice (idempotent job).
- Given a 7-day simulated week with fake clock (§43 done-when), When a scripted user studies, skips 3 days, and returns, Then light → dim → relight states match a golden expected timeline. **This is the Phase 2 acceptance test.**

### INT-002-S04: Gold ring — T1
As an aspirant, I want to pass a timed, exam-level set with 80% or more, so that Gold shows I'm exam-ready. [§5.1]

- Given a Lit lamp, When I score ≥ 80% on its timed Gold set within the server-timed limit, Then `gold_at` is set.
- Given I score 79%, Then no Gold. Given answers arrive after the server deadline, Then they are not counted.
- Set size, time limit, prerequisite (Lit vs Steady), and whether Gold is lost when dimming: **Q4**.

### INT-002-S05: Career Ladder rank from lamps only — T1
As an aspirant, I want my rank to come only from my Lit, Steady and Gold lamps, so that it is honest proof of mastery. [§5.2, §5.3 firewall rule 4]

- Given a change in my ring counts, When rank is recomputed on the server, Then the level (1 Aspirant … 11 Chief Secretary) follows the threshold table in **Q6**.
- *(changed 2026-10-22, D-2026-10-22-01)* Given the rank titles, Then they are read from the exam family's title set (TN titles for TNPSC; R6); the level number logic does not depend on the family's titles. Given any amount of Study Room focus hours (INT-007), Then rank is unchanged.
- Given any purchase or entitlement, Then rank is unchanged (test: rank function takes only ring counts as input).
- Given a rank-up, Then the app shows the rank-up screen with "Game title. Not an official designation." on the Rank Card. [§5.2, §10.6]
- XP amounts and which module owns XP: **Q7**.

### INT-002-S06: Practice and recall sessions — T1
As an aspirant, I want one question per screen with big tap targets and instant feedback with an explanation, so that I learn from each answer. [§10.6 Practice/recall, §19.4 Q32, Q38]

- Given a practice session, When I answer, Then the answer is saved on the phone instantly and shows correct/wrong with the explanation and source (exam, year, number). [§24, §19.4 Q32, §19.8 Q76]
- Given a question flagged as affected by later changes, Then it shows the note. [§19.4 Q33]
- Given a wrong answer, Then mistake review shows why mine was wrong, why the answer is right, and which lamp to relight. [§19.4 Q38]
- Given every question, Then a "Report" control exists (report intake belongs to `content`, INT-001; confirm route exists: dependency D1). [§19.4 Q34]
- Given a weak spot after a session, Then the affected lamps are marked on my map. [§19.5 Q41]

### INT-002-S07: Free practice limit (30 a day, IST) — **T2 (paywall copy)**
As a free user, I want 30 practice questions a day, so that I can prepare seriously for free. [§11, §13, §37 error example]

- Given 30 practice answers today (Asia/Kolkata day), When I request the 31st, Then the server returns `PRACTICE_DAILY_LIMIT` with message "You've used today's 30 free questions." [§37]
- Given 23:59 IST with 30 used, When the IST day turns at 00:00, Then the count resets. Given the phone clock is changed, Then the count is unchanged. [§18]
- Given offline answers synced later, Then they count toward the IST day they were answered on, as judged by the server within §39 limits (exact rule: **Q8**).
- Given the limit is hit, Then the screen shows the §13 limit message with a visible "Not now" button, appears at most once a day, and never blocks lessons, relights or mocks. [§13]
- Given the `billing` stub in Phase 2, Then everyone is free; whether the Pro offer line is shown before Pro can be bought: **Q10**.
- Which question types count toward 30 (recall, relight, Lit check, Gold set, onboarding first lamp): **Q8**.

### INT-002-S08: Mistake loop — T1
As an aspirant, I want repeated mistakes to create a concept drill and an explanation from another angle. [§36 practice, §19.6 Q60 (Pro)]

- Given the same concept answered wrong N times, Then a concept drill is created (N and Pro gating: **Q9**).

### INT-002-S09: PYQ Vault — T1
As an aspirant, I want PYQs filtered by exam, year, subject, topic and difficulty, so that I practise the real thing. [§19.4 Q31, §11]

- Given a free user, When I open the Vault, Then I see the latest 2 years; older years show a "Pro" marker before I tap. [§11, §19.9 Q82]
- Given any filter combination, Then results are cursor-paginated (`?cursor&limit=20`) and p95 ≤ 300 ms. [§37, §24]
- Given a Tamil Language paper question, Then it is shown in Tamil; all other interface text stays English. [§1 decision 3, §19.4 Q35] *(changed 2026-10-22, D-2026-10-22-01: the language comes from the paper's content-language field, R5; the Vault filters by family → exam → stage → paper as well as year, subject, topic, difficulty.)*
- "Latest 2 years" is relative to which year: **Q23**.

### INT-002-S10: Exam Hall (OMR + CBT, scoring, resume) — T1 (90% coverage)
As an aspirant, I want mocks that match the official pattern, marking and time in OMR or CBT mode, so that test day feels familiar. [§10.6 Exam Hall, §19.4 Q36–37, §9.10]

- Given a mock, When I start, Then the server issues the start time and deadline; the timer is server time. [§34.1, §18]
- Given OMR mode, Then I see a bubble sheet; given CBT mode, Then a question palette with mark-for-review. [§10.6]
- Given the Exam Hall is open, Then no game styling, no game sounds, no animations, no haptics, no alerts. [§9.10, §10.4]
- Given the app is killed mid-mock, When I reopen, Then the mock resumes exactly where I left off with server remaining time. [§19.8 Q76]
- Given negative marking in the exam pattern, When scored on the server, Then marks = correct × mark − wrong × penalty per pattern; unanswered = 0. (Pattern data source: **Q11**.)
- *(changed 2026-10-22, D-2026-10-22-01)* Given two papers with different marking schemes (incl. no negative marking, sectional limits, qualifying-only), When the same answers are scored, Then each uses only its own scheme from `exams` (R1). Given a paper with answer mode `descriptive`, Then starting a mock is refused with a stable error code (R4). Given OMR vs CBT, Then the mode comes from the paper's answer mode, not from the exam name.
- Given a free user, Then 1 full mock a month + every State Mock Sunday; the 2nd mock in a month is refused with a stable error code and "Not now". [§11] (Month = IST calendar month? **Q12**.)
- Given a submitted mock, Then the report shows score, sectional results, mistakes linked to lamps, and a blurred preview of the full Pro report. [§13 "Proof before payment", §19.4 Q38]
- Given mock answers, Then Gold/ring effects follow §5.1 only through `mastery` public API.

### INT-002-S11: State Mock Sunday — T1
As an aspirant, I want one full mock for the whole state at the same time on the 1st and 3rd Sunday with a statewide rank, free for everyone. [§9.9, §8, §17.2]

- Given the 1st or 3rd Sunday (IST), Then the mock opens at the scheduled time for all users and is free.
- Given an attempt made or synced offline, Then it never counts for the statewide rank. [§18 offline row, §39]
- Given results, Then statewide rank is computed on the server. Start time, late-join window, rank publish time and who schedules it without `liveops` (week 4): **Q13**.
- Load: State Mock Sunday k6 scenario is INT-004 (§43 wk 4); Phase 2 adds a smoke-level concurrency test only.
- *(changed 2026-10-22, D-2026-10-22-01)* Given the mock-day schedule, Then it is stored with an exam-family scope (State Mock Sunday = TNPSC family, "statewide"); ranks are computed among takers of the same exam/paper (R6). Only the TN schedule is loaded in Phase 2.

### INT-002-S12: My Plan and Today Card — T1
As an aspirant, I want a plan built from my study hours and exam date, and one clear "do this now" card, so that I always know what to do. [§19.2 Q11–Q13, Q15–Q18, Q20, §17.1 step 9, §10.5, §10.6 Today]

- Given weekday/weekend hours and an exam date (auto-filled from `exams`), When I finish onboarding step 9, Then My Plan is created with lamps and time estimates on a calendar. [§17.1 step 9]
- Given a new user, Then a 7-day starter path is built for the main exam. [§19.2 Q11]
- Given the Today screen, Then it shows the rank badge + XP bar at top, one big Today Card, and "Relight N · M min" for dimming lamps. [§10.6 Today]
- Given pocket-session choice, Then 5/10/15-minute sessions are offered. [§19.2 Q15]
- Given I missed days, When I return, Then the plan auto-rebalances and shows a kind welcome-back; nothing says "streak lost". [§19.2 Q18, §7]
- Given the exam date changes (`exams.date_changed`), Then the plan stretches or shrinks automatically. [§19.10 Q97]
- Given up to 3 exams, Then one calendar with separate dates. [§19.10 Q94]
- Rebalance and balance-dial rules (new topics / relights / PYQs / mocks mix): **Q19**.
- *(changed 2026-10-22, D-2026-10-22-01)* Given I prepare for an exam with several stages or attempt cycles, Then the plan targets my chosen attempt cycle and its next stage date (R2), and "exam date (auto-filled)" in onboarding step 9 means that stage date. Given focus hours from Study Rooms (INT-007, Phase 3), Then the plan's study log accepts them through `plan`'s public API (design the StudyLog source field now: `lesson | practice | mock | focus`).

### INT-002-S13: Final Stretch — T1
As an aspirant close to my exam, I want the plan to change at 90/60/30/7 days. [§17.3, §19.10 Q93]

- Given 90 days left, Then the plan prioritises remaining lamps and Gold attempts; 60 days: more mocks + weekly mistake review; 30 days: no new topics unless critical, relight + mocks; 7 days: quiet games, sleep reminders, hall-ticket checklist, exam-centre tips. [§17.3]
- "Critical" topic definition and checklist content: **Q18**.
- *(changed 2026-10-22, D-2026-10-22-01)* Given a multi-stage exam, Then the 90/60/30/7-day windows count down to the next stage date of my attempt cycle (R2). Hall-ticket checklist content is per exam family.

### INT-002-S14: Readiness Meter — T1
As an aspirant, I want four evidence bars and a plain label, so that I know where I stand without a fake percentage. [§19.5 Q42, Q46, Q48]

- Given a free user, Then Coverage and Memory bars are shown; Exam performance and Speed show as Pro. [§11, §19.5 Q46]
- Given any state, Then the label is one of Not yet / Building / Close / Mock-ready, and no single overall percentage is shown anywhere. [§19.5 Q46]
- Given Coverage view, Then Lit / Steady / Gold % for the whole syllabus. [§19.5 Q42]
- Given thresholds are not met, Then sectional tests are suggested; the "Ready for full mocks" badge unlocks at thresholds in **Q14**.

### INT-002-S15: Sunday Report — T1
As an aspirant, I want a weekly report, so that I see proof of study. [§19.5 Q50, §19.10 Q100, §11]

- Given Sunday (IST), When the worker job runs, Then each active user gets a short report (free) built from server data; Pro gets the full one with next week's plan. [§11]
- Given the report, Then it never promises selection. [§19.10 Q100]
- Run time and template vs AI text: **Q15**.

### INT-002-S16: Alerts with a daily budget — T1
As an aspirant, I want at most 3 alerts a day, separate exam alerts, opt-in offers and quiet hours. [§19.8 Q78, §17.1 step 11, §6, §36 notifications]

- Given 3 non-exam alerts sent today (IST), When a 4th is queued, Then it is dropped and logged. Exam Alerts don't count toward the 3.
- Given quiet hours set, Then non-exam alerts inside them are not sent (Exam Alert behaviour in quiet hours: **Q16**).
- Given the morning dimming alert, Then it is sent only when lamps are really dimming ("4 Polity lamps are dimming"). [§6]
- Given offers are not opted in, Then no offer alert is ever sent. Given an active Exam Hall attempt, Then no alerts. [§9.10]
- Given push token registration, Then tokens are stored per device and removed on logout/account deletion.

### INT-002-S17: Exam Alerts from official-site changes — **T2 (official data correctness)**
As an aspirant following an exam, I want an alert within hours of an official notification, after a human check. [§19.1 Q7, §17.5 Ops + System, §20.2, §18 wrong-data row]

- Given changedetection.io posts a webhook, When the API receives it with a valid shared secret, Then a pending change is stored in `exams` and nothing is sent to users.
- Given an invalid or replayed webhook, Then it is rejected (401/409) and logged.
- Given a staff member with the right role approves the change, Then `exams.notification_published` fires and followers get an Exam Alert linking to the official notification with "Always confirm with the official notification."
- Given no human approval, Then no alert is ever sent.
- Phase 2 approval surface before HeyMey Desk (week 4): **Q17**.

### INT-002-S18: Offline study and outbox sync — T1
As an aspirant with weak data, I want to study offline and have my answers sync later. [§39, §19.3 Q28, §19.8 Q72–73, §34.2]

- Given an answer, lesson-complete or relight offline, Then it is written to Drift first and added to the outbox with a client UUID + timestamp.
- Given connectivity returns, Then the outbox is sent in batches; the server accepts each UUID once and returns authoritative topic state; the app replaces its local rings with the server's. [§39]
- Given conflicting rings, Then the server wins; notes/bookmarks: last write wins. [§39]
- Given an action older than 7 days at sync, Then it is stored as a study log only and changes no ring. [§39]
- Given offline actions, Then they never earn ranked rewards or statewide mock rank. [§39, §18]
- Given content packs, Then they are versioned zips from `cdn.heymey.app`, Wi-Fi-only by default, SHA-256 checked; a checksum mismatch discards the pack. Free users download free content only. [§39, §11]
- Given overnight scheduling, Then downloads can wait for Wi-Fi at night. [§19.8 Q73]

### INT-002-S19: Calm Mode — T1
As an aspirant who wants it simple, I want a Today screen with only Today Card, Study and Relight, bigger text, voice guidance and fewer animations, with the same account and progress. [§10.7, §19.8 Q79]

- Given Calm Mode on, Then Today shows only Today Card, Study, Relight; competitive items are hidden; switching off restores them with no data change.

### INT-002-S20: Lite Mode — T1
As an aspirant on a low-end phone, I want a static map, simple animations and compressed images, with every core feature working. [§10.8, §24]

- Given a phone with ≤ 3 GB RAM, Then Lite Mode switches on automatically (user can override, per INT-001 shell switch).
- Given Lite Mode, Then every Phase 2 screen renders at 60 fps on the 3 GB reference phone. [§24]

## Non-functional criteria (all stories)
- **Performance (§24):** API p95 ≤ 300 ms for all Phase 2 routes; answer save instant (local first); 60 fps screens in Lite Mode on a 3 GB phone; install size stays ≤ 40 MB (content in packs).
- **Offline (§39, §34.2):** study (lessons, practice, recall, relight, non-State mocks: see Q25) works offline; State Mock Sunday rank, alert sending online only.
- **Accessibility (§10.9, §11 last line):** TalkBack/VoiceOver labels on every control, 200% text, high contrast, rings differ by shape and colour, 48 dp targets, Listen Mode on explanations; never behind a paywall.
- **Security (§23, §37):** server-side authorisation on every route; rate limits per user/IP; webhook shared secret; no personal data in logs or to AI.
- **Copy (§10.2):** simple English, verb buttons ("Start", "Relight", "Not now"); no Tamil in interface text; tap-to-see glossary for exam terms (negative marking, OMR, CBT).
- **Dark Patterns (§13):** limit messages and Pro previews: "Not now" always, once a day max, never block study, no fake urgency; compliance review + founder approval of the text.
- **Time (§37, §18):** server time everywhere; IST days; fake clock in tests.
- **Coverage (§44):** mastery, exam-hall ≥ 90%; others ≥ 70%; goldens for every new screen in dark/light/high-contrast/Calm/200% text.
- **Observability (§45):** scheduler run counts, dimmed-lamp counts, outbox sync failures, alert budget drops in Grafana.

## Units
| Unit | Modules / features | Stories | Tier | Owning agent | Depends on |
|---|---|---|---|---|---|
| U-mastery | `packages/domain/src/modules/mastery`, `apps/worker` (dimming scheduler) | S01–S05, S18 (server side) | T1 (90%) | backend | syllabus, content (INT-001) |
| U-practice | `modules/practice` (+ `billing` stub read) | S06–S09 | T1; S07 copy T2 | backend | content, mastery, billing stub |
| U-exam-hall | `modules/exam-hall` | S10, S11 | T1 (90%) | backend | content, mastery, billing stub; exams (pattern, Q11) |
| U-plan | `modules/plan`, `apps/worker` (rebalance) | S12, S13 | T1 | backend | syllabus, mastery, exams |
| U-readiness | `modules/readiness`, `apps/worker` (Sunday Report) | S14, S15 | T1 | backend | mastery, practice, exam-hall |
| U-notifications | `modules/notifications`, `apps/worker` (FCM/APNs sender) | S16, S17 (send) | T1 | backend | users, liveops stub; consumes `exams.notification_published` (architect to confirm event wiring needs no new dependency) |
| U-exams (extension) | `modules/exams` (webhook intake, pending change, approve) | S17 | T2 | backend | syllabus; `roles` guard |
| U-infra (extension) | `infra/` changedetection.io container, CDN pack bucket | S17, S18 | T1 | devops | U-infra (INT-001) |
| U-app-shell (extension) | `dart/hm_data` (Drift tables, outbox for study actions, pack downloader), `hm_core` (Calm/Lite switches) | S18–S20 | T1 | flutter-ui | U-contracts |
| U-app-today | `dart/hm_features/lib/src/today`, `plan`, `alerts` | S05 (rank bar/rank-up), S12, S13, S16, S17, S19 | T1 | flutter-ui | U-plan, U-notifications, U-mastery |
| U-app-study | `hm_features/lib/src/practice`, `pyq_vault`, `study_map` (dimming, relight queue, weak spots) | S01–S04, S06–S09 | T1; limit sheet T2 | flutter-ui | U-mastery, U-practice |
| U-app-exam-hall | `hm_features/lib/src/exam_hall`, `readiness` | S10, S11, S14, S15 | T1 | flutter-ui | U-exam-hall, U-readiness |
| Contracts/schema | `packages/contracts`, `packages/db/prisma` (UserTopicState, PracticeAttempt, Answer, Mock, MockAttempt, MockAnswer, Plan, PlanItem, StudyLog, PushToken, AlertPreference, SendLog, pending exam change) | all | T1 (migration rules) | architect | INT-001 schema v1 |

Not touched in Phase 2: economy, games, squads, billing (stub only), marketplace, institutions, support, moderation, liveops (stub only), ai, analytics (events only if INT-001 provides ingestion), auth/users/roles (consumed only).

### Dependencies on INT-001 deliverables
- D1 `content`: question/lesson serving, versions, sources, explanations, Report route (BOLT-0003).
- D2 `syllabus`: topics (lamps), TopicExamTag for shared lamps (BOLT-0003).
- D3 `exams`: exam dates, followed exams, patterns (BOLT-0003; patterns may need data, Q11).
- D4 `auth`/`users`/`roles`: JWT guard, onboarding state, consent (alerts/offers), staff role for alert approval (BOLT-0002).
- D5 Platform: idempotency, error envelope, rate limits, X-Min-App-Version (BOLT-0001, BOLT-0007 fixes).
- D6 App shell: routing, 5 tabs, session, outbox engine skeleton, Lite/Calm switches, `hm_design` rings (BOLT-0004; **blocked on hm_api compile issue**).
- D7 Infra: staging, worker container, Valkey/BullMQ (BOLT-0005).
- D8 Fake clock in `packages/testing`.
Phase 2 construction should not start until BOLT-0002/0003/0004 pass G-C.

## Proposed bolts
| Bolt | Goal | Units | Owner agent | Tier |
|---|---|---|---|---|
| BOLT-0008 | Unit designs (domain models incl. lamp ring state machine, logical designs) + contract diffs + Prisma schema for Phase 2. *(changed 2026-10-22, D-2026-10-22-01: starts with the exam-family ADR + schema, R7)* | all Phase 2 units | architect (+ backend, flutter-ui authors) | T1 |
| BOLT-0009 | `mastery`: rings, recall ladder, dimming scheduler, relight, rank, sync-accept endpoint; 7-day fake-clock acceptance test | U-mastery | backend | T1 (90%) |
| BOLT-0010 | `practice`: sessions, IST 30/day limit via billing stub, mistake review, mistake loop, PYQ Vault queries | U-practice | backend | T1 / T2 copy |
| BOLT-0011 | `exam-hall`: OMR/CBT attempts, server timer, resume, negative marking, free monthly allowance, State Mock Sunday + statewide rank, reports | U-exam-hall | backend | T1 (90%) |
| BOLT-0012 | `plan`: plan builder, starter path, Today Card, rebalance job, Final Stretch, date-change reaction | U-plan | backend | T1 |
| BOLT-0013 | `readiness`: four bars, label, badge, Sunday Report job | U-readiness | backend | T1 |
| BOLT-0014 | `notifications` (tokens, budget, quiet hours, FCM/APNs worker) + `exams` webhook intake + approve → Exam Alert | U-notifications, U-exams ext | backend | T2 (S17) |
| BOLT-0015 | changedetection.io container, webhook secret, content pack CDN bucket + checksums | U-infra ext | devops | T1 |
| BOLT-0016 | `hm_data`: Drift tables for topic state/plan/answers, outbox for study actions, pack downloader (Wi-Fi only, SHA-256) | U-app-shell ext | flutter-ui | T1 |
| BOLT-0017 | App: practice/recall, Lit check, Gold set, relight queue, dimming on map, PYQ Vault, limit sheet | U-app-study | flutter-ui | T1 / T2 sheet |
| BOLT-0018 | App: Today, My Plan, rank bar + rank-up, Exam Alerts, alert settings, Calm Mode Today, Lite Mode pass | U-app-today | flutter-ui | T1 |
| BOLT-0019 | App: Exam Hall (OMR + CBT, resume, quiet mode), mock report, Readiness Meter, Sunday Report view | U-app-exam-hall | flutter-ui | T1 |
| BOLT-0020 | Reviews + the §43 done-when run on staging (a week of study offline/online, fake clock) | — | qa (+ security for S17 webhook, compliance for S07/S10 copy) | — |

Order: 0008 → (0009 ∥ 0015 ∥ 0016) → (0010, 0011, 0012 after 0009) → 0013, 0014 → app bolts 0017–0019 (after their backend bolt's contract merges) → 0020.

## Success metrics (Operations)
- §43 done-when: scripted 7-day study run on staging passes (light, dim, relight, sync).
- API p95 ≤ 300 ms on Phase 2 routes; outbox sync failure rate < 1% (proposed, founder to confirm); alert budget never exceeded (0 users > 3 non-exam alerts/day).
- Feeds §29 Day-7 retention (25% month 1) once launched.

## Open questions (founder)
- [ ] Q1: Lit check: pass = 3/3 or 2/3? Can it be retried immediately? [§5.1]
- [ ] Q2: Steady: earned at the first passed recall (day 1) or after the full 1→3→7→21 ladder? What does `steady_level` mean per step? After day 21, does recall keep going (e.g. every 21 days)? On a failed recall, step back one or restart? [§5.1, §22]
- [ ] Q3: Dimming: how long overdue before the Steady ring is lost? Is there more than one dim stage? Does a dimmed lamp also lose Gold? [§5.1]
- [ ] Q4: Gold set: number of questions, time limit, must the lamp be Steady first, can Gold be lost? [§5.1]
- [ ] Q5: Relight: number of questions and pass mark (to fit 2–5 minutes)? [§5.1]
- [ ] Q6: Career Ladder thresholds for levels 1–11 (ring counts or weighted score; per exam or across all my syllabuses)? [§5.2]
- [ ] Q7: XP: amounts per study action, which module owns XP (mastery or economy), and how XP relates to rank ("rank comes only from lamps" vs "XP for rank progress")? [§5.2, §5.3]
- [ ] Q8: Which questions count toward the 30/day free limit (recall, relight, Lit check, Gold set, onboarding)? Offline answers synced next day: count on the day answered or the day synced? [§11, §39]
- [ ] Q9: Mistake loop is listed as Pro (§19.6 Q60) but in `practice` scope for week 2: build gated now (stub = everyone free, so everyone gets it) or hide until billing? What repeat count triggers a drill?
- [ ] Q10: Until Pro can be bought (week 3), should limit screens show the Pro price line from §13 or only the limit + "Not now"? (Paywall/offer text needs founder approval.)
- [ ] Q11: Where do exam patterns (marks per question, negative marking, sections, time) come from: `exams` data (Track B) or seed? Are verified patterns for Group 4 and Group 2/2A ready?
- [ ] Q12: "1 full mock a month": IST calendar month or rolling 30 days? Should Pro-only features (Retry Wrong Only, Custom Test Builder, full Readiness, trends, PYQ older years) be built in week 2 behind the entitlement stub, or in week 3?
- [ ] Q13: State Mock Sunday: start time, late-join window, can it be taken later without rank, when the statewide rank is published, and who schedules it before `liveops` (week 4)? [§9.9]
- [ ] Q14: Readiness: thresholds for Not yet / Building / Close / Mock-ready, and for the "Ready for full mocks" badge. [§19.5 Q46, Q48]
- [ ] Q15: Sunday Report: send time, and template-only in week 2 (AI notes need `ai`, week 3, §20.4)?
- [ ] Q16: Quiet hours: default values? Are Exam Alerts sent during quiet hours? Morning alert time? [§19.8 Q78]
- [ ] Q17: Exam Alerts human check before Desk exists (week 4): which role approves, and through what (a minimal staff API, or hold alerts until Desk)? [§17.5 Ops]
- [ ] Q18: Final Stretch: what is a "critical" topic at 30 days, and who writes the hall-ticket checklist and exam-centre tips (content track)? [§17.3]
- [ ] Q19: Rebalance and balance dial: the mix rules by time left; how many missed days trigger a rebalance? [§19.2 Q18, Q20]
- [ ] Q20: Which content packs exist for Phase 2 (per subject? per exam?), and the size limit per pack? [§39]
- [ ] Q21: FCM/APNs need Firebase and Apple push setup in the founder's accounts: who creates them and when? (Blueprint §36 names them; confirms no new paid service.)
- [ ] Q22: Today lists check-in and the lucky-game tile (§10.6) but they are week 3: show nothing, or a placeholder?
- [ ] Q23: PYQ Vault "latest 2 years": the 2 most recent exam years held per exam, or calendar years from today?
- [ ] Q24: Multi-exam plans: one daily hour budget split across up to 3 exams, or by main exam priority? [§19.10 Q94]
- [ ] Q25: Can a normal (non-State) mock be taken offline and synced (§19.8 Q76 resume) given server timers (§34.1)? If yes, how is the time limit enforced?
- [ ] Q26 *(added 2026-10-22, D-2026-10-22-01)*: Confirm Phase 2 builds the exam-family model (R1–R7) now with TN data only. It adds an architect ADR and some schema work to BOLT-0008; it removes a rewrite before waves 1–3. Proposed: yes.
- [ ] Q27 *(added 2026-10-22, D-2026-10-22-01)*: Does the Readiness Meter label ("Mock-ready") and cutoff history (§19.5 Q49) stay TN-only in Phase 2, with the per-family rules decided per wave? Proposed: yes.

## G-I checklist (founder)
- [ ] Every story cites a blueprint section; nothing contradicts the blueprint
- [ ] Acceptance criteria are testable (Given/When/Then)
- [ ] Scope matches §43 week 2 exactly; out-of-scope items are listed with their intent
- [ ] Units, owners and risk tiers are set (architect confirmed the unit table and the `exams` → `notifications` event wiring)
- [ ] T2 items identified: S07 limit copy, S10 Pro preview, S17 Exam Alerts publishing
- [ ] Dependencies on INT-001 (D1–D8) are at G-C, incl. the hm_api compile blocker in BOLT-0004
- [ ] Open questions Q1–Q25 answered in `aidlc/decisions.md` (Q1–Q8, Q11, Q13, Q14 block BOLT-0009/0011/0013 design)
- [ ] Bolt list BOLT-0008…0020 accepted
- Approved by: ______ date: ______

## Outcome (filled at G-O)
