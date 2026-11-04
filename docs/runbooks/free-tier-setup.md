# Free-tier setup (founder steps)

BOLT-0023 · ADR-0014. Do these steps in this order. Each one ends with something you note down. Put those values
into the SOPS files or GitHub secrets **only** (`infra/secrets/README.md`), never into chat, issues or documents.

| Part | Where it runs |
|---|---|
| Postgres | Supabase (Mumbai, ap-south-1) |
| Content packs + backups | Cloudflare R2 (`cdn.heymey.app`) |
| Marketing site `heymey.app` | Vercel (GitHub integration; D-2026-11-04-01) |
| Desk `desk.heymey.app` | Firebase Hosting |
| API, realtime, worker, scheduler, Valkey, Caddy, changedetection | one VM (Oracle Always Free ARM, or Hetzner) |
| Local development | unchanged (`pnpm infra:up`) |

## 1. Supabase (database)

1. supabase.com → New project `heymey-production`, region **South Asia (Mumbai) ap-south-1**, a strong DB password
   (password manager).
2. Make a second project `heymey-staging` (same region). Staging only ever gets test data.
3. For each project: **Connect** → copy:
   - **Transaction pooler** (port **6543**) → `DATABASE_URL`. Add `?pgbouncer=true&connection_limit=5&sslmode=require`.
   - **Session pooler** (port **5432**) or Direct connection → `DIRECT_URL`. Add `?sslmode=require`.
4. Project Settings → Database → turn on **Enforce SSL**. Leave the Data API (PostgREST) **off** for the app schema:
   Settings → API → Exposed schemas: remove `public` (the app talks to Postgres only through our API).
5. Optional: a read-only role for monitoring (`DATA_SOURCE_NAME`), created in the SQL editor.

## 2. Cloudflare R2 (storage)

1. Cloudflare dashboard → R2 → create buckets `heymey-content`, `heymey-content-staging`, `heymey-backups`
   (location hint: Asia-Pacific).
2. `heymey-content` → Settings → **Custom Domains** → add `cdn.heymey.app`. Keep **r2.dev access disabled** on all buckets.
3. Add the WAF rule and Cache Rule from `infra/content-cdn/README.md` (only `packs/free/` is public).
4. `heymey-backups` → Settings → Object lifecycle → delete objects after **35 days**.
5. R2 → Manage API tokens → create:
   - `heymey-app`: Object Read & Write, **only** `heymey-content` → `S3_ACCESS_KEY` / `S3_SECRET_KEY` (production).
   - `heymey-app-staging`: only `heymey-content-staging` (staging).
   - `heymey-backup`: Object Read & Write, only `heymey-backups` → `BACKUP_S3_ACCESS_KEY` / `BACKUP_S3_SECRET_KEY`.
   - Note the S3 endpoint `https://<account-id>.r2.cloudflarestorage.com` → `S3_ENDPOINT`, `BACKUP_S3_ENDPOINT`.
6. Backup encryption key, on **your own computer** (not the VM): `age-keygen -o heymey-backup.key`. The printed
   public key (`age1…`) → `BACKUP_AGE_RECIPIENT`. Keep the key file offline in two places (it is needed to restore).

## 3. Firebase Hosting (Desk)

1. console.firebase.google.com → Add project `heymey-desk` (Analytics off).
2. Hosting → Get started → keep the default site; add a second site `heymey-desk-staging`.
3. Default site → Add custom domain `desk.heymey.app` → note the DNS records Firebase shows (step 6).
4. Project settings → Service accounts → Google Cloud → create a service account with role **Firebase Hosting Admin**
   → JSON key → GitHub secret `FIREBASE_SERVICE_ACCOUNT`. Project id → GitHub variable `FIREBASE_PROJECT_ID`.
5. If the ids differ from `heymey-desk` / `heymey-desk-staging`, update `apps/desk/.firebaserc.example` and copy it
   to `apps/desk/.firebaserc` (CI uses the `projectId` variable and the targets in `firebase.json`).

## 4. Vercel (marketing) — D-2026-11-04-01

**Plan:** the Vercel **Hobby** plan does not allow commercial use. heymey.app is a commercial site, so it needs
**Vercel Pro (US$20/month per member)**. Your choice; see ADR-0014 amendment 2026-11-04.

1. vercel.com → Add New → Project → **Import** the GitHub repository (install the Vercel GitHub app on that repo only).
2. **Root Directory**: `apps/marketing`. **Framework Preset**: Next.js. Leave Build/Install/Output on defaults:
   `apps/marketing/vercel.json` sets them (pnpm install from the repo root, `turbo run build`, and `turbo-ignore`
   so commits that do not touch marketing skip the build). Node.js version: 24.x (Project Settings → General).
