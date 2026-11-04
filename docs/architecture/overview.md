# Architecture overview

The engineering spec is blueprint Part J (§34–§46). This page shows how the repository implements it.
Generated companions: [ports.md](ports.md) (port map) and [modules.md](modules.md) (module graph).

## 1. System context

```
 Aspirants, supporters, mentors ──► HeyMey mobile app (Flutter, Android + iOS) ──┐
 Partners and staff ─────────────► HeyMey Desk (Flutter web) ─────────────────────┤ HTTPS / WSS
 Everyone ───────────────────────► heymey.app marketing + policies (Next.js) ─────┤
                                                                                   ▼
                              Cloudflare (DNS, CDN cache, DDoS, Desk/ops access protection)
                                                                                   │
                                        ONE VPS (Docker Compose)                   ▼
                                                                                Caddy :80/:443
 External (paid, irreplaceable): Google Play + App Store billing, FCM/APNs, SMTP provider, Razorpay, OpenRouter
```

## 2. Containers and ports (target dedicated-VPS layout, NOT what runs at launch; launch tier in §2a)

```
Caddy :443 ─┬─ heymey.app        ─► marketing  :4570  Next.js standalone
            ├─ api.heymey.app    ─► api        :4567  NestJS + Fastify      ×3  ─┐
            ├─ rt.heymey.app     ─► realtime   :4568  Socket.IO             ×2  ─┤
            ├─ desk.heymey.app   ─► desk       :4569  static Flutter web         │
            ├─ cdn.heymey.app    ─► seaweedfs  :8333  (host 4583) read-only      │
            └─ ops.heymey.app*   ─► grafana 4590 · glitchtip 4593 · metabase 4594 · uptime-kuma 4595 · changedetection 4596
                                                                                  │
 worker :4571 ×2 · scheduler :4572 ×1  (BullMQ on Valkey)                       ◄─┤
 pgbouncer :4581 ─► postgres :4580 (17 + pgBackRest → off-site WAL)             ◄─┤
 valkey :4582 (cache, rate limits, queues, leaderboards, room state, socket adapter) ◄┘
 prometheus :4591 · loki :4592 · alloy · node-exporter · cadvisor · postgres-exporter
 * VPN / IP allowlist only.     Staging: same images, project "heymey-staging", ports +100.
```

Rules: only Caddy is public. App containers listen on their series port on the Docker network; single-replica data
and ops services are also published on `127.0.0.1:<series port>` for on-box debugging. See ADR-0002, ADR-0010.



## 2a. Launch-tier placement (ADR-0014, D-2026-11-01-01, PROVISIONAL)

At launch the diagram above is split across free/starter tiers. The dedicated-VPS layout stays the target once revenue justifies it.

```
heymey.app ──────────► Vercel (Next.js, GitHub integration; D-2026-11-04-01, changed 2026-11-04)
desk.heymey.app ─────► Firebase Hosting (static Flutter web) behind Cloudflare Access
cdn.heymey.app ──────► Cloudflare R2 (packs, audio, images; nightly pg_dump bucket separate, private)
api. / rt. ──────────► ONE small VM (Oracle Always Free ARM; fallback Hetzner CX22), Docker Compose:
                         caddy → api :4567 · realtime :4568 · worker :4571 · scheduler :4572
                         valkey :4582 · changedetection :4596 · (grafana/glitchtip only if RAM allows)
                         └─► Supabase Postgres (ap-south-1): app = transaction pooler :6543, migrations = direct :5432
Errors/metrics: Sentry free + Grafana Cloud free (or self-hosted on the VM). Email: SES. Push: FCM.
```

Backups: Supabase has no pgBackRest/WAL access on our side, so the `backup` service runs a nightly `pg_dump`
(custom format, via `DIRECT_URL`) → age-encrypted → R2 bucket `heymey-backups` (35-day lifecycle), plus one before
every production migration (`infra/backup/pg-dump-r2.sh`, `infra/scripts/restore.sh`). No pgbouncer: Supabase's
transaction pooler (6543) does the pooling.

