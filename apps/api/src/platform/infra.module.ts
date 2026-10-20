import { Global, Inject, Module, type OnApplicationShutdown } from "@nestjs/common";
import { Queue } from "bullmq";
import { Redis } from "ioredis";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { systemClock } from "@heymey/domain/shared";
import { type ApiEnv, loadApiEnv } from "./env.js";
import { CLOCK, ENV, IDEMPOTENCY_STORE, JOB_QUEUE, PRISMA, RATE_LIMITER, VALKEY } from "./tokens.js";
import { ValkeyIdempotencyStore, ValkeyRateLimiter } from "./valkey.js";

/** Enqueue a background job for apps/worker. Queue names are declared in apps/worker/src/queues/registry.ts. */
export interface JobQueue {
  add(queue: string, name: string, data: Record<string, unknown>, opts?: { delayMs?: number; jobId?: string }): Promise<void>;
  close(): Promise<void>;
}

function bullJobQueue(valkeyUrl: string): JobQueue {
  const url = new URL(valkeyUrl);
  // Keep credentials: staging/production Valkey requires a password (SEC-L2).
  const connection = {
    host: url.hostname,
    port: Number(url.port || 6379),
    ...(url.username ? { username: decodeURIComponent(url.username) } : {}),
    ...(url.password ? { password: decodeURIComponent(url.password) } : {}),
    maxRetriesPerRequest: null,
  };
  const queues = new Map<string, Queue>();
  const get = (name: string) => {
    let q = queues.get(name);
    if (!q) queues.set(name, (q = new Queue(name, { connection })));
    return q;
  };
  return {
    async add(queue, name, data, opts) {
      await get(queue).add(name, data, {
        removeOnComplete: true,
        // Email jobs carry an address and a one-time code: never keep them longer than the code lives (SEC-M2).
        removeOnFail: { age: queue.startsWith("email.") ? 600 : 24 * 3600 },
        attempts: 5,
        backoff: { type: "exponential", delay: 2000 },
        ...(opts?.delayMs ? { delay: opts.delayMs } : {}),
        ...(opts?.jobId ? { jobId: opts.jobId } : {}),
      });
    },
    async close() {
      await Promise.all([...queues.values()].map((q) => q.close()));
    },
  };
}

/** Process-wide singletons. Lazy connections, so the app (and the contract test) can boot without infra. */
@Global()
@Module({
  providers: [
    { provide: ENV, useFactory: () => loadApiEnv() },
    { provide: PRISMA, inject: [ENV], useFactory: (env: ApiEnv) => createPrismaClient(env.DATABASE_URL) },
    {
      provide: VALKEY,
      inject: [ENV],
      useFactory: (env: ApiEnv) => new Redis(env.VALKEY_URL, { lazyConnect: true, maxRetriesPerRequest: 2, enableOfflineQueue: true }),
    },
    { provide: CLOCK, useValue: systemClock },
    { provide: RATE_LIMITER, inject: [VALKEY], useFactory: (v: Redis) => new ValkeyRateLimiter(v) },
    { provide: IDEMPOTENCY_STORE, inject: [VALKEY], useFactory: (v: Redis) => new ValkeyIdempotencyStore(v) },
    { provide: JOB_QUEUE, inject: [ENV], useFactory: (env: ApiEnv) => bullJobQueue(env.VALKEY_URL) },
  ],
  exports: [ENV, PRISMA, VALKEY, CLOCK, RATE_LIMITER, IDEMPOTENCY_STORE, JOB_QUEUE],
})
export class InfraModule implements OnApplicationShutdown {
  constructor(
    @Inject(PRISMA) private readonly prisma: PrismaClient,
    @Inject(VALKEY) private readonly valkey: Redis,
    @Inject(JOB_QUEUE) private readonly jobs: JobQueue,
  ) {}

  async onApplicationShutdown(): Promise<void> {
    await Promise.allSettled([this.prisma.$disconnect(), this.jobs.close(), this.valkey.quit()]);
  }
}
