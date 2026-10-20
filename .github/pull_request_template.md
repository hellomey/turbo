## Traceability
`§__ → INT-___-S__ → U-_____ → BOLT-____`

**Risk tier:** T0 / T1 / T2   ·   **Bolt file:** `aidlc/construction/bolts/BOLT-____-*.md`

## What changed

## Evidence
- `pnpm verify`:
- Flutter (`flutter analyze`, tests, goldens):
- Coverage of touched modules:
- Screenshots / goldens / k6 (if relevant):

## Definition of done (blueprint §45)
- [ ] Matches the blueprint (or founder-approved change logged in `aidlc/decisions.md`)
- [ ] API in `@heymey/contracts`; OpenAPI + Dart client regenerated
- [ ] Server-side permission checks + rate limits; idempotent writes
- [ ] Tests at coverage targets (+ goldens for UI); firewall suite untouched or extended
- [ ] Offline behaviour per §39 where applicable
- [ ] Dark / light / high-contrast, Calm, Lite, 200% text; screen-reader labels
- [ ] Simple-English copy; Dark Patterns checklist for any offer text
- [ ] Logs / metrics / errors visible; feature flag if risky
- [ ] Performance budget (§24)
- [ ] `aidlc/state.md` and the bolt "Result" updated

## Reviews
- [ ] qa  ·  T2 only: [ ] security  [ ] compliance  [ ] founder
