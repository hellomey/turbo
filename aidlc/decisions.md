# Decision log

Append-only. Small decisions and answers to open questions. Lasting architecture decisions go to `docs/adr/` instead.
Format: `D-YYYY-MM-DD-NN` · decision · who · links. An **OPEN** entry is a question waiting for the founder.

---

### D-2026-10-20-01 · Repository is a Turborepo + pnpm monorepo with a Dart pub workspace
Decided by: founder (request) + architect. See ADR-0001, ADR-0007.

### D-2026-10-20-02 · OPEN: primary domain
The blueprint uses `heymey.app` everywhere (api., rt., desk., cdn., ops.). The current marketing site uses `heymey.in`
(`metadataBase`, privacy@ / grievance@ addresses) and links to `app.heymey.in`.
**Question for the founder:** is `heymey.app` the primary domain, with `heymey.in` redirecting to it?
Infra (Caddyfile) currently assumes `heymey.app`. Blocks INT-005 and store listings.

### D-2026-10-20-03 · OPEN: marketing site calls to action
In the new product there is no aspirant web app. Proposed: "Get started" → store pre-registration links; "Sign in" removed;
contact form → `POST /v1/public/leads`. **Founder to confirm.** Blocks INT-005.

### D-2026-10-20-04 · Port series
Applications 4567–4579, data services 4580–4589, ops tools 4590–4599; staging = production + 100.
api 4567 · realtime 4568 · desk 4569 · marketing 4570 · worker 4571 · scheduler 4572. Decided by: founder (request) + architect. See ADR-0002.

### D-2026-10-20-05 · Marketing site (Next.js) replaces the blueprint's static `apps/site`
The blueprint §35 planned static HTML legal pages in `apps/site`. The existing Next.js marketing site already has
legal pages and is kept as `apps/marketing` on port 4570. See ADR-0003.

### D-2026-10-20-06 · TypeScript 6.0 (not 7) for now
TypeScript 7 (native compiler) is current, but NestJS relies on legacy decorators + emitDecoratorMetadata. Builds use SWC;
`tsc` 6.0 is used for type-checking. Revisit when Nest and TS 7 confirm support. See ADR-0009.

### D-2026-10-20-07 · OPEN: third-party image versions
`infra/compose/images.env` uses floating tags as placeholders. INT-001 / U-infra must pin each to a verified version and digest
before the first production deploy.

---

## 2026-10-20 (second session): Phase 1 start

### D-2026-10-20-02 · RESOLVED: primary domain is `heymey.app`
Founder: "domain: heymey.app". `heymey.in` is legacy. Infra already uses heymey.app; the marketing site's
`metadataBase`, contact addresses and app links move to heymey.app (BOLT-0005).

### D-2026-10-20-08 · Week N of blueprint §43 is "Phase N"
Founder: "make the week 1 as phase 1". Phase 1 = INT-001, Phase 2 = INT-002, Phase 3 = INT-003, Phase 4 = INT-004.

### D-2026-10-20-09 · INT-001 passes G-I
Founder instruction "lets start our development ... complete the first phase" is recorded as approval of INT-001.
Open questions Q1, Q3, Q4 were answered by the conductor with the defaults below; the founder may override any of them.

### D-2026-10-20-10 · (INT-001 Q1) SMTP is provider-agnostic
The code sends plain SMTP through Nodemailer; the provider is configuration (`SMTP_*`). Local: Mailpit (:4584, inbox :4585).
Production provider (ZeptoMail / SES / Brevo) is chosen in track C with SPF/DKIM/DMARC on mail.heymey.app.

### D-2026-10-20-11 · (INT-001 Q3) Access tokens are EdDSA (Ed25519) JWTs via `jose`
15-minute access tokens; opaque refresh tokens (sha256 stored) rotating per use; 60 days (app) / 12 hours (Desk).

