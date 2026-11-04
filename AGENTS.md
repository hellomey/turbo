# AGENTS.md: HeyMey monorepo

Instructions for every AI agent working in this repository. Read this file fully before your first change.
A closer `AGENTS.md` in a sub-folder adds rules for that folder; when they conflict, the closer one wins,
**except for the Non-negotiables below, which no file can override.**

## 1. Read order

1. **This file.**
2. [`aidlc/README.md`](aidlc/README.md): the development lifecycle (phases, gates, bolts, risk tiers, stop-and-ask).
3. [`aidlc/state.md`](aidlc/state.md): what is in progress right now and what is waiting on whom.
4. The **blueprint sections** your task cites: [`docs/HEYMEY_PRODUCT_BLUEPRINT.md`](docs/HEYMEY_PRODUCT_BLUEPRINT.md). It is the spec. Part J (§34–§46) is the engineering spec.
5. For backend work: the module's `MODULE.md` + `module.json` in `packages/domain/src/modules/<module>/`.
6. The nested `AGENTS.md` of every folder you will touch.

**Navigate code through the knowledge graph (Graphify), not raw search.** The repo has a graph in `graphify-out/`
(rebuilt by git hooks on commit/checkout). Before your first grep or source read, run `graphify query "<question>"`;
use `graphify explain "<symbol>"` and `graphify path "<A>" "<B>"` for focused context. After changing code run
`graphify update .` (AST-only, free). The Claude Code skill is `.claude/skills/graphify`; other tools use `.agents/skills/graphify`.

**Product phases:** Phase N = Week N of blueprint §43 (Phase 1 = INT-001 Foundation).

## 2. What this repo is

HeyMey: a gamified government-exam preparation app for Tamil Nadu aspirants. One Flutter codebase (mobile app for
everyone + HeyMey Desk web for partners/staff), a TypeScript backend, a Next.js marketing site. **At launch (ADR-0014) it runs on free/starter tiers:** Postgres on Supabase, files and packs on Cloudflare R2, marketing on Vercel, Desk on Firebase Hosting, and api/realtime/worker/scheduler/Valkey on **one small VM in Docker Compose**. Paid plans or a dedicated VPS come only once revenue comes in.

```
apps/
  api/          NestJS HTTP API (Fastify)               :4567  api.heymey.app
  realtime/     Socket.IO gateway, game rooms            :4568  rt.heymey.app
  desk/         Flutter web: HeyMey Desk (staff/partner) :4569  desk.heymey.app (Firebase Hosting in prod)
  marketing/    Next.js marketing + legal pages          :4570  heymey.app (Vercel in prod)
  worker/       BullMQ workers :4571 + scheduler :4572   (internal)
  mobile/       Flutter app, Android + iOS               (stores)
packages/       TypeScript libraries (@heymey/*)
  config/       ports.json (THE port list), env schemas
  contracts/    Zod schemas -> OpenAPI 3.1 -> Dart client. The one contract.
  domain/       24 business modules (framework-free) + the money/game firewall
  db/           Prisma schema (one file per owning module), migrations, seed
  ai-gateway/   the only way to call an AI model (OpenRouter)
  testing/      fake clock, factories (tests only)
  eslint-config/
dart/           Flutter packages: hm_design, hm_api (generated), hm_core, hm_data, hm_games, hm_features, hm_desk
content/        syllabus YAML + content pipeline
infra/          compose stacks, Caddyfile, Dockerfiles, backups, monitoring, VPS scripts, encrypted secrets
docs/           blueprint, architecture, ADRs, runbooks
aidlc/          the lifecycle: intents, units, bolts, decisions, templates, status board
tools/          repo scripts (ports, module generator, firewall guard, codegen)
.claude/        agent definitions (agents/) and lifecycle skills (skills/)
```

## 3. Non-negotiables

These come from the blueprint and are enforced by CI where possible. Breaking one is never "a small fix".

