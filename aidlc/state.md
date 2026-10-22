# AIDLC status board

> The single source of truth for "what is happening". Every agent updates this file as part of each step.
> Phases of the lifecycle: Inception (Capture → Elaborate → Decompose → **G-I**) · Construction (Design → **G-D** → Bolts → **G-C**) · Operations (Release → Observe → **G-O**)
> Product phases (D-2026-10-20-08): **Phase N = Week N of blueprint §43.**

Last updated: 2026-10-22 by conductor

## Intents

| Intent | Lifecycle step | Tier | Next action | Waiting on |
|---|---|---|---|---|
| [INT-000](inception/intents/INT-000-architecture-scaffold.md) Architecture scaffold | Operations / G-O | T2 | Founder reviews the scaffold | **Founder** |
| [INT-001](inception/intents/INT-001-foundation.md) **Phase 1** Foundation | **Construction / Bolts** (G-I passed: D-2026-10-20-09) | T2 | All bolts green; **waiting for founder G-C** | **Founder** |
| [INT-002](inception/intents/INT-002-core-study.md) Phase 2 Core study | Inception / Elaborate done | T1 | Founder answers Q1-Q25, then architect BOLT-0008, then G-I | founder, architect |
| [INT-003](inception/intents/INT-003-games-squads-money.md) Phase 3 Games, squads, money | Inception / Capture | T2 | Elaborate | spec |
| [INT-004](inception/intents/INT-004-desk-safety-polish.md) Phase 4 Desk, safety, polish | Inception / Capture | T2 | Elaborate | spec |
| [INT-005](inception/intents/INT-005-marketing-alignment.md) Marketing alignment | Inception / Capture | T2 | Domain decided (heymey.app); CTAs still open (D-…-03) | **Founder** |
| [INT-006](inception/intents/INT-006-multi-exam-expansion.md) Multi-exam expansion (UPSC, SSC, Banking, CA, CS) | Inception / Elaborate done | T1/T2 | Founder answers Q1-Q12; schema lands in Phase 2 (BOLT-0008) | **Founder**, architect |
| [INT-007](inception/intents/INT-007-study-rooms.md) Study Rooms (live focus rooms, hours boards) | Inception / Elaborate done | T2 | Founder answers Q1-Q15; MVP Phase 3b | **Founder** |

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
| BOLT-0009 mastery | U-mastery | backend | building |
| BOLT-0011 exam-hall + structure | U-exam-hall, U-exams | backend | building |
| BOLT-0014 notifications + Exam Alerts | U-notifications, U-exams | backend | building |
| BOLT-0015 changedetection + pack CDN | U-infra | devops | in review (security review; env var name to align with BOLT-0014) |
| BOLT-0016 offline store, outbox, packs | U-app-shell | flutter-ui | building |
| BOLT-0010, 0012, 0013 | practice, plan, readiness | backend | after 0009 |
| BOLT-0017..0019 app screens, BOLT-0020 reviews | app, qa | flutter-ui, qa | after backends |

## Units in design
Each building agent writes `construction/units/<unit>/domain-model.md` + `logical-design.md` first (skill `aidlc-design`);
architect review happens before G-C.

## Parallel tracks (blueprint §27)

| Track | Status | Owner |
|---|---|---|
| A. Engineering | Phase 1 in construction | agents |
| B. Content (syllabus mapping, PYQs, lessons, eligibility data) | not started (Phase 1 uses marked seed data) | content agents + reviewers |
| C. Company & legal | not tracked here | founder |
