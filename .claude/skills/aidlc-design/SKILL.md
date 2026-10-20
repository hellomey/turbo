---
name: aidlc-design
description: AIDLC Construction design step for one HeyMey unit. Writes the domain model and logical design (contract changes, data/migrations, queues, offline behaviour, failure modes, test plan) and prepares gate G-D. Use after an intent passes G-I and before any bolt on that unit.
---

# AIDLC design: domain model + logical design → G-D

Precondition: the unit's intent is `approved (G-I)` in `aidlc/state.md`. If not, stop and say so.

1. Orient with `graphify query "<unit topic>"` / `graphify path "<module A>" "<module B>"`, then read the intent's stories, the unit row in `aidlc/inception/units.md`, the module's `MODULE.md` and `module.json`,
   the module's `.prisma` file, and the relevant blueprint sections (Part J §34–§46 always applies).
2. Create `aidlc/construction/units/U-<name>/domain-model.md` from `aidlc/templates/domain-model.md`:
   language, aggregates, **invariants** (each becomes a test), state machines, domain events, firewall impact.
3. Create `logical-design.md` from `aidlc/templates/logical-design.md`: use cases with idempotency key + role,
   contract diff (non-breaking /v1), Prisma changes with an expand → migrate → contract plan, queues (IST cron),
   client + offline behaviour (§39), flags (§34.6), failure modes with simple-English messages, NFR budget, test plan.
4. Check boundaries: if the design needs a module not in `module.json` `dependsOn`, propose an ADR instead.
5. T2 units: list new `FW-xxx` firewall tests; request `security` and `compliance` review of the design.
6. Paste the G-D checklist (`aidlc/templates/gate-review.md`), ask `architect` to approve (and the founder for T2).
7. Plan the bolts: one line per bolt in the logical design (each ends in a mergeable PR). Update `aidlc/state.md`.
