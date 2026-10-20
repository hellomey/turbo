# INT-000: Architecture scaffold

| | |
|---|---|
| Status | **released** (awaiting founder G-O) |
| Blueprint | §20, §21, §26, §34, §35, §36, §37, §42 |
| Risk tier | T2 (sets the money/game firewall and security boundaries) |
| Owner | conductor |

## Why
Before agents build features, the repository must make the right thing easy and the wrong thing fail CI:
one monorepo, one port series on one VPS, module ownership, one contract, a permanent money/game firewall,
and a written development lifecycle (AIDLC) with agent roles.

## What was delivered (BOLT-0000)
- Turborepo + pnpm workspace; Dart pub workspace for Flutter; existing Next.js marketing site moved to `apps/marketing`.
- Port series 4567+ from one source (`packages/config/ports.json` → generated env, TS, docs; CI drift check).
- 24 domain modules scaffolded with `module.json` boundaries enforced by dependency-cruiser.
- Money/game firewall implemented in `economy` with 9 permanent tests (FW-001…FW-009) and a CI guard.
- Contracts package (Zod → OpenAPI 3.1) with the first routes; socket event types.
- Prisma 7 multi-file schema with the critical tables (auth, users, roles, audit, ledgers, entitlements, odds, flags, mastery).
- api / realtime / worker / scheduler skeletons that boot on 4567 / 4568 / 4571 / 4572.
- Flutter mobile (5-tab shell) + Desk (web) apps, `hm_*` packages, design tokens from §10.3.
- Compose stacks (dev, app, staging, edge, monitoring), Caddyfile, Dockerfiles, VPS scripts, backups config.
- AIDLC, AGENTS.md (root + nested), agent definitions, skills, ADRs, runbooks, CI workflows.

## Outcome
To be accepted by the founder (G-O). Open questions are in `aidlc/decisions.md`.
