import type { PrismaClient } from "@heymey/db";
import type { EconomyRepository } from "../application/progression.js";

const checkInKey = (userId: string, day: string) => `check_in:${userId}:${day}`;

/** Prisma adapter for XP awards, Points (PointsLedger), trophies and leaderboard opt-in. Unique keys make writes idempotent. */
export class PrismaEconomyRepository implements EconomyRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async awardXp(a: { userId: string; amount: number; reason: string; sourceKey: string; at: Date }): Promise<boolean> {
    const r = await this.prisma.xpAward.createMany({
      data: [{ userId: a.userId, amount: a.amount, reason: a.reason, sourceKey: a.sourceKey, createdAt: a.at }],
      skipDuplicates: true,
    });
    return r.count === 1;
  }

  async checkIn(a: { userId: string; day: string; xp: number; points: number; at: Date }): Promise<boolean> {
    return this.prisma.$transaction(async (tx) => {
      const p = await tx.pointsLedger.createMany({
        data: [{ userId: a.userId, delta: a.points, reason: "check_in", idempotencyKey: checkInKey(a.userId, a.day), createdAt: a.at }],
        skipDuplicates: true,
      });
      if (p.count === 0) return false;
      await tx.xpAward.createMany({
        data: [{ userId: a.userId, amount: a.xp, reason: "check_in", sourceKey: `check_in:${a.day}`, createdAt: a.at }],
        skipDuplicates: true,
      });
      return true;
    });
  }

  async hasCheckedIn(userId: string, day: string): Promise<boolean> {
    return (await this.prisma.pointsLedger.count({ where: { idempotencyKey: checkInKey(userId, day) } })) > 0;
  }

  async awardPoints(a: { userId: string; delta: number; reason: string; key: string; at: Date }): Promise<boolean> {
    const r = await this.prisma.pointsLedger.createMany({
      data: [{ userId: a.userId, delta: a.delta, reason: a.reason, idempotencyKey: a.key, createdAt: a.at }],
      skipDuplicates: true,
    });
    return r.count === 1;
  }

  async xpTotal(userId: string): Promise<number> {
    return (await this.prisma.xpAward.aggregate({ where: { userId }, _sum: { amount: true } }))._sum.amount ?? 0;
  }

  async pointsBalance(userId: string): Promise<number> {
    return (await this.prisma.pointsLedger.aggregate({ where: { userId }, _sum: { delta: true } }))._sum.delta ?? 0;
  }

  async trophiesOf(userId: string): Promise<{ code: string; earnedAt: Date }[]> {
    return this.prisma.userTrophy.findMany({ where: { userId }, select: { code: true, earnedAt: true }, orderBy: { earnedAt: "asc" } });
  }

  async awardTrophy(userId: string, code: string, at: Date): Promise<boolean> {
    return (await this.prisma.userTrophy.createMany({ data: [{ userId, code, earnedAt: at }], skipDuplicates: true })).count === 1;
  }

  async studyDays(userId: string): Promise<number> {
    const rows = await this.prisma.$queryRaw<{ n: number }[]>`
      SELECT COUNT(DISTINCT ("createdAt" + interval '330 minutes')::date)::int AS n
      FROM "XpAward" WHERE "userId" = ${userId}::uuid AND "reason" <> 'check_in'`;
    return rows[0]?.n ?? 0;
  }

  async setOptIn(userId: string, optIn: boolean, at: Date): Promise<void> {
    await this.prisma.leaderboardOptIn.upsert({ where: { userId }, create: { userId, optIn, updatedAt: at }, update: { optIn, updatedAt: at } });
  }

  async isOptedIn(userId: string): Promise<boolean> {
    return (await this.prisma.leaderboardOptIn.findUnique({ where: { userId } }))?.optIn ?? false;
  }

  async weeklyXp(from: Date, to: Date, limit: number): Promise<{ userId: string; xp: number }[]> {
    return this.prisma.$queryRaw<{ userId: string; xp: number }[]>`
      SELECT x."userId"::text AS "userId", SUM(x."amount")::int AS xp
      FROM "XpAward" x JOIN "LeaderboardOptIn" o ON o."userId" = x."userId" AND o."optIn"
      WHERE x."createdAt" >= ${from} AND x."createdAt" < ${to}
      GROUP BY x."userId" ORDER BY xp DESC, x."userId" LIMIT ${limit}`;
  }
}
