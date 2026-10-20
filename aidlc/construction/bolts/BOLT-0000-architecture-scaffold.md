# BOLT-0000: Architecture scaffold

| | |
|---|---|
| Unit | (all: repository foundation) |
| Stories | INT-000 |
| Risk tier | T2 |
| Agent | conductor (with architect, devops roles) |
| Branch / PR | `main` (initial commit) |
| Status | in review |

## Plan
Set up the monorepo, port series, module boundaries, contract pipeline, money/game firewall, app skeletons,
infrastructure-as-code and the AIDLC process, without building product features.

## Result
- Verified locally on 2026-10-20:
  - `pnpm install`, `turbo run build typecheck lint test` for all TS packages: **green**
  - `pnpm firewall:check`: 9 permanent tests present; `vitest` firewall suite: **9/9 passed**
  - `pnpm ports:check`: up to date; `pnpm boundaries`: no violations, and a deliberate games→billing import **was caught** (3 errors), then removed
  - api :4567 `/v1/health` 200 with `X-Min-App-Version`; realtime :4568, worker :4571, scheduler :4572 health 200
  - `flutter pub get` (workspace), `flutter analyze`: no issues; mobile + desk widget tests passed
  - `docker compose config`: dev, app (production + staging overrides), edge, monitoring files valid; staging publishes 4680–4683
- **Not verified** here: Caddyfile validation and image builds (Docker daemon was not running). CI runs both.
- Follow-ups: INT-001 open questions; D-2026-10-20-02, -03, -07.