3. Environment variables: none are secret. Set `NEXT_PUBLIC_APP_URL` only if the founder has chosen a value (INT-005).
4. Deploy. Production branch = `main`; every PR gets a Preview URL (no personal data on the site).
5. Project → Settings → **Domains** → add `heymey.app` and `www.heymey.app` (redirect `www` → `heymey.app`).
   Vercel shows the DNS records to create (step 6). **Verify the values Vercel shows in its Domains tab**; they
   can differ from the ones below.
6. Settings → Deployment Protection: keep Preview deployments protected (Vercel Authentication).

## 5. The VM (API stack)

1. cloud.oracle.com → Compute → Create instance: Ubuntu 24.04, shape **VM.Standard.A1.Flex** (4 OCPU, 24 GB, arm64),
   region **Mumbai** or **Hyderabad**, your SSH public key, 100 GB boot volume.
   (No capacity? Retry later, or use Hetzner CAX21/CPX31; the images are amd64 + arm64.)
2. Networking → the subnet's Security List → Ingress: allow TCP 80, TCP 443, UDP 443 from 0.0.0.0/0, and your SSH port.
3. SSH in, then: `sudo bash provision.sh deploy <ssh-port>` (copy `infra/scripts/provision.sh` first). It installs
   Docker, ufw, CrowdSec, opens 80/443 in Oracle's own iptables rules and adds swap.
4. As `deploy`: `git clone <repo> /srv/heymey`; put the SOPS age key at `/srv/heymey/.age/key.txt` (`chmod 600`).
5. Fill the secrets (every key is listed in `infra/secrets/.env.example`):
   `sops infra/secrets/production.enc.env` and `sops infra/secrets/staging.enc.env`.
6. `docker login ghcr.io` with a read-only package token, then start Caddy:
   `cd /srv/heymey/infra/compose && docker compose -p heymey-edge --env-file images.env -f compose.edge.yml up -d`.
7. Note the VM's public IP and its SSH host key fingerprint (`ssh-keyscan -p <port> <ip> | ssh-keygen -lf -`).

## 6. DNS (Cloudflare → DNS → zone heymey.app)

| Name | Type | Value | Proxy |
|---|---|---|---|
| `api` | A | VM IP | proxied |
| `rt` | A | VM IP | proxied (WebSockets on) |
| `ops` | A | VM IP | proxied |
| `staging-api`, `staging-rt` | A | VM IP | proxied |
| `desk` | as shown by Firebase (A / TXT) | Firebase | **DNS only** (grey) |
| `cdn` | added by R2 custom domain | R2 | proxied (automatic) |
| `@` | A | `76.76.21.21` (Vercel; verify in Vercel's Domains tab) | **DNS only** (grey) |
| `www` | CNAME | `cname.vercel-dns.com` (verify in Vercel's Domains tab) | **DNS only** (grey) |

SSL/TLS mode: **Full (strict)**. Old records for `staging`, `staging-desk` can be deleted.

## 7. GitHub secrets and variables

Settings → Environments `staging` and `production` (production: **required reviewer = founder**, this is Promote):

- Secrets: `VPS_HOST`, `VPS_SSH_PORT`, `VPS_USER`, `VPS_SSH_KEY`, `VPS_HOST_FINGERPRINT`, `STAGING_ACCESS_KEY`,
  `FIREBASE_SERVICE_ACCOUNT`.
- Variables: `FIREBASE_PROJECT_ID`.
- Marketing needs no GitHub secret: Vercel deploys through its own GitHub app. Delete `CLOUDFLARE_API_TOKEN` /
  `CLOUDFLARE_ACCOUNT_ID` if you created them for the old Workers plan.

## 8. First deploy, in this order

1. **Migrate**: merge to `main` (or re-run the `deploy` workflow). `deploy.sh` runs `prisma migrate deploy` with
   `DIRECT_URL` against Supabase. Check in Supabase → Table editor that the tables exist.
2. **API**: the same run starts api, realtime, worker, scheduler. Check `https://api.heymey.app/v1/health`.
3. **Desk**: the workflow deploys `desk.heymey.app` (Firebase). Open it, sign in.
4. **Marketing**: Vercel deploys `heymey.app` on every push to `main` that touches marketing. Open it.
5. Production happens only after you press **Promote** (approve the `production` environment); staging goes first.
6. Within a week: do the first restore drill (`docs/runbooks/restore.md`, `infra/scripts/restore.sh drill`).

Local development does not change: `pnpm env:dev --append` adds the new `DIRECT_URL` / `S3_*` keys to an existing `.env`.
