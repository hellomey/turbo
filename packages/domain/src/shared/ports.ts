/**
 * Ports (interfaces) that modules depend on. Adapters live in the apps (Valkey, BullMQ) or in a module's
 * infrastructure/ (Prisma), so domain/ and application/ stay framework-free and unit-testable with fakes.
 */

/** Idempotency store (§34.3): key + response kept 24h. */
export interface IdempotencyStore {
  get(scope: string, key: string): Promise<{ status: number; body: unknown } | null>;
  put(scope: string, key: string, value: { status: number; body: unknown }, ttlSeconds: number): Promise<void>;
}

/** Fixed-window counter (Valkey in production). */
export interface RateLimiter {
  hit(key: string, limit: number, windowSeconds: number): Promise<{ allowed: boolean; retryAfterSeconds: number }>;
}

/** Domain events cross module boundaries; modules never read each other's tables (§34.8). */
export interface DomainEvent<TType extends string = string, TPayload = unknown> {
  type: TType;
  occurredAt: Date;
  payload: TPayload;
}

export interface EventPublisher {
  publish(event: DomainEvent): Promise<void>;
}

/** Feature flags + emergency switch (liveops). Checked on the server on every request that needs them. */
export interface FlagReader {
  isOn(flag: string): Promise<boolean>;
}

/** Who is acting, for authorisation and the audit log. `null` actor = the system. */
export interface Actor {
  userId: string | null;
  role: string;
  ip?: string;
  requestId?: string;
}
