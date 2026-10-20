# ADR-0002: One port series starting at 4567

| | |
|---|---|
| Status | accepted |
| Date | 2026-10-20 |
| Deciders | founder, architect agent |
| Blueprint | §21 |

## Context
Everything runs on one VPS. The founder asked for all applications to use a series of ports starting at 4567.

## Decision
- Single source: `packages/config/ports.json`. `pnpm ports:gen` generates `infra/compose/ports.env`,
  `packages/config/src/ports.generated.ts` (`PORTS.API` …) and `docs/architecture/ports.md`. CI runs `ports:check`.
- Blocks: **apps 4567–4579**, **data 4580–4589**, **ops 4590–4599**. Staging = production + **100**.
- Assigned: api 4567 · realtime 4568 · desk 4569 · marketing 4570 · worker 4571 · scheduler 4572 · postgres 4580 ·
  pgbouncer 4581 · valkey 4582 · S3 4583 · mailpit 4584/4585 (local) · grafana 4590 · prometheus 4591 · loki 4592 ·
  glitchtip 4593 · metabase 4594 · uptime-kuma 4595 · changedetection 4596.
- Only Caddy is public (80/443). App containers listen on their series port inside Docker; data/ops ports bind to 127.0.0.1.

## Consequences
The same port means the same service on a laptop, on staging (+100) and in production. The marketing site keeps
4570, which it already used. Replicated services (api ×3, realtime ×2) are not host-published; Caddy reaches them by name.
