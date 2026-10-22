# Secrets

Encrypted with **SOPS + age** (blueprint §20.3). Rules in `/.sops.yaml`.

| File | Committed? | What |
|---|---|---|
| `production.enc.env` | ✅ encrypted | Production secrets (DB password, JWT keys, OTP pepper, SMTP, OpenRouter, store keys, Razorpay, B2/R2 backup keys, `VALKEY_PASSWORD`, `CHANGEDETECTION_WEBHOOK_SECRET` + `CHANGEDETECTION_API_KEY` (Exam Alerts webhook, BOLT-0015); edge-only `OPS_ALLOWLIST`, `STAGING_ACCESS_KEY` read by Caddy) |
| `staging.enc.env` | ✅ encrypted | Staging secrets (own `VALKEY_PASSWORD`). Sandbox store/Razorpay keys only. |
| `*.env`, `*.s3.json` | ❌ never | Decrypted on the server by `infra/scripts/deploy.sh`, `chmod 600`. Git-ignored. |
| `.env.example` | ✅ | Every key name with a fake value, so agents know what exists. |

```bash
sops infra/secrets/production.enc.env        # edit (needs an age key listed in .sops.yaml)
```

Never:
- put a secret in the app (Flutter) or in the marketing site bundle;
- paste a secret into a prompt, an issue, a PR, a log line or an AIDLC document;
- commit a decrypted file (`gitleaks` runs in CI).

`<stack>.s3.json` (SeaweedFS identities, incl. anonymous Read on `heymey-content` for the pack CDN): shape in
`infra/content-cdn/README.md`. Staging has no changedetection (profile `never`), so no webhook secret there.