Local development: `pnpm infra:up` runs Postgres (4580), Valkey (4582), SeaweedFS (4583) and Mailpit (4584/4585).
Port 4581 (pgbouncer) stays reserved in `ports.json` for the dedicated-VPS layout but nothing runs on it.
Staging = a second Compose project on the same VM (ports +100) + a second Supabase project.

## 3. Repository → runtime

| Runtime | Source | Build | Image |
|---|---|---|---|
| api, realtime, worker, scheduler | `apps/{api,realtime,worker}` + `packages/*` | `nest build` (SWC) / `tsc` | `ghcr.io/heymey/server:<sha>` (one image, 4 entrypoints) + `migrator` target |
| desk | `apps/desk` + `dart/hm_desk`… | `flutter build web` | none (Firebase Hosting, ADR-0014) |
| marketing | `apps/marketing` | `turbo run build` → `next build` on Vercel (`apps/marketing/vercel.json`) | none (Vercel) |
| mobile | `apps/mobile` + `dart/*` | fastlane (AAB / IPA) | stores |

## 4. Backend: a modular monolith

```
apps/api  ──┐   HTTP adapters (controllers)            apps/realtime ── gateways     apps/worker ── processors
            └──────────────┬───────────────────────────────────┬──────────────────────────┘
                           ▼                                   ▼
           @heymey/domain  modules/<m>/index.ts  (public API, 24 modules, see modules.md)
                           │  application/ use cases → ports
                           │  domain/      pure rules (firewall lives in economy/domain)
                           │  infrastructure/ adapters ──► @heymey/db (Prisma, only here)
           @heymey/contracts  Zod: HTTP routes + socket events ──► OpenAPI 3.1 ──► dart/hm_api
```

- A module owns its tables (its own `.prisma` file); no other module reads them; no cross-file Prisma relations.
- `module.json` lists the only modules it may import; dependency-cruiser enforces it, plus: domain layer purity,
  DB access only from infrastructure, games never touching billing/Sparks, AI only through the gateway,
  marketing isolated from server packages. See ADR-0004.
- All three processes import the same modules, so moving a process to another VPS (§25) is a compose change.

## 5. Request lifecycle (api)

```
Caddy → Fastify → auth guard (JWT, 15 min) → role guard → rate limit (Valkey) → idempotency (Idempotency-Key, 24 h)
      → controller (Zod parse from contracts) → use case (domain) → infrastructure (Prisma tx / Valkey / queue)
      → response (+ X-Min-App-Version)   |  DomainError → error envelope { error: { code, message, details } }
```

## 6. The money/game firewall

```
 Store / Razorpay ──► billing ──► economy.SparksLedger (purchase | milestone | spend | reversal)
                                        ✗ no conversion ✗
 games / squads ────────────────► economy.PointsLedger, TrophyLedger, non-sold cosmetics only
 games ──✗──► billing / entitlements / Sparks       (dependency-cruiser + FW-008)
```

Code: `packages/domain/src/modules/economy/domain/firewall.ts`. Permanent tests FW-001…FW-009. See ADR-0008.

## 7. Client architecture (Flutter)

```
apps/mobile ─► hm_features ─► hm_games ─► hm_design
     │              ├──────► hm_data (Drift + outbox sync) ─► hm_core ─► hm_api (generated)
apps/desk  ─► hm_desk ──────────────────────────────────────► hm_core
```

Feature layers: presentation → application (Riverpod) → domain → data. `apps/mobile` never depends on `hm_desk`
(ADR-0007). Study is offline-first (write locally, outbox, server wins for rings/rank/rewards); competition and
purchases are online-only (§39).

## 8. Environments

| | Where | Data | Deploy |
|---|---|---|---|
| local | developer / agent machine; `pnpm infra:up` + `pnpm dev` | seed | — |
| staging | same VM, project `heymey-staging`, own Supabase project (ADR-0014), ports +100, `staging-*.heymey.app` | seed / anonymised | automatic on merge to `main` |
| production | VM, project `heymey` + Supabase + Cloudflare R2 + Firebase Hosting (desk) + Vercel (marketing) (ADR-0014) | real | manual **Promote** (founder) → rolling, auto-rollback |
