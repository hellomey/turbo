import type { PrismaClient } from "@heymey/db";
import type { DuelRow, GamesRepository, SpinRow } from "../application/games.js";

/** Prisma adapter for Daily Spin and Confidence Duel rows. Unique keys and conditional updates make writes idempotent. */
export class PrismaGamesRepository implements GamesRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async spinOf(userId: string, day: string): Promise<SpinRow | null> {
    return this.prisma.dailySpin.findUnique({ where: { userId_day: { userId, day } } });
  }

  async insertSpin(row: SpinRow): Promise<boolean> {
    return (await this.prisma.dailySpin.createMany({ data: [row], skipDuplicates: true })).count === 1;
  }

  async createDuel(d: Omit<DuelRow, "id" | "submittedAt" | "pointsAwarded" | "result">): Promise<string> {
    const r = await this.prisma.confidenceDuel.create({
      data: { userId: d.userId, examCode: d.examCode, questions: d.questions, startedAt: d.startedAt },
      select: { id: true },
    });
    return r.id;
  }

  async duel(id: string): Promise<DuelRow | null> {
    const r = await this.prisma.confidenceDuel.findUnique({ where: { id } });
    return r && { ...r, questions: r.questions as DuelRow["questions"] };
  }

  async finishDuel(id: string, f: { submittedAt: Date; pointsAwarded: number; result: unknown }): Promise<boolean> {
    const r = await this.prisma.confidenceDuel.updateMany({
      where: { id, submittedAt: null },
      data: { submittedAt: f.submittedAt, pointsAwarded: f.pointsAwarded, result: f.result as object },
    });
    return r.count === 1;
  }

  async duelPointsBetween(userId: string, from: Date, to: Date): Promise<number> {
    const r = await this.prisma.confidenceDuel.aggregate({ where: { userId, submittedAt: { gte: from, lt: to } }, _sum: { pointsAwarded: true } });
    return r._sum.pointsAwarded ?? 0;
  }
}
