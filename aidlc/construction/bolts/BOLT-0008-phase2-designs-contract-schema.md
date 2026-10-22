# BOLT-0008: Phase 2 unit designs, contract and Prisma schema (exam-agnostic)

| | |
|---|---|
| Unit | U-mastery, U-practice, U-exam-hall, U-plan, U-readiness, U-notifications, U-exams (ext), U-app-shell (ext), Contracts/schema |
| Stories | INT-002-S01 … S20 (design only), R1–R7 |
| Risk tier | T1 (migration rules); S07/S10 copy and S17 alerts are T2 at their bolts |
| Agent | architect |
| Branch / PR | `bolt/BOLT-0008-phase2-designs` · not committed (founder instruction: no commits) |
| Status | in review (awaiting G-D; all numbers PROVISIONAL, founder to confirm) |

## Plan
- Design every Phase 2 backend unit (+ U-exams and U-app-shell extensions) with the `aidlc-design` skill.
- Exam-agnostic catalogue per D-2026-10-22-01 and blueprint §1a/§22 entity names (ADR-0013).
- Provisional defaults for INT-002 Q1–Q27 in versioned configs + `aidlc/decisions.md` (D-2026-10-22-10 … -35).
- Contract first: all Phase 2 routes with auth / idempotent / rateLimit; new error codes only; codegen.
- Prisma: one file per owning module; one expand-only migration.

## Result

**What changed**
- ADRs: `docs/adr/0012-exam-hall-depends-on-exams.md` (the only new module dependency), `docs/adr/0013-exam-agnostic-catalogue.md`.
- Contract (`packages/contracts/src`): new `http/questions.ts`, `mastery.ts`, `practice.ts`, `exam-hall.ts`, `plan.ts`,
  `readiness.ts`, `notifications.ts`, `sync.ts`, `routes-study.ts` (45 routes); `exams.ts` extended (catalogue
  structure, attempt cycles, Exam Alerts, changedetection webhook, Desk review; `UserExamsBody.attemptCycles` optional);
  22 new error codes (none renamed). OpenAPI + `dart/hm_api` regenerated (`dart analyze`: 0 errors).
- Prisma: `exams` (ExamFamily, ExamStage, Paper, MarkingScheme, PaperSection, ExamAttemptCycle, ExamWatchChange,
  ExamAlert; `Exam.familyId`, `UserExamChoice.attemptCycleId`), `content` (Question, QuestionVersion, Source, Correction,
  QuestionReport, ContentPack), `syllabus` (`TopicExamTag.priority`), `mastery` (UserTopicState columns, TopicCheck,
  RingEvent, UserRank), `practice`, `exam-hall`, `plan`, `readiness`, `notifications`. Migration
  `20261022061048_phase2_core_study`: additive only (0 DROP / ALTER COLUMN), applied to local Postgres.
- `module.json`: `exam-hall.dependsOn += exams`; `owns` lists updated for exams, content, mastery, practice, exam-hall,
  plan, readiness. `docs/architecture/modules.md` regenerated.
