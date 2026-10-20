---
name: aidlc-intent
description: AIDLC Inception for HeyMey. Capture a new intent from a blueprint section or founder request, elaborate it into stories with Given/When/Then acceptance criteria, decompose it into units, and prepare gate G-I. Use when someone asks to start, plan, scope or spec a feature.
---

# AIDLC Inception: capture → elaborate → decompose → G-I

1. **Read** `aidlc/README.md`, `aidlc/state.md`, `aidlc/inception/units.md`, and every blueprint section involved
   (`docs/HEYMEY_PRODUCT_BLUEPRINT.md`). Check that the intent does not already exist in `aidlc/inception/intents/`.
2. **Capture**: copy `aidlc/templates/intent.md` to `aidlc/inception/intents/INT-<next>-<slug>.md`. Fill Why, Scope,
   Blueprint §, Risk tier (`aidlc/README.md` §5; when unsure, the higher tier). Add a row to `aidlc/state.md`.
3. **Elaborate** (role: `spec`): stories with acceptance criteria in Given/When/Then; include §18 loopholes and
   NFRs (§24 performance, §39 offline, §10.9 accessibility, §23 security, §10.2 copy, §13 Dark Patterns).
   Anything the blueprint doesn't answer → Open questions. Do not invent behaviour.
4. **Decompose** (role: `architect`): map stories to units. Reuse existing units in `aidlc/inception/units.md`
   when the module already exists; add new rows otherwise. Set dependencies, tier, owning agent.
5. **Prepare G-I**: paste the G-I checklist from `aidlc/templates/gate-review.md` into the intent, tick what is
   true, list the open questions, and ask the founder. Set status `elaborating` until the founder approves.
6. **Record** answers in `aidlc/decisions.md` (append-only) and update `aidlc/state.md`.

Output to the user: the intent file path, the number of stories and units, the tier, and the open questions.
