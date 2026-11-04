import { existsSync } from "node:fs";
import { defineConfig } from "prisma/config";

// Prisma 7 does not read .env files itself. Locally, `pnpm db:migrate` / `pnpm db:seed` run from packages/db,
// so load the repo-root .env written by `pnpm env:dev` (BOLT-0005). An explicit URL in the environment
// (CI, the migrator container in deploy.sh) always wins; a missing .env is fine.
const rootEnv = new URL("../../.env", import.meta.url);
if (!process.env.DIRECT_URL && !process.env.DATABASE_URL && existsSync(rootEnv)) process.loadEnvFile(rootEnv);

// The Prisma CLI (migrate, db pull, studio) is the only user of this URL. It must be a DIRECT / session
// connection: DDL and advisory locks break behind a transaction pooler (Supabase :6543). BOLT-0023, ADR-0014.
// The app itself never reads this file; it connects via createPrismaClient(DATABASE_URL) (pooler in prod).
// Local default: the dev Postgres on the HeyMey port series (4580), where DIRECT_URL == DATABASE_URL.
const url =
  process.env.DIRECT_URL ?? process.env.DATABASE_URL ?? "postgresql://heymey:heymey@localhost:4580/heymey";

export default defineConfig({
  schema: "prisma/schema",
  migrations: {
    path: "prisma/migrations",
    seed: "tsx prisma/seed.ts",
  },
  datasource: { url },
});
