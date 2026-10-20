# One image for api, realtime, worker and scheduler (same code, different entrypoint in compose).
# Built from the repo root:  docker build -f infra/docker/server.Dockerfile --target runtime -t ghcr.io/heymey/server:<sha> .
#                            docker build -f infra/docker/server.Dockerfile --target migrator -t ghcr.io/heymey/migrator:<sha> .
# Base image pin = NODE_IMAGE in infra/compose/images.env (D-2026-10-20-07). The root .dockerignore keeps .env,
# secrets, .git, graphify-out and host node_modules out of the build context.
FROM node:24.22.0-bookworm-slim@sha256:a5f4366e834695d5f363b920c104953a535d3a9864d1bdf74566a0ebe01daee5 AS base
# COREPACK_HOME outside /root: the pnpm binary corepack downloads during the build must stay usable by the
# non-root `node` user in the migrator stage (which has no internet on the stack's internal network).
ENV PNPM_HOME=/pnpm PATH=/pnpm:$PATH COREPACK_ENABLE_DOWNLOAD_PROMPT=0 COREPACK_HOME=/corepack
# openssl: the Prisma schema engine (migrate deploy) needs libssl; the slim image has none.
RUN apt-get update \
 && apt-get install -y --no-install-recommends openssl ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && corepack enable
WORKDIR /repo

FROM base AS build
COPY . .
# pnpm 12 `deploy` (non-legacy) writes a self-contained app folder with its own lockfile and copies workspace
# dependencies (@heymey/*) in as files, so no `--legacy` / inject-workspace-packages setting is needed.
RUN pnpm install --frozen-lockfile \
 && pnpm turbo run build --filter=@heymey/api --filter=@heymey/realtime --filter=@heymey/worker \
 && pnpm deploy --filter=@heymey/api --prod /out/api \
 && pnpm deploy --filter=@heymey/realtime --prod /out/realtime \
 && pnpm deploy --filter=@heymey/worker --prod /out/worker

# Runs `prisma migrate deploy` during deploy.sh (DATABASE_URL from the stack's env). Has the Prisma CLI;
# never serves traffic.
# Runs as the non-root `node` user (SEC-L3): the sources stay root-owned and read-only to it.
FROM build AS migrator
ENV NODE_ENV=production
USER node
CMD ["pnpm", "--filter", "@heymey/db", "migrate:deploy"]

FROM node:24.22.0-bookworm-slim@sha256:a5f4366e834695d5f363b920c104953a535d3a9864d1bdf74566a0ebe01daee5 AS runtime
ENV NODE_ENV=production
WORKDIR /srv
COPY --from=build /out/api ./apps/api
COPY --from=build /out/realtime ./apps/realtime
COPY --from=build /out/worker ./apps/worker
COPY --from=build /repo/packages/db/prisma ./packages/db/prisma
USER node
# api 4567 · realtime 4568 · worker 4571 · scheduler 4572 (docs/architecture/ports.md)
EXPOSE 4567 4568 4571 4572
CMD ["node", "apps/api/dist/main.js"]
