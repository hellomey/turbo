import type { Redis } from "ioredis";
import type { RateLimiter } from "@heymey/domain/shared";

/** Fixed-window rate limiter on Valkey: INCR + EXPIRE in one round trip. */
export class ValkeyRateLimiter implements RateLimiter {
  constructor(private readonly valkey: Redis) {}

  async hit(key: string, limit: number, windowSeconds: number): Promise<{ allowed: boolean; retryAfterSeconds: number }> {
    const res = await this.valkey.multi().incr(key).expire(key, windowSeconds, "NX").ttl(key).exec();
    const count = Number(res?.[0]?.[1] ?? 0);
    const ttl = Number(res?.[2]?.[1] ?? windowSeconds);
    return { allowed: count <= limit, retryAfterSeconds: ttl > 0 ? ttl : windowSeconds };
  }
}

type Stored = { state: "pending"; hash: string } | { state: "done"; hash: string; status: number; body: unknown };
export type BeginResult =
  | { kind: "new" }
  | { kind: "replay"; status: number; body: unknown }
  | { kind: "conflict" }
  | { kind: "in_progress" };

/** Idempotency-Key store on Valkey (24h). A short "pending" marker guards concurrent duplicates. */
export class ValkeyIdempotencyStore {
  constructor(private readonly valkey: Redis) {}

  private k(scope: string, key: string) {
    return `idem:${scope}:${key}`;
  }

  async begin(scope: string, key: string, hash: string): Promise<BeginResult> {
    const pending: Stored = { state: "pending", hash };
    const created = await this.valkey.set(this.k(scope, key), JSON.stringify(pending), "EX", 60, "NX");
    if (created === "OK") return { kind: "new" };
    const raw = await this.valkey.get(this.k(scope, key));
    if (!raw) return this.begin(scope, key, hash);
    const stored = JSON.parse(raw) as Stored;
    if (stored.hash !== hash) return { kind: "conflict" };
    if (stored.state === "pending") return { kind: "in_progress" };
    return { kind: "replay", status: stored.status, body: stored.body };
  }

  async complete(scope: string, key: string, hash: string, status: number, body: unknown, ttlSeconds: number): Promise<void> {
    const done: Stored = { state: "done", hash, status, body };
    await this.valkey.set(this.k(scope, key), JSON.stringify(done), "EX", ttlSeconds);
  }

  /** The handler failed: forget the key so the client can retry. */
  async abandon(scope: string, key: string): Promise<void> {
    await this.valkey.del(this.k(scope, key));
  }
}
