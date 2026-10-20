# AGENTS.md: apps/api (NestJS HTTP API, port 4567)

Owner: `backend`. Root rules in `/AGENTS.md` apply.

- Composition root only. Business rules live in `@heymey/domain`; this app wires them to HTTP.
- Routes must match `@heymey/contracts` `routes` exactly. Change the contract first, then `pnpm codegen`.
- Layout: `src/platform/` (cross-cutting: errors, idempotency, app-version, auth/role guards, rate limits),
  `src/http/<module>/` (one controller + Nest module per business module, see `src/http/README.md`).
- Every route declares its guard (`@Public()` explicitly for public ones). Desk routes: `/v1/desk/...` + Desk session (TOTP) + role.
- Errors: throw `DomainError(code)`; `DomainErrorFilter` maps it to the envelope. Never return raw exceptions.
- Webhooks (`/v1/billing/*`) verify signatures and use the store transaction id as the idempotency key.
- Port from `PORTS.API` (`@heymey/config`), overridable by `PORT` env. Never hard-code.
- Tests: `test/*.spec.ts` (Vitest + SWC). Integration: `test/integration/` with Testcontainers (`pnpm test:integration`).
