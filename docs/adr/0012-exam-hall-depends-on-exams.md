# ADR-0012: `exam-hall` depends on `exams` for papers and marking schemes

| | |
|---|---|
| Status | proposed (architect, BOLT-0008); founder confirms at G-D |
| Date | 2026-10-22 |
| Deciders | architect agent; founder |
| Blueprint | §1a, §10.6 Exam Hall, §19.4 Q36-Q37, §22, §34.8, §36; INT-002 R1, R4 |

## Context
The Exam Hall must score every mock with the official pattern: marks per question, negative marking, sections,
sectional time, qualifying-only papers and answer mode (OMR / CBT / descriptive). After D-2026-10-22-01 and ADR-0013
that shape is data owned by `exams` (Paper, PaperSection, MarkingScheme). `exam-hall` previously depended only on
`content`, `mastery` and `billing`.

Alternatives considered:
1. Copy the scheme into each `Mock` row. Rejected: two sources of truth for marking; a verified correction to a scheme
   would not reach new mocks.
2. Have the API composition root pass the scheme in on every call. Workable, but every exam-hall use case (start,
   resume, submit, rank job in the worker) would need the same plumbing, and the domain would be tested without the
   real lookup.

## Decision
- Add `exams` to `exam-hall`'s `dependsOn`. `exam-hall` calls only the `exams` public API
  (`paperForMock(paperId)` → paper + answer mode + published marking scheme by version). It never reads `exams` tables.
- A `MockAttempt` stores the `schemeVersion` it was scored with, so later scheme versions never rescore old attempts.
- No cycle: `exams` depends only on `syllabus`.
- `games` still never depends on `billing`/`marketplace` (unchanged).

## Consequences
`exams` must keep `paperForMock` stable. Scheme lookups are cached per process (schemes change rarely, are versioned).
