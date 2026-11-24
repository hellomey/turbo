# Handoff for the next Claude session (written 2026-11-24 by Kural)

Read `CLAUDE.md` first, then this file. Where this file and CLAUDE.md §2/§4 disagree, **this file wins**: the founder cut
scope on 2026-11-24 (see "Scope"). CLAUDE.md §2/§4 and `aidlc/status/board.md` have NOT yet been rewritten to match.
Do that first (small docs PR).

## Goal
A real, working Android app on the founder's phone ASAP, then Dec 2 testing release, then the stall (Dec 9-13, 3 m x 2 m
stall A130, CODISSIA). The founder is judging on a real phone: it must look good, run smoothly, and actually work end to end.

## Scope (founder decision, 2026-11-24)
SHIP: auth (email OTP), onboarding, eligibility, Study Map and lamps, lessons + Listen, practice, mistakes, PYQ Vault,
Exam Hall, plan, Today, readiness + Sunday Report, Exam Alerts.
OUT OF SCOPE for Dec 2 and the stall, flagged off, not "todo": games, Study Rooms, billing, AI gateway, squads, every Desk
role beyond sign-in. Mark their bolts "out of scope" on the board. Do not build them.
Skip new golden tests for now. Priority is look, feel and a working flow on a real phone.

## Real state of the repo (verified, not from the board)
- Built and unit-tested (452 domain tests pass): domain modules auth, users, roles, audit, exams (eligibility), syllabus,
  content, mastery, practice, exam-hall, plan, readiness, notifications in `packages/domain/src/modules/`.
- Stubs (5 lines): ai, analytics, institutions, liveops, marketplace, moderation, squads, support. Partial: economy, games, billing. Out of scope anyway.
- Flutter learning screens have real code in `dart/hm_features/lib/src/` (exam_hall, practice, onboarding, plan, study_map,
  readiness, today, lessons, alerts, profile, pyq_vault, eligibility). Stubs: current_affairs, library, support, wellbeing,
  staff_quick_actions, play, squad, store (out of scope or later).
- **There is NO deployed backend.** `apps/api` (NestJS) exists, but api/app/desk.heymey.app return HTTP 525; only
  heymey.app (marketing, Vercel) is live. No Supabase project, no Vercel API project exist yet (founder creates accounts).
- **There are no content YAMLs** (only `content/syllabus/tnpsc-group-4.yaml`). No lessons or questions anywhere.
- The app has no mock-data mode. Without a backend, sign-in (OTP email via API) fails, so a first APK is not usable for testing.
- Only the founder and Paalam have ever made commits; the "15-agent crew" on the board is fiction. Real crew now: Kural,
  Paalam, Thoon, Kalai. Do not claim anything is done unless you can point to a commit, PR or release.

## Environment facts
- Windows 11, Git Bash. `gh` is logged in via `GH_TOKEN`. The founder updated the token (needs Pull requests, Contents,
  Actions, Workflows read/write). Env vars load at IDE start, so a stale session still has the old token: test with
  `gh pr create`; if it says "Resource not accessible by personal access token", ask the founder to fully restart the IDE.
- pnpm: `corepack pnpm ...` works (pnpm 12.14.0). For turbo, put a corepack shim dir on PATH:
  `corepack enable --install-directory <dir>` then `export PATH=<dir>:$PATH` (use `/c/...` style paths in Git Bash).
- Flutter SDK is installed on Windows but was not on the Bash PATH. Ask for the folder or find it before local Flutter runs.
- Full `pnpm verify` result on 2026-11-23: all TypeScript lint/typecheck/test green (36/38 tasks), only `@heymey/dart`
  lint/test failed (no Flutter on PATH then). `pnpm firewall:check` only counts 12 test files; it does not run them.
- Never read `.env`. No secrets in commits. Conventional commits, end with the Co-Authored-By line from the session reminder.
- The auto-mode classifier blocked force-push and remote branch deletion. Do not retry; use new branches and PRs.
- `graphify` git hook prints a harmless warning on every commit. `pubspec.lock` shows as modified locally; ignore or
  commit separately.

## What was done on 2026-11-23/24 (PRs)
- PR #4 crew setup: merged by founder (includes the junk commit "k", one line in graphify lock, harmless).
- PR #6 BOLT-0077: `.github/workflows/android-beta.yml` merged. Builds release APK on push to main and manual dispatch,
  publishes GitHub Release `v0.1.0-beta.<yyyymmdd>.<run>` and a moving `latest` release (asset `heymey-latest.apk`),
  notes state the backend and that signing is the debug key. Backend comes from workflow input `api_base_url` or repo
  variable `API_BASE_URL` (+ `API_BACKEND_LABEL`); with neither it says "none".
