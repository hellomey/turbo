# INT-007: Study Rooms (live group study, server-timed focus hours)

| | |
|---|---|
| Status | **draft** (spec written 2026-10-22; architect to decompose and write the ADR for the `focus` module) |
| Blueprint | §9.11 (new); §1 decision 18; §3 names; §5.1, §5.2; §5.3 firewall rule 5; §7; §9.5; §9.10; §10.5, §10.7, §10.9; §11; §17.5 Moderator, System; §18; §19.7 Q70; §19.9 Q89; §19.10 Q98; §22; §23; §24; §34; §36 `focus` (proposed); §37; §39; §40; §43 row 3b |
| Decision | D-2026-10-22-02 (founder) |
| Risk tier | **T2**: game fairness (boards, anti-cheat), personal data (presence, visibility), the money/game firewall (rule 5), and user-generated names in public rooms. Coverage ≥ 90% on `focus`. |
| Owner (conductor) | conductor |
| Founder approval (G-I) | _pending_ |

## Why
The founder found that CA and CS students study alone for years, often without an academy. Many use a group study app
where everyone preparing for the same exam joins a group and sees "this person studied 12 hours today, that person
15 hours"; they say it motivates them and makes them compete. Study Rooms bring this into HeyMey's game layer, with
HeyMey's rules: the server is the source of truth (§34.1), boards are kind (§19.7 Q70), nothing rewards unhealthy days
(§9.10 spirit), and money never touches it (§5.3).

## Scope
- **In (Phase 3, row 3b of §43):** public Study Rooms per exam (and per paper where configured), Squad Rooms, focus
  sessions (start/pause/resume/end on the server), heartbeats, auto-pause, "Still studying?" check, Studying now,
  Hours Boards (Today / This week, IST, capped), focus days, nudges, Calm Mode hiding, privacy toggles, report + block,
  cheat flags, firewall tests, link of focus hours to `plan` study log.
- **Out:** free-text chat in rooms (squad chat stays in `squads`); video/camera/audio rooms; rewards worth money (never);
  rank effects (never, §5.2); Desk moderation screens (INT-004, reports are stored in Phase 3); offline sessions on boards (never, §18).

## Stories

> Server time = injected `Clock`; days and weeks in Asia/Kolkata (§37). Every write has `Idempotency-Key` (§34.3).
> Numbers marked "Q…" are open questions; tests use the values from `aidlc/decisions.md` once answered.

### INT-007-S01: Join a Study Room — T1
As an aspirant, I want to join a live room with people preparing for my exam, so that I don't study alone. [§9.11 Rooms]

- Given I follow exam X, When I open Study Rooms, Then I see the public room for X (and per-paper rooms if configured) and my Squad Room if I am in a squad.
- Given a room group is full (size Q2), When I join, Then the server places me in a room group with space; I never see more than one group's board.
- Given I am not a member of squad S, When I try to join `squadstudy:S`, Then the server refuses (403, stable code) and the socket is not subscribed.
- Given I am in a room, When I open another, Then I leave the first (one room at a time while a session runs).

### INT-007-S02: Server-timed focus session — T2 (fairness)
As an aspirant, I want my focus time counted by the server, so that everyone's hours are real. [§9.11 Focus session, §34.1, §18 clock row]

- Given no active session, When I tap "Start focus", Then `POST /v1/focus/sessions` creates a session with `started_at` = server time.
- Given an active session on device A, When I start on device B, Then the server refuses with a stable code (one session per account) and offers "Move it here", which ends A's session first.
- Given the same start request twice with one idempotency key, Then exactly one session exists.
- Given pause/resume/end, Then each is recorded at server time; credited seconds = sum of time between received heartbeats while running.
- Given the phone clock is changed, Then credited seconds are unchanged.

### INT-007-S03: Heartbeats and auto-pause — T2 (fairness)
As HeyMey, I want time credited only while the app proves the user is there, so that hours can't be faked. [§9.11 Focus session, Anti-cheat]

- Given heartbeats every Q1 seconds, When one is missed beyond the tolerance (Q1), Then the session is auto-paused at the last received heartbeat and `study.session_state` says "Paused: connection lost".
- Given the app reports background, When it stays in background longer than the grace period (Q3), Then the session auto-pauses at the moment it went to background (time inside the grace period is credited only if the app returns within it).
- Given no interaction for the "Still studying?" interval (Q1), When the check is shown and not answered within its window, Then the session auto-pauses at the check time.
- Given a heartbeat with a forged session id or for another user, Then it is rejected and logged.
- Given the realtime server restarts, Then credited time already flushed to PostgreSQL is kept and the session resumes or auto-pauses correctly (no double credit).
- Given an auto-paused session with no resume for Q1 (max idle), Then it ends automatically.

### INT-007-S04: Studying now and member tiles — T1 (T2 privacy)
As an aspirant in a room, I want to see how many people are studying now, so that I feel I'm studying together. [§9.11 Live counts]

