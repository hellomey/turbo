# AIDLC status board

> The single source of truth for "what is happening". Every agent updates this file as part of each step.
> Phases of the lifecycle: Inception (Capture → Elaborate → Decompose → **G-I**) · Construction (Design → **G-D** → Bolts → **G-C**) · Operations (Release → Observe → **G-O**)
> Product phases (D-2026-10-20-08): **Phase N = Week N of blueprint §43.**

Last updated: 2026-10-20 by conductor

## Intents

| Intent | Lifecycle step | Tier | Next action | Waiting on |
|---|---|---|---|---|
| [INT-000](inception/intents/INT-000-architecture-scaffold.md) Architecture scaffold | Operations / G-O | T2 | Founder reviews the scaffold | **Founder** |
| [INT-001](inception/intents/INT-001-foundation.md) **Phase 1** Foundation | **Construction / Bolts** (G-I passed: D-2026-10-20-09) | T2 | Bolts 0001–0006 below | agents |
| [INT-002](inception/intents/INT-002-core-study.md) Phase 2 Core study | Inception / Capture | T1 | Elaborate after Phase 1 G-C | spec |
| [INT-003](inception/intents/INT-003-games-squads-money.md) Phase 3 Games, squads, money | Inception / Capture | T2 | Elaborate | spec |
| [INT-004](inception/intents/INT-004-desk-safety-polish.md) Phase 4 Desk, safety, polish | Inception / Capture | T2 | Elaborate | spec |
| [INT-005](inception/intents/INT-005-marketing-alignment.md) Marketing alignment | Inception / Capture | T2 | Domain decided (heymey.app); CTAs still open (D-…-03) | **Founder** |

## Phase 1 bolts (INT-001)

| Bolt | Units | Agent | Status |
|---|---|---|---|
| [BOLT-0001](construction/bolts/BOLT-0001-phase1-platform-contract.md) Contract, schema, platform core, test harness, audit reference module | U-contracts, U-platform-api, U-audit | architect + conductor | done (contract test red until 0002/0003 land, by design) |
| [BOLT-0002](construction/bolts/BOLT-0002-identity.md) Identity: auth (OTP, sessions, Desk TOTP, deletion), users, roles, OTP email worker | U-auth, U-users, U-roles | backend (identity) | in review |
| [BOLT-0003](construction/bolts/BOLT-0003-catalog.md) Catalog: exams + eligibility engine, syllabus/Study Map, lessons, glossary, seed | U-exams, U-syllabus, U-content | backend (catalog) | in review |
| [BOLT-0004](construction/bolts/BOLT-0004-app-desk.md) App + Desk: shell, onboarding, eligibility, OTP sign-in, consent, Study Map, lessons + Listen, Desk TOTP | U-app-shell, U-design-system, U-app-onboarding, U-app-study, U-desk (sign-in) | flutter-ui | in review (71 Flutter tests green; BLOCKER: generated hm_api does not compile, see bolt file) |
| [BOLT-0005](construction/bolts/BOLT-0005-devops.md) DevOps: CI for Phase 1, image pins, marketing domain → heymey.app, graphify in workflow | U-infra, U-marketing (domain only) | devops | in review |
| [BOLT-0006](construction/bolts/BOLT-0006-reviews.md) Reviews: qa, security, compliance on bolts 0002–0005 | — | qa, security, compliance | in progress; **security: request changes** (SEC-H1 XFF rate-limit bypass, SEC-H2 Desk TOTP brute force, 4 Medium; founder question SEC-M4 Desk TOTP enrollment); **qa: pass with findings** (coverage targets met; Q-1 nested personal data in audit, Q-2 no X-Min-App-Version on guard errors; Q-5 `pnpm verify` red only in `@heymey/dart#lint`) |

## Units in design
Each building agent writes `construction/units/<unit>/domain-model.md` + `logical-design.md` first (skill `aidlc-design`);
architect review happens before G-C.

## Parallel tracks (blueprint §27)

| Track | Status | Owner |
|---|---|---|
| A. Engineering | Phase 1 in construction | agents |
| B. Content (syllabus mapping, PYQs, lessons, eligibility data) | not started (Phase 1 uses marked seed data) | content agents + reviewers |
| C. Company & legal | not tracked here | founder |
