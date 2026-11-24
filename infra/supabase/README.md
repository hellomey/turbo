# Supabase setup (staging project `femlzgwiilwccyudleai`)

Run these in the Supabase dashboard, **SQL Editor**, in this order. Each file is one paste and one Run.
Wait for "Success" before the next one.

| Order | File | What it does |
| --- | --- | --- |
| 1 | `sql/01_extensions.sql` | pgcrypto and pg_trgm (safe to re-run) |
| 2 | `sql/02_schema.sql` | All 71 tables, enums, indexes. **Run once on an empty database.** Re-running errors with "already exists"; that is expected and harmless. |
| 3 | `sql/03_security.sql` | Turns on Row Level Security on every table and removes rights from `anon` and `authenticated`, so the publishable key can read nothing. |

After step 3, in **Table Editor** every table should show "RLS enabled".

## Why the app does not use `supabase_flutter` for data
The Flutter app talks to the HeyMey API only (`dart/hm_api`, contract-first). The API connects to Postgres with the
server role, applies the rules (auth, rate limits, eligibility, honesty), and returns only what the user may see.
If the app read tables directly with the publishable key, those rules would be bypassed. The publishable key is safe to
ship in the app, but it must stay unable to read tables, which step 3 guarantees. Supabase Realtime and Storage (later)
use the same key through their own policies.

## What the API needs (set as Vercel environment variables, never in git)
See `infra/supabase/env.template`. The database password comes from Supabase > Project Settings > Database.

## After the SQL: seed and baseline
- Seed the catalogue (exams, eligibility rules, syllabus) with `pnpm db:seed` against `DIRECT_URL`. Hand the founder-run
  steps to Kural, who runs it once the connection string is shared privately.
- Because the SQL was run by hand, mark the Prisma migrations as applied so `prisma migrate deploy` does not re-run them:
  `pnpm --filter @heymey/db exec prisma migrate resolve --applied <name>` for each folder in `packages/db/prisma/migrations`.

## Vercel: importing the API
The import screen lists "marketing" and "realtime" only because it scans the repo root. For the API:
1. Click **Edit** next to Root Directory and choose `apps/api`. Application Preset: **Other**. Do not use "Services".
2. Leave Build and Install commands alone; `apps/api/vercel.json` sets them.
3. Settings > General: turn on "Include source files outside of the Root Directory in the Build Step".
4. Environment Variables: paste the values from `env.template`.
Project name suggestion: `heymey-api`. `apps/realtime` is the old Socket.IO server and is not deployed (replaced by Supabase Realtime).
