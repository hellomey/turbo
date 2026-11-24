# Seeds the staging Supabase project and marks the hand-run SQL migrations as applied.
# Run from the repo root:  powershell -ExecutionPolicy Bypass -File infra/supabase/seed-staging.ps1
# The password is typed here, hidden, and lives only in this process. It is never written to disk.
$ErrorActionPreference = "Stop"
$ref  = "femlzgwiilwccyudleai"
$host_ = "aws-1-ap-northeast-1.pooler.supabase.com"

$secure = Read-Host "Supabase database password" -AsSecureString
$plain  = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
$enc    = [Uri]::EscapeDataString($plain)

$env:HEYMEY_ENV  = "staging"
$env:DATABASE_CA = (Get-Content -Raw "infra/supabase/supabase-root-2021-ca.crt")
$env:DATABASE_URL = "postgresql://postgres.$ref`:$enc@$host_`:5432/postgres?sslmode=require"
$env:DIRECT_URL   = $env:DATABASE_URL

Write-Host "Seeding catalogue..."
corepack pnpm db:seed
if ($LASTEXITCODE -ne 0) { throw "seed failed" }

Write-Host "Marking migrations as applied (the SQL was run by hand in the SQL editor)..."
Push-Location packages/db
foreach ($m in Get-ChildItem prisma/migrations -Directory | Sort-Object Name) {
  corepack pnpm exec prisma migrate resolve --applied $m.Name
}
Pop-Location
Write-Host "Done. Check https://heymey-api.vercel.app/v1/exams"
