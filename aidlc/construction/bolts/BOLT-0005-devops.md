# BOLT-0005: Phase 1 devops: pinned images, buildable server/marketing images, CI, domain switch, local DX

| | |
|---|---|
| Unit | U-infra (INT-001, Phase 1) |
| Stories | INT-001 platform/infra stories (blueprint §21, §42, §43 week 1) |
| Risk tier | T1 (infra; `security` review on every `infra/` change) |
| Agent | devops |
| Branch / PR | `bolt/BOLT-0005-devops` · not opened (agents do not commit in this session) |
| Status | in review (built and verified locally, uncommitted) |

## Plan
- Pin every third-party image by version tag + multi-arch digest (D-2026-10-20-07); dev/edge compose and the
  Dockerfiles use the same pins.
- `infra/docker/server.Dockerfile` (runtime + migrator) and `marketing.Dockerfile` build with pnpm 12; root `.dockerignore`.
- CI for Phase 1: Testcontainers integration job, codegen before typecheck, image builds, pin guard, graphify build.
- Marketing domain switch `heymey.in` → `heymey.app` (D-2026-10-20-02 resolved). CTAs untouched (D-2026-10-20-03 OPEN).
- Fresh-clone order `pnpm install → flutter pub get → pnpm env:dev → pnpm infra:up → pnpm db:migrate → pnpm db:seed → pnpm dev`.
- Files: `infra/**`, `.github/workflows/ci.yml`, `.dockerignore`, root `package.json` scripts, `README.md` quick start,
  `docs/runbooks/{README,local-dev,vps-rebuild}.md`, `packages/db/prisma.config.ts` (root `.env` loading only),
  `apps/marketing/src/app/layout.tsx`, `apps/marketing/src/content/legal.ts`.

## Result
### What changed
- **`infra/compose/images.env`**: all 17 third-party images + `NODE_IMAGE` pinned `image:tag@sha256:<index digest>`
  (each index verified to contain linux/amd64 with `docker buildx imagetools inspect`; all 18 pulled OK).
  `compose.dev.yml` and `compose.edge.yml` now use `${*_IMAGE}`; Dockerfile `FROM` lines carry the same pins
  (node 24.22.0-bookworm-slim, caddy 2.11.7-alpine, postgres 17.11-bookworm).
- **Dev stack**: valkey + seaweedfs got health checks; `pnpm infra:up` passes `--env-file images.env` and `--wait`;
  new `pnpm infra:ps`. Recreated on the pinned images: postgres/valkey/seaweedfs/mailpit all `healthy`;
  `heymey-dev_pg-data` volume kept (same CreatedAt, `prisma migrate status` still "up to date").
- **Server image**: pnpm 12 non-legacy `deploy` works without `--legacy` / `inject-workspace-packages`
  (no `pnpm-workspace.yaml` change). Added `openssl` to the build/migrator base for the Prisma schema engine.
  `docker run --rm heymey/server:local` → `Error: Invalid environment: DATABASE_URL … (local development: run pnpm env:dev once)`.
  realtime, worker and scheduler entrypoints also start from the image. Migrator against the dev DB:
  "No pending migrations to apply." Neither image contains `.env`, `.git` or `graphify-out`.
- **Root `.dockerignore`**: excludes `.env*`, `infra/secrets`, `.git`, `graphify-out`, `.claude`, `aidlc`, host
  `node_modules`/build output and Flutter sources (keeps workspace `package.json`s and `apps/desk/build/web`).
- **Marketing image**: builds; container on 127.0.0.1:4570 → `GET /` 200, `/legal/privacy` shows `privacy@heymey.app`;
  container stopped and removed.
- **CI (`ci.yml`)**: new `integration` job (Docker check, codegen, `pnpm turbo run test:integration`); `server` job's
  codegen (Prisma client + OpenAPI) is an explicit named step before lint/typecheck/test; `infra` job checks that images are
  pinned (images.env, literal `image:` lines, Dockerfile `FROM`) and validates Caddyfiles with the pinned caddy;
  new `images` job builds server runtime/migrator/marketing and asserts the "Invalid environment" start; new `graph`
  job `pip install graphifyy==0.9.92 && graphify update .` (not committed). `docs:check` was already in `guards`;
  flutter drift already uses `node tools/dart-api-codegen.mjs`; `turbo.json` already had `test:integration`
  (`cache:false`, `^build` + `codegen`), unchanged.
- **Root scripts**: `env:dev`, `db:migrate`, `db:migrate:dev`, `db:seed`, `infra:ps`. `packages/db/prisma.config.ts`
  loads the repo-root `.env` when `DATABASE_URL` is not already set.
- **Docs**: README quick start in the fresh-clone order; `docs/runbooks/local-dev.md` (sequence, D-2026-10-20-16
  port collision with check commands); `vps-rebuild.md` edge command passes `images.env`.

### Evidence (all run locally 2026-10-20)
- `docker compose … config -q`: dev, production, staging, edge, monitoring all OK (dummy secrets created then deleted).
- `docker build … --target runtime` / `--target migrator` / `marketing.Dockerfile`: exit 0.
- `@action-validator/cli` on ci.yml, deploy.yml, mobile-release.yml: exit 0; YAML parse OK.
- CI pin-guard shell run locally: no findings; `caddy validate` (pinned image): both Caddyfiles valid.
- `pnpm --filter @heymey/marketing lint typecheck build`: pass.
- `pnpm env:dev` / `db:migrate` / `db:seed`: OK (seed: catalog + identity, 0 new users).
- `pnpm ports:check && docs:check && firewall:check && boundaries`: all pass (274 modules, no violations).
- Not run: `pnpm dev` (long-running; realtime/desk/worker/scheduler ports held by old `heymey-app` containers,
  D-2026-10-20-16). The CI jobs themselves have not run on GitHub (nothing pushed).

### Follow-ups / open
- **Hero pixel test fails, before and after this bolt**: `capture-hero` + `diff-hero` against `next start` on :4570
  gives 0.98% / 0.61% / 48.1% (390x844) / 0.76% — identical pixel counts with the domain edits reverted, so not caused
  by this bolt (likely local rendering vs. the 2026-10-18 baseline). Hero files untouched. Owner `flutter-ui` to investigate.
  Also `pnpm test:hero` on Windows does not expand `${BASE_URL:-…}` (cmd shell); run the two node commands directly.
- `APP_URL` default (`https://app.heymey.in`), "Sign in"/"Get started" and the lead form target left as is:
  D-2026-10-20-03 still OPEN. `apps/marketing/README.md` still describes `heymey.in` (owner `flutter-ui`).
- `ghcr.io/heymey/postgres-pgbackrest:17` in `compose.yml` is our own image (built from the pinned postgres.Dockerfile);
  deploy.yml should build and tag it by sha.
- Server image is 852 MB on disk (186 MB content); the deployed app folders still carry `src/`, `test/` — trim later.
- Conductor: record D-2026-10-20-07 as resolved in `aidlc/decisions.md`.