- Versioned configs (pure data, no logic): `packages/domain/src/modules/{mastery,practice,exam-hall,plan,readiness,notifications}/domain/config.ts`.
  (Domain paths are backend-owned; created on the conductor's explicit instruction. Backend owns them from BOLT-0009.)
- Designs: `aidlc/construction/units/U-{mastery,practice,exam-hall,plan,readiness,notifications}/{domain-model,logical-design}.md`;
  Phase 2 sections appended to `U-exams/*` and `U-app-shell/*`.

**Routes per backend bolt** (the contract test lists these as missing until each lands)
- BOLT-0009 mastery (7): `GET /v1/me/mastery`, `GET /v1/me/topic-states`, `GET /v1/me/relight-queue`,
  `POST /v1/topics/{topicId}/lesson-complete`, `POST /v1/topics/{topicId}/checks`, `POST /v1/checks/{checkId}/submit`,
  `POST /v1/sync/study-actions` (dispatcher; practice/plan actions plug in at 0010/0012).
- BOLT-0010 practice + content (9): `POST /v1/practice/sessions`, `POST /v1/practice/sessions/{sessionId}/answers`,
  `GET /v1/me/practice/usage`, `GET /v1/me/mistakes`, `GET /v1/me/drills`, `GET /v1/pyq`, `GET /v1/pyq/facets`,
  `POST /v1/questions/{questionId}/reports`, `GET /v1/content/packs`.
- BOLT-0011 exam-hall + catalogue (10): `GET /v1/exams/{code}/structure`, `GET /v1/mocks`, `POST /v1/mocks/{mockId}/attempts`,
  `GET /v1/mock-attempts/{attemptId}`, `PUT /v1/mock-attempts/{attemptId}/answers`, `POST /v1/mock-attempts/{attemptId}/submit`,
  `GET /v1/mock-attempts/{attemptId}/report`, `GET /v1/me/mock-attempts`, `GET /v1/state-mock-sunday`, `GET /v1/mocks/{mockId}/statewide-rank`.
- BOLT-0012 plan (6): `GET /v1/me/today`, `GET /v1/me/plan`, `PUT /v1/me/plan`, `GET /v1/me/plan/days`,
  `POST /v1/me/plan/items/{itemId}/status`, `POST /v1/me/plan/rebalance` (+ `attemptCycles` in `PUT /v1/me/exams`).
- BOLT-0013 readiness (4): `GET /v1/me/readiness`, `GET /v1/me/readiness/trend`, `GET /v1/me/sunday-reports`, `GET /v1/me/sunday-reports/{reportId}`.
- BOLT-0014 notifications + exams alerts (9): `POST /v1/me/push-tokens`, `DELETE /v1/me/push-tokens/{deviceId}`,
  `GET /v1/me/alert-settings`, `PUT /v1/me/alert-settings`, `GET /v1/me/exam-alerts`, `POST /v1/webhooks/changedetection`,
  `GET /v1/desk/exam-changes`, `POST /v1/desk/exam-changes/{changeId}/approve`, `POST /v1/desk/exam-changes/{changeId}/reject`.
  BOLT-0014 also adds `/v1/webhooks/changedetection` to the idempotency allow-list in `apps/api/test/contract.spec.ts`
  (machine caller, deduped by `(watchUuid, changeId)`).

**Evidence (local, 2026-10-22)**
- `pnpm verify`: ports, docs, firewall (9 permanent tests), boundaries (0 violations) green; turbo 34/37 then stop on
  `@heymey/api#test`. With `--continue`: 38/39 green, only `@heymey/api#test` red: `contract.spec.ts` 2 of 3 failing —
  "every contract route is implemented" (the 45 routes above) and "only read-only POSTs opt out" (webhook). Expected.
- `prisma validate` + `format --check` green; `dart analyze dart/hm_api`: 0 errors.

**Deviations / notes for the next bolts**
- `apps/api` `DomainErrorFilter` status map needs the 22 new codes (each owning bolt adds its codes).
- `apps/worker/src/queues/registry.ts`: new/changed schedules listed in each logical design (owner bolt + devops).
- Enum `DateStatus` created but unused (stage dates are JSON on `ExamAttemptCycle`); harmless, kept for the cycle API.
- Phase 1 flat pattern columns on `Exam` and `ExamDetail.pattern` stay until a later contract step (ADR-0013).
- Study Rooms / `focus` module deliberately not added (Phase 3, per conductor).

**Follow-ups**
- Founder: confirm D-2026-10-22-10 … -35; D-…-33 Firebase/APNs accounts (founder action); G-D approval; ADR-0012/0013.
- security: review S17 webhook + Desk approval design (U-exams ext). compliance: limit sheet (S07), blurred report (S10).
- Track B: verified patterns for Group 4 / 2 / 2A before any production mock.
