# BOLT-0015: changedetection.io -> api webhook wiring, and the content-pack CDN

| | |
|---|---|
| Unit | U-infra (infra parts of U-exams Exam Alerts webhook, U-app-shell packs) |
| Stories | INT-002 (Exam Alerts S17 webhook; offline packs) |
| Risk tier | T1 (security review: webhook secret, public bucket routing) |
| Agent | devops |
| Branch / PR | `bolt/BOLT-0015-changedetection-pack-cdn` · not opened (no commits, per conductor) |
| Status | in review |

## Plan
- changedetection.io (production only) POSTs `SiteChangeWebhookBody` to `http://api:4567/v1/webhooks/changedetection`
  on the internal network with header `x-heymey-webhook-secret` (§17.5, §20.2; U-exams logical design).
- Seed watch list of official TN exam sites as config (URLs only, nothing scraped).
- Pack hosting: SeaweedFS bucket/path layout, immutable checksum-named files, Caddy cache headers, Cloudflare-friendly (§39, §21).

## Result
- `infra/compose/compose.yml` changedetection: health check, 0.5 CPU / 512M limit, log rotation, `BASE_URL`,
  loopback-only port `127.0.0.1:4596` (for the sync tool). Staging keeps `profiles: ["never"]`.
- `infra/changedetection/watches.json`: 6 official URLs (TNPSC home + notifications, TNUSRB, TRB, MRB, MHC recruitment), 6 h interval.
- `tools/changedetection-sync.mjs`: idempotent create/update of watches via the changedetection API; notification
  `post://api:<API_PORT>/v1/webhooks/changedetection?+x-heymey-webhook-secret=...` with a Jinja JSON body matching
  `SiteChangeWebhookBody` (changeId = UTC timestamp via `{% now %}`). `--dry-run` passes.
- Secrets: `CHANGEDETECTION_WEBHOOK_SECRET`, `CHANGEDETECTION_API_KEY` in `infra/secrets/.env.example` + README.
- `infra/caddy/Caddyfile` `cdn.heymey.app`: was a full proxy of SeaweedFS (bucket listing + every bucket public);
  now only GET/HEAD `^/packs/free/<exam>/<pack>/v<n>.<sha256>.pack$` -> `/heymey-content/...`,
  `Cache-Control: public, max-age=31536000, immutable`, X-Amz-*/Server/Set-Cookie stripped; else 404 / 405.
- `infra/content-cdn/README.md`: bucket layout, immutability rules, Cloudflare cache rule, `s3.json` shape (anonymous Read).
- Evidence: `docker compose config -q` OK for compose.yml (production), compose.yml+compose.staging.yml, dev, edge,
  monitoring (dummy env; temporary empty `../secrets/<stack>.env` created and removed). `caddy validate` with pinned
  `caddy:2.11.7-alpine@sha256:d854...` -> "Valid configuration". `pnpm ports:check` -> "ports: up to date".

### Open points / follow-ups
1. **Env var name not yet in `packages/config/src/env.ts`** at hand-back. This bolt uses `CHANGEDETECTION_WEBHOOK_SECRET`;
   BOLT-0014 must use the same name (or tell devops to rename).
2. Verify on a running changedetection 0.60.9 that the `post://` handler + `{% now %}` template produce valid JSON (needs live smoke on the server).
3. Pro packs are not public (routing only). Presigned-URL delivery for `pro/` packs = backend + contract follow-up.
4. content-verifier should confirm the six watch URLs before go-live.
5. security review: anonymous Read on `heymey-content` relies on SeaweedFS staying unpublished + Caddy allow-list.