1. **Server is the source of truth** (§34.1). Scores, rewards, unlocks, timers, ranks, purchases are decided on the server. The app displays.
2. **Money/game firewall** (§5.3, §18, §30). No conversion between Sparks and anything else; nothing bought with money enters or plays a game; no game rewards anything worth money; Pro/Season Pass give no game advantage.
   Code: `packages/domain/src/modules/economy/domain/firewall.ts`. Tests `FW-001…` in `packages/domain/test/firewall/` may be **added to, never deleted, skipped or weakened** (`pnpm firewall:check`).
3. **Every write is idempotent** (§34.3): `Idempotency-Key` on every state-changing request; ledgers keyed by unique idempotency keys.
4. **One contract** (§34.4): routes and socket events are defined in `@heymey/contracts` first; OpenAPI and `dart/hm_api` are generated. Never hand-write API models twice; never edit `hm_api`.
5. **Module ownership** (§34.8): a module owns its tables and is imported only via its `index.ts`, and only by modules listed in its `module.json` (`pnpm boundaries`). New dependency = ADR.
6. **Server time, IST days** (§37): never `Date.now()` in domain code (inject `Clock`); day logic uses Asia/Kolkata; randomness for games uses the server CSPRNG.
7. **Ports come from `packages/config/ports.json`** only. Never hard-code a new port. `pnpm ports:gen` after editing.
8. **No secrets in code, apps, prompts or docs.** Secrets live in `infra/secrets/*.enc.env` (SOPS). The OpenRouter key never leaves the server. No personal data is ever sent to an AI model.
9. **Simple English, no dark patterns** (§10.2, §13). Every paywall has "Not now"; no fake urgency; prices include GST. Tamil appears only inside Tamil Language paper content.
10. **The founder approves** merges to `main`, prices, legal text, store submissions, odds changes, and any code touching money or personal data (§26.2 rule 4).

## 4. How work flows (AIDLC, short version)

```
Intent (INT-xxx) -> stories -> units -> [G-I founder] -> domain model + logical design -> [G-D]
  -> bolts: contract -> failing tests -> code -> pnpm verify -> reviews -> [G-C] -> release -> observe -> [G-O]
```

- Start every session by reading `aidlc/state.md`. Pick up only work that is on the board.
- One bolt = one branch `bolt/BOLT-xxxx-<slug>` = one PR. Create the bolt file from `aidlc/templates/bolt.md` **before** coding.
- Stay inside your unit's modules/features. Need something from another module? Use its public API, or raise it.
- Update `aidlc/state.md` and the bolt file when you start, when you open the PR, and when you finish.
- Risk tier T2 (money, personal data, game fairness, security, legal text) needs `security` + `compliance` review and founder approval at design and merge.
- **Stop and ask** (write the question into the artefact, then ask) in every case listed in `aidlc/README.md` §6.

## 5. Agent roster

Definitions with full instructions: [`.claude/agents/`](.claude/agents). Other tools: read the same files as role prompts.

| Agent | Owns (may change) | Reviews | Never touches |
|---|---|---|---|
| `conductor` | `aidlc/**` | gate readiness | product code |
| `spec` | `aidlc/inception/**` | stories vs blueprint | code |
| `architect` | `packages/contracts`, `packages/db/prisma`, `module.json`, `docs/adr`, `docs/architecture` | every design (G-D) | feature implementation |
| `backend` | `packages/domain/src/modules/*` (assigned unit), `apps/api`, `apps/worker` | — | `dart/`, `infra/` |
| `realtime` | `apps/realtime`, socket contracts, `games`/`squads` room logic | — | billing, economy ledgers |
| `flutter-ui` | `apps/mobile`, `apps/desk`, `dart/hm_design`, `hm_core`, `hm_data`, `hm_features`, `hm_desk` | accessibility | `hm_api` (generated) |
| `game` | `dart/hm_games`, `hm_features/lib/src/play`, Rive/Flame assets | game feel | odds values, rewards |
| `ai-gateway` | `packages/ai-gateway`, `ai` module | AI cost/privacy | content publishing |
| `qa` | tests anywhere, `infra/k6` | every PR | production code (only via findings) |
| `security` | — (review only, may add tests) | T2 PRs, `infra/`, auth | — |
| `devops` | `infra/**`, `.github/workflows/**`, `tools/**` | deploy safety | domain logic |
| `content-writer` | `content/**` drafts | — | publishing, code |
| `content-verifier` | verification reports in `content/` | every content item | writing the item it verifies |
| `compliance` | — (review only) | offers, paywalls, game rules, legal text, store copy | — |

