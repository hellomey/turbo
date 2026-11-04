import { Prisma, type PrismaClient } from "@heymey/db";
import type { ReportBody } from "../domain/report.js";
import type { ReadinessRepository, ReportRow, SnapshotRow } from "../application/ports.js";

type ReportRecord = { id: string; userId: string; weekStart: string; tier: string; body: Prisma.JsonValue; createdAt: Date };

const toReport = (r: ReportRecord): ReportRow => ({
  id: r.id,
  userId: r.userId,
  weekStart: r.weekStart,
  tier: r.tier === "full" ? "full" : "short",
  body: r.body as unknown as ReportBody,
  createdAt: r.createdAt,
});

/** Prisma adapter for ReadinessSnapshot + SundayReport (tables owned by `readiness`, §34.8). */
export class PrismaReadinessRepository implements ReadinessRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async upsertSnapshot(s: SnapshotRow): Promise<void> {
    const { userId, examCode, istDay, ...rest } = s;
    await this.prisma.readinessSnapshot.upsert({
      where: { userId_examCode_istDay: { userId, examCode, istDay } },
      create: s,
      update: rest,
    });
  }

  async snapshotsBetween(userId: string, examCode: string, fromDay: string, toDay: string): Promise<SnapshotRow[]> {
    return this.prisma.readinessSnapshot.findMany({
      where: { userId, examCode, istDay: { gte: fromDay, lte: toDay } },
      orderBy: { istDay: "asc" },
    });
  }

  async hasReport(userId: string, weekStart: string): Promise<boolean> {
    return (await this.prisma.sundayReport.count({ where: { userId, weekStart } })) > 0;
  }

  async createReport(r: Omit<ReportRow, "id">): Promise<{ row: ReportRow; created: boolean }> {
    try {
      const row = await this.prisma.sundayReport.create({
        data: { userId: r.userId, weekStart: r.weekStart, tier: r.tier, body: r.body as unknown as Prisma.InputJsonValue, createdAt: r.createdAt },
      });
      return { row: toReport(row), created: true };
    } catch (e) {
      if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === "P2002") {
        const row = await this.prisma.sundayReport.findUniqueOrThrow({ where: { userId_weekStart: { userId: r.userId, weekStart: r.weekStart } } });
        return { row: toReport(row), created: false };
      }
      throw e;
    }
  }

  async pageReports(userId: string, after: { createdAt: Date; id: string } | null, limit: number): Promise<ReportRow[]> {
    const rows = await this.prisma.sundayReport.findMany({
      where: {
        userId,
        ...(after ? { OR: [{ createdAt: { lt: after.createdAt } }, { createdAt: after.createdAt, id: { lt: after.id } }] } : {}),
      },
      orderBy: [{ createdAt: "desc" }, { id: "desc" }],
      take: limit,
    });
    return rows.map(toReport);
  }

  async getReport(id: string): Promise<ReportRow | null> {
    const row = await this.prisma.sundayReport.findUnique({ where: { id } });
    return row ? toReport(row) : null;
  }
}
