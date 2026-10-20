# AGENTS.md: packages/contracts (THE contract)

Owner: `architect`. Root rules apply.

- Every HTTP route (`src/http/routes.ts`) and socket event (`src/socket/events.ts`) is defined here first, with Zod schemas.
- `pnpm codegen` → `openapi/openapi.json` (OpenAPI 3.1) → `dart/hm_api` (generated Dart client). CI fails if either is stale.
- /v1 is never broken: add optional fields and new routes; breaking changes go to /v2 with 6 months of /v1 support (§37).
- Error codes in `src/errors.ts` are stable: add, never rename or reuse. Messages are simple English the app may show directly.
- Timestamps are UTC ISO-8601 strings on the wire.
