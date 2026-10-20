# BOLT-0001: Phase 1 contract, schema, platform core

| | |
|---|---|
| Unit | U-contracts, U-platform-api, U-audit |
| Stories | INT-001-S07 (platform guarantees), enables S01–S06 |
| Risk tier | T2 |
| Agent | architect + conductor |
| Status | done |

## Plan
Contract-first for all of Phase 1 so identity, catalog and app tracks can build in parallel.

## Result
- `@heymey/contracts`: 23 routes (auth incl. Desk TOTP + delete-account, users, consents, exams, eligibility, my exams,
  study map, lessons, glossary), each with `auth` level, `idempotent` flag and rate limits. OpenAPI 3.1 regenerated;
  `dart/hm_api` regenerated (openapi-generator `dart`, no build_runner).
- Prisma: Phase 1 models for users (+UserProfile), auth (OtpCode purpose/lock, Session expiry/revocation, TwoFactor replay step),
  exams (Exam, EligibilityRule versioned, UserExamChoice), syllabus (Subject, Topic, TopicExamTag, TextbookRef, GlossaryTerm),
  content (Lesson). Migration `phase1_init` (+ pg_trgm, pgcrypto).
- API platform: `PlatformGuard` (contract lookup → auth level → rate limits in Valkey), `IdempotencyInterceptor` (Valkey,
  replay / conflict / in-progress), `DomainErrorFilter` (status map, Retry-After, request ids), `AppVersionInterceptor`,
  `InfraModule` (Prisma, Valkey, BullMQ job queue, clock), health with Postgres + Valkey checks, CORS.
- **Contract test** (`apps/api/test/contract.spec.ts`): fails if API and contract differ in either direction.
- Local env: `pnpm env:dev` writes a git-ignored `.env` (Ed25519 keys, pepper, TOTP key, local URLs on the port series).
- Test harness: `@heymey/testing` `startPostgres()` (migrations applied) + `startValkey()` via Testcontainers.
- `audit` module: reference implementation of the module pattern; unit + real-Postgres integration tests pass.
