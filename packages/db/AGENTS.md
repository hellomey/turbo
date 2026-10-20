# AGENTS.md: packages/db (Prisma 7)

Owner: `architect` (schema), module owners propose changes in their unit's logical design. Root rules apply.

- One `.prisma` file per owning module in `prisma/schema/`. `_base.prisma` = generator + datasource; `_platform.prisma` = idempotency + sync receipts.
- **No Prisma relations across module files.** Reference other modules' rows by id (`userId String @db.Uuid`).
- Ledgers (`SparksLedger`, `PointsLedger`, `TrophyLedger`) and `AuditLog` are append-only. Money is integer (paise / Sparks).
- Migrations: expand → migrate → contract; never break the live app version (§42). Raw SQL migrations for extensions and partitions.
- `pnpm --filter @heymey/db codegen` regenerates the client into `src/generated/` (git-ignored). `lint` = validate + format check.
- Local DB: `pnpm infra:up` → Postgres on 127.0.0.1:4580.
