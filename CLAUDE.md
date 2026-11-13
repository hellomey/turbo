# CLAUDE.md: HeyMey

This file is the operating manual for every Claude session and sub-agent in this repo. Read it fully before any work.
`AGENTS.md` names the crew and who owns what. When this file and an older doc disagree, this file wins, then
`docs/HEYMEY_PRODUCT_BLUEPRINT.md`, then `aidlc/decisions.md`. `HEYMEY_COMPLETE_PLAN.md` is an earlier concept and is
superseded. Never build from it.

## 1. What HeyMey is

HeyMey is an exam-preparation app for TNPSC aspirants in Tamil Nadu. It includes eligibility checks, a Study Map of lamps
that light and dim with memory, recall and relight, practice, past papers, Exam Hall mocks, a readiness meter, a study plan,
Exam Alerts, games, squads, Study Rooms, a store and staff tools (Desk). The brand promise is **honesty**: the readiness
score is a simple, explainable formula, and nothing in the product is faked.

## 2. The mission and the dates (fixed)

| Date | Milestone |
| --- | --- |
| Nov 20 | Production infrastructure live on Vercel + Supabase. Docker removed from the deploy path. |
| Nov 27 | Every module feature-complete (list in section 4), behind feature flags where approvals are pending. |
| Nov 29 | Verified Group 4 content and the question bank seeded to production. Group 2/2A started. |
| Dec 1 | Release candidate. Feature freeze. Bug fixes only. |
| **Dec 2 (Wed)** | **Production testing release**: real testers on Android, the web app and Desk. |
| Dec 6 | Stall build frozen (app, web app, install page, posters, stickers flow). |
| Dec 9–13 | Stall at Products of PSG Products expo, CODISSIA, Coimbatore, Hall A, stall A130 (3 m × 2 m). |

We build the production app from now on. There is no separate "demo app".

## 3. Production architecture (no Docker)

| Part | Runs on | Notes |
| --- | --- | --- |
| Mobile app (`apps/mobile`, Flutter) | Android release APK at `dl.heymey.app`; iOS later | Signed in GitHub Actions. In-app "update available" prompt, because sideloaded apps get no store updates. |
| Web app (same Flutter code, web target) | Vercel, `app.heymey.app` | The no-install "try it" path for iPhone users and stall visitors. Log this as a decision that amends Decision 2 (no web for aspirants). |
| Desk (`apps/desk`, `dart/hm_desk`) | Vercel, `desk.heymey.app` | Staff only. TOTP required. |
| Marketing (`apps/marketing`, Next.js) | Vercel, `heymey.app` | Includes `/try`, `/waitlist`, `/privacy`, `/terms`, `/refunds`, `/rules` (Game Rules & Odds), `/community-guidelines`. |
| API (`apps/api`, NestJS + Fastify) | Vercel Functions, Node runtime, Mumbai region (`bom1`) | Serverless adapter. Keep handlers stateless and fast. Check the plan's maximum duration and keep every request well under it. |
| Database | Supabase Postgres, separate **staging** and **production** projects | Prisma with `DATABASE_URL` = transaction pooler (port 6543, `pgbouncer=true`, `connection_limit=1`) and `DIRECT_URL` = session pooler (port 5432) for migrations. Never the IPv6-only direct host. |
| Background jobs (was BullMQ worker + scheduler) | Supabase Queues (pgmq) + `pg_cron` + `pg_net` calling signed `/internal/jobs/*` endpoints on Vercel | Every one of the 8 old processors becomes an idempotent, chunked HTTP job. Vercel Cron is used only where its plan frequency allows. |
| Realtime (was `apps/realtime`, Socket.IO) | Supabase Realtime (broadcast + presence) | The server stays authoritative: game and room state live in Postgres and change only through API endpoints. Clients only listen. Check current free-tier connection limits. |
| Cache, rate limits, idempotency (was Valkey) | Postgres tables with TTL cleanup jobs | Add Upstash Redis free tier only if measurements show the need. |
| Files | Supabase Storage (content packs, avatars); Cloudflare R2 (APK downloads, backups) | Signed URLs for Pro packs. |
| Email OTP | Brevo (primary, 300/day), Resend (fallback, 100/day) | Switch with `EMAIL_PROVIDER`. SPF, DKIM and DMARC on heymey.app. Email OTP only, never SMS. |
| Push | Firebase Cloud Messaging | APNs when iOS ships. |
| AI | `packages/ai-gateway` only: OpenRouter and Gemini, free models first | Budgets, fallbacks, no personal data in prompts, log costs. |
| Payments | Razorpay **test mode**, Google Play Billing (when Play Console exists) | Fully built, flag `billing.live=false` in production until the company, GST, Razorpay KYC and store accounts exist. |
| Observability | Sentry (Flutter + NestJS), PostHog (after consent), Vercel logs, UptimeRobot | Strip personal data from events. |
| CI/CD | GitHub Actions → Vercel; `prisma migrate deploy`; APK build; nightly `pg_dump` to R2 | Production deploys only from `main` after CI is green. |

