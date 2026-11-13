# HeyMey: repository report, plan review and launch gap list

Written 2026-11-13 for the founder. Every repo fact below was checked in the code or on the AIDLC board during this review.
External facts were searched on the web; where sources disagree, that is stated. **Verified** means checked here,
**Assessment** means my judgement, and **Verify** means it still needs a check before you rely on it.

---

## 0. Summary

1. **`docs/HEYMEY_COMPLETE_PLAN.md` is not correct as a plan for this repository.** Its goals are right, but it describes a
   different product shape than the one we locked and built. The main conflicts:
   - it assumes a Next.js PWA with Capacitor; we build Flutter;
   - it calls the currency "Sudar" and says it is earned from game prizes; our firewall forbids that, and so does the law;
   - its "already built" list describes the old Next.js app, not this repo.

   Section 1 lists every conflict. Keep the plan's ideas, but do not treat it as the spec.
2. **The repo is a working Phase 1 + Phase 2 product.** That means sign-in, onboarding, Study Map with lamps, recall
   and relight, practice, past papers, mock exams, readiness, plan, Exam Alerts, offline sync and 2 themes. It has 68 API
   routes, 68 database tables and about 255 Flutter tests, and it all runs on your PC and on the emulator.
   About 13 of the 24 backend modules are implemented. **The games, squads, money, AI, Study Rooms and most of Desk are
   stubs.**
3. **Launch is blocked by things that are not code**, plus Phase 3 and 4 engineering:
   - **Real content:** there are 25 topics, 4 lessons and 3 placeholder mocks. There is no real question bank.
   - **A live API server:** none is deployed, so no phone can use the app today.
   - **Company, store and legal steps** (section 4.C).
4. **Urgent finding on the live marketing site:** it shows invented testimonials from named people, referring to
   features that do not exist yet (section 4.F). If they are not real, remove them before the site is public.

---

## 1. Is `HEYMEY_COMPLETE_PLAN.md` correct?

### 1.1 Short answer

**Partly.** The product idea, the honesty principle and many game ideas match the blueprint. But several decisions
contradict the locked blueprint, the code and Indian law, and the "what is built" section is wrong for this repository.
I recommend marking the file **"earlier concept, superseded by the blueprint"** and moving any idea you still want into
the blueprint through the normal decision process (`aidlc/decisions.md`).

### 1.2 Conflicts

