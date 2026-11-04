# ADR-0014: Free-tier launch architecture (managed free tiers + one small VM)

| | |
|---|---|
| Status | proposed (architect); **PROVISIONAL, founder to confirm** (D-2026-11-01-01, risk tier T2) |
| Date | 2026-11-01 |
| Deciders | founder (request) + main session + architect |
| Blueprint | §14.1, §20.2, §20.3, §21, §24, §25, §34.1, §34.3, §34.7, §42 |
| Supersedes (in part) | the "one VPS, everything in Docker" hosting choice (blueprint decision 5, §20.3, §21, §25, §42); ADR-0010 for production placement of data services |

## Context
The blueprint (§14.1, §20.3) budgets one 16 vCPU / 64 GB VPS (≈ ₹9,000/month) plus self-hosted Postgres, pgbouncer,
SeaweedFS, GlitchTip and Grafana. The founder wants to launch on free and starter tiers and pay for hosting only once
revenue arrives. Constraints that do not change:

- Server-authoritative (§34.1): api, realtime, worker and scheduler are long-lived processes with websockets and
  BullMQ; they cannot run on serverless functions.
- Idempotent writes (§34.3) and append-only ledgers (§34.5) need one real Postgres with transactions; Prisma stays.
- Our own auth stays (email OTP, refresh sessions, Desk TOTP; §38). **Supabase Auth is not adopted.**
- Port series 4567+ (ADR-0002) stays for everything that still runs in containers.
- No personal data outside India-agnostic processors we already list in the privacy notice without a compliance review
  (see Risks: data residency).

## Decision

| Concern | Before | After (launch tier) | Paid upgrade trigger |
|---|---|---|---|
| Postgres | Self-hosted on VPS + pgbouncer | **Supabase Free**. App uses the transaction pooler (Supavisor, port 6543, `pgbouncer=true` style, no prepared statements); migrations use the direct/session URL (5432). Prisma stays. Supabase Auth **not** adopted. | **Supabase Pro ($25/mo) before public launch**: Free pauses after 7 days idle and has no backups. Our nightly `pg_dump` → R2 continues regardless. |
| Object storage + pack CDN | SeaweedFS | **Cloudflare R2**: 10 GB-month storage free, zero egress, S3 API, served via custom domain `cdn.heymey.app` | Pay as you go (≈ $0.015/GB-month above 10 GB; verify on vendor pricing page) |
| Marketing (Next.js) | VPS container | **Cloudflare Workers/Pages** via `@opennextjs/cloudflare`. Commercial use allowed on free. **Not Vercel Hobby** (terms forbid commercial use; Vercel Pro $20/mo). | Not needed (Workers Paid $5/mo only if >100k requests/day) |
| Desk (Flutter web) | VPS + Caddy | **Firebase Hosting** (Spark, free: 10 GB storage, 360 MB/day transfer; verify on vendor pricing page) at `desk.heymey.app`. Cloudflare Access stays in front. | Blaze, pay as you go |
| api, worker, scheduler, realtime | VPS | **One small always-on VM** running Docker Compose: api, worker, scheduler, realtime, valkey, caddy, changedetection. First choice **Oracle Cloud Always Free** Ampere A1 (4 OCPU / 24 GB, $0). Fallback **Hetzner CX22** (2 vCPU / 4 GB, ≈ €4/mo; verify on vendor pricing page). Ports 4567+ unchanged. | Bigger VM, or split realtime/worker onto a second VM (§25) |
| Queue + cache | Valkey on VPS | Valkey stays on the VM. Upstash free (500k commands/mo) is far too small for BullMQ polling. | — |
| Email | SES (`docs/runbooks/email-setup.md`) | SES, ≈ $0.10 per 1,000 mails | — |
| Push | — | FCM (free) | — |
| Errors + metrics | GlitchTip, Grafana self-hosted | **Sentry Developer (free, 5k errors/mo)** and **Grafana Cloud Free** (10k metric series, 50 GB logs, 14-day retention; verify on vendor pricing page), or keep GlitchTip/Grafana self-hosted on the VM if RAM allows (Oracle: yes; Hetzner CX22: no) | Sentry Team / Grafana Cloud Pro when limits are hit |
| DNS, WAF | Cloudflare | Cloudflare free | — |

