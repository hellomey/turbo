# BOLT-0003: Catalog — exams + eligibility engine, Study Map, lessons, glossary, seed

| | |
|---|---|
| Unit | U-exams, U-syllabus, U-content |
| Stories | INT-001-S01 (eligibility), INT-001-S04 (Study Map), INT-001-S05 (lessons) |
| Risk tier | T2 (eligibility correctness) |
| Agent | backend (catalog track) |
| Branch / PR | `bolt/BOLT-0003-catalog` · (not opened by the agent) |
| Status | in review (code complete, not committed; awaiting qa + founder review of seed eligibility data) |

## Plan
- Implement the BOLT-0001 contract routes: `GET /v1/exams`, `GET /v1/exams/{code}`, `POST /v1/eligibility/check`,
  `GET|PUT /v1/me/exams`, `GET /v1/exams/{code}/study-map`, `GET /v1/topics/{topicId}/lesson`, `GET /v1/glossary`.
- Modules: `exams` (eligibility engine, my exams), `syllabus` (Study Map, glossary, textbook refs), `content` (lessons).
- Seed (local/staging only): 5 exams + published SEED rules, syllabus YAML (6 subjects, stable ids), 4 original lessons, glossary.
- No contract or schema changes.
- Tests first: eligibility engine invariants, my-exams validation, study-map grouping, glossary query; integration on
  real Postgres; API e2e.

## Result
**What changed**
- `exams`: pure eligibility engine (`domain/eligibility.ts`), exam mapping/order (`domain/exam.ts`), my-exams validation
  (`domain/my-exams.ts`), use cases (catalog, check-eligibility with IST clock, my exams), `PrismaExamsRepository`
  (latest *published* rule per exam; malformed rule JSON → rule not used; choices replaced in one `$transaction`).
- `syllabus`: `buildStudyMap` (pure grouping, shared lamps filtered to published exams, unlit ring), glossary query
  building, `getStudyMap` taking `StudyMapPorts` (syllabus stays a leaf), `PrismaSyllabusRepository`.
- `content`: `latestPublished`, `getLesson` (textbook refs via the syllabus public API), `PrismaLessonRepository`.
- API: `ExamsController`, `SyllabusController` (composes exams + content into the Study Map), `ContentController`;
  http modules provide `EXAMS_API`, `SYLLABUS_API`, `CONTENT_API`. `POST /v1/eligibility/check` and `PUT /v1/me/exams` → 200.
- Seed `packages/db/prisma/seed/catalog.ts` (refuses `HEYMEY_ENV=production`, upserts only) + `content/syllabus/tnpsc-group-4.yaml`
  (6 subjects, 25 topics, stable hand-written UUIDv7-shaped ids, `shared_with`, textbook refs marked "to be verified").
- Design: `construction/units/U-exams|U-syllabus|U-content/{domain-model,logical-design}.md`.

**Evidence (local, 2026-10-20)**
- Domain unit: eligibility 75, exams 14, syllabus 9, content 4 (package total 161 incl. other tracks) — green.
- Domain integration (real Postgres): exams.int 4, syllabus.int 7 (seeder twice idempotent, refuses production) — package total 20 green.
- API integration `test/integration/catalog.spec.ts`: 14 green. API unit (contract test) 3 green.
- `pnpm firewall:check` green; `pnpm --filter @heymey/db seed` ok (run several times); `pnpm --filter @heymey/db lint` ok.
- `pnpm boundaries`: 1 violation NOT from this bolt: `packages/testing/src/index.ts → containers.ts` matches
  `no-test-code-in-production` (the rule does not exempt the testing package itself). Owner: devops/architect.

**Deviations**
- `PUT /v1/me/exams` happy path is tested at domain-integration level; over HTTP only the 401 is tested, because the
  token verifier was a reject-all placeholder when the test was written (identity track, BOLT-0002).
- Relaxations: the largest single relaxation applies (not the sum). Missing community key → OC limit (never "no limit").

**Follow-ups**
- Content track B: verify textbook chapters/pages, replace seed rules with human-checked notification data.
- Add an HTTP happy-path test for `PUT /v1/me/exams` once auth issues real tokens.
- Open questions Q-E1 (TN community → central category mapping), Q-E2 (max vs sum relaxations) in U-exams domain model.
