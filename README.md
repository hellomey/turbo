# HeyMey

Gamified government-exam preparation for Tamil Nadu aspirants. One monorepo for the backend, the Flutter mobile
app and HeyMey Desk, the marketing site, infrastructure, content, and the AI-driven development process.

- **What we build:** [`docs/HEYMEY_PRODUCT_BLUEPRINT.md`](docs/HEYMEY_PRODUCT_BLUEPRINT.md) (the spec)
- **How we build it:** [`aidlc/README.md`](aidlc/README.md) (lifecycle) · [`AGENTS.md`](AGENTS.md) (rules for agents) · [`aidlc/state.md`](aidlc/state.md) (status board)
- **How it fits together:** [`docs/architecture/overview.md`](docs/architecture/overview.md) · [ports](docs/architecture/ports.md) · [modules](docs/architecture/modules.md) · [ADRs](docs/adr/README.md)

## Services and ports (one VPS)

| Port | Service | Public host |
|---|---|---|
| 4567 | `apps/api`: NestJS HTTP API | api.heymey.app |
| 4568 | `apps/realtime`: Socket.IO + game rooms | rt.heymey.app |
| 4569 | `apps/desk`: HeyMey Desk (Flutter web) | desk.heymey.app |
| 4570 | `apps/marketing`: Next.js site + policies | heymey.app |
| 4571 / 4572 | `apps/worker`: workers / scheduler | internal |
| 4580–4589 | Postgres, pgbouncer, Valkey, S3, Mailpit (local) | never public |
| 4590–4599 | Grafana, Prometheus, Loki, GlitchTip, Metabase, Uptime Kuma, changedetection | ops.heymey.app (VPN) |

Staging uses the same services at **port + 100**. Only Caddy listens on 80/443. Full map: [ports.md](docs/architecture/ports.md).

## Quick start

Requirements: Node 24, corepack (pnpm 12), Flutter stable, Docker. Run these in order on a fresh clone:

```bash
corepack enable
pnpm install          # Node packages
flutter pub get       # Dart pub workspace
pnpm env:dev          # writes the git-ignored local .env (local URLs + fresh dev keys)
pnpm infra:up         # Postgres :4580, Valkey :4582, S3 :4583, Mailpit inbox http://localhost:4585 (waits until healthy)
pnpm db:migrate       # apply Prisma migrations to the local database
pnpm db:seed          # local seed data
pnpm dev              # api :4567, realtime :4568, desk :4569, marketing :4570, worker :4571, scheduler :4572
pnpm verify           # everything CI checks for TypeScript
```

Details, `infra:down` / `infra:ps`, and the known local port collision with the old `heymey-app` containers:
[docs/runbooks/local-dev.md](docs/runbooks/local-dev.md).

## Layout

```
apps/        api · realtime · worker · desk · mobile · marketing
packages/    config · contracts · domain · db · ai-gateway · testing · eslint-config
dart/        hm_design · hm_api (generated) · hm_core · hm_data · hm_games · hm_features · hm_desk
content/     syllabus maps + content pipeline
infra/       compose · caddy · docker · backup · monitoring · scripts · secrets (SOPS)
docs/        blueprint · architecture · adr · runbooks
aidlc/       intents · units · bolts · decisions · templates · state board
.claude/     agent definitions + lifecycle skills
```