- Given N users with running sessions in my room group, Then `study.presence` shows N within 5 seconds of a change (proposed).
- Given a user has public visibility off, Then they count in "Studying now" but have no tile (count-only; confirm Q10).
- Given a tile, Then it shows display name, avatar, shared subject tag (if allowed) and today's capped hours, and nothing else (no email, real name, scores). [§19.9 Q89]

### INT-007-S05: Hours Board (Today, This week), IST and capped — T2 (fairness)
As an aspirant, I want daily and weekly boards in my room, so that steady effort is visible. [§9.11 Live counts and boards, §19.7 Q70, §37]

- Given sessions crossing midnight IST, Then seconds before 00:00 IST count to the earlier day, after to the new day.
- Given my credited hours today exceed the daily board cap (Q4), Then the board shows the cap value with "cap reached", and the week total uses capped days only.
- Given any board, Then I see the top places (count: Q2) and my own place only; given I hide myself, Then I disappear from boards immediately.
- Given offline study, Then it never appears on boards. [§18 offline row]
- Given an account flagged for cheating, Then it is removed from boards until review.
- Week boundaries: Q5.

### INT-007-S06: Focus days (personal record) — T1
As an aspirant, I want to see my focused days and hours over time, so that I see my consistency. [§9.11 Personal record, §7]

- Given a day with at least the minimum focused time (Q6), Then it counts as a focus day.
- Given I miss a day, Then nothing resets to zero, and no text says "streak lost", "you broke", or similar (copy test against a banned-phrase list). [§7]
- Given my personal totals, Then they show real credited hours, including above the board cap.
- Rewards for focus days, if any: Q7 (never Sparks; firewall S10).

### INT-007-S07: Hours feed My Plan, not rank — T1
As an aspirant, I want my focus time to show up in my plan and next to the lamps I worked on, so that it helps my preparation. [§5.1 changed, §5.2 changed, §19.2]

- Given a session tagged with topics, When it ends, Then credited minutes are written to `plan`'s study log through its public API, with the topic tags.
- Given lamps I lit/relit during the session, Then the session summary lists them; no ring changes because of time alone (test: a 3-hour session with no checks changes no `UserTopicState`).
- Given any amount of focus hours, Then the Career Ladder level is unchanged (test: rank function input does not include focus data).

### INT-007-S08: Wellbeing guardrails — T1
As an aspirant, I want reminders to take breaks and rest, so that the competition doesn't harm me. [§9.11 Wellbeing, §9.10, §10.7, §19.10 Q98]

- Given a continuous session reaches the break threshold (Q8), Then `study.nudge` (break) is sent once, and again every Q8 interval; the session is not paused by it.
- Given my credited day reaches the cap, Then a rest nudge is sent and the board stops adding hours.
- Given a session between 12 AM and 5 AM IST, Then a sleep reminder is shown; board counting follows Q8.
- Given Calm Mode, Then the room shows no boards, no counts, no tiles; the timer works.
- Given any room screen, Then Wellbeing Corner and Tele-MANAS 14416 are reachable in one tap.
- Given any text, Then nothing celebrates hours above the cap (no badge, no title, no message).

### INT-007-S09: Privacy and visibility — T2 (personal data)
As an aspirant, I want to choose who sees my study hours, so that I stay private if I want. [§9.11 Privacy, §19.9 Q89, §17.5 Supporter, §23]

- Given a new account, Then public-room visibility follows the default in Q10 (proposed: off) and nothing is pre-ticked. [§17.1 step 8 "nothing pre-ticked"]
- Given Squad Room visibility is a separate setting, When I change one, Then the other is unchanged.
- Given a supporter, Then they see focus hours only if I allowed it.
- Given account deletion, Then focus sessions are erased with personal data (§38.7); boards drop me on the next refresh.
- Given an account reported as under 18, Then it is paused per §18 and removed from all rooms.

### INT-007-S10: Money/game firewall for study hours — T2
As HeyMey, I want study hours kept apart from money, so that we stay within §5.3 and §30. [§5.3 rule 5, §18 new rows, §30]

- FW test (new, number assigned by `security`): no code path writes to `SparksLedger` from `focus` (import/boundary test + behaviour test).
- FW test: an account with Pro/Exam Pass/Season Pass and one without, with identical heartbeats, get identical credited seconds, caps, board places and focus days.
- FW test: no product in `billing` has an effect on `focus` (no entitlement is read by `focus`).
- FW test: no Store item or cosmetic adds, protects or restores hours or focus days.

### INT-007-S11: Moderation, report and block — T1 (T2 for names)
As an aspirant, I want to report or block someone in a room, so that rooms stay safe. [§9.11 Moderation, §17.5 Moderator, §18 harassment row]

- Given a room, Then there is no free-text input; reactions are a fixed list.
- Given I report a display name or avatar, Then a moderation case is created (`moderation` module; stored in Phase 3, worked in the Desk in Phase 4) and I get a confirmation.
- Given I block a user, Then they disappear from my room view and boards.
- Given reactions, Then they are rate-limited per user (value proposed by architect).