### Supabase free-tier limits we design for (verify on vendor pricing page)
500 MB database, 5 GB egress, 2 free projects per org, paused after 7 days without activity, no automated backups,
shared CPU / 500 MB RAM ("Nano"), ~200 pooler client connections. **Staging and production must be two projects**;
the free tier allows exactly two, so a preview/dev project needs Pro.

### Consequences for code and infra (implemented by devops, not by this ADR)
- `DATABASE_URL` (pooler 6543, `?pgbouncer=true&connection_limit=…`) and `DIRECT_URL` (5432) for `prisma migrate deploy`.
- pgbouncer, postgres, pgBackRest and SeaweedFS leave the production compose stack; they stay in the **local** stack
  (`pnpm infra:up`) so tests and offline development do not change. Port numbers 4580/4581/4583 stay reserved.
- §42 step "pgBackRest snapshot" becomes "`pg_dump` to R2 before migrate" (plus Supabase PITR once on Pro + add-on).
- Expand → migrate → contract (§42) is unchanged.

## Monthly cost

Excludes OpenRouter, reviewers, marketing, store fees (unchanged from §14.1). ₹ at ≈ ₹85/$, rounded. All usage numbers
are estimates; verify on vendor pricing pages before budgeting.

| Item | Launch (closed beta) | ~10k users | ~100k users |
|---|---|---|---|
| Supabase | $0 (Free) → $25 Pro before public launch | $25 Pro (8 GB DB incl.) | $25 + compute add-on (Small/Medium ≈ $15–60) + PITR add-on (verify) ≈ $100 |
| VM (api/rt/worker/valkey) | $0 Oracle (or ≈ €4 Hetzner) | $0 Oracle (or Hetzner CX32 ≈ €7) | 2 × Hetzner CCX/CPX class ≈ €40–60 (Oracle free capacity not enough) |
| Cloudflare R2 | $0 (<10 GB) | $0–1 | ≈ $2–5 (100–300 GB packs/audio, zero egress) |
| Cloudflare Workers (marketing) + DNS/WAF | $0 | $0 | $0–5 |
| Firebase Hosting (Desk) | $0 | $0 | $0 (staff/partners only) |
| SES email | ≈ $0–1 | ≈ $3 (≈ 30k mails) | ≈ $30 (≈ 300k mails) |
| FCM | $0 | $0 | $0 |
| Sentry + Grafana Cloud | $0 | $0 | $0–26 (Sentry Team) or self-host |
| Off-site dump storage | in R2 | in R2 | in R2 |
| **Total** | **≈ $0 (₹0); ≈ $26 (≈ ₹2,200) once Supabase Pro** | **≈ $30 (≈ ₹2,500)** | **≈ $200–250 (≈ ₹17,000–21,000)** |

Blueprint §14.1 budgeted ₹10,000/month (VPS + backups) for hosting; this saves ≈ ₹8,000–10,000/month at launch.

## Risks
1. **Supabase Free pauses after 7 days idle and has no backups.** Mitigation: never run production on Free past the
   closed beta; upgrade to Pro before public launch; nightly `pg_dump` → R2 always; monthly restore drill continues.
2. **Supabase limits**: 500 MB DB (Free) / 8 GB (Pro) included; pooler connection caps; shared compute. Transaction
   pooling forbids session features (prepared statements, `LISTEN/NOTIFY`, advisory session locks). Mitigation: Prisma
   `pgbouncer=true`; any session-level need uses `DIRECT_URL` from the worker only; alert at 70% DB size.
3. **Oracle reclaims idle Always Free instances** (CPU, network and memory utilisation below ~20% over 7 days; verify on
   vendor policy page) and A1 capacity is often unavailable in Indian regions. Mitigation: upgrade the Oracle account to
   Pay-As-You-Go (still $0 for Always Free shapes, exempt from idle reclamation; verify); keep the Hetzner fallback
   scripted (`docs/runbooks/vps-rebuild.md`); the VM is stateless except Valkey, which is rebuildable (queues are
   re-derivable, leaderboards are recomputed from Postgres).
