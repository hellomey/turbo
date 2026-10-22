# INT-006: Multi-exam expansion (exam families and waves)

| | |
|---|---|
| Status | **draft** (spec written 2026-10-22; architect to decompose; waves are post-launch except S01–S03, which land in Phase 2) |
| Blueprint | §1 decisions 1, 3, 16, 17; §1a (new); §2; §5.1; §5.2; §9.9; §10.6 Exam Hall; §11; §17.1 steps 1–4; §18; §19.1; §19.3 Q22/Q24; §19.4 Q35–Q37; §19.10 Q94/Q97; §22; §26.2 rule 5; §27; §36 `exams`, `syllabus`; §43 |
| Decision | D-2026-10-22-01 (founder) |
| Risk tier | **T1** for the catalogue/model work. **T2** for: eligibility rules for new families (official-data correctness, §18), the under-18 question (personal data, DPDP §30), Exam Pass validity per attempt cycle (money, §12), any new price or store text |
| Owner (conductor) | conductor |
| Founder approval (G-I) | _pending_ |

## Why
Founder: "we are not only doing this for TNPSC, we are doing this for all exams, even for UPSC, CA and CS exams."
The long-preparation loop (§2: lamps, Relight, squads, readiness) is not specific to Tamil Nadu. CA and CS students often
prepare alone for years. The launch stays on the Tamil Nadu wedge (§1 decision 16) so the 2 Dec 2026 launch target is
not put at risk; what changes now is that the product is **built exam-agnostic** so each new family is data + content.

## Scope
- **In (Phase 2, no launch risk):** exam-family data model (family → exam → stage → paper → section, marking scheme,
  answer mode, content language, attempt cycle) in `exams`/`syllabus`; Phase 2 modules read exam shape as data
  (see INT-002 "Exam-agnostic build rules"); onboarding questions driven by the family; per-paper content-language rule.
- **In (post-launch, one wave at a time):** wave 1 SSC / Banking / Railways; wave 2 CA (ICAI) + CS (ICSI) incl. the
  descriptive paper type; wave 3 UPSC CSE (§1a). Each wave becomes its own child intent with Track B content.
- **Out:** content for any new family before launch; any new interface language (§1 decision 3); writing exam facts for
  UPSC/CA/CS into the product without an official source. **All syllabus and pattern details for UPSC, CA and CS are
  "to verify from official source (upsc.gov.in, icai.org, icsi.edu)".**

## Stories

### INT-006-S01: Exam families in the catalogue — T1
As Ops, I want to enter an exam family with its exams, stages, papers and sections as data, so that a new family needs no code change. [§1 decision 17, §1a, §22, §36 `exams`]

**Acceptance criteria**
- Given a new family with exams, stages, papers and sections, When Ops saves it as draft, Then it is stored and invisible to aspirants.
- Given a draft family without an official source link on every exam and paper, When Ops tries to publish, Then publishing is refused with a stable error code. [§26.2 rule 5, §18 wrong-data row]
- Given a published family, When the app loads the catalogue, Then the family, its exams, stages and papers are returned with no family-specific code path (test: a fixture family "TEST-FAMILY" renders the Study Map and an exam page).
- Given the TNPSC seed, When migrated to the new model, Then Group 4 and Group 2/2A appear as exams under family TNPSC with the same subjects and topics as before (no lamp ids change).

### INT-006-S02: Marking scheme and answer mode as data — T1
As an aspirant, I want every mock and paper to use its own official marking and timing, so that practice matches my exam. [§10.6 Exam Hall, §19.4 Q36–Q37, §1a]

**Acceptance criteria**
- Given a paper with marks per question, negative marking (or none), qualifying-only flag and time, When a mock on that paper is scored on the server, Then the score uses only that paper's scheme (test: two fixture papers with different schemes score the same answers differently).
- Given a paper whose answer mode is `descriptive`, When an aspirant opens a mock for it, Then the server refuses with a stable error code until the descriptive mode exists (Q4), and the app shows "Coming soon" with no dead button.
- Given a qualifying-only paper, Then its marks are shown but not added to the merit total.

### INT-006-S03: Attempt cycles — T1 (T2 for Exam Pass validity)
As an aspirant, I want to choose the attempt (sitting) I am preparing for, so that my plan, Final Stretch and countdowns use its dates. [§1a, §12 Exam Pass, §17.3, §19.10 Q94, Q97]

**Acceptance criteria**
- Given an exam with more than one attempt cycle, When I pick one in onboarding step 4, Then My Plan and Final Stretch use that cycle's stage dates.
- Given a multi-stage exam, Then each stage has its own date and the plan targets the next stage.
- Given an attempt cycle's date changes, Then the plan stretches or shrinks and the change is logged with its official source. [§19.10 Q97]
- Given I move to a later attempt, Then my lamps stay and a new season starts on the same map. [§17.3, §19.10 Q99]
- Exam Pass "until 30 days after that exam" maps to which date for multi-stage exams: **Q7** (T2, price/offer).

### INT-006-S04: Onboarding by family — T1 (T2 for eligibility data)
As a new user, I want onboarding to ask only what my exam family needs, so that a CA student is not asked about TN community categories. [§17.1 steps 2–4, §19.1 Q1]

**Acceptance criteria**
- Given I choose a family that does not use community categories or PSTM, Then step 2 does not ask them and nothing is stored for them (data minimisation, §23).
- Given the TNPSC family, Then step 2 is unchanged.
- Given a family whose eligibility rules are not yet published, Then the Eligibility Checker says so plainly and links to the official site; it never guesses.
- Whether the first screen asks "Which exam family?" before date of birth: **Q8**.

### INT-006-S05: Content language per paper — T1
As an aspirant, I want study content in the language my paper is tested in, with an English interface everywhere. [§1 decision 3, §10.4, §19.3 Q24, §19.4 Q35]

