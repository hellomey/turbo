# Content-pack hosting (BOLT-0015)

Blueprint: §39 (offline packs, SHA-256 checked), §11 (free users: free packs only), §21 (one VPS, Cloudflare in front).
Consumers: `GET /v1/content/packs` (`ContentPack.url`, `sha256`, `tier`) and the app `PackDownloader` (BOLT-0016).

## Bucket and path layout (SeaweedFS S3, bucket `S3_BUCKET_CONTENT` = `heymey-content`)

```
heymey-content/
  packs/
    free/<examCode>/<packCode>/v<version>.<sha256>.pack   # public via cdn.heymey.app (Caddy allow-list)
    pro/<examCode>/<packCode>/v<version>.<sha256>.pack    # NEVER public; not routed by Caddy
```

- `examCode`: `[a-z0-9-]+` (e.g. `tnpsc-group-4`); `packCode`: `[a-z0-9.-]+` (e.g. `tnpsc-group-4.polity`).
- `<sha256>` = lowercase hex SHA-256 of the exact file bytes; equals `ContentPack.sha256`.
- **Immutable**: an object is written once and never overwritten. A content change = new `version` = new key.
  Old versions stay until no published `ContentPack` row points at them (cleanup is a later worker job).
- Public URL: `https://cdn.heymey.app/packs/free/<examCode>/<packCode>/v<version>.<sha256>.pack`.
- Staging uses its own SeaweedFS (`staging-seaweedfs`) and synthetic content only; it has no public CDN host.

## Edge behaviour (`infra/caddy/Caddyfile`, host `cdn.heymey.app`)

- Only `GET`/`HEAD` on paths matching `^/packs/free/[a-z0-9-]+/[a-z0-9.-]+/v[0-9]+\.[a-f0-9]{64}\.pack$`;
  rewritten to `/heymey-content/...` on `production-seaweedfs:8333`. Everything else: 404 (listing, other buckets,
  `pro/`), non-GET/HEAD: 405.
- Response: `Cache-Control: public, max-age=31536000, immutable`, `Content-Type: application/octet-stream`,
  `Access-Control-Allow-Origin: *`; `X-Amz-*`, `Server`, `Set-Cookie` stripped; `Authorization`/`Cookie` never forwarded.
- Cloudflare: proxied (orange cloud) DNS record; Cache Rule "cdn.heymey.app/packs/* -> Eligible for cache,
  Edge TTL = respect origin". No purge is ever needed (names change on every new version).

## SeaweedFS access (`infra/secrets/<stack>.s3.json`, decrypted on the server only)

Caddy has no credentials, so the bucket needs anonymous **Read** on `heymey-content`; this is safe because SeaweedFS
is not published (127.0.0.1 + Docker networks only) and Caddy routes only `packs/free/`. Shape (no real keys here):

```json
{
  "identities": [
    { "name": "app", "credentials": [{ "accessKey": "<S3_ACCESS_KEY>", "secretKey": "<S3_SECRET_KEY>" }],
      "actions": ["Read:heymey-content", "Write:heymey-content", "List:heymey-content", "Tagging:heymey-content"] },
    { "name": "anonymous", "actions": ["Read:heymey-content"] }
  ]
}
```

Open point (security review): pro packs are protected by routing only. A presigned-URL endpoint for `pro/` packs is
a follow-up (backend + contract), raised in BOLT-0015.
