import type { PrismaClient } from "@heymey/db";
import type { OneTimeTokenStore } from "@heymey/domain/modules/auth";
import type { RateLimiter } from "@heymey/domain/shared";

/**
 * Postgres-backed platform stores. They replace Valkey (rate limits, idempotency, one-time tokens) and BullMQ (jobs)
 * so the API runs stateless on Vercel with Supabase as the only datastore. Every method is one atomic statement.
 */

/** Fixed-window rate limiter: one upsert that starts a new window when the old one has ended. */
export class PgRateLimiter implements RateLimiter {
  constructor(private readonly prisma: PrismaClient) {}

  async hit(key: string, limit: number, windowSeconds: number): Promise<{ allowed: boolean; retryAfterSeconds: number }> {
    const rows = await this.prisma.$queryRaw<{ count: number; retry: number }[]>`
      INSERT INTO "RateLimitCounter" ("key", "count", "resetAt")
      VALUES (${key}, 1, now() + (${windowSeconds} * interval '1 second'))
      ON CONFLICT ("key") DO UPDATE SET
        "count"   = CASE WHEN "RateLimitCounter"."resetAt" <= now() THEN 1 ELSE "RateLimitCounter"."count" + 1 END,
        "resetAt" = CASE WHEN "RateLimitCounter"."resetAt" <= now() THEN now() + (${windowSeconds} * interval '1 second')
                         ELSE "RateLimitCounter"."resetAt" END
      RETURNING "count", GREATEST(1, CEIL(EXTRACT(EPOCH FROM ("resetAt" - now()))))::int AS retry`;
    const row = rows[0];
    const count = Number(row?.count ?? 0);
    return { allowed: count <= limit, retryAfterSeconds: Number(row?.retry ?? windowSeconds) };
  }
}

export type BeginResult =
  | { kind: "new" }
  | { kind: "replay"; status: number; body: unknown }
  | { kind: "conflict" }
  | { kind: "in_progress" };

const PENDING_SECONDS = 60;

/** Idempotency-Key store in Postgres. status 0 = "pending" marker; it expires after 60 s so a crashed request can retry. */
export class PgIdempotencyStore {
  constructor(private readonly prisma: PrismaClient) {}

  async begin(scope: string, key: string, hash: string): Promise<BeginResult> {
    // Take over a dead pending marker or an expired record; otherwise insert. Returns a row only when we own the key.
    const mine = await this.prisma.$queryRaw<{ scope: string }[]>`
      INSERT INTO "IdempotencyRecord" ("scope", "key", "requestHash", "status", "body", "createdAt", "expiresAt")
      VALUES (${scope}, ${key}::uuid, ${hash}, 0, 'null'::jsonb, now(), now() + (${PENDING_SECONDS} * interval '1 second'))
      ON CONFLICT ("scope", "key") DO UPDATE SET
        "requestHash" = EXCLUDED."requestHash", "status" = 0, "body" = 'null'::jsonb,
        "createdAt" = now(), "expiresAt" = EXCLUDED."expiresAt"
      WHERE "IdempotencyRecord"."expiresAt" <= now()
      RETURNING "scope"`;
    if (mine.length > 0) return { kind: "new" };

    const rows = await this.prisma.$queryRaw<{ requestHash: string; status: number; body: unknown }[]>`
      SELECT "requestHash", "status", "body" FROM "IdempotencyRecord"
      WHERE "scope" = ${scope} AND "key" = ${key}::uuid`;
    const stored = rows[0];
    if (!stored) return this.begin(scope, key, hash); // deleted between the two statements
    if (stored.requestHash !== hash) return { kind: "conflict" };
    if (stored.status === 0) return { kind: "in_progress" };
    return { kind: "replay", status: stored.status, body: stored.body };
  }

  async complete(scope: string, key: string, hash: string, status: number, body: unknown, ttlSeconds: number): Promise<void> {
    await this.prisma.$executeRaw`
      UPDATE "IdempotencyRecord"
      SET "status" = ${status}, "body" = ${JSON.stringify(body ?? null)}::jsonb,
          "expiresAt" = now() + (${ttlSeconds} * interval '1 second')
      WHERE "scope" = ${scope} AND "key" = ${key}::uuid AND "requestHash" = ${hash}`;
  }

  /** The handler failed: forget the key so the client can retry. */
  async abandon(scope: string, key: string): Promise<void> {
    await this.prisma.$executeRaw`
      DELETE FROM "IdempotencyRecord" WHERE "scope" = ${scope} AND "key" = ${key}::uuid AND "status" = 0`;
  }
}

/** A JWT id may be consumed once. True for the first caller. Fails closed: a database error rejects the request. */
export function pgOneTimeTokens(prisma: PrismaClient): OneTimeTokenStore {
  return {
    async consume(jti, ttlSeconds) {
      const rows = await prisma.$queryRaw<{ jti: string }[]>`
        INSERT INTO "OneTimeToken" ("jti", "expiresAt") VALUES (${jti}, now() + (${Math.max(1, Math.ceil(ttlSeconds))} * interval '1 second'))
        ON CONFLICT ("jti") DO UPDATE SET "expiresAt" = EXCLUDED."expiresAt" WHERE "OneTimeToken"."expiresAt" <= now()
        RETURNING "jti"`;
      return rows.length > 0;
    },
  };
}

export interface JobQueue {
  add(queue: string, name: string, data: Record<string, unknown>, opts?: { delayMs?: number; jobId?: string }): Promise<void>;
  close(): Promise<void>;
}

/** Jobs go into "JobQueueItem". A duplicate `jobId` is ignored, which keeps fan-out events exactly-once. */
export class PgJobQueue implements JobQueue {
  constructor(private readonly prisma: PrismaClient) {}

  async add(queue: string, name: string, data: Record<string, unknown>, opts?: { delayMs?: number; jobId?: string }): Promise<void> {
    const delay = Math.max(0, opts?.delayMs ?? 0);
    await this.prisma.$executeRaw`
      INSERT INTO "JobQueueItem" ("queue", "name", "jobId", "data", "runAt")
      VALUES (${queue}, ${name}, ${opts?.jobId ?? null}, ${JSON.stringify(data)}::jsonb, now() + (${delay} * interval '1 millisecond'))
      ON CONFLICT ("jobId") DO NOTHING`;
  }

  async close(): Promise<void> {}
}
