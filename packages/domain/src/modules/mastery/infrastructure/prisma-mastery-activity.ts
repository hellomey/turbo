import type { PrismaClient } from "@heymey/db";

/** Lamp work in a time window, counted from the append-only RingEvent history (§5.1). Read-only. */
export interface MasteryWeekCounts {
  /** `lit` events (lamps lit for the first time or again after a lit_fail). */
  lit: number;
  /** `recall_pass` events (each one is one Steady step earned). */
  steadyEarned: number;
  gold: number;
  relit: number;
}

/**
 * Read-only activity view of mastery for other modules' batch jobs (added for `readiness`, BOLT-0013). Exposed through
 * `createMasteryActivity` in index.ts; no write path, no lamp rules.
 */
export class PrismaMasteryActivity {
  constructor(private readonly prisma: PrismaClient) {}

  /** Users with any lamp event since `since`, keyset-paged by userId ascending. */
  async activeUserIds(q: { since: Date; afterUserId: string | null; limit: number }): Promise<string[]> {
    const rows = await this.prisma.ringEvent.findMany({
      where: { at: { gte: q.since }, ...(q.afterUserId ? { userId: { gt: q.afterUserId } } : {}) },
      distinct: ["userId"],
      orderBy: { userId: "asc" },
      select: { userId: true },
      take: q.limit,
    });
    return rows.map((r) => r.userId);
  }

  /** Counts of lamp events for one user in [from, to). */
  async weekCounts(userId: string, from: Date, to: Date): Promise<MasteryWeekCounts> {
    const rows = await this.prisma.ringEvent.groupBy({
      by: ["kind"],
      where: { userId, at: { gte: from, lt: to }, kind: { in: ["lit", "recall_pass", "gold", "relight"] } },
      _count: { _all: true },
    });
    const n = (k: string) => rows.find((r) => r.kind === k)?._count._all ?? 0;
    return { lit: n("lit"), steadyEarned: n("recall_pass"), gold: n("gold"), relit: n("relight") };
  }
}