### D-2026-10-20-12 · (INT-001 Q4) Eligibility data in Phase 1
Engine is fully data-driven (Exam + versioned EligibilityRule). Seed data covers TNPSC Group 4, Group 2, Group 2A and
two central exams for local/staging only, marked `SEED - verify against the official notification`. Production
eligibility data is entered and human-checked by Ops (content track B) before `status = published`.

### D-2026-10-20-13 · Free/Pro lesson gating moves to Phase 3
"First 2 topics of every subject free" (§11) needs `billing` entitlements (Phase 3). Phase 1 serves published lessons
to everyone; the gate lands with U-billing without a contract break (a `PRO_REQUIRED` error code is additive).

### D-2026-10-20-14 · Per-user lamp rings arrive in Phase 2
Phase 1 serves the Study Map with every ring unlit (contract field `ring` exists). `mastery` fills it in Phase 2.
Onboarding steps 6 ("light your first lamp") and 9-10 (hours/plan, squad) move to Phase 2/3 with their modules.

### D-2026-10-20-15 · Graphify is the code knowledge graph for every agent
`graphifyy` installed project-scoped (skill in `.claude/skills/graphify`, `.agents/skills/graphify`; PreToolUse hooks;
git hooks rebuild `graphify-out/graph.json` on commit/checkout). Agents query the graph before grepping.

### D-2026-10-20-16 · OPEN: local port collision with the old `heymey-app` containers
The old product's Docker project `heymey-app` holds 127.0.0.1:4568 (postgres), 4569 (redis), 4571/4572 (mailpit) on this
machine, which the new series assigns to realtime/desk/worker/scheduler. **Founder to decide:** stop the old containers
when working on the new stack (they restart with Docker), or keep them and accept that those four services can't run locally
at the same time. Production is unaffected (new app containers publish no host ports).

### D-2026-10-20-07 · RESOLVED: third-party images pinned (BOLT-0005)
All 18 images pinned as `tag@sha256:<multi-arch index digest>` in `infra/compose/images.env` (and Dockerfile `FROM` lines);
CI fails on an unpinned image. Our own `ghcr.io/heymey/postgres-pgbackrest` image still needs a build+tag step in deploy.yml.

### D-2026-10-20-17 · OPEN: delete-account signs the user out everywhere? (Q-A1)
Implemented: a confirmed deletion request revokes all sessions; signing in within 7 days cancels the deletion (§38.7).
**Founder to confirm** or ask for "keep the current session signed in".

### D-2026-10-20-18 · OPEN: eligibility seed choices (Q-E1, Q-E2)
Seed maps TN communities to central categories as BC/BCM/MBC_DNC → OBC, SC/SCA → SC, ST → ST; multiple special
categories use the LARGEST single relaxation (not the sum); a community missing from a rule falls back to the OC limit.
**Founder / Ops to verify** against the official notifications before any production data is published.

### D-2026-10-20-19 · Marketing hero pixel test fails on this machine (pre-existing)
`test:hero` diffs (390×844: 48%) are identical with and without BOLT-0005's domain change, so they predate Phase 1
(likely font/rendering differences vs the 2026-10-18 baseline). Hero files untouched. Owner: flutter-ui (web) to
re-baseline on the CI renderer or fix. `pnpm test:hero` also needs a Windows-safe script.

---

## 2026-10-22: Scope decisions from the founder

### D-2026-10-22-01 · HeyMey covers all Indian competitive and professional exams (multi-exam scope)
Decided by: **founder**. Founder's words: "we are not only doing this for TNPSC, we are doing this for all exams, even
for UPSC, CA and CS exams".
- Positioning changes from "Tamil Nadu government-job aspirants" to **Indian competitive and professional exams**.
- **The launch wedge stays Tamil Nadu** (TNPSC Group 4 + Group 2/2A full content, as blueprint §1 decision 16), so the
  2 Dec 2026 launch target is not put at risk. New exam families come in **waves** after launch (proposed order in
  blueprint §1a; the founder confirms the order: INT-006 Q1).
