import { existsSync } from "node:fs";
import { defineConfig } from "prisma/config";

// Prisma 7 does not read .env files itself. Locally, `pnpm db:migrate` / `pnpm db:seed` run from packages/db,
// so load the repo-root .env written by `pnpm env:dev` (BOLT-0005). An explicit DATABASE_URL in the
// environment (CI, the migrator container in deploy.sh) always wins; a missing .env is fine.
const rootEnv = new URL("../../.env", import.meta.url);
if (!process.env.DATABASE_URL && existsSync(rootEnv)) process.loadEnvFile(rootEnv);

// Local default points at the dev Postgres on the HeyMey port series (4580). See docs/architecture/ports.md.
const url = process.env.DATABASE_URL ?? "postgresql://heymey:heymey@localhost:4580/heymey";

export default defineConfig({
  schema: "prisma/schema",
  migrations: {
    path: "prisma/migrations",
    seed: "tsx prisma/seed.ts",
  },
  datasource: { url },
});
