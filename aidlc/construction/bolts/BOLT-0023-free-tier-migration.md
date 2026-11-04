# BOLT-0023: move deployment to a free/starter-tier setup (Supabase, R2, Firebase Hosting, Cloudflare, one VM)

| | |
|---|---|
| Unit | U-platform (infra) |
| Stories | founder decision: free-tier hosting (ADR-0014, written in parallel by `architect`) |
| Risk tier | T1 (deploy safety, secrets, personal data location: Supabase ap-south-1) → `security` review of infra/CI |
| Agent | devops |
| Branch / PR | `bolt/BOLT-0023-free-tier-migration` · not opened (no commits asked) |
| Status | in review |

## Plan
- Postgres → Supabase: app via transaction pooler (`DATABASE_URL`, :6543), migrations via `DIRECT_URL`.
- Storage → Cloudflare R2 (S3 API), public custom domain `cdn.heymey.app` for `packs/free/` only.
- Marketing → Cloudflare Workers (@opennextjs/cloudflare); Desk → Firebase Hosting.
- One VM (Oracle Always Free ARM / Hetzner): api, realtime, worker, scheduler, valkey, caddy, changedetection.
- Local dev unchanged (Docker Postgres, Valkey, S3, Mailpit).
- Note: tasks touch `packages/db`, `packages/config`, `apps/desk`, `apps/marketing` (outside devops paths) on the
  conductor's explicit instruction; config-only, no domain logic. Owners (architect / flutter-ui) to review.

## Result
- **Prisma**: `prisma.config.ts` uses `DIRECT_URL ?? DATABASE_URL` (Prisma 7: the CLI URL lives in the config, not
  the schema; so the migrator uses DIRECT_URL). `createPrismaClient` strips `pgbouncer`/`connection_limit` hints and
  maps `connection_limit` to the pg pool `max`. `@prisma/adapter-pg` sends unnamed prepared statements unless
  `statementNameGenerator` is set, so the Supabase transaction pooler is safe; no setting needed (comment added).
  Test: `packages/db/test/database-url.spec.ts`.
- **Config**: `databaseEnv.DIRECT_URL` (optional) + `directUrl()` helper; `s3Env` endpoint-agnostic (`S3_REGION=auto`,
  `S3_BUCKET`, `S3_PUBLIC_BASE_URL`, `S3_FORCE_PATH_STYLE`; `S3_BUCKET_CONTENT` kept, deprecated). CORS default already
  covers desk.heymey.app + heymey.app + www. `tools/dev-env.mjs` writes the new keys; `--append` adds missing keys only.
- **Compose**: postgres, pgbouncer, seaweedfs, desk, marketing removed from compose.yml/staging; new `backup` service
  (pg_dump via DIRECT_URL → age → R2, nightly 02:30 IST; `infra/docker/backup.Dockerfile`, `infra/backup/pg-dump-r2.sh`).
  deploy.sh: backup → migrate (DIRECT_URL) → rolling restart → rollback. restore.sh rewritten (production | drill;
  staging never gets real data). pgBackRest conf, postgres/desk/marketing Dockerfiles, desk.Caddyfile deleted.
  Caddyfile: only api, rt, ops (+ staging-api, staging-rt). provision.sh: Oracle iptables + swap.
- **Desk**: `apps/desk/firebase.json` (targets desk / desk-staging, SPA rewrite, cache + security headers, CSP),
  `.firebaserc.example`. **Marketing**: `@opennextjs/cloudflare` + `wrangler` devDeps, `open-next.config.ts`,
  `wrangler.toml`, `cf:build|cf:preview|cf:deploy` scripts; `pnpm dev` unchanged; `workerd` allowed in pnpm-workspace.
- **CI**: deploy.yml multi-arch images (QEMU, amd64+arm64) incl. backup image; desk → Firebase, marketing →
  Cloudflare for staging then production after Promote; all actions SHA-pinned; packages:write only on `images`.
  ci.yml infra job updated (no desk Caddyfile/marketing image; firebase.json + wrangler.toml checks).
