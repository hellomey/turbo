# AIDLC status board

> **From 2026-11-13 the live board is [`status/board.md`](status/board.md).** This file keeps the history up to BOLT-0023.

> The single source of truth for "what is happening". Every agent updates this file as part of each step.
> Phases of the lifecycle: Inception (Capture → Elaborate → Decompose → **G-I**) · Construction (Design → **G-D** → Bolts → **G-C**) · Operations (Release → Observe → **G-O**)
> Product phases (D-2026-10-20-08): **Phase N = Week N of blueprint §43.**

Last updated: 2026-10-22 by conductor

## Intents

| Intent | Lifecycle step | Tier | Next action | Waiting on |
|---|---|---|---|---|
| [INT-000](inception/intents/INT-000-architecture-scaffold.md) Architecture scaffold | Operations / G-O | T2 | Founder reviews the scaffold | **Founder** |
| [INT-001](inception/intents/INT-001-foundation.md) **Phase 1** Foundation | **Construction / Bolts** (G-I passed: D-2026-10-20-09) | T2 | All bolts green; **waiting for founder G-C** | **Founder** |
| [INT-002](inception/intents/INT-002-core-study.md) Phase 2 Core study | **Construction / review** | T1 | Bolts 0008-0019 built and green; founder manual test, BOLT-0020 reviews, G-C | **Founder**, qa |
| [INT-003](inception/intents/INT-003-games-squads-money.md) Phase 3 Games, squads, money | Inception / Capture | T2 | Elaborate | spec |
| [INT-004](inception/intents/INT-004-desk-safety-polish.md) Phase 4 Desk, safety, polish | Inception / Capture | T2 | Elaborate | spec |
| [INT-005](inception/intents/INT-005-marketing-alignment.md) Marketing alignment | Inception / Capture | T2 | Domain decided (heymey.app); CTAs still open (D-…-03) | **Founder** |
| [INT-006](inception/intents/INT-006-multi-exam-expansion.md) Multi-exam expansion (UPSC, SSC, Banking, CA, CS) | Inception / Elaborate done | T1/T2 | Founder answers Q1-Q12; schema lands in Phase 2 (BOLT-0008) | **Founder**, architect |
| [INT-007](inception/intents/INT-007-study-rooms.md) Study Rooms (live focus rooms, hours boards) | Inception / Elaborate done | T2 | Founder answers Q1-Q15; MVP Phase 3b | **Founder** |
| Decision | [D-2026-11-01-01](decisions.md) free-tier launch architecture (ADR-0014) | architect | T2 | PROVISIONAL: founder confirms; security + compliance review (new processors Supabase, Cloudflare); devops implements infra in parallel | **Founder**, devops |

## Phase 1 bolts (INT-001)

| Bolt | Units | Agent | Status |
|---|---|---|---|
| [BOLT-0001](construction/bolts/BOLT-0001-phase1-platform-contract.md) Contract, schema, platform core, test harness, audit reference module | U-contracts, U-platform-api, U-audit | architect + conductor | done (contract test red until 0002/0003 land, by design) |
| [BOLT-0002](construction/bolts/BOLT-0002-identity.md) Identity: auth (OTP, sessions, Desk TOTP, deletion), users, roles, OTP email worker | U-auth, U-users, U-roles | backend (identity) | in review |
| [BOLT-0003](construction/bolts/BOLT-0003-catalog.md) Catalog: exams + eligibility engine, syllabus/Study Map, lessons, glossary, seed | U-exams, U-syllabus, U-content | backend (catalog) | in review |
| [BOLT-0004](construction/bolts/BOLT-0004-app-desk.md) App + Desk: shell, onboarding, eligibility, OTP sign-in, consent, Study Map, lessons + Listen, Desk TOTP | U-app-shell, U-design-system, U-app-onboarding, U-app-study, U-desk (sign-in) | flutter-ui | in review (Flutter tests green; hm_api compiles since contract fix) |
| [BOLT-0005](construction/bolts/BOLT-0005-devops.md) DevOps: CI for Phase 1, image pins, marketing domain → heymey.app, graphify in workflow | U-infra, U-marketing (domain only) | devops | in review |
| [BOLT-0007](construction/bolts/BOLT-0007-security-fixes.md) Security fixes from BOLT-0006 review | U-auth, U-platform, U-infra | backend + devops | done 2026-10-22: all findings fixed, every security test is a plain `it` and passes on real Postgres + Valkey. Founder: add VALKEY_PASSWORD, STAGING_ACCESS_KEY, VPS_HOST_FINGERPRINT secrets; answer staging-access question |
| [BOLT-0006](construction/bolts/BOLT-0006-reviews.md) Reviews: qa, security, compliance on bolts 0002–0005 | — | qa, security, compliance | done: security findings fixed in BOLT-0007; QA Q-1..Q-3, Q-5 fixed; compliance C1–C3 fixed, C4/C5 need founder |