- First run FAILED (run 45337947743): Flutter stable needs AGP >= 9.1.1, project had 9.1.0.
- BOLT-0078 branch `agent/paalam/BOLT-0078-agp-bump` pushed, PR NOT yet created (token): bumps
  `apps/mobile/android/settings.gradle.kts` to 9.1.1. Create the PR, merge, watch the android-beta run, fix the next error.

## Current red CI on main (fix after the APK works; do not merge other work on red without saying so)
- flutter job: golden tests fail (goldens were generated on Windows; CI compares on Linux, now the reference platform).
  Fix by regenerating goldens on Linux in CI (e.g. `flutter test --update-goldens` in a workflow_dispatch job that commits them), not by deleting tests.
- security job: `semgrep` step fails. images job: "server (api, realtime, worker, scheduler)" docker build fails.
  `deploy` workflow also failed on the merge. Read the logs with `gh run view <id> --log-failed`.

## Plan, in order
1. Create PR for BOLT-0078, merge, get the first APK on GitHub Releases, send the founder the link.
2. Docs PR: rewrite CLAUDE.md §2 and §4 for the cut scope; rewrite `aidlc/status/board.md` from this file (real crew, dropped modules "out of scope").
3. Backend so the app has something to call (Thoon): real HTTP routes in `apps/api` over the existing domain modules (auth/OTP,
   users, exams+eligibility, syllabus, content, mastery, practice, exam-hall, plan, readiness, notifications). Contract first
   (Zod -> OpenAPI -> `dart/hm_api`), contract test must pass. Check what routes already exist before writing new ones.
4. Platform (Paalam), no credentials needed first: Vercel project configs (API in Mumbai `bom1`, serverless adapter),
   Supabase migration files + seed scripts, env var templates, GitHub Actions secrets structure. Prisma: `DATABASE_URL` =
   transaction pooler (6543, pgbouncer=true, connection_limit=1), `DIRECT_URL` = session pooler (5432). Valkey/BullMQ
   replacement can be deferred for the learning core if it blocks (rate limits/idempotency in Postgres; OTP email via Brevo/Resend).
5. When the founder hands over Supabase URL/keys and Vercel access: run migrations, seed, deploy API, set repo variable
   `API_BASE_URL` + `API_BACKEND_LABEL=staging`, re-run android-beta, and tell the founder the exact backend per build.
6. UI (Kalai): bento grid + motion from CLAUDE.md §7 on onboarding, Study Map, practice, exam hall, plan, readiness (in that
   order). Extend `dart/hm_design` (Nunito, v2). `flutter_animate`, 150-400 ms spring curves, honour reduce-motion/Calm/Lite.
   No games/Desk screens. Also consider an offline/demo fallback only if the backend slips.
7. Content stopgap: one Aptitude and Mental Ability unit, about 10 lessons and 80 questions, original writing (no copying
   from coaching sites/apps/PDFs), in the `content/` YAML schema, passing `pnpm content:validate`, loaded via
   `pnpm db:seed:content`, shown in-app labelled "sample content, under review". Every question needs source fields
   and `review_status` not `verified`. Check `content/AGENTS.md` and `content/pipeline/validate.mjs` for the schema.
8. Fix red CI, then the founder's gates: Dec 1 freeze, Dec 2 release.

## Honesty rules for status messages
Report only what a commit/PR/release proves. If a date looks unreachable, say which and why. Nothing invented
(users, reviews, counts). Stall copy submitted to PSG Products says visitors can "try it live": that needs a working backend
by Dec 9. Stall size: CLAUDE.md says 3 m x 2 m but the exhibitor form showed a 24 sq.m booking; the founder submitted it
and said to leave it, so do not raise it again.

## Dates (today 2026-11-24)
Nov 20 infra: missed. Nov 27 all modules: replaced by the cut scope above. Nov 29 verified content: not reachable at full scope;
only the sample unit is feasible. Dec 1 RC / freeze. Dec 2 testing release (learning core only). Dec 6 stall freeze. Dec 9-13 stall.
Biggest risk: no backend and no accounts yet. Everything useful on a phone depends on step 5.
