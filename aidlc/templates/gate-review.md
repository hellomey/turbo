# Gate review checklists

Paste the relevant block into the artefact being approved and tick it. The approver writes their name and date.

## G-I: Intent approved (founder)
- [ ] Every story cites a blueprint section; nothing contradicts the blueprint
- [ ] Acceptance criteria are testable (Given/When/Then)
- [ ] Units, owners and risk tiers are set
- [ ] Open questions answered in `decisions.md`
- Approved by: ______ date: ______

## G-D: Design approved (architect; + founder for T2)
- [ ] Module ownership respected; no new cross-module dependency without an ADR
- [ ] Contract diff is non-breaking for /v1
- [ ] Migration is expand-only for this release
- [ ] Idempotency, authorisation and rate limits defined for every write
- [ ] Offline/online behaviour matches §39
- [ ] T2: firewall impact analysed; new FW tests listed
- Approved by: ______ date: ______

## G-C: Change approved (per PR)
- [ ] CI green: ports, firewall, boundaries, lint, typecheck, tests, codegen drift, security scans
- [ ] Definition of Done (blueprint §45) ticked in the PR
- [ ] Reviewer agents: qa ✔ (+ security ✔, compliance ✔ for T2)
- [ ] Bolt "Result" section filled
- [ ] Founder approves merge to `main`
- Approved by: ______ date: ______

## G-O: Outcome accepted (founder)
- [ ] Released to production; release notes published
- [ ] Success metrics checked against thresholds
- [ ] No open Sev-1/Sev-2 incidents caused by this intent
- Approved by: ______ date: ______