- From Phase 2 on, the catalogue, syllabus, mock and plan models are built **exam-agnostic** (exam family → exam →
  stage → paper → section, marking scheme as data, attempt cycles of months or years, objective and descriptive papers).
- Language: **English-first** interface. The "Tamil only in the Tamil Language paper" rule becomes a per-paper content
  language rule (blueprint §1 decision 3, changed).
- Exam facts for UPSC, CA and CS are **not** written into the blueprint; every pattern/syllabus detail is
  "to verify from official source (upsc.gov.in, icai.org, icsi.edu)".
Links: blueprint §1, §1a, §2, §5.1, §5.2, §22, §36, §43 (all marked "changed 2026-10-22, D-2026-10-22-01");
`aidlc/inception/intents/INT-006-multi-exam-expansion.md`; INT-002 "Exam-agnostic build rules".
Needs: architect ADR for the exam-family data model before INT-002 BOLT-0008 (Phase 2 schema).

### D-2026-10-22-02 · Study Rooms: live group study with server-timed focus hours
Decided by: **founder**. Pain point the founder found: CA and CS students study alone for years, often without an
academy; many use a group study app where everyone preparing for the same exam joins a group and sees "this person
studied 12 hours today, that person 15 hours", and they say it motivates them and makes them compete. The founder wants
this in HeyMey's gamification.
- New feature **Study Rooms** (blueprint §9.11): live rooms per exam or paper (public) and per squad (private), a
  server-timed **focus session**, live "studying now" counts, daily/weekly study-hours boards in IST days, focus-hour
  streaks, anti-cheat, wellbeing guardrails (capped hours on boards, nudges, Calm Mode hides boards), privacy (display
  name only, opt-in), moderation, and the money/game firewall.
- Proposed placement: **MVP in Phase 3**, next to `squads` and the realtime gateway (blueprint §43, reasoning there).
- Proposed ownership: a new `focus` module + `squads` (private rooms) + `apps/realtime` (presence) → **needs an
  architect ADR** (new module, new `module.json` dependencies).
Links: blueprint §9.11, §5.3, §18, §36, §40, §43; `aidlc/inception/intents/INT-007-study-rooms.md`.
Open: the numbers (heartbeat, caps, nudges), streak rules vs §7 "no streak lost", and how hours relate to lamps (INT-007 Q1–Q15).


---

## 2026-10-22: INT-002 provisional defaults (architect, BOLT-0008)

The founder asked development to proceed with sensible, blueprint-grounded defaults for INT-002 Q1-Q27. Each value
lives in one versioned config (`packages/domain/src/modules/<module>/domain/config.ts`, `version` stored on results)
or in data rows, so a change is a config edit, not a redesign. **All entries below are PROVISIONAL (founder to confirm).**
No real exam fact is decided here: patterns and marks come from data marked SEED/verify (ADR-0013).

### D-2026-10-22-10 PROVISIONAL (founder to confirm) · Q1 Lit check
3 questions, pass = 2 of 3; retry at once with a new question set. `MASTERY_CONFIG.litCheck`. [§5.1]

### D-2026-10-22-11 PROVISIONAL (founder to confirm) · Q2 Steady and the recall ladder
Steady is earned at the first passed recall (day 1). `steady_level` 1..4 = passed recalls at +1, +3, +7, +21 IST days.
After level 4, a maintenance recall every 30 days (level stays 4). A failed recall steps back one level and is due again
in 1 day; at level 0 the lamp stays Lit. A recall before `next_due_at` never advances the ladder. `MASTERY_CONFIG.recall`.

### D-2026-10-22-12 PROVISIONAL (founder to confirm) · Q3 Dimming
One "dimming" stage starts at `next_due_at`; after 7 more days overdue the lamp is "dim" and the Steady ring is lost
(history kept in `RingEvent`). Gold is not removed by dimming (§5.1 only says Steady is lost). `MASTERY_CONFIG.dimming`.

