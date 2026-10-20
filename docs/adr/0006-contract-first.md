# ADR-0006: Contract-first: Zod → OpenAPI 3.1 → Dart client

| | |
|---|---|
| Status | accepted |
| Date | 2026-10-20 |
| Deciders | founder, architect agent |
| Blueprint | §20.1, §20.2, §34.4, §37 |

## Context
"The OpenAPI spec is generated from the backend, and the Dart client is generated from that spec" (§34.4).

## Decision
`@heymey/contracts` holds the Zod schemas **and** the route list (`routes.ts`) plus socket event types. `pnpm codegen` writes
`openapi/openapi.json` (zod-to-openapi) and regenerates the whole `dart/hm_api` package (openapi-generator `dart-dio` via Docker).
The API validates with the same schemas (nestjs-zod). CI regenerates both and fails on any diff. Error codes are stable strings.

## Consequences
A route cannot exist in the app without existing in the contract first. Contract changes are reviewed by `architect`.
