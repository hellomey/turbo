# HeyMey AIDLC: the AI-Driven Development Lifecycle

HeyMey is built by AI agents, with the founder as product owner (blueprint §1 decision 7, §26).
This folder is the operating system for that work. It defines **how an idea in the blueprint becomes
running, verified software**, who (which agent, or the founder) does each step, and where every
decision is written down.

> Every agent reads this file before doing anything that changes the repo.
> `docs/HEYMEY_PRODUCT_BLUEPRINT.md` says **what** to build. This file says **how** we build it.

---

## 1. Principles

1. **The blueprint is the spec.** If a task conflicts with it, or the blueprint is silent on something that
   matters, **stop and ask the founder** (§26.2 rule 1). Never guess on money, personal data, game fairness or legal text.
2. **AI proposes, the founder approves.** Agents do the work and write the artefacts. The founder approves at
   gates. Approval is recorded in the repo, never implied.
3. **Context lives in the repo, not in chat.** Every intent, design, decision and bolt result is a file here.
   A new agent session must be able to continue from the files alone.
4. **Design before code, contract before implementation, tests before merge.** Domain model → logical design →
   contract (Zod/OpenAPI) → failing tests → code → green gates.
5. **Small, traceable steps.** Work moves in **bolts**: short cycles (hours, at most a day) that end in a
   verified, mergeable change. Every bolt traces back to a blueprint section.
6. **Risk sets the ceremony.** A docs fix and a change to the Sparks ledger do not get the same process (§5).
7. **Quality gates are code.** If a rule can be checked by a machine (ports, boundaries, firewall, contract
   drift, coverage), it is checked in CI, not in a reviewer's memory.

---

## 2. Vocabulary

| Term | Meaning | ID format | Lives in |
|---|---|---|---|
| **Intent** | A goal worth building, taken from the blueprint ("Email OTP login", "Week 2: core study"). | `INT-001` | `inception/intents/` |
| **Story** | A user-visible behaviour with acceptance criteria (Given/When/Then), inside an intent. | `INT-001-S03` | inside the intent file |
| **Unit (of work)** | A cohesive, separately testable slice that one agent team can build. Usually one backend module and/or one app feature. | `U-auth`, `U-app-onboarding` | `inception/units.md`, `construction/units/<unit>/` |
| **Bolt** | One short build cycle on one unit: plan → build → verify → record. Ends in a PR. | `BOLT-0001` | `construction/bolts/` |
| **Gate** | A checkpoint where evidence is reviewed and the founder (or a reviewer agent) approves. | `G-I`, `G-D`, `G-C`, `G-O` | recorded in the artefact being approved |
| **ADR** | A lasting architecture decision. | `ADR-0011` | `docs/adr/` |
| **Decision log** | Small decisions and answers to open questions, append-only. | `D-2026-10-20-01` | `decisions.md` |

Traceability chain (every PR description carries it):

```
Blueprint §  ->  INT-xxx  ->  INT-xxx-Sxx  ->  U-<unit>  ->  BOLT-xxxx  ->  PR  ->  tests (incl. FW-xxx)
```

---

## 3. The lifecycle

```
            ┌──────────────── INCEPTION ────────────────┐   ┌──────────── CONSTRUCTION ─────────────┐   ┌──── OPERATIONS ────┐
 blueprint ─► 1 Capture ─► 2 Elaborate ─► 3 Decompose ─► G-I ─► 4 Design ─► G-D ─► 5 Bolts (repeat) ─► G-C ─► 6 Release ─► 7 Observe ─► G-O
   §           intent       stories +      units +             domain model   contract,        DoD +          staging ->     dashboards,
                            criteria       risk tier            + logical      tests, code      approvals      production     feedback ─┐
                                                                design                                                                   │
                ▲                                                                                                                        │
                └──────────────────────── new intents from incidents, corrections, metrics ─────────────────────────────────────────────┘
```

### Phase 1: INCEPTION (what and why)

| Step | Who | Output | Template |
|---|---|---|---|
| 1. **Capture** the intent from a blueprint section or a founder request | `conductor` | `inception/intents/INT-xxx-<slug>.md` with status `draft` | `templates/intent.md` |
| 2. **Elaborate**: stories with Given/When/Then acceptance criteria, each citing blueprint §; NFRs (performance §24, security §23, accessibility §10.9, offline §39); open questions | `spec` | Stories inside the intent file | `templates/intent.md` |
| 3. **Decompose** into units, set dependencies, assign the **risk tier** (§5), name owning agents | `architect` | Rows in `inception/units.md`; the intent's unit table | `templates/unit.md` |
| **Gate G-I** | **Founder** | Intent status → `approved`. Open questions answered in `decisions.md`. | `templates/gate-review.md` |

Inception can be done as **mob elaboration**: the conductor drafts, then the founder and agents iterate on the
file in one session until open questions are closed. Questions go in the file, answers go in `decisions.md`.

### Phase 2: CONSTRUCTION (how, then build)

**4. Design** (once per unit, updated when the unit changes):