## 6. Commands

```bash
pnpm install                 # Node 24, pnpm 12 (corepack)
flutter pub get              # Dart workspace (root pubspec.yaml)
pnpm env:dev                 # once: git-ignored .env with local URLs + generated keys (never read or share it)
pnpm infra:up                # local Postgres :4580, Valkey :4582, S3 :4583, Mailpit :4584 (inbox :4585)
pnpm db:migrate && pnpm db:seed
pnpm codegen                 # Prisma client, OpenAPI (contracts), Dart client (needs Docker)
pnpm dev                     # api, realtime, worker, desk, marketing on their ports
pnpm test:integration        # real Postgres + Valkey via Testcontainers (needs Docker)
graphify query "how does OTP login work"   # navigate code via the knowledge graph
graphify update .            # after code changes
pnpm verify                  # ports + firewall + boundaries + lint + typecheck + tests (run before every PR)
pnpm gen:module <name> --summary "..."   # new backend module (then an ADR)
pnpm --filter @heymey/domain test:firewall
flutter analyze && node tools/flutter-test-all.mjs
```

## 7. Definition of done (every PR, blueprint §45)

- [ ] Matches the blueprint (or the founder approved a change, logged in `aidlc/decisions.md`)
- [ ] API in `@heymey/contracts`; OpenAPI + Dart client regenerated
- [ ] Server-side permission checks + rate limits; idempotent writes
- [ ] Tests at coverage targets (90%: economy, billing, mastery, exam-hall, games, auth; 70% elsewhere) + goldens for UI
- [ ] Offline behaviour per §39 where applicable
- [ ] Dark / light / high-contrast, Calm Mode, Lite Mode, 200% text checked; screen-reader labels on every control
- [ ] Simple-English copy; Dark Patterns checklist for any offer text
- [ ] Logs, metrics, errors visible (Grafana / GlitchTip); feature flag if risky
- [ ] Performance budget met (§24)
- [ ] Bolt file "Result" filled; `aidlc/state.md` updated

## 8. Conventions

- **Commits**: Conventional Commits with the bolt id: `feat(auth): rotate refresh tokens [BOLT-0012]`.
- **Branches**: `bolt/BOLT-xxxx-<slug>`. Never commit to `main` directly.
- **PR description**: traceability line `§38 → INT-001-S02 → U-auth → BOLT-0012`, risk tier, DoD checklist.
- **TypeScript**: ESM, strict, `.js` import suffixes, no `any`, no floats for money (integer paise / integer Sparks).
- **Errors**: throw `DomainError(code)` with a code from `@heymey/contracts` `ERROR_CODES`; add new codes, never rename.
- **Dart**: feature layers `presentation/ → application/ → domain/ → data/`; Riverpod; no business rules in widgets.
- **Docs**: when you make a lasting decision, write an ADR from `aidlc/templates/adr.md`.

## 9. Nested AGENTS.md

`apps/api` · `apps/realtime` · `apps/worker` · `apps/mobile` · `apps/desk` · `apps/marketing` · `packages/domain` ·
`packages/db` · `packages/contracts` · `packages/ai-gateway` · `dart` · `infra` · `content`
