# HeyMey board

The single board for the Dec 2 testing release. Owners update their row when they start, block or finish.
Branch for every bolt: `agent/<owner>/<bolt-id>`, in the owner's own worktree. One bolt per PR.
Definition of done: `CLAUDE.md` section 10. Kaaval reviews anything touching auth, money, games, personal data, uploads or
Desk; Kanakku reviews anything touching a currency or a prize. Earlier history (Phase 1, Phase 2, BOLT-0001..0023) stays
in `aidlc/state.md`.

Last updated: 2026-11-13 by Kural

## Milestones

| Date | Milestone | Status |
| --- | --- | --- |
| Nov 20 | Production infra on Vercel + Supabase, Docker out of the deploy path | open |
| Nov 27 | Every module feature-complete, flagged where approvals are pending | open |
| Nov 29 | Verified Group 4 content and question bank in production | open |
| Dec 1 | Release candidate, feature freeze | open |
| Dec 2 | Production testing release (Android, web, Desk) | open |
| Dec 3 | Flex and poster files to the printer | open |
| Dec 6 | Stall build frozen | open |
| Dec 9-13 | Stall A130, Hall A, CODISSIA | open |

## Bolts

States: `todo`, `doing`, `review`, `blocked`, `done`. Depends lists bolts that must merge first.

### Kural (orchestration)

| Bolt | Work | Depends | Reviewers | Due | State | Blocker |
| --- | --- | --- | --- | --- | --- | --- |
| BOLT-0024 | ADRs: Vercel serverless API, Supabase Queues + pg_cron jobs, Supabase Realtime, `focus` module, Flutter web app (amends Decision 2) | - | Founder | Nov 15 | doing | - |
| BOLT-0025 | Elaborate INT-003 (games, squads, money) and INT-004 (Desk, safety) into stories with acceptance criteria | - | Founder | Nov 16 | todo | - |

### Paalam (platform)

| Bolt | Work | Depends | Reviewers | Due | State | Blocker |
| --- | --- | --- | --- | --- | --- | --- |
| BOLT-0026 | Vercel projects (marketing, web app, Desk, API in `bom1`), Supabase staging + production, pooler URLs, CI deploy from green `main` | 0024 | Kaaval, Vizhi | Nov 18 | todo | Founder creates accounts and adds secrets |
| BOLT-0027 | Move Docker files to `infra/legacy-docker/` with README; `pnpm dev` against staging Supabase | - | Vizhi | Nov 17 | todo | - |
| BOLT-0028 | Nightly `pg_dump` to Cloudflare R2; restore drill run and written up | 0026 | Kaaval, Vizhi | Nov 20 (drill passed by Nov 27) | todo | - |
| BOLT-0029 | pgmq + `pg_cron` + `pg_net` wiring and request signing for `/internal/jobs/*` | 0026 | Kaaval | Nov 20 | todo | - |
| BOLT-0030 | Signed APK in GitHub Actions, `dl.heymey.app` on R2, version manifest; Flutter web to `app.heymey.app`; Desk to `desk.heymey.app` | 0026 | Kaaval, Vizhi | Nov 24 | todo | Founder supplies keystore as a GitHub secret |

### Thoon (backend)

| Bolt | Work | Depends | Reviewers | Due | State | Blocker |
| --- | --- | --- | --- | --- | --- | --- |
| BOLT-0031 | NestJS on Vercel Functions (serverless adapter, stateless handlers, duration budget) | 0024 | Vizhi, Kaaval | Nov 18 | todo | - |
| BOLT-0032 | The 8 BullMQ processors become idempotent, chunked `/internal/jobs/*` endpoints | 0029, 0031 | Vizhi, Kaaval | Nov 20 | todo | - |
| BOLT-0033 | Postgres rate limits, idempotency and cache with TTL cleanup (Valkey removed) | 0031 | Vizhi, Kaaval | Nov 19 | todo | - |
| BOLT-0034 | Phase 2 carry-overs: nightly readiness snapshot, Pro readiness trend, `MOCK_NOT_SUBMITTED`, Exam Alert outbox, signed Pro-pack links, FCM push + delete token on logout, Brevo/Resend OTP | 0032 | Vizhi, Kaaval | Nov 25 | todo | - |
| BOLT-0035 | `analytics` module: consent-gated, personal data stripped | 0031 | Kaaval | Nov 26 | todo | - |
| BOLT-0036 | Sticker codes: issue a one-time code on first lit lamp, verify and burn from Desk | 0031 | Kaaval, Vizhi | Nov 24 | todo | - |

