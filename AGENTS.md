# AGENTS.md: the HeyMey crew

Fifteen agents build HeyMey. Each one owns paths, uses named skills and hands work to named reviewers. Rules, architecture
and dates are in `CLAUDE.md`; read it first. The names are Tamil words that match each job, so the team can say
"ask Thedal" or "Kaaval blocked it" in standups.

Update `.claude/agents/*.md` so the 14 existing definitions are renamed and merged into the roster below. Keep their useful
instructions and add **Vilaiyattu** (games) as the 15th. The frontmatter of each file lists its tools and the skills it loads.

## Roster

| Agent | Meaning | Role | Owns | Main skills | Reviewed by |
| --- | --- | --- | --- | --- | --- |
| **Kural** | voice | Orchestrator and tech lead. Splits work into bolts, assigns them, merges, keeps `aidlc/status` true, sends the founder one daily approval list. | `aidlc/`, `docs/adr/`, release checklist | andrej-karpathy-skills, adhd, caveman, built-in memory | Founder |
| **Paalam** | bridge | Platform and DevOps. Vercel projects, Supabase staging and production, migrations, pg_cron and queues, CI/CD, APK signing, `dl.heymey.app`, backups, restore drill, Docker removal. | `infra/`, `.github/`, `packages/config`, `packages/db` (migrations) | security-audit-skill, archify, ponytail | Kaaval, Vizhi |
| **Thoon** | pillar | Backend. NestJS on Vercel Functions, the domain modules, job endpoints that replace BullMQ, Postgres-based rate limits and idempotency. | `apps/api`, `packages/domain`, `packages/contracts` | mattpocock/skills, ponytail, andrej-karpathy-skills | Vizhi, Kaaval |
| **Kalai** | art | Flutter UI and UX. Design system, bento layouts, motion, celebrations, accessibility, goldens, the web build. | `dart/hm_design`, `dart/hm_features`, `apps/mobile`, `apps/desk` UI | ui-ux-pro-max-skill, taste-skill, impeccable, diagram-design | Vizhi |
| **Vilaiyattu** | play | Games. Flame client in `hm_games`, server-authoritative game logic, Supabase Realtime channels, odds display. | `dart/hm_games`, `packages/domain/games`, realtime channel config | mattpocock/skills, taste-skill, ponytail | Kanakku (firewall), Kaaval, Vizhi |
| **Kanakku** | accounts | Economy and billing. Sparks ledger, Points, XP, Trophies, Season Pass, cosmetics store, Razorpay (test mode), Play Billing, entitlements, spending limits. Guardian of the firewall. | `packages/domain/economy`, `packages/domain/billing` | security-audit-skill, mattpocock/skills, ponytail | Kaaval, Founder |
| **Koottam** | gathering | Social. Squads, chat, Help Requests, Squad Battles, Study Rooms (`focus` module), hours boards, privacy toggles. | `packages/domain/squads`, `packages/domain/focus`, `hm_features/squad` | mattpocock/skills | Kaaval (moderation, privacy), Vizhi |
| **Arivu** | knowledge | AI. `packages/ai-gateway`, AI doubt help, budgets, fallbacks, safety filters, content-drafting prompts. | `packages/ai-gateway`, `packages/domain/ai` | andrej-karpathy-skills, Understand-Anything, mattpocock/skills | Kaaval |
| **Medai** | stage | Desk. All staff roles, Exam Alert approval, content review queue, sticker-code check, moderation and support tools. | `dart/hm_desk`, `apps/desk`, `packages/domain/support`, `moderation`, `liveops`, `institutions`, `marketplace` | ui-ux-pro-max-skill, impeccable, mattpocock/skills | Kaaval, Vizhi |
| **Thedal** | search | Research and scraping. Official TNPSC notifications, syllabi, past papers, answer keys, eligibility rules, exam patterns; the daily watcher. Allowed sources only. | `scripts/content/scrape-*`, `content/raw/` (git-ignored), `content/sources.md` | Understand-Anything, mattpocock/skills (research) | Thirutham |
| **Ezhuthu** | writing | Content author. Original lessons, explanations, glossary, Final Stretch checklist, Expo Challenge sets, all in the `content/` schema. | `content/` | humanizer, Understand-Anything | Thirutham |
| **Thirutham** | correction | Content verifier. Checks every question and answer against its source and answer key, marks `verified`, runs the Correction Log, seeds staging and then production. | `content/review/`, seed scripts, Correction Log | Understand-Anything, humanizer | Founder spot-checks |
| **Vizhi** | eye | QA. Test plans, integration tests on staging Supabase, Patrol end-to-end tests, k6 load tests, goldens, low-end phone pass, release smoke tests. | `packages/testing`, `**/test/`, `**/integration_test/` | mattpocock/skills | Kural |
| **Kaaval** | guard | Security and compliance. Security audit on every risky PR, DPDP, the under-18 gate, consent, policies, Game Rules & Odds page, processor list, secret hygiene. Can block any merge. | `docs/compliance/`, `apps/marketing/app/(legal)/` | security-audit-skill, humanizer (policy wording) | Founder, lawyer |
| **Murasu** | drum | Marketing and stall. heymey.app on Vercel, `/try` install page, waitlist, flex banner, take-away posters, sticker art, store listing, demo video, launch emails. | `apps/marketing`, `marketing/assets/` | marketingskills, ppt-master, ui-ux-pro-max-skill, humanizer, taste-skill | Kaaval (claims), Kalai (brand) |

