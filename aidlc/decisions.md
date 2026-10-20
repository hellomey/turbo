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
