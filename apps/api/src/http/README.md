# HTTP adapters

One folder per business module, created in that module's Construction bolt:

```
src/http/<module>/
├─ <module>.controller.ts    Routes. Must match @heymey/contracts `routes` exactly (path, method, schemas).
├─ <module>.http-module.ts   Nest module: binds domain use cases + infrastructure adapters.
└─ <module>.controller.spec.ts
```

Rules:
- Controllers are thin: parse with the contract's Zod schema (nestjs-zod), call ONE use case, return.
- No business rules here. Rules live in `packages/domain/src/modules/<module>/domain`.
- Import a module only via `@heymey/domain/modules/<module>` (dependency-cruiser enforces it).
- Every route declares its role guard explicitly, even public ones (`@Public()`).
- Desk-only routes live under `/v1/desk/...` and require a Desk session (TOTP) + role.
- Admin/Ops routes additionally require the protected access layer (Caddy only routes them from the ops allowlist).