### INT-007-S12: Cheat flags — T2 (fairness)
As Ops, I want suspicious focus patterns flagged, so that boards stay honest. [§9.11 Anti-cheat, §17.5 System]

- Given a device integrity check fails, Then sessions from it do not count on boards.
- Given the same device used by two accounts for sessions, Then both are flagged.
- Given patterns beyond thresholds (Q12), Then the account is flagged and hidden from boards pending review; the user is told plainly.

**Non-functional (all stories)**
- **Performance (§24):** focus REST writes p95 ≤ 300 ms; presence update fan-out ≤ 5 s (proposed); heartbeats must not drain battery (interval Q1); Lite Mode room screen at 60 fps on a 3 GB phone; boards from Valkey sorted sets.
- **Offline (§39, §34.2):** sessions need a connection to count for boards; the app shows "Offline: your time isn't counting on boards" plainly.
- **Accessibility (§10.9):** timer and counts read by TalkBack/VoiceOver; 200% text; 48 dp targets; boards readable without colour.
- **Security (§23):** socket auth with access JWT; server checks room membership on every join; rate limits on start/heartbeat/react; no personal data in logs.
- **Copy (§10.2):** simple English ("Start focus", "Pause", "End", "Studying now", "Not now"); no shaming; no "streak lost".
- **Dark Patterns (§13):** no offer is ever shown inside a room or on a nudge (proposed rule; confirm Q13).

## Units (proposed, architect to confirm with an ADR)
| Unit | Modules / features | Tier | Owning agent | Depends on |
|---|---|---|---|---|
| U-focus (new module) | `packages/domain/src/modules/focus` (rooms, sessions, crediting, caps, boards, focus days, cheat flags) | T2 (90%) | backend | `squads` (membership), `plan` (study log), `users` (privacy), `moderation` (reports) via public APIs: **new `module.json` deps → ADR** |
| U-realtime-study | `apps/realtime` `study:*` / `squadstudy:*` rooms, heartbeat intake, presence in Valkey | T2 | realtime | U-focus, socket contracts |
| Contracts/schema | `packages/contracts` (REST + `study.*` events), `packages/db/prisma` (StudyRoom, RoomMembership, FocusSession, FocusSegment, FocusDayTotal) | T2 | architect | ADR |
| U-app-study-rooms | `dart/hm_features/lib/src/study_rooms` (rooms, timer, board, nudges, privacy) | T1 | flutter-ui | contracts |
| Firewall tests | `packages/domain/test/firewall/` (additions only) | T2 | security + qa | U-focus |

## Success metrics (Operations)
- Share of weekly active users who run ≥ 1 focus session (target to set with founder).
- Day-30 retention of room users vs non-users (§29 18% month 6).
- Share of credited days at the cap < 5% (proposed; a higher share means the cap or nudges need work).
- Faked-time reports and cheat flags reviewed within 72 h.

## Open questions (founder)
- [ ] Q1: Heartbeat interval, missed-heartbeat tolerance, "Still studying?" interval and answer window, max idle before an auto-paused session ends. (Battery vs accuracy; architect proposes numbers.)
- [ ] Q2: Room group size; number of top places on boards; per-paper rooms or per-exam only at MVP.
- [ ] Q3: Background grace period. Does time in another app (PDF reader, calculator, a textbook app) count? Proposed: short grace only; long background = paused.
- [ ] Q4: Daily board cap (hours). The founder's example mentions 12–15 hours/day; the guardrail says nothing rewards unhealthy days. Proposed cap: to be set by the founder with wellbeing advice.
- [ ] Q5: Week boundary for "This week" (Monday 00:00 IST proposed, matching the §8 calendar).
- [ ] Q6: Focus days: minimum minutes for a day to count; name in the app ("Focus days"?); shape of the record (longest run, monthly count, weekly target) given §7 "missing a day never resets you".
- [ ] Q7: Any rewards for focus hours or focus days (Points, cosmetics, XP)? XP note: §5.2 says rank comes only from lamps; INT-002 Q7 on XP is still open. Never Sparks (§18 "milestones hard to fake").
- [ ] Q8: Break-nudge threshold and repeat interval; do 12 AM–5 AM hours count on boards?
- [ ] Q9: Offline study time: shown in private totals (as unverified) or not at all?
- [ ] Q10: Default visibility on public boards and in Squad Rooms; are hidden users counted in "Studying now"?
- [ ] Q11: Where Study Rooms live in navigation (Squad tab proposed) and whether Today gets a "Start focus" shortcut.
- [ ] Q12: Cheat thresholds (e.g. very long sessions without pauses, many days at the cap) and what the user sees when flagged.
- [ ] Q13: Confirm: no offers or paywalls inside rooms or nudges.
- [ ] Q14: Placement: Study Rooms MVP in Phase 3 after the week-3 money/game bolts, behind a feature flag (§43 row 3b). Accept, or move to Phase 4 / after launch?
- [ ] Q15: Can Study Rooms open for a not-yet-launched exam family (e.g. CA/CS) before its lamps/content exist, as an early way in (links INT-006 Q1)?

## Outcome (filled at G-O)
