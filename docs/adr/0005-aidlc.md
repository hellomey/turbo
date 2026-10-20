# ADR-0005: AIDLC is the development lifecycle

| | |
|---|---|
| Status | accepted |
| Date | 2026-10-20 |
| Deciders | founder, architect agent |
| Blueprint | §26 |

## Context
AI agents build HeyMey; the founder approves (§26). We need a repeatable lifecycle that keeps humans in control of
money, data and fairness, and keeps all context in the repo.

## Decision
Adopt the HeyMey **AI-Driven Development Lifecycle** in `aidlc/README.md`: Inception (intent → stories → units, gate G-I),
Construction (domain model + logical design, gate G-D; bolts ending in PRs, gate G-C), Operations (release, observe, gate G-O).
Risk tiers T0/T1/T2 scale the ceremony. Artefacts live in `aidlc/`; `aidlc/state.md` is the only status board.
Agent roles are defined in `.claude/agents/` and summarised in `AGENTS.md`. We do not use a spec-diff tool (e.g. OpenSpec).

## Consequences
Every PR traces to a blueprint section. Founder attention is spent on T2 gates, not on every line.
