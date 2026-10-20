# Units of work

Every unit is a cohesive slice one agent team can design, build and test on its own. Backend units map 1:1 to
the domain modules in `packages/domain/src/modules/` (their `module.json` is the dependency truth). Client units map
to feature folders in `dart/hm_features` / `dart/hm_desk`. Week = blueprint §43.

Tier: **T2** = money, personal data, game fairness, security, legal text (founder approves design and merge).

## Platform units (week 1, first)

| Unit | Intent | Where | Tier | Agent | Depends on |
|---|---|---|---|---|---|
| U-infra | INT-001 | `infra/`, `.github/workflows/` | T2 (secrets, backups) | devops | — |
| U-platform-api | INT-001 | `apps/api/src/platform/` (errors, idempotency, rate limits, guards, app-version gate, observability) | T2 | backend | U-infra |
| U-contracts | INT-001 | `packages/contracts`, `tools/dart-api-codegen.mjs`, `dart/hm_api` | T1 | architect | — |
| U-design-system | INT-001 | `dart/hm_design` | T1 | flutter-ui | — |
| U-app-shell | INT-001 | `dart/hm_core`, `dart/hm_data`, `apps/mobile`, `apps/desk` (routing, session, outbox sync engine, Lite/Calm switches) | T1 | flutter-ui | U-contracts, U-design-system |

## Backend module units

| Unit | Week | Intent | Module | Tier | Agent | Depends on (module.json) |
|---|---|---|---|---|---|---|
| U-audit | 1 | INT-001 | `audit` | T2 | backend | — |
| U-users | 1 | INT-001 | `users` | T2 | backend | audit |
| U-auth | 1 | INT-001 | `auth` | T2 | backend | users, audit |
| U-roles | 1 | INT-001 | `roles` | T2 | backend | audit |
| U-syllabus | 1 | INT-001 | `syllabus` | T1 | backend | — |
| U-exams | 1 | INT-001 | `exams` (eligibility engine) | T2 (eligibility correctness) | backend | syllabus |
| U-content | 1 | INT-001 | `content` | T1 | backend | syllabus, ai |
| U-mastery | 2 | INT-002 | `mastery` | T1 (90% coverage) | backend | syllabus, content |
| U-practice | 2 | INT-002 | `practice` | T1 | backend | content, mastery, billing |
| U-exam-hall | 2 | INT-002 | `exam-hall` | T1 (90% coverage) | backend | content, mastery, billing |
| U-plan | 2 | INT-002 | `plan` | T1 | backend | syllabus, mastery, exams |
| U-readiness | 2 | INT-002 | `readiness` | T1 | backend | mastery, practice, exam-hall |
| U-notifications | 2 | INT-002 | `notifications` | T1 | backend | users, liveops |
| U-economy | 3 | INT-003 | `economy` | **T2** | backend | audit, liveops |
| U-games | 3 | INT-003 | `games` + `apps/realtime` match rooms | **T2** | realtime + game | content, economy, liveops |
| U-squads | 3 | INT-003 | `squads` + `apps/realtime` squad rooms | T1 | realtime | content, economy, moderation |
| U-billing | 3 | INT-003 | `billing` | **T2** | backend | economy, audit |
| U-ai | 3 | INT-003 | `ai` + `packages/ai-gateway` | T2 (data to third party) | ai-gateway | — |
| U-liveops | 4 | INT-004 | `liveops` | T2 (emergency switch) | backend | audit |
| U-support | 4 | INT-004 | `support` | T1 | backend | users, billing, audit |
| U-moderation | 4 | INT-004 | `moderation` | T2 (self-harm protocol) | backend | users, ai, audit |
| U-institutions | 4 | INT-004 | `institutions` | T2 (student data) | backend | users, exam-hall, readiness, audit |
| U-marketplace | 4 | INT-004 | `marketplace` | **T2** | backend | content, billing, audit |
| U-analytics | 4 | INT-004 | `analytics` | T1 | backend | — |

> Week ordering note: `practice`/`exam-hall` depend on `billing` for the free/Pro limits, but billing is built in
> week 3. In week 2 they use the `billing` **public API stub** that returns "free" for everyone; the real
> entitlement check lands with U-billing. This keeps the dependency direction while respecting the schedule.
> Likewise `liveops` flags are read through a stub until week 4.

## App units (Flutter)

| Unit | Week | Intent | Feature folder(s) | Tier | Agent | Depends on |
|---|---|---|---|---|---|---|
| U-app-onboarding | 1 | INT-001 | `onboarding`, `eligibility` | T2 (DOB gate, consent) | flutter-ui | U-app-shell, U-auth, U-exams |
| U-app-study | 1–2 | INT-001/002 | `study_map`, `lessons`, `practice`, `pyq_vault`, `library`, `current_affairs` | T1 | flutter-ui | U-app-shell, U-mastery, U-practice |
| U-app-today | 2 | INT-002 | `today`, `plan`, `alerts` | T1 | flutter-ui | U-plan, U-notifications |
| U-app-exam-hall | 2 | INT-002 | `exam_hall`, `readiness` | T1 | flutter-ui | U-exam-hall, U-readiness |
| U-app-games | 3 | INT-003 | `play` + `dart/hm_games` | **T2** | game | U-games, U-economy |
| U-app-squad | 3 | INT-003 | `squad` | T1 | flutter-ui | U-squads |
| U-app-store | 3 | INT-003 | `store` | **T2** (paywalls, Dark Patterns) | flutter-ui | U-billing, U-economy |
| U-app-profile | 1–4 | INT-001/004 | `profile`, `wellbeing`, `support`, `staff_quick_actions` | T2 (deletion, emergency switch) | flutter-ui | U-users, U-support, U-liveops |
| U-desk | 4 | INT-004 | `dart/hm_desk/*` + `apps/desk` | **T2** (admin powers) | flutter-ui | U-roles (TOTP), all desk APIs |

## Other units

| Unit | Intent | Where | Tier | Agent |
|---|---|---|---|---|
| U-marketing | INT-005 | `apps/marketing` | T2 (public claims, legal pages) | flutter-ui (web) + compliance |
| U-content-pipeline | track B | `content/` | T2 (exam correctness) | content-writer + content-verifier |
| U-load-test | INT-004 | `infra/k6/` | T1 | qa |