**Acceptance criteria**
- Given a paper with content language Tamil, Then its questions and lessons render in Tamil with Noto Sans Tamil, and every button, label and error is English.
- Given any other paper in v1, Then content is English.
- Given any interface string, Then it contains no Tamil or other Indian-language script (test scans the ARB/strings files). 

### INT-006-S06: Family-scoped events, ranks and titles — T1
As an aspirant in a non-TN family, I want events, mock ranks and rank titles that fit my exam. [§5.2, §9.6, §9.9, §1a TN-only table]

**Acceptance criteria**
- Given an event tagged with family TNPSC, Then only TNPSC-family aspirants see it.
- Given a mock day for any family, Then the rank is "among HeyMey takers of this exam", never "statewide" unless the family is a state family.
- Given a family without a configured Career Ladder title set, Then the app uses the titles in **Q5** (blocked until answered).

### INT-006-S07: Wave readiness gate — T1
As the founder, I want a wave to open only when its official facts are verified and its content is reviewed, so that we never publish wrong exam data. [§26.2 rule 5, §18, §1a]

**Acceptance criteria**
- Given a wave's family, When any exam, paper or marking scheme lacks a verified official source (upsc.gov.in, icai.org, icsi.edu, or the official notification), Then the family cannot be published.
- Given a wave opens, Then Exam Alerts for that family use the same human-checked pipeline (INT-002-S17).

### INT-006-S08 (wave 2): Descriptive paper practice — T1/T2 (if AI feedback)
As a CA/CS/UPSC Mains aspirant, I want to practise written answers and get honest feedback. [§1a, §20.4]
- **Not specified.** Mode (self-check against a model answer, peer, mentor, AI feedback), Exam Hall look, and how
  descriptive work moves rings are **Q4**. No acceptance criteria until answered. AI feedback must send no personal data (§20.4).

**Non-functional (all stories):** performance §24 (catalogue reads p95 ≤ 300 ms, cached); offline §39 (exam catalogue
and packs per paper); accessibility §10.9; security §23 (Ops-only writes, audit log); copy §10.2 (simple English; exam
terms in the glossary); no Dark Patterns (§13) in any new-family offer.

## Units (proposed, architect to confirm)
| Unit | Modules / features | Tier | Owning agent | Depends on |
|---|---|---|---|---|
| U-exams (family model) | `packages/domain/src/modules/exams`, `packages/db/prisma` (exams schema) | T1 / T2 eligibility | architect (schema, ADR) + backend | INT-001 U-exams |
| U-syllabus (paper tags) | `modules/syllabus` (TopicExamTag → exam/stage/paper) | T1 | backend | U-exams |
| U-exam-hall (scheme as data) | `modules/exam-hall` | T1 (90%) | backend | U-exams; done inside INT-002 |
| U-plan (attempt cycles) | `modules/plan` | T1 | backend | U-exams; done inside INT-002 |
| U-app-onboarding (family) | `dart/hm_features/lib/src/onboarding` | T1 | flutter-ui | U-exams |
| Content per wave | `content/**` | T1 | content-writer + content-verifier | official sources |

## Success metrics (Operations)
- Adding a fixture family in staging needs zero code changes (catalogue, map, mock, plan work).
- Per wave (after launch): Day-7 retention of the new family ≥ the TN launch month (§29); content errors fixed within 72 h ≥ 90%.

## Open questions (founder)
- [ ] Q1: Confirm the wave order in §1a (1 SSC/Banking/Railways, 2 CA + CS, 3 UPSC). Should CA/CS move to wave 1 because of the pain point, given they need the descriptive paper type?
- [ ] Q2: Is any **TN-relevant SSC exam** meant to have full content **at launch**? The blueprint's launch content is TNPSC Group 4 and 2/2A only (§1 decision 16); adding SSC content would add to Track B before launch. Proposed: no, alerts + eligibility only at launch.
- [ ] Q3: **Under 18.** HeyMey is 18+ (§17.1, §18, §30). CA Foundation and CSEET aspirants can be under 18 (eligibility ages **to verify from icai.org / icsi.edu**). Keep 18+ (and lose them), or support under-18 with verifiable parental consent under DPDP (legal opinion needed)? T2.
- [ ] Q4: **Descriptive papers** (CA/CS, UPSC Mains): how are they practised and checked (model answer + self-check, peer review in squads, mentor review, AI feedback)? How do they move Steady/Gold? Does the Exam Hall offer a written-answer mode (typed? photo of handwriting?)?
- [ ] Q5: Career Ladder titles for non-TN families (TN titles are TN government posts). One neutral ladder for all, or one per family? Note §5.2 "game title, not an official designation".
- [ ] Q6: District Quest is a TN board. Other families: other boards (e.g. an India map), or no board game?
- [ ] Q7: Exam Pass for multi-stage, multi-attempt exams: valid until 30 days after which date (the stage, the final stage, the attempt)? (Price/offer: founder approval.)
- [ ] Q8: Onboarding: ask the exam family first, or keep date of birth first (§17.1 step 1) for everyone?
- [ ] Q9: "State Board textbook map" for other families: NCERT for UPSC; ICAI/ICSI study material for CA/CS. Can we link or map institute material (copyright, **to verify** with the lawyer, §30)?
- [ ] Q10: Content language for other families: English only in v1 for all of them (proposed), or Hindi-medium content for central exams later?
- [ ] Q11: Do pricing (₹149/₹999, Exam Pass ₹399) stay the same for CA/CS/UPSC, or does each family get its own price? (Founder approves prices.)
- [ ] Q12: Do month-1 targets (§14) and §29 metrics stay TN-only for launch? Proposed: yes; new targets per wave.

## Outcome (filled at G-O)
