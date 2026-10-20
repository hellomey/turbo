// Seed data for `local` and `staging` ONLY. Never real personal data (blueprint §42). Idempotent: safe to re-run.
//   pnpm db:seed
// Each track owns its own file in ./seed/ so parallel work never collides.
import { createPrismaClient } from "../src/index.js";

if (process.env.HEYMEY_ENV === "production") {
  console.error("seed: refusing to run in production");
  process.exit(1);
}

process.loadEnvFile?.(new URL("../../../.env", import.meta.url));
const url = process.env.DATABASE_URL;
if (!url) throw new Error("DATABASE_URL missing (run `pnpm env:dev`)");
const prisma = createPrismaClient(url);

type Seeder = { name: string; run: (p: typeof prisma) => Promise<string> };
const seeders: Seeder[] = [];
for (const file of ["./seed/catalog.ts", "./seed/identity.ts"]) {
  try {
    const mod = (await import(file)) as { seeder?: Seeder };
    if (mod.seeder) seeders.push(mod.seeder);
  } catch (e) {
    if ((e as NodeJS.ErrnoException).code !== "ERR_MODULE_NOT_FOUND") throw e;
  }
}

try {
  for (const s of seeders) console.log(`seed ${s.name}: ${await s.run(prisma)}`);
  if (!seeders.length) console.log("seed: no seeders yet");
} finally {
  await prisma.$disconnect();
}
