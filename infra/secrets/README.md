# Secrets

Encrypted with **SOPS + age** (blueprint §20.3). Rules in `/.sops.yaml`.

| File | Committed? | What |
|---|---|---|
| `production.enc.env` | ✅ encrypted | Production secrets (Supabase `DATABASE_URL` (pooler :6543) + `DIRECT_URL` (session/direct), R2 `S3_*` + `BACKUP_S3_*` + `BACKUP_AGE_RECIPIENT` (BOLT-0023), JWT keys, OTP pepper, SMTP, OpenRouter, store keys, Razorpay, `VALKEY_PASSWORD`, `CHANGEDETECTION_WEBHOOK_SECRET` + `CHANGEDETECTION_API_KEY` (Exam Alerts webhook, BOLT-0015); edge-only `OPS_ALLOWLIST`, `STAGING_ACCESS_KEY` read by Caddy) |
| `staging.enc.env` | ✅ encrypted | Staging secrets (own Supabase project URLs, own R2 bucket, own `VALKEY_PASSWORD`). Sandbox store/Razorpay keys only. |
| `*.env` | ❌ never | Decrypted on the server by `infra/scripts/deploy.sh`, `chmod 600`. Git-ignored. |
| `.env.example` | ✅ | Every key name with a fake value, so agents know what exists. |

```bash
sops infra/secrets/production.enc.env        # edit (needs an age key listed in .sops.yaml)
```

Never:
- put a secret in the app (Flutter) or in the marketing site bundle;
- paste a secret into a prompt, an issue, a PR, a log line or an AIDLC document;
- commit a decrypted file (`gitleaks` runs in CI).

Staging has no changedetection and no backup service (profile `never`), so no webhook or backup secrets there.

## Not on the VM (GitHub Actions secrets, BOLT-0023)

| Secret | Used by | Scope |
|---|---|---|
| `VPS_HOST`, `VPS_SSH_PORT`, `VPS_USER`, `VPS_SSH_KEY`, `VPS_HOST_FINGERPRINT` | deploy api/staging/production | environment `staging` / `production` |
| `FIREBASE_SERVICE_ACCOUNT` (JSON, role Firebase Hosting Admin) | desk → Firebase Hosting | environment `production` (+ `staging` for the preview channel) |
| `FIREBASE_PROJECT_ID` (variable, not secret) | desk | repo variable |
| (none) | marketing → Vercel deploys via its own GitHub app; no token in GitHub (D-2026-11-04-01) | — |
| `STAGING_ACCESS_KEY` | staging smoke + k6 | environment `staging` |