| Artefact | Who | What it fixes |
|---|---|---|
| `construction/units/<unit>/domain-model.md` | `architect` + owning agent | Entities, value objects, invariants, state machines (e.g. lamp rings), domain events, which module owns which table |
| `construction/units/<unit>/logical-design.md` | owning agent | Use cases, ports/adapters, API routes + socket events (as contract diffs), migrations (expand → migrate → contract), queues, flags, failure modes, NFR budget, test plan (incl. new FW-xxx tests if money/games are touched) |

**Gate G-D**: `architect` approves every unit. **Founder** also approves T2 units (money, personal data, games, auth, legal text).

**5. Bolts** (repeat until the unit is done). One bolt = one PR:

```
 a. Plan     construction/bolts/BOLT-xxxx.md: goal, stories covered, files/modules touched, risk tier, test list
 b. Contract change @heymey/contracts first (routes / schemas / socket events) -> pnpm codegen (OpenAPI + hm_api)
 c. Tests    write the failing tests for the acceptance criteria (domain unit -> integration -> widget/golden)
 d. Build    implement in the owning module/feature only; respect module.json boundaries
 e. Verify   pnpm verify (ports, firewall, boundaries, lint, typecheck, tests) + flutter analyze/test
 f. Review   reviewer agents per risk tier (qa, security, compliance) comment on the PR
 g. Record   fill the bolt's "Result" section: what changed, evidence, follow-ups, new decisions
```

**Gate G-C** (per PR): CI green + reviewer agents approve + the **Definition of Done** (blueprint §45) checklist is
ticked in the PR. **Founder** approves the merge to `main` (§26.2 rule 4) and must approve any T2 change.

### Phase 3: OPERATIONS (run, observe, learn)

| Step | Who | Output |
|---|---|---|
| 6. **Release**: main → staging (automatic) → smoke + k6 quick test → **Promote** (founder) → production rolling deploy with auto-rollback | `devops` | Release notes in simple English, `docs/runbooks/release.md` followed |
| 7. **Observe**: Grafana / GlitchTip / Uptime Kuma / Metabase against the intent's success metrics (§29) and budgets (§24) | `devops`, `qa` | Notes in the intent's "Outcome" section |
| **Gate G-O** | **Founder** | Intent status → `done`, or new intents for gaps |
| Feedback | anyone | Incidents (`templates/incident.md`), content corrections, metric misses → new intents |

---

## 4. Agents and responsibilities

The roster mirrors blueprint §26.1. Definitions (prompts, tools, owned paths) live in `.claude/agents/*.md`;
`AGENTS.md` at the repo root has the summary table. The **conductor** runs the lifecycle: it reads `state.md`,
picks the next step, delegates to the specialist agent, and updates the board. Specialists never skip a gate.

---

## 5. Risk tiers

| Tier | What | Ceremony |
|---|---|---|
| **T0** | Docs, comments, test-only additions, dev tooling | One bolt, CI green, any reviewer agent. No design artefacts. |
| **T1** | Normal product features, UI, content serving, infra tuning | Full lifecycle. `qa` review. Founder approves merge to main. |
| **T2** | **Money** (economy, billing, marketplace, prices, payouts), **personal data** (auth, users, deletion/export, consent), **game fairness** (games, odds, leagues), **security** (roles, Desk access, secrets), **legal / offer / paywall text**, **migrations that touch these tables** | Full lifecycle + `security` and `compliance` reviews + **founder approval at G-D and G-C**. Firewall tests must be extended, never weakened. Coverage ≥ 90%. |

When unsure, use the higher tier.

---

## 6. Stop-and-ask triggers

An agent **stops, writes the question in the artefact, and asks the founder** when:

- the blueprint and the task disagree, or the blueprint is silent on a user-visible or money/data/fairness behaviour;
- a change would weaken a firewall rule, remove/skip a test in `packages/domain/test/firewall/`, or add any path where money touches a game;
- a migration is not backward compatible with the live app version;
- a price, offer text, paywall, odds table, legal text, or store listing would change;
- a new third-party service, paid dependency, or a non-open-source component would be added (§1 decision 5);
- personal data would leave the server (including to an AI model) or a new kind of personal data would be collected;
- a module needs a new dependency in `module.json` (that needs an ADR);
- a port, domain, or public URL would change.

---

## 7. Files in this folder

```
aidlc/
├─ README.md                  this lifecycle (read first)
├─ state.md                   THE status board: every intent, unit and active bolt, with phase and owner
├─ decisions.md               append-only decision log + open questions for the founder
├─ inception/
│  ├─ intents/INT-xxx-*.md    one file per intent (stories, units, gates, outcome)
│  └─ units.md                every unit, its module(s), dependencies, tier and owning agent
├─ construction/
│  ├─ units/<unit>/           domain-model.md, logical-design.md (created at step 4)
│  └─ bolts/BOLT-xxxx.md      one file per bolt (plan + result)
├─ operations/
│  ├─ README.md               release / observe / incident loop
│  └─ incidents/              INC-xxxx.md
└─ templates/                 intent, unit, domain-model, logical-design, bolt, gate-review, incident, adr
```

**Updating `state.md` is part of every step.** If it isn't on the board, it isn't happening.
