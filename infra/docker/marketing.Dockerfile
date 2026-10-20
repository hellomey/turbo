# Marketing site (Next.js standalone). Port 4570.
# Base image pin = NODE_IMAGE in infra/compose/images.env (D-2026-10-20-07).
FROM node:24.22.0-bookworm-slim@sha256:a5f4366e834695d5f363b920c104953a535d3a9864d1bdf74566a0ebe01daee5 AS build
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable
WORKDIR /repo
COPY . .
RUN pnpm install --frozen-lockfile --filter=@heymey/marketing... \
 && pnpm turbo run build --filter=@heymey/marketing

FROM node:24.22.0-bookworm-slim@sha256:a5f4366e834695d5f363b920c104953a535d3a9864d1bdf74566a0ebe01daee5 AS runtime
ENV NODE_ENV=production PORT=4570 HOSTNAME=0.0.0.0
WORKDIR /srv
COPY --from=build /repo/apps/marketing/.next/standalone ./
COPY --from=build /repo/apps/marketing/.next/static ./apps/marketing/.next/static
COPY --from=build /repo/apps/marketing/public ./apps/marketing/public
USER node
EXPOSE 4570
CMD ["node", "apps/marketing/server.js"]