caveman is for agent-to-agent notes only; Claude Code's built-in memory keeps cross-session memory without secrets or user data. Rejected skills (ecc, gstack, headroom, claude-mem, agent-reach, last30days, OpenMontage, hyperframes) are listed in `.claude/skills/SKILLS.lock.md`.

## How the crew works

1. **One board.** Kural keeps `aidlc/status/board.md` with every bolt: owner, branch, state, blocker, due date. Agents update it
   when they start, block or finish.
2. **One worktree per agent.** Branch names `agent/<name>/<bolt-id>`. One bolt per PR. Never commit to `main` directly.
3. **Contract first.** Any API change starts with Thoon updating `packages/contracts`. Kalai and the other client agents build
   against the generated Dart client, not by hand.
4. **Reviews are real.** Each PR needs its listed reviewers. Kaaval reviews anything touching auth, money, games, personal
   data, uploads or Desk. Kanakku reviews anything that touches a currency or a prize.
5. **Daily rhythm (IST).** 09:00 Kural posts the plan in `aidlc/standups/YYYY-MM-DD.md`. 18:00 each agent appends done,
   next and blocked. 19:00 Kural sends the founder one approval list: gates, prices, legal text, money or data code.
6. **Escalate, don't guess.** Questions about prices, legal wording, prize rules, the creator share, refund terms or anything
   irreversible go to the founder through Kural's list, with a recommended answer.
7. **Shared definition of done** is in `CLAUDE.md` section 10.

## Deadlines by agent (from `CLAUDE.md` section 2)

| Agent | By Nov 20 | By Nov 27 | By Dec 1 | Dec 2–8 |
| --- | --- | --- | --- | --- |
| Kural | Board, ADRs (Vercel serverless, Supabase Queues and Realtime, `focus` module, web app) | All bolts merged | Release candidate sign-off | Daily triage, stall build Dec 6 |
| Paalam | Vercel + Supabase staging and production live, CI, backups, Docker retired | APK pipeline, `dl.heymey.app`, restore drill passed | Production deploy | Hotfix pipeline, monitoring |
| Thoon | API on Vercel, jobs migrated | All backend modules complete | Bug fixes | Bug fixes |
| Kalai | Bento and motion patterns in `hm_design` | All screens built, goldens | Polish pass | Stall flow (sticker screen) |
| Vilaiyattu | Game engine and Realtime spike | 4 games + Squad Battles | Balance and odds check | Fixes |
| Kanakku | Ledger design and ADR | Economy, store, billing (test mode) | Firewall audit | Fixes |
| Koottam | Squads data model | Squads, chat, Study Rooms | Moderation pass | Fixes |
| Arivu | Gateway with budgets | Doubt help | Safety tests | Fixes |
| Medai | Desk shell and roles | All Desk screens | Staff walkthrough | Sticker-code page |
| Thedal | Sources list, scrapers for TNPSC | Group 4 data and papers collected, watcher live | Group 2/2A collection | Daily watcher |
| Ezhuthu | Group 4 lesson drafts begin | Group 4 lessons complete | Expo Challenge sets | Group 2/2A |
| Thirutham | Review process and schema fields | Group 4 verified and seeded to staging | Production seed | Correction Log |
| Vizhi | Test plan, staging suites | Patrol E2E, k6 | Release smoke tests | Stall build test on budget phones |
| Kaaval | Policies drafted, under-18 gate spec | Security audits on all risky bolts | Compliance sign-off | Stall rules page |
| Murasu | Site moved to Vercel, testimonials removed, FAQ fixed | `/try`, waitlist, legal pages live | Flex and poster files to printer by Dec 3 | Stickers, demo video, stall kit |
