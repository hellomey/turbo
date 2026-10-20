# Domain model: U-exams

Status: draft (G-D: architect; founder for T2 — eligibility correctness)

## Ubiquitous language
- **Exam**: a recruitment exam (`tnpsc-group-4`). Only `status = published` exams are ever shown (§26.2 rule 5).
- **Eligibility rule**: versioned data per exam (age-as-on date, min age, max age per community, relaxation years,
  accepted qualifications, degree subjects, PSTM note). Only the latest *published* version is used.
- **Eligibility Checker**: pure computation over profile answers + today's IST date (§17.1 steps 1-3, §19.1 Q1/Q4). Nothing stored.
- **Fit rank**: 1 = best fit.
- **Main exam / other exams**: the user's choice, main + up to 2 more (§17.1 step 4).

## Aggregates and entities
| Aggregate | Entities / value objects | Owning module | Table(s) |
|---|---|---|---|
| Exam | Exam, EligibilityRule (versioned) | exams | Exam, EligibilityRule |
| UserExamChoice | (userId, examCode, isMain) | exams | UserExamChoice |

## Invariants (each is a unit test: `packages/domain/test/modules/eligibility.spec.ts`, `exams.spec.ts`)
1. Under 18 on **today's Asia/Kolkata date** → `UNDER_18`; nothing is computed or stored.
2. Age = completed years on `rule.ageAsOf`; a birthday exactly on that date counts.
3. `age < minAge` → `AGE_TOO_LOW`. Max age = `maxAgeByCommunity[community]` (missing key → the `OC` value; `null` =
   no upper limit) + **the largest** relaxation among the user's special categories (relaxations do **not** add up;
   conservative, documented choice). `age > max` → `AGE_TOO_HIGH`.
4. Qualifications are ordered `sslc < hsc < iti < diploma < degree < pg` (contract `QUALIFICATIONS`). Eligible if the
   candidate's level ≥ the lowest level in `rule.qualifications` (empty → `exam.minQualification`).
5. Non-empty `degreeSubjects` + candidate degree/pg → case-insensitive match on `degreeSubject`, else `DEGREE_SUBJECT_REQUIRED`.
6. `pstm` + rule `pstmNote` → `PSTM_PREFERENCE` reason (information only, never changes eligibility).
7. Only published exams and published rules are used; an exam with no published rule is left out.
8. Ranking (both lists): full-prep launch exams first → smallest gap between the candidate's level and the exam's
   minimum level → larger age headroom (no limit = largest) → name.
9. `officialNotificationUrl = notificationUrl ?? officialUrl`; the result `disclaimer` contains `OFFICIAL_CONFIRM_LINE`.
10. My exams: main + ≤ 2 others, all distinct, main not repeated (`VALIDATION_FAILED`); each must be a published exam
    (`EXAM_NOT_FOUND`); choices are replaced atomically (one transaction).

## State machines
```
Exam / EligibilityRule: draft --human check (verifiedBy, verifiedAt)--> published --new version--> superseded
```
Phase 1 has no Desk editor. Seed data (local/staging only) is published with verifiedBy = null and marked SEED.

## Domain events
None in Phase 1 (`exams.notification_published` arrives with Exam Alerts).

## Rules that touch the money/game firewall (T2)
None. T2 here is eligibility correctness, not money.

## Open questions
- Q-E1: Central exams use OBC/SC/ST categories. The mapping from TN communities (BC/BCM/MBC_DNC → OBC?) is a content
  decision for Ops. The seed maps BC/BCM/MBC_DNC → OBC limits and SC/SCA → SC.
- Q-E2: Relaxations: max (chosen) vs sum. Some notifications allow combined relaxations (e.g. PwD + community).
  Ops to confirm per notification; the engine can switch with one line.