- **Docs**: `docs/runbooks/free-tier-setup.md`, `infra/content-cdn/README.md` (R2), `infra/secrets/.env.example`, README.
- Evidence: TS lint/typecheck/test 36/36 green; `docker compose config -q` OK for dev/prod/staging/edge/monitoring;
  `next build` OK. Not run (Docker daemon down locally): `pnpm test:integration`, `caddy validate`, dart codegen;
  `opennextjs-cloudflare build` fails on Windows only (symlink EPERM), runs on the Linux CI runner.
- Follow-ups: (1) GlitchTip + Metabase "own database" lived on the old Postgres: give them a Supabase schema or a
  small local Postgres in compose.monitoring.yml (devops, next bolt). (2) No S3 client exists in code yet; the backend
  bolt that uploads packs must read `s3Env`. (3) Verify arm64 entries of every digest in images.env
  (`docker buildx imagetools inspect`). (4) docs/architecture, docs/runbooks/restore.md, ports.md, event-day.md still
  mention pgbouncer/pgBackRest: architect (ADR-0014 docs). (5) security review of firebase.json CSP and the R2 WAF rule.

### Amendment 2026-11-04: marketing on Vercel (D-2026-11-04-01)
Founder replaced Cloudflare Workers/OpenNext with **Vercel** (GitHub integration) for `apps/marketing`. Nothing else changes.
- Removed: marketing-build job and both marketing deploy steps in `.github/workflows/deploy.yml`; the wrangler.toml
  check in `ci.yml` (now checks `apps/marketing/vercel.json`); `workerd` from `pnpm-workspace.yaml` allowBuilds;
  `.open-next/`, `.wrangler/`, `.dev.vars` from `.gitignore` (now `.vercel/`). `@opennextjs/cloudflare`, `wrangler`,
  `open-next.config.ts`, `wrangler.toml`, `cf:*` scripts were already gone from the working tree; lockfile has no trace.
- Added: `apps/marketing/vercel.json` (pnpm install from repo root, `turbo run build --filter=./apps/marketing`,
  `npx turbo-ignore`, security headers); `turbopack.root` in `next.config.ts` (repo root) so the build resolves `next`
  in the pnpm monorepo. CI now filters marketing by path (`./apps/marketing`), not by name.
- Docs: ADR-0014 amendment, D-2026-11-04-01, AGENTS.md §2, blueprint (7 places marked), overview.md,
  free-tier-setup.md §4/§6/§7/§8, secrets README, Caddyfile/compose comments. Follow-up (4) above is **done**:
  overview.md, restore.md (pg_dump→R2, drill/incident), ports.md (ports.json descriptions; 4581 reserved), event-day.md.
- Evidence: `pnpm turbo run build --filter=./apps/marketing` green (all routes static). `docker compose config -q` OK
  for compose.yml (prod), compose.yml+staging, dev, edge, monitoring with dummy `.env.example` secrets.
  `pnpm verify`: ports/docs/firewall/boundaries OK; turbo 37/39 — fails: `@heymey/dart#codegen` (Docker not running
  locally) and `@heymey/domain` `audit.spec.ts` "public API is write-only" (pre-existing, audit module, not touched here).
- **Founder questions:** (a) Vercel Hobby forbids commercial use → Vercel Pro $20/mo, your choice. (b) `apps/marketing`
  is currently a nested git checkout of `hellomey/hellomay-landing` with uncommitted changes in the monorepo
  (package renamed `hellomay-landing`, npm `package-lock.json`, README to npm, metadataBase `heymey.in`, AGENTS.md
  monorepo rules removed). Vercel will build the monorepo copy; decide which repo is the source of truth before
  connecting Vercel, and remove `apps/marketing/package-lock.json` (pnpm only). Not changed by devops (flutter-ui owns it).