| # | The plan says | The blueprint and repo say | Severity |
|---|---|---|---|
| 1 | One **Next.js** codebase: website, PWA and Android app via **Capacitor** (§2, §10) | Decision 2: **one Flutter codebase**, and **no web version for aspirants**. Desk web is for staff only. The repo is Flutter. | **High**: rewrites the whole app |
| 2 | Currency **"Sudar"**, mascot **"Sudi"**, one currency that is both earned and bought (§3, §5, §11) | Currencies are **XP, Points, Trophies, Match chips and Sparks** (§5.3). Only Sparks are bought; most rewards are Points, which can never be bought. The mascot and currency names are not in the blueprint. | High |
| 3 | The Daily Spin can land on **Sudars** (§5.2), and events give **Sudar prizes** to top district performers (§5.5) | Firewall rule 3: **no game rewards Sparks or anything worth money**. §9.1: "No prize is Sparks or anything with real-world value." The Online Gaming Act 2025 and its Rules, in force from 1 May 2026, ban "online money games" (see 1.4). A bought currency as a game prize is exactly the risk they target. | **Critical (legal)** |
| 4 | "Study Rooms" are 4–6 players answering one live question (§5.3) | §9.11 Study Rooms are **server-timed focus rooms with hours boards**. The live question battle is **Confidence Duel / Squad Battles**. | Medium: same name, different feature |
| 5 | Ranks **Bronze to Diamond** (§5.4) | §5.2 **Career Ladder** with 11 levels and titles from Typist to Chief Secretary. "Gold" is already a lamp ring. | Medium |
| 6 | A **Daily Flash Challenge** (§7, §8) | Decision 9: **no daily quiz**. The featured game changes every day. | Medium |
| 7 | **"Already built"**: Flash Challenge, AI doubt solver, Sudar ledger, Study Pods, admin panel (§15) | None of these is in this repo. `ai`, `squads` and `economy` are stubs (economy holds only the firewall code). There is no Flash Challenge by decision. Desk screens are placeholders. §15 describes the **old Next.js app**, which blueprint §46 says is replaced. | **High**: misleading status |
| 8 | Sign in with **"phone or email code"** (§7) | Decision 5a: **email OTP only, no SMS**. SMS would bring TRAI DLT duties (§30). | Medium |
| 9 | **Redis** | We run **Valkey** (open-source Redis-compatible). | Low |
| 10 | "One well-configured server" for everything (§10, §14) | ADR-0014 (2026-11-01): free tiers (Supabase, R2, Firebase, Vercel) plus one small VM. | Low (superseded) |
| 11 | **Dark theme throughout**, avoid flat white (§9) | You asked later for **light and dark** themes. §10.3, 10.7 and 10.9 also require high contrast, Calm Mode and Lite Mode. | Medium |
| 12 | Onboarding asks **"language"**, "in Tamil and English" (§7, §12) | Decision 3: the **interface is English only**. Tamil appears only in Tamil Language paper content. | **Needs your decision** |
| 13 | **Live ticker** with named users ("Priya in Salem just hit a 7-day streak") (§5.1, §5.7) | Real names and places need **opt-in consent** (DPDP Act). §9.11 uses display name only, opt-in. §13 bans fake "others are doing it" numbers. §13 also says the ticker may never be seeded with invented activity. | High |
| 14 | A **streak shield** forgives a missed day (§8) | §7 and §9.11: no "streak lost" wording at all, and missing a day never resets anything. The **Revision Shield** exists but stops a lamp dimming. | Low |
| 15 | Creator keeps **75%** (§6, §11) | No share is set in the blueprint. Marketplace and Creator Studio are planned for month 3 after launch, with TDS on payouts (§30). | Needs decision |
| 16 | **Parent** role planned (§6) | The blueprint has a **Supporter** role (parent, spouse, friend). | Low |
| 17 | Plan names "Cycle Pass" | Blueprint name is **Exam Pass** (₹399), with Pro prices set in §12. | Low |
| 18 | Legal section covers only the gaming ban | §30–§31 list about 18 laws, and 10 pre-launch steps that each block launch. | Medium: incomplete |

### 1.3 What is right and worth keeping

- **The honesty principle** (§16): the readiness score must stay a simple, explainable formula. This is the brand promise and the blueprint agrees (§5, §19.5).
- **Free daily spin that is never sold, with no stake and nothing at risk.** This matches §9.1. The only fix is that prizes must not be Sparks or anything with money value.
- **Cosmetic-only store, never pay-to-win** (§5.6). Matches the firewall.
- **A multi-year journey across attempts.** Already built into the data model as `ExamAttemptCycle` (ADR-0013).
- **Sunday "Exam Wars"** matches State Mock Sunday. **The free answer-key scorer** matches the Answer-key calculator.
- **Launch near a real TNPSC notification** matches §14.4 and §28.
- **A stall at an event** to seed the first users. You are doing this: Products by PSG Products Expo, Dec 9–13.
- **A live feed that makes the app feel alive** is a good idea, if it is opt-in and always real.

### 1.4 External facts checked