Free-tier facts every agent must respect:
- Supabase Free has **no backups** and pauses after a week idle. The nightly dump to R2 is mandatory, and a restore drill
  must pass before Dec 2.
- Vercel Hobby is for **non-commercial** use. Before the first real payment or paid promotion, the founder moves the team
  to Pro. Flag this in the release checklist; do not decide it yourself.
- Move `infra/` Docker files to `infra/legacy-docker/` with a README. Do not delete git history. Local development runs
  `pnpm dev` against the **staging** Supabase project.

## 4. Scope for Dec 2: everything

Nothing is excluded. Each module ships complete, tested and behind a flag if an outside approval is still pending.

- **Learning (built, harden it):** auth, onboarding, eligibility, Study Map and lamps, lessons + Listen, Lit/recall/relight/Gold checks,
  practice, mistakes, PYQ Vault, Exam Hall (OMR + CBT), plan, Today, readiness + Sunday Report, Exam Alerts, offline sync.
- **Economy:** Sparks ledger (double-entry, bought only), Points, XP, Trophies, Match chips, daily check-in, cosmetics, Season Pass.
- **Games (`dart/hm_games`, Flame):** Daily Spin, Lucky Slot, Confidence Duel, Clue Poker, Squad Battles. Server-authoritative, odds shown,
  no stake, prizes are Points, XP or cosmetics only.
- **Squads:** squads, chat with moderation, Help Requests, Squad Battles.
- **Study Rooms:** new `focus` module (write the ADR first), server-timed rooms, hours boards, nudges, privacy toggles.
- **Billing:** Razorpay, Google Play Billing, entitlements, restore purchases, spending limits, paywalls with "Not now".
- **AI:** AI gateway and AI doubt help with budgets and safety filters.
- **Desk:** Support, Moderation, Review, Ops, Admin, Institution, Creator Studio, Partner, Exam Alert approval, content review queue.
- **Backend stubs to finish:** `ai`, `analytics`, `institutions`, `liveops`, `marketplace`, `moderation`, `squads`, `support`,
  plus `economy`, `billing` and `games`.
- **Flutter stubs to finish:** `play`, `squad`, `store`, `current_affairs`, `library`, `support`, `wellbeing`, `staff_quick_actions`.
- **Phase 2 carry-overs:** offline cache for Today, plan and meter; Pro readiness trend; nightly readiness snapshot; real push;
  delete push token on logout; outbox for Exam Alert fan-out; `MOCK_NOT_SUBMITTED`; signed Pro-pack links; glossary and
  Final Stretch content; goldens at 200% text.

## 5. Rules that never bend

1. **Money/game firewall.** `pnpm firewall:check` must pass on every PR. No game rewards Sparks or anything worth money.
   Sparks are only bought. Points are never bought. No stake, no cash-out, odds always shown. India's Online Gaming Act 2025
   and its Rules (in force from 1 May 2026) ban online money games; the firewall is how we stay out of that category.
2. **Honesty.** No invented testimonials, users, counts, activity feeds or reviews. Live feeds and leaderboards show only real,
   opt-in activity, using display names only. No "streak lost" wording; missing a day resets nothing.
3. **Privacy (DPDP Act).** Users under 18 join the waitlist only, with no account. Consent before analytics. No personal data
   sent to AI. Never read `.env`. Secrets live only in Vercel, Supabase and GitHub settings.
4. **Contract first.** Zod routes → OpenAPI 3.1 → generated Dart client (`dart/hm_api`). The contract test must pass.
5. **Clean boundaries.** Business logic lives in `packages/domain`, free of frameworks. Controllers stay thin.
   Every write route uses `PlatformGuard`, rate limits and `Idempotency-Key`.
6. **Language.** The interface is English (Decision 3). Tamil appears in Tamil Language paper content.
7. **Repo conventions.** pnpm only. Ports: api 4567, marketing 4570. Conventional commits. One bolt per PR.
8. **Process.** AIDLC: intent → stories → unit design → G-D → bolt (contract → failing tests → code → verify) → QA,
   security and compliance review → G-C. The founder approves gates, prices, legal text and money or personal-data code.
   To keep pace, the orchestrator batches approvals into one daily list for the founder.

## 6. Content, scraping and the question bank

Goal: by Nov 29, production holds verified TNPSC Group 4 content (all units) and a real question bank, with Group 2/2A next.

**Allowed sources** (respect `robots.txt` and terms of use; rate-limit to 1 request per second or slower; identify the crawler):
- tnpsc.gov.in: notifications, syllabi, schemes of examination, previous question papers, tentative and final answer keys.
- Tamil Nadu government textbooks (Samacheer Kalvi) and other government portals, **as references to write original lessons
  from**, not text to copy.
- Official government sources (Gazette, PIB, TN government press releases) for current affairs.

**Not allowed:** copying question banks, notes or explanations from coaching institutes, apps, YouTube, Telegram PDFs or
paid books. When an item cannot be traced to an allowed source, write an original question instead.

