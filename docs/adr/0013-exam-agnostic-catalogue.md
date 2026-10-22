# ADR-0013: Exam-agnostic catalogue (family → exam → stage → paper → section, marking schemes, attempt cycles)

| | |
|---|---|
| Status | proposed (architect, BOLT-0008); founder confirms at G-D (INT-002 Q26) |
| Date | 2026-10-22 |
| Deciders | architect agent; founder (D-2026-10-22-01) |
| Blueprint | §1a, §1 decision 3, §5.2, §22, §36, §42; INT-002 R1-R7 |

## Context
The founder widened scope to all Indian exams (TNPSC first, then SSC/Banking/Railways, CA, CS, UPSC). Phase 1's `Exam`
row carries one flat pattern (`patternMode`, `patternQuestions`, `patternMinutes`, `negativeMarking`), which cannot
express multi-stage exams, papers with different marking, sectional limits, qualifying-only papers, descriptive papers,
or attempts (sittings) with their own dates.

## Decision
All tables are owned by `exams` (`packages/db/prisma/schema/exams.prisma`), with relations only inside that file.
Entity names follow blueprint §22:

| Entity | Purpose |
|---|---|
| `ExamFamily` | TNPSC, SSC, UPSC, ICAI-CA, ICSI-CS … Holds Career Ladder titles (`rankTitles`, R6) and the rank scope label ("statewide" for TNPSC). |
| `Exam` | Existing row; gains nullable `familyId`. |
| `ExamStage` | Prelims / Mains / Interview; Foundation / Intermediate / Final. |
| `Paper` | `answerMode` (`objective_omr`, `objective_cbt`, `descriptive`), `contentLanguage` (R5), `qualifyingOnly`. |
| `MarkingScheme` | Versioned per paper: duration, total questions, status, source, verifier. |
| `PaperSection` | Per scheme: question count, optional "answer any N", marks per correct and penalty per wrong as **exact fractions** (`num/den`), optional sectional minutes. |
| `ExamAttemptCycle` | A sitting with its own stage dates (`stageDates` JSON). Plans and Final Stretch target the cycle (R2). `UserExamChoice.attemptCycleId` (nullable) records the user's choice. |

Rules:
- **Data, not code.** No module hard-codes an exam, marks or time (R1). Test fixture family `TEST-FAMILY` with a different
  scheme must run the Exam Hall end to end.
- **Human check.** Every row has `status`, `sourceUrl`, `verifiedBy`, `verifiedAt`. Seed rows are marked
  "SEED - verify against the official notification" and are never published to production without a human check
  (§26.2 rule 5). Agents never write real exam facts from memory.
- **Scoring is exact.** Fractions, never floats; a mock attempt stores the scheme version it used.
- **Descriptive papers** are a valid `answerMode` and question `kind` now; the Exam Hall refuses them with
  `PAPER_TYPE_NOT_SUPPORTED` until wave 2 (R4).
- **Migration (§42):** expand only. New tables + nullable columns. The Phase 1 flat pattern columns on `Exam` and the
  `ExamDetail.pattern` contract field stay (read by the app). Contract step (removing them) happens only after every
  live app reads `/v1/exams/{code}/structure` and the backfill has run: a later bolt, never in /v1 without a 6-month window.

## Consequences
New families need data and content, not code. More joins on catalogue reads (small, cached tables). `exam-hall`
depends on `exams` (ADR-0012). Eligibility rules for professional courses (registration, stage progression) are a
later rule shape, designed before wave 2.
