import { spawnSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { PostgreSqlContainer, type StartedPostgreSqlContainer } from "@testcontainers/postgresql";
import { GenericContainer, type StartedTestContainer } from "testcontainers";

const repoRoot = join(dirname(fileURLToPath(import.meta.url)), "../../..");

export interface StartedDb {
  url: string;
  stop(): Promise<void>;
}

/**
 * A throwaway PostgreSQL 17 with every Prisma migration applied (blueprint §44: integration tests run
 * against REAL Postgres). Start once per test file in `beforeAll`; it takes a few seconds.
 */
export async function startPostgres(): Promise<StartedDb> {
  const container: StartedPostgreSqlContainer = await new PostgreSqlContainer("postgres:17-bookworm")
    .withDatabase("heymey")
    .withUsername("heymey")
    .withPassword("heymey")
    .start();
  const url = container.getConnectionUri();
  // nosemgrep: javascript.lang.security.audit.spawn-shell-true.spawn-shell-true -- constant command, needed for pnpm.cmd on Windows
  const res = spawnSync("pnpm exec prisma migrate deploy", {
    cwd: join(repoRoot, "packages/db"),
    env: { ...process.env, DATABASE_URL: url },
    shell: true,
    encoding: "utf8",
  });
  if (res.status !== 0) {
    await container.stop();
    throw new Error(`prisma migrate deploy failed:\n${res.stdout}\n${res.stderr}`);
  }
  return { url, stop: async () => void (await container.stop()) };
}

/** A throwaway Valkey 8 (rate limits, idempotency, queues). */
export async function startValkey(): Promise<StartedDb> {
  const container: StartedTestContainer = await new GenericContainer("valkey/valkey:8-alpine").withExposedPorts(6379).start();
  return {
    url: `redis://${container.getHost()}:${container.getMappedPort(6379)}`,
    stop: async () => void (await container.stop()),
  };
}