## Phase 2 bolts (INT-002)

| Bolt | Units | Agent | Status |
|---|---|---|---|
| [BOLT-0008](construction/bolts/BOLT-0008-phase2-designs-contract-schema.md) Designs, contract (45 routes), schema, ADR-0012/0013 | all Phase 2 units | architect | done; G-D + provisional defaults D-2026-10-22-10..35 await founder |
| [BOLT-0009](construction/bolts/BOLT-0009-mastery.md) mastery | U-mastery | backend | in review 2026-10-22: 7 routes + dimming worker, §43 7-day acceptance green, 97.9% stmt coverage; 2 design notes for architect (recall on dimming lamp, rank titles) |
| [BOLT-0011](construction/bolts/BOLT-0011-exam-hall.md) exam-hall + structure | U-exam-hall, U-exams | backend | in review: 10 routes, 2 worker queues, SEED catalogue; unit + integration green. Open: Marks negative scores, report-not-submitted code (architect) |
| [BOLT-0014](construction/bolts/BOLT-0014-notifications-exam-alerts.md) notifications + Exam Alerts | U-notifications, U-exams | backend | in review 2026-10-22: 9 routes, workers, integration green (api 50/50). Needs security + compliance review; founder must add CHANGEDETECTION_WEBHOOK_SECRET to SOPS |
| BOLT-0015 changedetection + pack CDN | U-infra | devops | in review (security review; env var name to align with BOLT-0014) |
| BOLT-0016 offline store, outbox, packs | U-app-shell | flutter-ui | in review (lint, tests, debug APK green; hm_api nullable-required codegen follow-up) |
| [BOLT-0010](construction/bolts/BOLT-0010-practice.md) practice + content routes | U-practice | backend | in review 2026-10-22: 9 routes + practice_answer sync; 40 parallel -> 30 counted (Testcontainers); 96% stmt coverage, limit logic 100%. Needs compliance on limit-sheet copy; question seed is a follow-up |
| [BOLT-0012](construction/bolts/BOLT-0012-plan.md) plan | U-plan | backend | in review 2026-10-23: 6 routes, plan_item_status sync, 2 worker queues; integration green (api 69/69, domain 60/60) |
| [BOLT-0013](construction/bolts/BOLT-0013-readiness.md) readiness + Sunday Report | U-readiness | backend | in review 2026-10-22: 4 routes, `readiness.sunday-report` worker at 08:00 IST, unit 30 + int (domain 4, api 3) green. Open: label for non-TN exams (contract has no null label), practice/billing ports stubbed |
| [BOLT-0017](construction/bolts/BOLT-0017-study-practice-screens.md) study app screens (checks, relight, practice, PYQ, limit sheet) | U-app-study | flutter-ui | in review 2026-10-23: tests + goldens + debug APK green; dart lint blocked only by format in parallel-bolt files; limit sheet needs compliance + founder (T2) |
| [BOLT-0019](construction/bolts/BOLT-0019-exam-hall-screens.md) Exam Hall screens | U-app-exam-hall | flutter-ui | in review (tests + goldens green, debug APK built; dart lint waits on BOLT-0017 formatting) |
| [BOLT-0018](construction/bolts/BOLT-0018-plan-readiness-alerts-screens.md) Today + plan card, My Plan, rank bar, Readiness, Sunday Report, Exam Alerts + settings, no-op push | U-plan, U-readiness, U-notifications (app) | flutter-ui | in review 2026-10-23: tests + goldens + debug APK green; dart lint clean except format in BOLT-0017 practice files |
| BOLT-0020 reviews | qa | qa | after BOLT-0017/0018/0019; security review done 2026-11-04: approve with findings (M1 audit not atomic, M2 exam-changes outside ops allowlist, M3 DB TLS not enforced) -> `bolts/BOLT-0020-reviews-security.md` ; compliance C-P2-1 + C-P2-3 fixed by flutter-ui 2026-11-04; qa review done 2026-11-04: pass with findings Q-1..Q-5 (integration needs a re-run with Docker up) -> `bolts/BOLT-0020-reviews-qa.md`; backend fixed SEC-P2-M1/M3/L1/L2/L3 2026-11-04 (verify + integration green; M2/L4/I1/I2 open for architect/devops); SEC-P2-L2 follow-up (mastery RingEvent + practice answer per-user dedupe) fixed 2026-11-04, migration awaits architect approval |
| [BOLT-0021](construction/bolts/BOLT-0021-design-system-v2.md) Design system v2: tokens, Nunito, gamified components, rewiring | U-design-system | flutter-ui | in review 2026-10-23: dart lint clean, all Flutter tests green (goldens regenerated + gallery goldens), debug APK built. Founder: approve font (Nunito) and primary teal / reward gold swap vs §10.3-§10.4. Next: BOLT-0022 restyle Phase 2 screens |
| [BOLT-0022](construction/bolts/BOLT-0022-screen-restyle.md) Restyle all app screens on design system v2 (step headers, skeletons, illustrations, celebrations) | U-design-system + app units | flutter-ui | in review 2026-11-01: dart lint exit 0, flutter test green in every member (hm_design 26, hm_core 21, hm_data 28, hm_features 170, hm_desk 4, mobile 2, desk 1; goldens regenerated with real Nunito), debug APK built, graphify updated. Compliance: new celebration copy |
| [BOLT-0023](construction/bolts/BOLT-0023-free-tier-migration.md) Free/starter-tier hosting: Supabase, R2, Firebase Hosting (desk), Vercel (marketing; amended 2026-11-04, D-2026-11-04-01), one ARM VM | U-platform | devops | in review 2026-11-04: Vercel amendment done (deploy.yml marketing jobs removed, apps/marketing/vercel.json, docs); founder: choose Vercel Pro vs Hobby, apps/marketing is a nested git checkout (hellomay-landing) renamed off @heymey/marketing - decide. 2026-11-01: TS lint/typecheck/test green (36 tasks), compose config OK on all stacks. Docker was not running locally: integration tests, caddy validate, dart codegen and the opennext build (Windows symlink EPERM) still need a run on CI/Linux. Founder: follow docs/runbooks/free-tier-setup.md; security review of infra/CI |


## Units in design
Each building agent writes `construction/units/<unit>/domain-model.md` + `logical-design.md` first (skill `aidlc-design`);
architect review happens before G-C.

## Parallel tracks (blueprint §27)

| Track | Status | Owner |
|---|---|---|
| A. Engineering | Phase 1 in construction | agents |
| B. Content (syllabus mapping, PYQs, lessons, eligibility data) | not started (Phase 1 uses marked seed data) | content agents + reviewers |
| C. Company & legal | not tracked here | founder |
