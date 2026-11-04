# Content-pack hosting (BOLT-0015, moved to Cloudflare R2 in BOLT-0023 / ADR-0014)

Blueprint: §39 (offline packs, SHA-256 checked), §11 (free users: free packs only), §21.
Consumers: `GET /v1/content/packs` (`ContentPack.url`, `sha256`, `tier`) and the app `PackDownloader` (BOLT-0016).

## Buckets (Cloudflare R2, S3 API; env: `S3_ENDPOINT`, `S3_REGION=auto`, `S3_BUCKET`, `S3_PUBLIC_BASE_URL`)

| Bucket | Public? | What |
|---|---|---|
| `heymey-content` (production) | **custom domain `cdn.heymey.app`, `packs/free/` only** (see below) | content packs |
| `heymey-content-staging` | no public access (r2.dev off) | synthetic packs only |
| `heymey-backups` | never | age-encrypted nightly `pg_dump` (infra/backup/pg-dump-r2.sh), lifecycle 35 days |

Local dev keeps SeaweedFS on `:4583` (compose.dev.yml) with the same layout; only `S3_ENDPOINT` changes.

## Path layout

```
heymey-content/
  packs/
    free/<examCode>/<packCode>/v<version>.<sha256>.pack   # public: https://cdn.heymey.app/packs/free/...
    pro/<examCode>/<packCode>/v<version>.<sha256>.pack    # NEVER public (blocked by the WAF rule below)
```

- `examCode`: `[a-z0-9-]+`; `packCode`: `[a-z0-9.-]+`; `<sha256>` = lowercase hex SHA-256 of the exact bytes = `ContentPack.sha256`.
- **Immutable**: written once, never overwritten. A content change = new `version` = new key. Upload with
  `Cache-Control: public, max-age=31536000, immutable` and `Content-Type: application/octet-stream`.
- Public URL = `${S3_PUBLIC_BASE_URL}/packs/free/<examCode>/<packCode>/v<version>.<sha256>.pack`.

## Making only `packs/free/` public

R2 public access is per bucket, so the restriction is enforced at the Cloudflare edge on the custom domain:

1. R2 bucket `heymey-content` → Settings → Custom Domains → `cdn.heymey.app`. Keep the `r2.dev` URL **disabled**.
2. Security → WAF → Custom rule on zone `heymey.app`, action **Block** (works on the Free plan):
   `(http.host eq "cdn.heymey.app" and not (http.request.method in {"GET" "HEAD"} and starts_with(http.request.uri.path, "/packs/free/") and ends_with(http.request.uri.path, ".pack")))`
   On Pro+ the stricter regex `^/packs/free/[a-z0-9-]+/[a-z0-9.-]+/v[0-9]+\.[a-f0-9]{64}\.pack$` can replace the prefix test.
3. Cache Rule: `cdn.heymey.app/packs/*` → Eligible for cache, Edge TTL = respect origin. No purge ever needed.
4. CORS on the bucket: `GET, HEAD` from `*` (packs are public, no credentials).

The app's write credentials (`S3_ACCESS_KEY`/`S3_SECRET_KEY`) are an R2 API token scoped to **Object Read & Write
on `heymey-content` only**. Pro packs stay private; a presigned-URL endpoint for `pro/` is the follow-up from BOLT-0015.