**Pipeline:** `scripts/content/scrape-*` → raw files in `content/raw/` (git-ignored) → extract → normalise to the
`content/` YAML schema → `pnpm content:validate` → human review → `pnpm db:seed:content` (idempotent upserts with stable IDs)
to staging, then production. Every question stores `source_url`, `source_title`, `retrieved_at`, `exam`, `year`,
`question_no`, `answer_key_source`, `review_status` and `reviewed_by`. Only `verified` items reach users. Items still
unverified show the label "practice set, not official". Every item has a "Report a mistake" action feeding the Correction Log.
**Verify with the founder's lawyer** how much of TNPSC's published papers may be reproduced before the Dec 2 release.

**Exam data:** eligibility rules, age limits, community relaxations, exam patterns, negative marking and dates come only
from official notifications. Store the notification URL and date on each rule. A watcher job checks official pages daily,
and any change goes to Desk for staff approval before it reaches users.

## 7. UI and UX standard

- Extend design system v2 in `dart/hm_design` (Nunito, warm light and rich dark themes). Do not start a second system.
- Use **bento grid** layouts for Today, Readiness, Profile, the Play hub, the Store and the Desk home, with clear hierarchy, generous
  spacing and one hero tile per screen.
- **Motion:** `flutter_animate` for transitions; Rive or Lottie for celebrations (lamp lighting, Gold, level-up). Durations of
  150–400 ms with spring curves. Shared-element transitions between the Study Map and topics. Haptics on key wins.
- **Accessibility:** respect Calm Mode, Lite Mode, the OS reduce-motion setting, high contrast and 200% text. Golden tests
  for every new screen at 100% and 200% text, in light and dark.
- **Performance:** 60 fps on a budget Android phone with 3 GB RAM, APK under 40 MB if possible, first screen in under 2 s on 4G.
- The marketing site and posters use the same tokens. Avoid generic AI-looking layouts; run the taste and impeccable skills
  on every screen before review.

## 8. The stall (no TV)

What we have: a flex banner, take-away posters and stickers for people who actually tried the app.

- **One QR everywhere → `heymey.app/try`.** The page detects the device: Android → download the APK from `dl.heymey.app`
  with a 3-step visual install guide; iPhone or laptop → open `app.heymey.app` instantly; under 18 → waitlist.
- Each print piece carries its own QR source tag (`?src=flex`, `?src=poster`) for PostHog.
- **Sticker earned in-app:** after a visitor lights a first lamp, the app shows a "Collect your sticker" screen with a one-time
  code that staff verify on a Desk page. Only people who tried get a sticker, and it cannot be faked.
- **Take-away poster:** an A3/A4 Group 4 syllabus checklist with the QR. It is useful on its own wall, so it keeps working
  after the expo.
- No deploys during stall hours. Critical fixes only, after hours.

## 9. Skills

Skills and plugins live in `.claude/skills/` (project skills) or are installed as plugins. Every one is pinned to a commit in
`.claude/skills/SKILLS.lock.md`, listing repo, commit, install date and what it does. **Before enabling any skill, read its
`SKILL.md` and every script or hook it ships.** Reject anything that sends code, secrets or user data to an outside service,
runs network calls you did not expect, or edits files outside this repo.

| Use | Skills |
| --- | --- |
| Writing code | cloudflare/security-audit-skill, mattpocock/skills, affaan-m/ecc, multica-ai/andrej-karpathy-skills, dietrichgebert/ponytail |
| Research | Panniantong/agent-reach, Egonex-AI/Understand-Anything, mvanhorn/last30days-skill |
| Workflow and context | garrytan/gstack, juliusbrussee/caveman, headroomlabs-ai/headroom, thedotmack/claude-mem |
| UI and design | nextlevelbuilder/ui-ux-pro-max-skill, leonxlnx/taste-skill, tt-a1i/archify, pbakaus/impeccable, hugohe3/ppt-master, cathrynlavery/diagram-design |
| Focus, marketing, media, copy | uditakhourii/adhd, coreyhaines31/marketingskills, OpenMontageInc/OpenMontage, heygen-com/hyperframes, blader/humanizer |

Usage rules:
- Run the security audit skill on every PR touching auth, billing, economy, games, uploads or Desk.
- Terse styles from caveman and headroom apply to agent-to-agent notes only. Never use them in user-facing copy, docs, commit
  messages or code comments.
- Run humanizer on every piece of user-facing copy (app strings, emails, site, posters). Content must still be factually exact.
- claude-mem must never store secrets, `.env` contents or user personal data.

## 10. Definition of done (every bolt)

Contract updated and Dart client regenerated; failing tests written first, then passing; `pnpm verify` green; firewall check green;
coverage at least 90% for money, economy and games code and at least 80% elsewhere; golden tests for new screens; security and
compliance review notes in the PR; deployed to staging and smoke-tested; a short screen recording attached for UI work;
`aidlc/status` updated.

## 11. Never

Push to `main` without green CI. Run a production migration without a fresh backup. Delete user data outside the deletion flow.
Commit secrets. Disable or weaken the firewall tests. Seed unverified or SEED data as real. Scrape a source on the
not-allowed list. Use an invented person, review or number anywhere.