### Kalai (Flutter UI)

| Bolt | Work | Depends | Reviewers | Due | State | Blocker |
| --- | --- | --- | --- | --- | --- | --- |
| BOLT-0037 | Bento grid and motion patterns in `hm_design`: Rive/Lottie celebrations, shared Study Map -> topic transition, haptics, reduce-motion and Lite variants | - | Vizhi | Nov 20 | todo | - |
| BOLT-0038 | Harden learning screens; bento Today, Readiness, Profile; offline cache for Today, plan, meter; goldens at 200% text | 0037 | Vizhi | Nov 27 | todo | - |
| BOLT-0039 | Finish stubs: `current_affairs`, `library`, `support`, `wellbeing`, `staff_quick_actions` | 0037 | Vizhi | Nov 27 | todo | - |
| BOLT-0040 | Flutter web target, in-app "update available" prompt, "Collect your sticker" screen | 0030, 0036 | Vizhi, Kaaval | Nov 26 | todo | - |

### Vilaiyattu (games)

| Bolt | Work | Depends | Reviewers | Due | State | Blocker |
| --- | --- | --- | --- | --- | --- | --- |
| BOLT-0041 | Game engine and Supabase Realtime spike: Flame scene, Postgres state, broadcast channel, reconnect | 0024 | Kanakku, Kaaval, Vizhi | Nov 19 | todo | - |
| BOLT-0042 | Daily Spin + Lucky Slot with server odds table, odds button and rules card | 0041, 0046 | Kanakku, Kaaval, Vizhi | Nov 24 | todo | Founder approves odds and prizes |
| BOLT-0043 | Confidence Duel + Clue Poker | 0041 | Kanakku, Kaaval, Vizhi | Nov 27 | todo | - |
| BOLT-0044 | Squad Battles (with Koottam) | 0041, 0049 | Kanakku, Kaaval, Vizhi | Nov 27 | todo | - |

### Kanakku (economy and billing)

| Bolt | Work | Depends | Reviewers | Due | State | Blocker |
| --- | --- | --- | --- | --- | --- | --- |
| BOLT-0045 | Ledger design and ADR (double-entry Sparks, Points, XP) | - | Kaaval, Founder | Nov 18 | todo | - |
| BOLT-0046 | Economy: Sparks, Points, XP, Trophies, Match chips, daily check-in, cosmetics, Season Pass | 0045 | Kaaval, Founder | Nov 25 | todo | - |
| BOLT-0047 | Billing: Razorpay test mode, Play Billing, entitlements, restore, spending limits, paywalls with "Not now", `billing.live=false` | 0045 | Kaaval, Founder | Nov 27 | todo | Founder sets prices |
| BOLT-0048 | Firewall audit across economy, billing and games | 0042-0047 | Kaaval | Dec 1 | todo | - |

### Koottam (social)

| Bolt | Work | Depends | Reviewers | Due | State | Blocker |
| --- | --- | --- | --- | --- | --- | --- |
| BOLT-0049 | Squads data model, squads, chat with moderation hooks, Help Requests | 0031 | Kaaval, Vizhi | Nov 25 | todo | - |
| BOLT-0050 | Study Rooms (`focus` module): server-timed rooms, hours boards, nudges, privacy toggles | 0024 | Kaaval, Vizhi | Nov 27 | todo | INT-007 founder questions |

### Arivu (AI)

| Bolt | Work | Depends | Reviewers | Due | State | Blocker |
| --- | --- | --- | --- | --- | --- | --- |
| BOLT-0051 | AI gateway: budgets, fallbacks, redaction, cost log | - | Kaaval | Nov 20 | todo | - |
| BOLT-0052 | AI doubt help with safety filters and limits | 0051 | Kaaval | Nov 27 | todo | - |

### Medai (Desk)

| Bolt | Work | Depends | Reviewers | Due | State | Blocker |
| --- | --- | --- | --- | --- | --- | --- |
| BOLT-0053 | Desk shell and roles on `desk.heymey.app`, TOTP, audit log | - | Kaaval, Vizhi | Nov 20 | todo | - |
| BOLT-0054 | Desk screens: Support, Moderation, Review, Ops, Admin, Institution, Creator Studio, Partner, Exam Alert approval, content and watcher queues | 0053 | Kaaval, Vizhi | Nov 27 | todo | - |
| BOLT-0055 | Backend modules: `support`, `moderation`, `liveops`, `institutions`, `marketplace` | 0031 | Kaaval, Vizhi | Nov 26 | todo | - |
| BOLT-0056 | Sticker-code check page | 0036, 0053 | Kaaval | Dec 4 | todo | - |

