# AGENTS.md: infra/ (one VPS, Docker Compose)

Owner: `devops`; reviewer `security` on every change. Root rules apply.

| File | What |
|---|---|
| `compose/compose.dev.yml` | local deps (Postgres :4580, Valkey :4582, S3 :4583, Mailpit :4584/:4585) |
| `compose/compose.yml` | app stack; production AND staging (`-p heymey-staging -f compose.staging.yml`) |
| `compose/compose.edge.yml` | Caddy: the only public listener (80/443) |
| `compose/compose.monitoring.yml` | Prometheus, Loki, Alloy, Grafana, GlitchTip, Metabase, Uptime Kuma (ops.heymey.app only) |
| `compose/ports.env` | GENERATED from `packages/config/ports.json` (`pnpm ports:gen`) |
| `compose/images.env` | third-party image tags in one place (pin to digests) |
| `caddy/Caddyfile` | hosts → `<stack>-<service>:<series port>` |
| `docker/` | server (api/realtime/worker/scheduler + migrator), marketing, desk, postgres+pgBackRest images |
| `scripts/` | provision.sh, deploy.sh (rolling + rollback), restore.sh |
| `secrets/` | SOPS-encrypted env files only |

- Every container: limits, health check, `restart: unless-stopped`, log rotation.
- Every 45xx port binds to 127.0.0.1 or stays on the Docker network. Database never public.
- Client IP (BOLT-0007 SEC-H1, blueprint §38 per-IP limits): Caddy trusts only Cloudflare ranges
  (`trusted_proxies`) and takes the client from `CF-Connecting-IP` (`client_ip_headers`); EVERY `reverse_proxy`
  sets `header_up X-Forwarded-For {client_ip}` (one value, client input overwritten). api/realtime run with
  `TRUST_PROXY_HOPS: "1"` (exactly one trusted hop = Caddy). A new `reverse_proxy` without that `header_up` is a bug.
- Access layer (§15): `ops_only` matches `client_ip` against `OPS_ALLOWLIST` (never `remote_ip`: behind Cloudflare
  that is the CF edge). `staging-api` / `staging-rt` use `staging_only` = allowlist OR the pipeline's
  `X-HeyMey-Staging-Key` (`STAGING_ACCESS_KEY`, fail-closed when unset/short).
- Origin firewall: the VPS should accept 80/443 from Cloudflare ranges only. `provision.sh` has it as an opt-in
  (`CF_ONLY_ORIGIN=1`): rules go into Docker's `DOCKER-USER` chain (ufw alone does not filter Docker-published
  ports); SSH stays open. Enable only after every public DNS record is proxied (orange cloud).
- Valkey: staging/production require `VALKEY_PASSWORD` (`--requirepass`; apps get `redis://:<pw>@valkey:6379`).
  The dev stack is password-less on purpose (127.0.0.1 only, throwaway data).
- Validate before PR: `docker compose --env-file compose/ports.env --env-file compose/images.env -f compose/<file> config -q`.
