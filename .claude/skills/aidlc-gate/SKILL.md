---
name: aidlc-gate
description: Prepare or review an AIDLC gate (G-I intent, G-D design, G-C change, G-O outcome) for HeyMey - gather evidence, tick the checklist, list blockers, and hand the decision to the founder or architect. Use when asked "is this ready", to review a PR against the Definition of Done, or to close out an intent.
---

# AIDLC gate review

1. Identify the gate and the artefact: G-I → intent file; G-D → `aidlc/construction/units/U-*/`; G-C → PR + bolt file; G-O → intent Outcome.
2. Paste the matching checklist from `aidlc/templates/gate-review.md` into the artefact.
3. Gather evidence for each item yourself; do not trust claims. Run what can be run:
   `pnpm verify`, `pnpm --filter @heymey/domain test:firewall`, `pnpm ports:check`, `pnpm boundaries`,
   `flutter analyze`, the unit's tests with coverage. Link CI runs for anything you could not run.
4. Tick only items with evidence. List every unticked item as a blocker with the owner who can fix it.
5. Founder gates (G-I, G-O, and G-D/G-C for T2): never mark them passed. Summarise in 5 lines or fewer for the
   founder: what, risk tier, evidence, blockers, the decision needed.
6. Record the outcome in `aidlc/state.md`; decisions go to `aidlc/decisions.md`.