### D-2026-10-22-13 PROVISIONAL (founder to confirm) · Q4 Gold set
15 exam-level questions (difficulty 3 or more, PYQs preferred), 15 minutes on the server timer (60 s each), pass at 80%
(12 of 15), needs Lit (not Steady), max 2 attempts per lamp per IST day, answers later than deadline + 5 s are ignored.
Gold is never lost.

### D-2026-10-22-14 PROVISIONAL (founder to confirm) · Q5 Relight
5 questions, pass 4 of 5 (about 3 minutes). A passed relight counts as a passed recall (a dim lamp returns to Steady level 1).

### D-2026-10-22-15 PROVISIONAL (founder to confirm) · Q6 Career Ladder thresholds
Rank = lamp points as a percent of the maximum over the user's syllabus (union of followed exams, shared lamps once),
so it is fair across exam families of different size. Levels 1-11 at 0, 2, 5, 10, 18, 27, 37, 48, 60, 75, 90 %.
Rank is recomputed (it may go down quietly; never "rank lost" copy). Titles are per-family data (`ExamFamily.rankTitles`, R6).

### D-2026-10-22-16 PROVISIONAL (founder to confirm) · Q7 XP
XP is not a currency and has no ledger: XP = lamp points (Lit 10, each Steady step 5, Gold 20; max 50 per lamp),
owned by `mastery`. "XP for rank progress" (§5.3) and "rank only from lamps" (§5.2) are then the same number.
Firewall: the rank/XP functions take ring counts only (new FW tests in BOLT-0009).

### D-2026-10-22-17 PROVISIONAL (founder to confirm) · Q8 What counts toward 30 a day
Only `practice` and `pyq` answers count. Lit checks, recalls, relights, Gold sets, mocks, drills and onboarding do not.
Offline answers count on the IST day of their client time, clamped to [server now - 7 days, server now]; answers over
that day's limit are kept as study log only (no error, no ring effect). `PRACTICE_CONFIG`.

### D-2026-10-22-18 PROVISIONAL (founder to confirm) · Q9 Mistake loop
Mistake review ("why mine was wrong") is free for everyone. Concept drills are built now behind the Pro entitlement (the
Phase 2 billing stub says free, so drills show `locked`): 3 wrong answers on one lamp within 14 days create an 8-question drill.

### D-2026-10-22-19 PROVISIONAL (founder to confirm) · Q10 Limit sheet before Pro can be bought
Limit message + "Not now" only; no price line until Pro can be bought (Phase 3). At most once per IST day (§13).
Offer text still needs compliance review and founder approval.

### D-2026-10-22-20 PROVISIONAL (founder to confirm) · Q23 PYQ Vault "latest 2 years"
The 2 most recent exam years for which that exam has published PYQs (not calendar years).

### D-2026-10-22-21 PROVISIONAL (founder to confirm) · Q11 Exam patterns
Patterns live in `exams` (Paper, PaperSection, MarkingScheme; ADR-0013), seeded as "SEED - verify" for local and staging
only. Production rows are entered and human-checked by Track B before `published`. Verified Group 4 / 2 / 2A patterns
are NOT ready; unverified schemes are served with `verified: false` and never in production.

### D-2026-10-22-22 PROVISIONAL (founder to confirm) · Q12 Monthly mock and Pro-only scope
"1 full mock a month" = IST calendar month. Week 2 builds entitlement checks only where cheap: PYQ older years locked,
Readiness Exam performance + Speed bars locked, trends return PRO_REQUIRED, drills locked, blurred full mock report.
Retry Wrong Only, Custom Test Builder, life profiles and pace forecast move to Phase 3 with `billing`.

### D-2026-10-22-23 PROVISIONAL (founder to confirm) · Q13 State Mock Sunday
1st and 3rd Sunday IST, opens 10:00, late join until 10:30, the paper's own duration. It can be taken later the same day
(until 23:59) as an unranked practice attempt. Rank is published at 20:00 IST by a worker job. Before `liveops`
(Phase 4) Ops schedules it as `Mock` rows (kind `state_mock_sunday`) with an ops script. Rank scope is per family (R6).

