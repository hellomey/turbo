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

Write-Host "Applying migrations (fresh database) or confirming they are applied..."
Push-Location packages/db
# migrate deploy creates every table on a new project and is a no-op when all are applied.
corepack pnpm exec prisma migrate deploy
if ($LASTEXITCODE -ne 0) { Pop-Location; throw "migrate deploy failed" }
Pop-Location

Write-Host "Seeding catalogue..."
# Run tsx directly: "pnpm db:seed" starts a nested pnpm, which is not on PATH in a plain PowerShell window.
Push-Location packages/db
corepack pnpm exec tsx prisma/seed.ts
$seedExit = $LASTEXITCODE
Pop-Location
if ($seedExit -ne 0) { throw "seed failed" }

Write-Host "Done. Check https://heymey-api.vercel.app/v1/exams"
