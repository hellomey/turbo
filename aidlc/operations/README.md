# Operations phase

| Step | How | Runbook |
|---|---|---|
| Release | merge to `main` → staging deploy (automatic) → smoke + k6 quick test → founder clicks **Promote** → production rolling deploy with auto-rollback | `docs/runbooks/release.md` |
| Mobile release | fastlane → internal tracks → staged rollout 10% → 50% → 100% while crash-free ≥ 99.5% | `docs/runbooks/release.md` |
| Observe | Grafana (api p95, error rate, queue depth, OTP delivery time), GlitchTip, Uptime Kuma + external monitor → Telegram | — |
| Event days | State Mock Sunday: k6 at 5× the week before, temporary extra app capacity | `docs/runbooks/event-day.md` |
| Incidents | open `incidents/INC-xxxx.md` from `aidlc/templates/incident.md`; actions become intents/bolts | `docs/runbooks/incident.md` |
| Restore drill | monthly, on staging | `docs/runbooks/restore.md` |
| VPS loss | rebuild within 1 hour | `docs/runbooks/vps-rebuild.md` |

After release, the conductor fills the intent's **Outcome** section with the observed metrics and asks the founder for **G-O**.