### D-2026-10-22-24 PROVISIONAL (founder to confirm) · Q25 Mocks on a weak connection
Starting a mock needs a connection (the server issues start and deadline). During the attempt answers are saved on the
phone and sent when possible; the server keeps answers that arrive by deadline + 2 minutes and ignores later ones.
Any answer that arrives after the deadline makes the attempt unranked. There is no fully offline mock.

### D-2026-10-22-25 PROVISIONAL (founder to confirm) · Q19 Rebalance and balance dial
Rebalance after 2 missed plan days (nightly job and on next app open). Mix by days left to the next stage date of the
attempt cycle (R2): over 90: new 60 / relight 20 / PYQ 15 / mocks 5; 61-90: 45/25/20/10; 31-60: 30/30/20/20;
8-30: 5/40/25/30; 0-7: 0/50/30/20. The balance dial (-2..+2) moves 10 points per step between new topics and relight.

### D-2026-10-22-26 PROVISIONAL (founder to confirm) · Q18 Final Stretch "critical" topics
Critical = `TopicExamTag.priority` of 2 or more, set by the content track per exam. The hall-ticket checklist and
exam-centre tips are content items written by content-writer and checked by content-verifier.

### D-2026-10-22-27 PROVISIONAL (founder to confirm) · Q24 Multi-exam plans
One daily minutes budget: main exam 60%, the others share 40%; within 60 days of an exam's next stage date that exam
gets +15 points. Shared lamps are planned once.

### D-2026-10-22-28 PROVISIONAL (founder to confirm) · Q22 Today tiles not built yet
Check-in, lucky-game and featured-game tiles are absent in Phase 2 (no placeholders).

### D-2026-10-22-29 PROVISIONAL (founder to confirm) · Q14 + Q27 Readiness labels
Checked top-down: Mock-ready = coverage 80+, memory 70+, exam performance 60+ (last 3 mocks); Close = coverage 60+,
memory 50+; Building = coverage 20+; otherwise Not yet. "Ready for full mocks" badge = coverage 60+ and memory 50+.
Labels use all server evidence; free users see only the Coverage and Memory bars. Q27: these rules and cutoff history
are TN-only in Phase 2, per-family rules per wave. `READINESS_CONFIG`.

### D-2026-10-22-30 PROVISIONAL (founder to confirm) · Q15 Sunday Report
Built Sunday 08:00 IST (cron `0 8 * * 0`; the worker registry entry moves from 06:00 in BOLT-0013), template text only.
AI notes arrive with `ai` (Phase 3). Never promises selection.

### D-2026-10-22-31 PROVISIONAL (founder to confirm) · Q16 Quiet hours
Default quiet hours 22:00-07:00 IST, on. Exam Alerts inside quiet hours are held until they end (not dropped).
Morning alert at 07:30 IST, only when lamps are really dimming. `NOTIFICATIONS_CONFIG`.

### D-2026-10-22-32 PROVISIONAL (founder to confirm) · Q17 Exam Alert approval before Desk
A minimal Desk API (`/v1/desk/exam-changes`: Desk session + role OPS or ADMIN, audited). No alert without a human
approval. The Desk screen arrives in Phase 4; until then Ops calls the API from an internal tool.

### D-2026-10-22-33 OPEN (founder action) · Q21 Firebase / APNs accounts
The founder creates the Firebase project and the APNs key in the company accounts (free; no new paid service).
Until then the push sender runs `log_only`.

### D-2026-10-22-34 PROVISIONAL (founder to confirm) · Q20 Content packs
One pack per exam per subject (zip of JSON + images + audio), max 25 MB each, `free` and `pro` tiers; free users get
free packs only. Packs contain answers (study only; ranked play never runs offline).