| Claim | Result |
|---|---|
| The Promotion and Regulation of Online Gaming Act 2025 bans "online money games", and its Rules are in force from 1 May 2026 | **Confirmed.** Rules notified by MeitY on 22 April 2026; they also set up the Online Gaming Authority of India ([News On Air](https://www.newsonair.gov.in/online-gaming-rules-2026-to-be-effective-from-tomorrow/), [Legal500](https://www.legal500.com/developments/?p=56348)). |
| Penalty "up to 3 years in prison and ₹1 crore" | **Mostly confirmed.** Most sources report up to 3 years and/or ₹1 crore ([Business Today](https://www.businesstoday.in/amp/technology/story/new-online-gaming-rules-from-may-1-violations-will-see-3-year-jail-term-rs1-crore-in-fines-528355-2026-04-30)). **Other figures conflict across sources** (₹10 crore, advertising fines, repeat offences). **Verify** in the Gazette text before quoting any number. Our firewall and the legal opinion matter more than the exact figure. |
| Vercel's free Hobby plan forbids commercial use | **Confirmed**: Hobby is for personal, non-commercial use. A business site needs Pro ($20/month) ([Vercel docs](https://vercel.com/docs/plans/hobby), [fair use](https://vercel.com/docs/limits/fair-use-guidelines)). Forum posts suggest even a business marketing site with no direct revenue counts as commercial. Those posts are interpretation, not Vercel policy. |
| Supabase Free pauses after 1 week idle, 500 MB database, no backups | **Confirmed** by the [official pricing page](https://supabase.com/pricing) and third-party guides. Pro at $25/month removes pausing and adds daily backups. |
| Oracle Always Free: 4 OCPU / 24 GB Arm; idle VMs can be reclaimed | **Partly confirmed.** The reclaim rule is in [Oracle docs](https://docs.oracle.com/iaas/Content/FreeTier/resourceref.htm): over 7 days, 95th-percentile CPU under 20%. **One 2026 blog claims the free Arm allowance was cut to about 2 vCPU / 12 GB; I could not confirm it in Oracle's documentation.** **Verify** on Oracle's page before you depend on it. |
| New Google Play personal accounts need a 12-tester, 14-day closed test | **Confirmed on Google's [help page](https://support.google.com/googleplay/android-developer/answer/14151465)** for personal accounts created after 13 Nov 2023. A blog says organisation accounts are exempt, but **I did not find that on Google's page. Verify in Play Console help.** |

---

## 2. What the repository contains

### 2.1 Map

| Path | What it is | State |
|---|---|---|
| `apps/api` | NestJS + Fastify HTTP API, :4567 | **Real.** 14 controllers, platform guard, rate limits, idempotency, 12 test files |
| `apps/worker` | BullMQ workers + scheduler | **Real.** 8 processors (below) |
| `apps/realtime` | Socket.IO gateway, :4568 | **Skeleton.** One 40-line match gateway, **no tests** |
| `apps/mobile` | Flutter app (Android + iOS) | **Real for Phase 1–2.** Android debug build works. **iOS never built here** |
| `apps/desk` + `dart/hm_desk` | Flutter web for staff | **Sign-in + home only.** 8 role screens are 8-line stubs |
| `apps/marketing` | Next.js landing page, :4570, Vercel | One page (see 4.F) |
| `packages/contracts` | Zod schemas → OpenAPI 3.1 → Dart client | **Real.** 68 routes |
| `packages/domain` | 24 business modules | 13 real, 3 partial, 8 stubs (2.2) |
| `packages/db` | Prisma schema, migrations, seed | 26 schema files, 68 tables, 6 migrations |
| `packages/ai-gateway` | The only way to call an AI model | **67-line stub** |
| `packages/config`, `testing`, `eslint-config` | Ports, env schemas, test tools | Real |
| `dart/` | hm_design, hm_core, hm_data, hm_features, hm_desk, hm_games, hm_api (generated) | hm_games is **empty** |
| `content/` | Syllabus YAML + validation | 1 file: TNPSC Group 4 syllabus (213 lines) |
| `infra/` | Compose stacks, Caddy, backups, monitoring, k6, scripts | Written and validated locally. **Never deployed** |
| `docs/` | Blueprint (1,585 lines), 14 ADRs, 9 runbooks, architecture | Real |
| `aidlc/` | 8 intents (INT-000 to INT-007), bolts BOLT-0001 to BOLT-0023, decisions, status board | Real |
| `.claude/` | 14 agent definitions + 5 lifecycle skills | Real |

### 2.2 The 24 backend modules

| Status | Modules |
|---|---|
| **Implemented** (13) | `auth`, `users`, `roles`, `audit`, `exams` (+ eligibility, Exam Alerts), `syllabus`, `content`, `mastery`, `practice`, `exam-hall`, `plan`, `readiness`, `notifications` |
| **Partial** (3) | `economy` (only the money/game **firewall rules** and their tests), `billing` (only an entitlement stub that returns "free" for everyone), `games` (only a limits file) |
| **Stub** (8: 5-line index file) | `ai`, `analytics`, `institutions`, `liveops`, `marketplace`, `moderation`, `squads`, `support` |

### 2.3 API, workers, data

- **68 routes**: 23 from Phase 1 (health, reference, auth, users, exams, study map, lessons) and 45 from Phase 2
  (mastery, practice, PYQ, mocks, plan, readiness, notifications, webhook, Desk approvals, sync, content packs).
- **8 worker processors**: email OTP, OTP cleanup, account deletion, mastery dimming, exam-hall expiry and ranks, plan
  rebalance, readiness Sunday Report, notifications.
- **Platform rules enforced for every route**: auth level, rate limit, Idempotency-Key (offline-safe), server time, safe error envelope,
  a contract test that fails if the API and contract differ.
- **Security work done**: 2 full review rounds. All High, Medium and Low findings are fixed, including OTP brute force, rate
  limit spoofing, TOTP lockout, atomic audit writes, DB TLS enforcement and per-user sync dedup.
- **Money/game firewall**: 12 permanent tests (`pnpm firewall:check`).

### 2.4 The Flutter app (`dart/hm_features`)

| Implemented | Stubs (8-23 lines each) |
|---|---|
| onboarding, eligibility, Study Map + lamps, lessons + Listen, Lit/recall/relight/Gold checks, practice, mistakes, PYQ Vault, free-limit sheet, Exam Hall (OMR + CBT, resume, report), plan setup + My Plan, Today, Readiness + Sunday Reports, Exam Alerts + settings, profile, offline outbox + content-pack downloads | `play` (games), `squad`, `store`, `current_affairs`, `library`, `support`, `wellbeing`, `staff_quick_actions` |

Design system v2 (Nunito, warm light and rich dark themes, high contrast, Calm and Lite Mode, 3D buttons,
celebrations, step headers) is applied to all of the above.

### 2.5 Hosting and process

- **Hosting plan (ADR-0014):** Supabase Postgres, Cloudflare R2, Firebase Hosting (Desk), Vercel (marketing), one VM
  (api, realtime, worker, scheduler, Valkey, Caddy). **Nothing is deployed yet.**
- **Git:** `main` holds Phase 1 + Phase 2 (PR #1), your marketing site (PR #2) and the Vercel fix (PR #3).
- **Process:** AIDLC, with bolts, gates and risk tiers. The Graphify knowledge graph (8,198 nodes) is used by every agent.

### 2.6 Quality numbers (last run 2026-11-04; re-run before relying on them)

| Check | Result |
|---|---|
| `pnpm verify` (ports, firewall, boundaries, lint, typecheck, unit tests) | 38/38 tasks pass |
| Integration tests on real Postgres + Valkey | api 70, domain 61 pass |
| Flutter tests | hm_design 26, hm_core 21, hm_data 28, hm_features 173, hm_desk 4, mobile 2, desk 1 |
| Coverage | mastery 98% lines, exam-hall about 95% branches, practice 96%, plan 86% (unit only) |
| **No tests at all** | `apps/realtime`, and the real `hm_games` |
| Not done | Patrol end-to-end tests, k6 load test, external penetration test, iOS build |

---

## 3. The flows that exist today

### 3.1 What a learner can do now

```
Open app → date of birth, exams, community (eligibility, 8 steps)
  → eligibility result → email + 6-digit OTP (code arrives by email) → consent (only "run my account" required)
  → plan setup (minutes a day, study days, attempt cycle) → Today (plan card, relight count, Exam Hall button)
  → Study Map (lamps) → open topic → lesson (read or Listen) → "I've finished"
  → Lit check (3 questions, pass 2) → lamp lights (celebration)
  → recall at +1, +3, +7, +21 days → Steady → Gold check (15 questions, 15 min, 80%)
  → miss a recall → lamp dims → Relight queue (5 questions, 4 right)
  → Practice (30 free a day, resets 12 AM IST) → mistakes review → PYQ Vault (latest 2 years free)
  → Exam Hall mock (server timer, resume, negative marking from data) → report (full report is Pro, locked)
  → Readiness Meter (Coverage + Memory) → Sunday Report (08:00 IST)
  → Exam Alerts (official sites watched; staff approve in Desk; held in quiet hours 22:00–07:00)
  → offline: actions queue and sync later (7-day window)
```

### 3.2 How a request travels on the server

`App → Caddy → NestJS controller → PlatformGuard (auth, role, rate limit) → Idempotency interceptor → module use case
(domain, no framework) → Prisma → Postgres` · side effects go to BullMQ (emails, dimming, ranks, notifications).
Contract first: Zod routes → OpenAPI → generated Dart client, so the app and server cannot drift.

### 3.3 How the code was built

Intent → stories → unit designs → **G-D** → bolts (contract → failing tests → code → verify) → reviews (QA, security,
compliance) → **G-C**. 14 specialist agents did the work; you approve gates, prices, legal text and money/data code.

### 3.4 What is waiting on you

Phase 1 G-C, Phase 2 G-C, the provisional decisions D-2026-10-22-10 to -35, D-2026-10-23-01 (design), D-2026-11-01-01
(free tier), D-2026-11-04-01 (Vercel), and the legal text (section 6).

---

## 4. What is still needed for launch

### 4.A Engineering (blueprint weeks 3, 3b and 4)

| Part | Work | Size (Assessment) |
|---|---|---|
| **Week 3: economy** | Sparks ledger, daily check-in, cosmetics, Season Pass | Large, T2, 90% coverage |
| **Week 3: games** | Daily Spin, Lucky Slot, Confidence Duel, Clue Poker, odds shown, server-authoritative rooms; the realtime gateway made real; `hm_games` (Flame) | Largest item |
| **Week 3: squads** | Squads, chat, Help Requests, Squad Battles | Large |
| **Week 3: billing** | Google Play Billing, Apple IAP, Razorpay, entitlements, restore purchases, spending limits, paywalls with "Not now" | Large, T2 |
| **Week 3: AI** | AI gateway (OpenRouter, fallbacks, budgets, no personal data), AI doubt help | Medium |
| **3b: Study Rooms** | New `focus` module (ADR needed), `study.*` socket events, boards, nudges, privacy toggles | Medium, T2 |
| **Week 4: Desk** | Support, Moderation, Review, Ops, Admin, Institution, Creator Studio, Partner screens, and the 6 stub backend modules behind them | Large |
| **Week 4: hardening** | Security pass, k6 State Mock Sunday run, accessibility pass, low-end phone pass, store listing assets | Medium |
| **Phase 2 carry-overs** | Offline cache for Today, plan and meter; Pro readiness trend; nightly readiness snapshot; real push (Firebase and APNs accounts); delete push token on logout; an outbox for Exam Alert fan-out; `MOCK_NOT_SUBMITTED` error code; signed Pro-pack download links; the glossary and Final Stretch checklist content; missing goldens at 200% text (QA Q-3) | Medium |

### 4.B Content (Track B): the largest non-code gap

- **Today:** 5 exams with SEED eligibility rules, 6 subjects, **25 topics, 4 lessons, 16 glossary terms, and 3 placeholder mocks of 10
  questions**. No real question bank exists.
- **Needed for launch (blueprint §27, §32):** Group 4 and Group 2/2A syllabus mapping, real previous-year questions with sources, lessons
  and explanations, the Tamil Language paper, **100% human review**, **verified** exam patterns and eligibility data, and
  a Correction Log process.
- **Never present SEED data as real.** The app shows "verify" in the data, so mock results must not be shown to users as official until verified.

### 4.C Company and legal (Track C: founder + CA + lawyer)

Each of these blocks launch (§31). **Status is unknown to me: tell me which are done.**
1. Incorporate HeyMey Technologies Pvt Ltd, then PAN/TAN and a bank account.
2. GST registration.
3. D-U-N-S number, then a Google Play organisation account and an Apple Developer organisation account.
4. Razorpay merchant account (needed only once billing ships).
5. SMTP domain with SPF, DKIM and DMARC (`docs/runbooks/email-setup.md`).
6. Trademark filing (classes 9, 41, 42).
7. Written legal opinion on gaming classification and the Online Gaming Authority registration question.
8. Public policies at heymey.app: Privacy (needs a full rewrite), Terms, Refunds, **Community Guidelines, Game Rules & Odds**.
9. A named Grievance Officer (name and address).
10. External penetration test (₹40,000–80,000 per blueprint §33).

**Compliance review (BOLT-0020) says "changes required" until the privacy policy and the missing legal pages exist.**
It must name every data processor: Supabase, Cloudflare, Firebase, Vercel, Amazon SES, OpenRouter (no personal data) and the VM provider.

### 4.D Infrastructure and accounts

You have a Supabase URL; nothing else exists yet. In this order (steps in `docs/runbooks/free-tier-setup.md`):

1. **Supabase**: use the pooler URLs, not the direct address. The `db.<project>.supabase.co:5432` host is usually IPv6-only. Put `DATABASE_URL`
   (transaction pooler, 6543) and `DIRECT_URL` (session pooler, 5432) in `.env`. I then run migrations. Decide staging vs production.
   **Move to Pro ($25/month) before public launch**: Free pauses after 1 week idle and has no backups.
2. **A server** for the API. Oracle Always Free is cheapest, but verify its current limits first (section 1.4) and keep Hetzner (about €4/month) as the fallback.
   **Without a live API no phone can use the app.** The emulator works only because it talks to your PC.
3. **Cloudflare R2** (content packs and backups), **Firebase** (Desk hosting and push), **Amazon SES** (OTP email).
4. **DNS** in Cloudflare, **GitHub secrets**, first staging deploy, and the **restore drill** (blueprint requires it).
5. **Vercel project** for marketing, set to **Pro** if the site is commercial (section 1.4).
6. **Monitoring**: GlitchTip and Metabase each need a database now that the VM no longer hosts Postgres.

### 4.E Mobile and store

- **iOS:** never built. It needs a Mac or a cloud build (for example Codemagic), an Apple account and signing.
- **Android release:** release signing key, Play listing, Data Safety form, age rating (blueprint expects about 18+ because of the gambling-style art), privacy policy URL.
- **Google Play testing rule:** see 1.4. If your account is personal, the 12-tester 14-day test comes first.
- **Patrol end-to-end tests** are in the testing plan (§44) but not written.

### 4.F Marketing site (`apps/marketing`, heymey.app)

Checked in the code:
- **Invented testimonials (urgent).** `components/Testimonials.tsx` has quotes from named people ("Pooja R.", "Arun Karthik", "kavya_s",
  "Siddharth Menon") with cartoon avatars from dicebear.com. They talk about "squad battles", "district quest" and "clue poker",
  **none of which exist**, and one praises streaks that "guilt-trip me", which §7 forbids. **I cannot tell if they are real.**
  If they are placeholders, remove them before launch. Fake reviews are a consumer-law and Dark Patterns risk.
  The compliance agent has not reviewed this page (**Verify** with your lawyer).
- **No legal pages.** There is one page (`app/page.tsx`) and no Privacy, Terms or Refund page. The stores require public policy links.
- **Wrong or missing links.** The calls to action point to `#cta`, and there are no store links, no pre-registration form and no QR target
  for your stall. Decision D-03 is still open.
- **A claim that is not true yet.** The FAQ (`components/Faq.tsx`) says "Full preparation content is live for TNPSC Group 4 (including VAO)
  and Group 2/2A". Today there are 25 topics and 4 lessons, and no app is released. Reword it before the site is public; a false claim on a
  consumer site is a misleading-advertisement risk (**Verify** with your lawyer).
- **Housekeeping.** The README still says npm and port 3000 (repo rules: pnpm, 4570). `apps/marketing/AGENTS.md` is gone. The site ships its own
  copy of the blueprint (`apps/marketing/HEYMEY_PRODUCT_BLUEPRINT.md`); keep only `docs/`.
- **Headers.** The strict security policy I wrote earlier was dropped because the new site loads Rive, CloudFront and dicebear.
  A fitted policy still needs writing.

---

## 5. Dates (Assessment)

- **Dec 2 launch** is from your earlier message. It is **not in the blueprint**. The blueprint says the code needs about 4 weeks of agent work and
  **public launch is realistically weeks 7–9**, because D-U-N-S, store accounts, legal review, human content review, beta and store review all have outside waiting times.
- **Today is Nov 13**, so Dec 2 is 19 days away. Phase 1 and 2 are built, but weeks 3, 3b and 4, real content, the server and the legal steps are not.
  **I do not think a full launch on Dec 2 is realistic.**
- **Dec 9–13 stall (Products by PSG Products Expo):** doable as a **demo**, if these exist by then:
  1. a live API server, Supabase, and email sending (SES, or a temporary SMTP);
  2. an installable Android build: a release APK on Firebase App Distribution, or a Play internal link;
  3. enough real Group 4 content to feel real;
  4. a QR code to a **waitlist/pre-registration page** on heymey.app, not to a store listing that may not exist.

  Options for the stall script call to action: "scan to join the first-users list" (safe) or "scan to install the demo" (needs 1 and 2).
- **Suggested scope for a first public release (Assessment):** Phase 1 + 2 as a free Android release with Exam Alerts, eligibility, lamps, practice and mocks on **verified** content,
  with billing, games and Study Rooms following in weeks 3–4. This avoids the gaming opinion and billing review as launch blockers, and the
  firewall tests stay in place. **This changes your launch story, so it needs your decision.**

---

## 6. Decisions only you can make

| # | Decision | Where |
|---|---|---|
| 1 | Is `HEYMEY_COMPLETE_PLAN.md` superseded, or do you want to change the blueprint (platform, currency name, prizes)? | Section 1 |
| 2 | Currency naming: keep **Sparks/Points** or adopt **Sudar/Sudi**? If Sudar, can it never be a game prize? | Conflicts 2, 3 |
| 3 | Launch scope and date: full launch vs free Android first (section 5) | Section 5 |
| 4 | Are the testimonials real? Reword the FAQ claim that content is "live" | 4.F |
| 5 | Interface language: English only (blueprint), or Tamil + English (the old plan)? | Conflict 12 |
| 6 | Where do the marketing buttons go (D-03)? Vercel Pro ($20/month)? | 4.F, 1.4 |
| 7 | Refund window and conditions; Grievance Officer name and address | 4.C |
| 8 | Exam Alerts approved by one person or two (blueprint §17.5 requires two-person approval for Admin powers such as prices and payouts) | D-2026-10-22-32 |
| 9 | Creator payout share (the plan says 75%; the blueprint sets none) | Conflict 15 |
| 10 | Confirm the provisional decisions and ADR-0012, -0013, -0014; approve the two per-user dedup migrations | Section 3.4 |
| 11 | INT-006 (12 questions) and INT-007 (15 questions) for multi-exam and Study Rooms | `aidlc/inception/intents/` |
| 12 | Whether the user-facing live feed ships, and with what consent | Conflict 13 |

---

## 7. Next steps, in order (Assessment)

1. Decide section 6, items 1–5. This takes under an hour and unblocks everything else.
2. Remove or confirm the testimonials, and add a waitlist form and the three legal pages to the marketing site.
3. Add `DATABASE_URL` and `DIRECT_URL` (pooler) to `.env`. I will run migrations against Supabase.
4. Create the server and the other accounts (4.D), then do the first staging deploy and the restore drill.
5. Start real content (4.B) with human reviewers. It has the longest lead time.
6. Start the company and legal steps (4.C) in parallel, especially D-U-N-S and the gaming legal opinion.
7. Run the integration tests and `pnpm verify` again against the deployed stack.
8. Then Phase 3: economy, billing, games, squads, Study Rooms (4.A), each as its own bolt with security and compliance review.

---

## 8. What I could not verify

- Whether the company, GST, D-U-N-S, store accounts, Razorpay and trademark steps are done: it is not recorded in the repo.
- The exact penalty text of the gaming law. Sources conflict beyond the 3-year and ₹1 crore figure.
- Oracle's current free allowance, and whether Google Play exempts organisation accounts from the 14-day test.
- Whether the testimonials are real.
- Test counts are from the last runs on 2026-11-04. I did not re-run the suites for this report.
- I did not read the `.env` file, as the project rules forbid it.

## Sources

- [Online Gaming Rules 2026 effective 1 May (News On Air)](https://www.newsonair.gov.in/online-gaming-rules-2026-to-be-effective-from-tomorrow/)
- [India's online gaming reset: PROGA and the 2026 Rules (Legal500)](https://www.legal500.com/developments/?p=56348)
- [Violations will see 3-year jail term, ₹1 crore fine (Business Today)](https://www.businesstoday.in/amp/technology/story/new-online-gaming-rules-from-may-1-violations-will-see-3-year-jail-term-rs1-crore-in-fines-528355-2026-04-30)
- [Promotion and Regulation of Online Gaming Act 2025 (negd.in)](https://lawascode.negd.in/laws/the-promotion-and-regulation-of-online-gaming-act-2025)
- [Vercel Hobby plan](https://vercel.com/docs/plans/hobby) and [Vercel fair use guidelines](https://vercel.com/docs/limits/fair-use-guidelines)
- [Supabase pricing](https://supabase.com/pricing)
- [Oracle Always Free resources](https://docs.oracle.com/iaas/Content/FreeTier/resourceref.htm)
- [Google Play: testing requirements for new personal accounts](https://support.google.com/googleplay/android-developer/answer/14151465)
