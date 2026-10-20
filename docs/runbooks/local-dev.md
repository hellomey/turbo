# Local development

A fresh clone, in this order (each step is safe to re-run):

```bash
corepack enable
pnpm install          # Node 24, pnpm 12
flutter pub get       # Dart pub workspace (root pubspec.yaml)
pnpm env:dev          # writes the git-ignored repo-root .env (local URLs + fresh dev keys); --force regenerates
pnpm infra:up         # Postgres :4580, Valkey :4582, S3 :4583, Mailpit SMTP :4584 / inbox http://localhost:4585 (waits until healthy)
pnpm db:migrate       # prisma migrate deploy against DATABASE_URL from .env
pnpm db:seed          # idempotent local seed data (never real personal data)
pnpm dev              # api :4567, realtime :4568, desk :4569, marketing :4570, worker :4571, scheduler :4572
```

Other useful commands:

| Command               | What                                                                                 |
| --------------------- | ------------------------------------------------------------------------------------ |
| `pnpm infra:ps`       | status of the local data services                                                    |
| `pnpm infra:down`     | stop them. **Keeps data.** Never add `-v` unless you mean to wipe the local database |
| `pnpm db:migrate:dev` | create a new migration (architect-owned schema changes only)                         |
| `pnpm codegen`        | Prisma client, OpenAPI, Dart client                                                  |
| `pnpm verify`         | what CI checks for TypeScript                                                        |

Image versions for the local stack come from `infra/compose/images.env` (pinned by tag + digest, D-2026-10-20-07),
the ports from `infra/compose/ports.env` (generated from `packages/config/ports.json`).

## Port collision with the old `heymey-app` containers (D-2026-10-20-16, OPEN)

On the founder's machine the previous product's Docker project `heymey-app` publishes host ports that the new series
assigns to apps:

| Host port             | Old container           | New owner                 |
| --------------------- | ----------------------- | ------------------------- |
| 127.0.0.1:4568        | `heymey-app-postgres-1` | realtime                  |
| 127.0.0.1:4569        | `heymey-app-redis-1`    | desk                      |
| 127.0.0.1:4571 / 4572 | `heymey-app-mailpit-1`  | worker / scheduler health |

The data services of the new stack (4580-4585) do not collide. Check before `pnpm dev`:

```bash
docker ps --format "table {{.Names}}\t{{.Ports}}" --filter name=heymey-app
# Windows (PowerShell): which process holds a port
Get-NetTCPConnection -LocalPort 4568,4569,4571,4572 -State Listen | Select-Object LocalPort,OwningProcess
# macOS / Linux
lsof -nP -iTCP:4568 -iTCP:4569 -iTCP:4571 -iTCP:4572 -sTCP:LISTEN
```

If the old containers hold those ports, realtime, desk, worker and scheduler cannot listen locally at the same time.
The founder decides (D-2026-10-20-16) whether to stop the old project while working on the new stack
(`docker compose -p heymey-app stop`, they come back on Docker restart because of their restart policy) or to
live without those four services locally. Agents never stop those containers themselves. Production is unaffected:
the new app containers publish no host ports.

## Troubleshooting

- `pnpm db:migrate` says it cannot reach `localhost:4580`: run `pnpm infra:up`, then `pnpm infra:ps`.
- `Invalid environment` when an app starts: run `pnpm env:dev` (once per clone).
- Prisma reads `DATABASE_URL` from the environment first, then from the repo-root `.env` (`packages/db/prisma.config.ts`).
