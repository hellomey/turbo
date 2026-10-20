# Release

## Server, Desk, marketing (blueprint §42)
1. PR merged to `main` (founder approved) → CI builds images tagged with the commit SHA → deploys **staging** automatically.
2. CI runs smoke tests + k6 quick test against `staging-api.heymey.app`. Check Grafana (staging): error rate, p95.
3. Founder clicks **Promote** (GitHub environment `production`, required reviewer = founder).
4. `infra/scripts/deploy.sh production <sha>`: pgBackRest backup → `migrator` (expand-only) → rolling `up --wait` per service → automatic rollback to the previous tag if a health check fails.
5. Watch for 30 minutes: Grafana (api p95 ≤ 300 ms, 5xx rate), GlitchTip (new issues), queue depth.
6. Publish release notes in simple English. Update the intent's Outcome.

Rollback by hand: `deploy.sh production <previous-sha>` (migrations are backward compatible by rule, so the old code still runs).

## Mobile
1. fastlane builds AAB + IPA (macOS runner / Codemagic) → Play internal testing + TestFlight.
2. Staged rollout 10% → 50% → 100%, advancing only while crash-free sessions ≥ 99.5%.
3. Urgent fix for old versions: raise `MIN_APP_VERSION` (X-Min-App-Version) so old apps show "Update needed".
