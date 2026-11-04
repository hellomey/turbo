import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "./generated/prisma/client.js";

export * from "./generated/prisma/client.js";

/** Query params that are Prisma-engine/pgbouncer hints, not node-postgres options. */
const POOLER_PARAMS = ["pgbouncer", "connection_limit", "pool_timeout", "statement_cache_size"] as const;

/**
 * Split a DATABASE_URL into a clean node-postgres connection string and a pool size.
 * `connection_limit` (Prisma URL convention) becomes the pg Pool `max`; `pgbouncer=true` is accepted and dropped.
 * Exported for tests.
 */
export function parseDatabaseUrl(databaseUrl: string): { connectionString: string; max?: number; ssl?: { rejectUnauthorized: boolean } } {
  const u = new URL(databaseUrl);
  const limit = Number(u.searchParams.get("connection_limit"));
  for (const p of POOLER_PARAMS) u.searchParams.delete(p);
  // SEC-P2-M3: TLS is set explicitly on the pool (not left to URL parsing). sslmode is removed from the string
  // because node-postgres lets the connection string override `ssl`. Certificates are verified.
  const sslmode = u.searchParams.get("sslmode");
  const tls = sslmode === "require" || sslmode === "verify-ca" || sslmode === "verify-full";
  if (tls) u.searchParams.delete("sslmode");
  return {
    connectionString: u.toString(),
    ...(Number.isInteger(limit) && limit > 0 ? { max: limit } : {}),
    ...(tls ? { ssl: { rejectUnauthorized: true } } : {}),
  };
}

/**
 * One client per process (api / realtime / worker composition root). In staging/production DATABASE_URL points at
 * the Supabase transaction pooler (:6543, BOLT-0023 / ADR-0014). That is safe with @prisma/adapter-pg because it
 * sends UNNAMED prepared statements unless `statementNameGenerator` is set, and we never set it: do not add one
 * (named statements break under transaction pooling). Migrations use DIRECT_URL (prisma.config.ts).
 */
export function createPrismaClient(databaseUrl: string): PrismaClient {
  return new PrismaClient({ adapter: new PrismaPg(parseDatabaseUrl(databaseUrl)) });
}