### D-2026-10-22-35 PROVISIONAL (founder to confirm) · Q26 Exam-family model now
Yes: BOLT-0008 adds the exam-family schema (ADR-0013) with TN data only, plus ADR-0012 (`exam-hall` depends on `exams`).

## D-2026-10-23-01 PROVISIONAL (founder to confirm): design system v2 (BOLT-0021)
Founder asked for a premium, gamified (Duolingo-like) UI in light and dark. Changes to §10.3/§10.4:
interface font Nunito (bundled, OFL) replaces Plus Jakarta Sans/Sora; primary action colour Peacock Teal (#19B5AE light / #2DD4C8 dark);
Temple Gold becomes the reward colour (lamps, Gold, XP); dark background #100D2B. All pairs WCAG AA (tested).

## 2026-11-01

### D-2026-11-01-01 PROVISIONAL (founder to confirm) · T2 · Free-tier launch architecture
Launch on free/starter tiers; pay only once revenue comes in. Postgres → Supabase (Free; **Pro $25/mo before public
launch**; app via transaction pooler 6543, migrations via direct URL; Prisma stays; Supabase Auth NOT adopted).
Files/packs → Cloudflare R2 (`cdn.heymey.app`). Marketing → Cloudflare Workers (`@opennextjs/cloudflare`; not Vercel Hobby).
Desk → Firebase Hosting. api/worker/scheduler/realtime/valkey/caddy/changedetection → one VM (Oracle Always Free ARM;
fallback Hetzner CX22), ports 4567+ unchanged. SES email, FCM push, Sentry + Grafana Cloud free (or self-hosted), Cloudflare DNS/WAF.
Nightly `pg_dump` → R2 always. T2 because it moves personal data to new processors (Supabase, Cloudflare): **security +
compliance review required; privacy-notice processor list must be updated**. Changes blueprint decision 5, §14.1, §20.2,
§20.3, §21, §23, §25, §42 and the pitch deck (marked in place). AGENTS.md §2 "one VPS" wording change pending founder.
Decided by: founder (request) + main session + architect. See ADR-0014. Infra: devops (parallel).

## 2026-11-04

### D-2026-11-04-01 · Marketing on Vercel (amends D-2026-11-01-01)
Founder decision: `apps/marketing` (Next.js) is hosted on **Vercel** at heymey.app, deployed by Vercel's GitHub
integration (Root Directory `apps/marketing`, `vercel.json`, `turbo-ignore`). Replaces Cloudflare Workers /
`@opennextjs/cloudflare` from BOLT-0023. Supabase, R2, Firebase Hosting (Desk) and the one VM are unchanged.
**Open for the founder:** the Vercel Hobby plan forbids commercial use, so the commercial site needs **Vercel Pro
($20/mo)**; founder's choice. Recorded in ADR-0014 (amendment 2026-11-04), blueprint §1/§5/§20.3/§25/§42 marked in place.
Decided by: founder. Implemented by: devops (BOLT-0023 amendment).


## 2026-11-04 — SEC-P2-L2 follow-up: per-user clientActionId dedupe for RingEvent and PracticeAnswer (PENDING ARCHITECT APPROVAL)
`RingEvent.clientActionId` was globally unique and `PracticeAnswer.id` was the client's UUID (global PK). Both now dedupe
on `(userId, clientActionId)` like `StudyLog` (BOLT-0020). Migration `20261104010000_ring_event_practice_client_action_per_user`:
creates `RingEvent_userId_clientActionId_key` then drops `RingEvent_clientActionId_key`; adds `PracticeAnswer.clientActionId`
(backfilled from `id`, NOT NULL) + `PracticeAnswer_userId_clientActionId_key`; new answer ids are server-generated.
Open: `SyncReceipt.clientActionId` is a global PK but no code uses the table; architect to decide (drop or re-key).
**Needs: architect approval of the schema/migration (owner of `packages/db/prisma`).** Implemented by: backend.