### Thedal (research)

| Bolt | Work | Depends | Reviewers | Due | State | Blocker |
| --- | --- | --- | --- | --- | --- | --- |
| BOLT-0057 | `content/sources.md`, robots.txt checks, TNPSC scrapers (notifications, syllabi, schemes, past papers, answer keys) | - | Thirutham | Nov 19 | todo | - |
| BOLT-0058 | Group 4 papers and keys collected; eligibility rules and patterns from official notifications with URL and date | 0057 | Thirutham | Nov 25 | todo | - |
| BOLT-0059 | Daily official-page watcher sending changes to the Desk queue | 0032, 0054 | Thirutham, Kaaval | Nov 27 | todo | - |
| BOLT-0060 | Group 2/2A collection | 0058 | Thirutham | Dec 1 | todo | - |

### Ezhuthu (content)

| Bolt | Work | Depends | Reviewers | Due | State | Blocker |
| --- | --- | --- | --- | --- | --- | --- |
| BOLT-0061 | Group 4 original lessons, explanations and questions, all units | 0057 | Thirutham | Nov 26 | todo | - |
| BOLT-0062 | Glossary, Final Stretch checklist, Expo Challenge sets | 0061 | Thirutham | Dec 1 | todo | - |

### Thirutham (verification)

| Bolt | Work | Depends | Reviewers | Due | State | Blocker |
| --- | --- | --- | --- | --- | --- | --- |
| BOLT-0063 | Source fields in the content schema, `content:validate` rules, review process | - | Founder | Nov 18 | todo | - |
| BOLT-0064 | Verify Group 4; seed staging by Nov 27, production by Nov 29 after a fresh backup | 0058, 0061, 0063, 0028 | Founder spot-check | Nov 29 | todo | Lawyer answer on reproducing TNPSC papers |
| BOLT-0065 | Correction Log and "Report a mistake" flow | 0054 | Kaaval | Nov 27 | todo | - |

### Vizhi (QA)

| Bolt | Work | Depends | Reviewers | Due | State | Blocker |
| --- | --- | --- | --- | --- | --- | --- |
| BOLT-0066 | Test plan; integration suites on staging Supabase (replacing Testcontainers + Valkey) | 0026 | Kural | Nov 20 | todo | - |
| BOLT-0067 | Patrol E2E (Android, web) and k6 against staging | 0066 | Kural | Nov 27 | todo | - |
| BOLT-0068 | Release smoke tests Dec 1-2; stall build on budget phones by Dec 6 | 0067 | Kural | Dec 6 | todo | - |

### Kaaval (security and compliance)

| Bolt | Work | Depends | Reviewers | Due | State | Blocker |
| --- | --- | --- | --- | --- | --- | --- |
| BOLT-0069 | Drafts: Privacy, Terms, Refunds, Community Guidelines, Game Rules & Odds; processor list; under-18 gate spec | - | Founder, lawyer | Nov 20 | todo | - |
| BOLT-0070 | Security audits on every risky bolt (rolling) | - | Founder | Nov 27 | doing | - |
| BOLT-0071 | Compliance sign-off for the release candidate | 0070 | Founder | Dec 1 | todo | - |

### Murasu (marketing and stall)

| Bolt | Work | Depends | Reviewers | Due | State | Blocker |
| --- | --- | --- | --- | --- | --- | --- |
| BOLT-0072 | Honesty fix: remove invented testimonials, counts and the "content is live" claim; fix FAQ | - | Kaaval | Nov 17 | todo | - |
| BOLT-0073 | `/try` device routing with 3-step install guide, `/waitlist` (under 18), legal pages live | 0069, 0030 | Kaaval, Kalai | Nov 26 | todo | - |
| BOLT-0074 | Flex banner and A3/A4 Group 4 syllabus-checklist poster, print-ready, with tagged QR codes | 0058 | Kaaval, Kalai | Dec 3 | todo | Founder confirms printer specs |
| BOLT-0075 | Sticker art, demo video, stall kit | 0040 | Kaaval, Kalai | Dec 6 | todo | - |
