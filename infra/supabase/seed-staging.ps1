# Creates the tables (prisma migrate deploy) and seeds the staging Supabase project. Safe to re-run.
# On a NEW project, run infra/supabase/sql/03_security.sql in the SQL editor afterwards (RLS + revoke anon).
# Run from the repo root:  powershell -ExecutionPolicy Bypass -File infra/supabase/seed-staging.ps1
# The password is typed here, hidden, and lives only in this process. It is never written to disk.
$ErrorActionPreference = "Stop"
$ref  = "gaghxdgwdrgaqacjrwat"  # Mumbai (ap-south-1) project
$host_ = "aws-1-ap-south-1.pooler.supabase.com"

$secure = Read-Host "Supabase database password" -AsSecureString
$plain  = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
$enc    = [Uri]::EscapeDataString($plain)

$env:HEYMEY_ENV  = "staging"
$env:DATABASE_CA = (Get-Content -Raw "infra/supabase/supabase-root-2021-ca.crt")
$env:DATABASE_URL = "postgresql://postgres.$ref`:$enc@$host_`:5432/postgres?sslmode=require"
$env:DIRECT_URL   = $env:DATABASE_URL

Write-Host "Installing dependencies and regenerating the database client (it must match the pulled schema)..."
$ErrorActionPreference = "Continue"
corepack pnpm install --frozen-lockfile 2>&1 | Out-Null
Push-Location packages/db
corepack pnpm exec prisma generate 2>&1 | Out-Null
$genExit = $LASTEXITCODE
Pop-Location
$ErrorActionPreference = "Stop"
if ($genExit -ne 0) { throw "prisma generate failed" }

Write-Host "Applying migrations (fresh database) or confirming they are applied..."
Push-Location packages/db
# migrate deploy creates every table on a new project and is a no-op when all are applied.
# A project whose tables were created by hand-run SQL (02_schema.sql) has no migration history (Prisma P3005):
# record every migration except the newest as applied (baseline), then deploy, which runs the newest.
# Every migration is written to be safe if its change already exists.
# Windows PowerShell turns native stderr into errors under "Stop", so relax it while capturing output.
$ErrorActionPreference = "Continue"
$out = corepack pnpm exec prisma migrate deploy 2>&1 | Out-String
$deployExit = $LASTEXITCODE
Write-Host $out
if ($deployExit -ne 0 -and $out -match "P3005") {
  Write-Host "Existing tables without migration history: baselining..."
  $all = Get-ChildItem prisma/migrations -Directory | Sort-Object Name
  foreach ($m in $all[0..($all.Count - 2)]) { corepack pnpm exec prisma migrate resolve --applied $m.Name | Out-Null }
  corepack pnpm exec prisma migrate deploy
  $deployExit = $LASTEXITCODE
}
$ErrorActionPreference = "Stop"
if ($deployExit -ne 0) { Pop-Location; throw "migrate deploy failed" }
Pop-Location

Write-Host "Seeding catalogue..."
# Run tsx directly: "pnpm db:seed" starts a nested pnpm, which is not on PATH in a plain PowerShell window.
Push-Location packages/db
corepack pnpm exec tsx prisma/seed.ts
$seedExit = $LASTEXITCODE
Pop-Location
if ($seedExit -ne 0) { throw "seed failed" }

Write-Host "Done. Check https://heymey-api.vercel.app/v1/exams"
