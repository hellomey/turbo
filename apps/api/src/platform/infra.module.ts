import { Global, Inject, Module, type OnApplicationShutdown } from "@nestjs/common";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { systemClock } from "@heymey/domain/shared";
import { type ApiEnv, loadApiEnv } from "./env.js";
import { PgIdempotencyStore, PgJobQueue, PgRateLimiter, type JobQueue } from "./pg-stores.js";
import { CLOCK, ENV, IDEMPOTENCY_STORE, JOB_QUEUE, PRISMA, RATE_LIMITER } from "./tokens.js";

export type { JobQueue } from "./pg-stores.js";

/**
 * Process-wide singletons. Postgres (Supabase) is the only datastore: rate limits, idempotency, one-time tokens and
 * background jobs all live in tables, so every Vercel function instance is stateless. Connections are lazy, so the app
 * (and the contract test) can boot without a database.
 */
@Global()
@Module({
  providers: [
    { provide: ENV, useFactory: () => loadApiEnv() },
    { provide: PRISMA, inject: [ENV], useFactory: (env: ApiEnv) => createPrismaClient(env.DATABASE_URL) },
    { provide: CLOCK, useValue: systemClock },
    { provide: RATE_LIMITER, inject: [PRISMA], useFactory: (p: PrismaClient) => new PgRateLimiter(p) },
    { provide: IDEMPOTENCY_STORE, inject: [PRISMA], useFactory: (p: PrismaClient) => new PgIdempotencyStore(p) },
    { provide: JOB_QUEUE, inject: [PRISMA], useFactory: (p: PrismaClient): JobQueue => new PgJobQueue(p) },
  ],
  exports: [ENV, PRISMA, CLOCK, RATE_LIMITER, IDEMPOTENCY_STORE, JOB_QUEUE],
})
export class InfraModule implements OnApplicationShutdown {
  constructor(@Inject(PRISMA) private readonly prisma: PrismaClient) {}

  async onApplicationShutdown(): Promise<void> {
    await this.prisma.$disconnect();
  }
}