4. **Latency and data residency.** Supabase region must be `ap-south-1` (Mumbai). Hetzner has no Indian region
   (higher latency to users; realtime games feel it). Oracle has Mumbai/Hyderabad. Personal data now sits with
   Supabase (AWS Mumbai) and Cloudflare: **compliance must update the processor list in the privacy notice (DPDP)**.
5. **Vendor lock-in.** Low by design: plain Postgres + Prisma (no Supabase Auth, RLS, Edge Functions or Realtime),
   S3 API for R2, static files for Desk, OpenNext for marketing, Compose for the VM.
6. **More moving parts / accounts.** Five vendors instead of one VPS. Mitigation: all in company accounts, secrets in
   SOPS, external uptime check per endpoint.
7. **Self-hosted monitoring on a 4 GB fallback VM will not fit.** Use Sentry + Grafana Cloud free there.

## Exit path per choice
| Choice | Exit |
|---|---|
| Supabase | `pg_dump`/`pg_restore` to any Postgres 15+ (self-hosted VPS per original §20.3, Neon, RDS); change two URLs. |
| Cloudflare R2 | S3 API: `rclone sync` to SeaweedFS/B2/S3; repoint `cdn.heymey.app`. |
| Cloudflare Workers (marketing) | Original standalone Next.js container on the VM (`output: standalone`, port 4570). |
| Firebase Hosting (Desk) | Static files: back to the `desk` container behind Caddy (port 4569) or Cloudflare Pages. |
| Oracle VM | Same Compose on Hetzner / any VPS; switch DNS (runbook `vps-rebuild.md`). |
| Sentry / Grafana Cloud | Same SDKs point at self-hosted GlitchTip / Grafana (blueprint §20.3). |

## Paid-upgrade triggers (summary)
- **Supabase Pro**: before public launch (hard rule), or DB > 350 MB, or first paying user — whichever is first.
- **Bigger VM / split**: p95 API latency above §24 budgets for 3 days, or VM RAM > 75% sustained, or Oracle reclaim/capacity issue.
- **Workers Paid**: marketing > 100k requests/day.
- **Firebase Blaze**: Desk transfer > 360 MB/day.
- **Sentry/Grafana paid**: monthly quota hit twice.
- **Return to a dedicated VPS (original §20.3)**: hosting bill above ≈ ₹9,000/month, when one VPS becomes cheaper.

## Amendment 2026-11-04: marketing on Vercel (founder decision D-2026-11-04-01)

**Change.** The marketing site (`apps/marketing`, Next.js) is hosted on **Vercel** at `heymey.app` / `www.heymey.app`,
deployed by Vercel's GitHub integration. This replaces the Cloudflare Workers / `@opennextjs/cloudflare` row above
(BOLT-0023). Everything else in this ADR is unchanged: Supabase (Postgres), R2 (storage), Firebase Hosting (Desk),
one VM (api/realtime/worker/scheduler/Valkey).

**How.** Vercel project Root Directory `apps/marketing`; `apps/marketing/vercel.json` installs with pnpm from the
repo root, builds with `turbo run build --filter=./apps/marketing`, skips unrelated commits with `npx turbo-ignore`,
and sets security headers (HSTS, nosniff, frame DENY, Referrer-Policy, Permissions-Policy, COOP). The marketing jobs
were removed from `.github/workflows/deploy.yml`; no Cloudflare API token is needed. DNS stays on Cloudflare with
`@` and `www` **DNS only** (grey cloud) pointing at Vercel (`docs/runbooks/free-tier-setup.md` §4, §6).

**Cost: founder to decide.** The Vercel **Hobby plan forbids commercial use** (Vercel Fair Use / Terms). heymey.app
markets a paid product, so it needs **Vercel Pro, US$20/month per member** (≈ ₹1,700/month). This replaces the
"$0" Cloudflare Workers line in the cost table; Hobby is acceptable only for a non-commercial preview.

**Exit.** Unchanged in spirit: standalone Next.js container on the VM (port 4570), or Cloudflare Workers via OpenNext.

**Paid-upgrade trigger.** Replace "Workers Paid" with: Vercel Pro from the day the site is commercial (public launch).
