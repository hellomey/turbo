# BOLT-0007: Security fixes from the BOLT-0006 security review (SEC-H1..SEC-L9)

| | |
|---|---|
| Unit | U-auth, U-platform, infra |
| Stories | BOLT-0006 security review findings |
| Risk tier | T2 |
| Agent | backend (app side), devops (infra side), conductor |
| Branch / PR | `bolt/BOLT-0007-security-fixes` · # |
| Status | building |

## Plan
- Fix the findings in `aidlc/construction/bolts/BOLT-0006-reviews.md` (## Security review). Each agent appends its
  own section below; never overwrite another agent's section.

## Result (filled when the PR is ready)

## BOLT-0007 infra

Agent: devops, 2026-10-20. Files: `infra/caddy/Caddyfile`, `infra/compose/compose.yml`, `compose.staging.yml`,
`compose.dev.yml` (comment), `compose.edge.yml` (comment), `infra/secrets/.env.example`, `infra/secrets/README.md`,
`infra/docker/server.Dockerfile`, `infra/scripts/provision.sh`, `infra/k6/quick.js`, `infra/AGENTS.md`, `.dockerignore`,
`.github/workflows/{ci,deploy,mobile-release}.yml`.

| Finding | Change | Evidence |
|---|---|---|
| SEC-H1 | Caddy `servers { trusted_proxies static <CF v4 + v6>; client_ip_headers CF-Connecting-IP }`; every `reverse_proxy` (15) `header_up X-Forwarded-For {client_ip}`; `TRUST_PROXY_HOPS: "1"` in the shared `x-app-env` (api, realtime, worker, scheduler). rt sticky policy `ip_hash` -> `client_ip_hash` (CF edge IP is not stable per client). Opt-in Cloudflare-only origin firewall in `provision.sh` (`CF_ONLY_ORIGIN=1`, DOCKER-USER chain, SSH untouched). | Caddy harness (pinned image): CF peer + spoofed `XFF: 9.9.9.9` + `CF-Connecting-IP: 5.6.7.8` -> upstream sees `xff=5.6.7.8`; non-CF peer sending `CF-Connecting-IP`/XFF -> upstream sees the socket IP. Generated firewall script ran twice in a NET_ADMIN container: idempotent, 2 DOCKER-USER jumps + RETURN per CF range + DROP. |
| SEC-L1 | `ops_only` uses `client_ip`; `@deskAdmin` = `/v1/desk/admin /v1/desk/admin/* /v1/desk/ops /v1/desk/ops/*`; `staging-api` + `staging-rt` behind `staging_only` = allowlist OR header `X-HeyMey-Staging-Key` == `STAGING_ACCESS_KEY` (edge secret, >= 32 chars, fail-closed). Needed so the deploy smoke + k6 (GitHub runners, dynamic IPs) still reach staging; `deploy.yml` and `infra/k6/quick.js` send the header from secret `STAGING_ACCESS_KEY`. `staging` / `staging-desk` stay pure `ops_only`. | Harness: bare `/v1/desk/admin` and `/v1/desk/ops/x` from non-allowlisted -> 404, from allowlisted -> 200; staging: key unset + empty header -> 404, right key -> 200, wrong/no key -> 404, short (<32) matching key -> 404. |
| SEC-M2 (infra) | Valkey `--requirepass "$VALKEY_PASSWORD"` (from container env, `${VALKEY_PASSWORD:?}` fails compose if missing), `appendonly yes` kept, authenticated healthcheck added; apps `VALKEY_URL: redis://:${VALKEY_PASSWORD}@valkey:6379`; `VALKEY_MAXMEMORY` env (prod 3gb, staging 384mb: the old fixed 3gb exceeded staging's 512M limit). Dev stack stays password-less (127.0.0.1, throwaway data, documented in compose.dev.yml). `VALKEY_PASSWORD` in `.env.example`. | Pinned Valkey image with the same command: unauthenticated `ping` -> `NOAUTH`; healthcheck passes; `appendonly yes`, `maxmemory 402653184`. `config -q` without `VALKEY_PASSWORD` -> "required variable VALKEY_PASSWORD is missing". **Depends on SEC-L2 (app side): `bullJobQueue` must keep the password.** |
| SEC-L3 | `.dockerignore`: `**/.env*` (+ `!**/.env.example`), `**/*.pem`, `**/*.age`, `**/*.key`, `**/.age`. Migrator stage `USER node`; `COREPACK_HOME=/corepack` so the build-time pnpm stays usable offline by `node`. | Reduced migrator image (same base/ENV/USER): `id` = node (1000), `pnpm --version` with `--network none` = 12.14.0, no `.env` in `/repo`, `prisma migrate status` as node against the dev DB -> "Database schema is up to date". Full `server.Dockerfile` build currently fails in `@heymey/domain` TS build from the in-progress app-side BOLT-0007 edits (not infra). |
| SEC-L4 | Top-level `permissions: contents: read` in ci.yml and mobile-release.yml (deploy.yml already had it); ci `security` job adds `pull-requests: read` for gitleaks. All 45 `uses:` pinned to full commit SHAs with the tag as a comment (annotated tags dereferenced: pnpm/action-setup, gitleaks, run-k6, osv-scanner). `fingerprint: ${{ secrets.VPS_HOST_FINGERPRINT }}` on both `appleboy/ssh-action` steps. Fixed latent bug: `google/osv-scanner-action/...@v2` tag does not exist -> pinned `v2.7.0`. | YAML parse of all 3 workflows OK; script check: 0 unpinned `uses`, 0 ssh-action steps without fingerprint. |
| SEC-L9 | Deleted empty stray dirs `infra/docker/desk.Caddyfile;C` AND `infra/caddy/Caddyfile;C` (both 0 entries). | `find . -name '*;C*'` -> none. |

Verification: `config -q` OK for compose.dev, compose.yml (production), compose.yml+staging, edge, monitoring (dummy
secret files created and removed, edge network created/removed); `caddy validate` OK for both Caddyfiles with the
pinned `CADDY_IMAGE`; `caddy fmt --diff` clean; `pnpm ports:check` and `pnpm docs:check` up to date; `pnpm infra:up`
-> 4/4 dev containers healthy.

Founder / ops actions before the next deploy (aidlc/README §6 - secrets and access):
1. Add `VALKEY_PASSWORD` (hex, `openssl rand -hex 32`) to `production.enc.env` and `staging.enc.env`; add
   `STAGING_ACCESS_KEY` to `production.enc.env` (Caddy reads it). Deploy fails fast without `VALKEY_PASSWORD`.
2. GitHub secrets: `VPS_HOST_FINGERPRINT` (`ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`, SHA256 form) in
   `staging` + `production` environments; `STAGING_ACCESS_KEY` (same value) in `staging`.
3. **Open question:** staging-api/rt are now allowlist-only. Mobile testers on staging builds must be on the VPN /
   allowlist (or we decide another access path). Confirm this is acceptable.
4. Enable `CF_ONLY_ORIGIN=1` once all public records are proxied (orange cloud).

Notes for review: the `heymey-edge` network also carries marketing/desk/seaweedfs/changedetection; a compromised
container there could reach api directly with its own XFF (one hop is trusted). Low; a follow-up could move api/rt
to a Caddy-only network. The staging key comparison is not constant-time (CEL `==`); acceptable for a staging gate.
