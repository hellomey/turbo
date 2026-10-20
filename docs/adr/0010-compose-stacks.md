# ADR-0010: Compose stacks: app (prod + staging), edge, monitoring

| | |
|---|---|
| Status | accepted |
| Date | 2026-10-20 |
| Deciders | founder, architect agent |
| Blueprint | §21, §42 |

## Context
One VPS hosts production, staging and the ops tools.

## Decision
- `compose.yml` is the app stack for **both** environments (project `heymey` / `heymey-staging`; `compose.staging.yml` lowers limits
  and shifts host ports +100). Services join the external `heymey-edge` network with aliases `<stack>-<service>`.
- `compose.edge.yml`: one Caddy for everything, the only public listener.
- `compose.monitoring.yml`: Prometheus, Loki, Alloy, Grafana, GlitchTip, Metabase, Uptime Kuma, exporters.
- One server image with four entrypoints (api, realtime, worker, scheduler) plus a `migrator` target with the Prisma CLI.
- `infra/scripts/deploy.sh`: decrypt secrets → (prod) pgBackRest backup → migrate (expand-only) → rolling `up --wait` per service → rollback on failure.

## Consequences
Staging and production cannot drift in shape. Moving a stack to a second VPS (§25) is a host change, not a rewrite.
