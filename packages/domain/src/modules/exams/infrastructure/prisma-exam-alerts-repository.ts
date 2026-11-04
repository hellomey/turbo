import { createHash, timingSafeEqual } from "node:crypto";
import type { PrismaClient } from "@heymey/db";
import { DomainError } from "../../../shared/errors.js";
import type { ExamAlertsRepository, ReviewTxHook } from "../application/exam-alerts.js";
import { applyStageDate, type ExamAlertKind, type ExamAlertRecord, type ExamChangeRecord, type ExamChangeStatus, type StageDateEntry } from "../domain/exam-alerts.js";

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
/** Cursors are row ids (uuid v7, time ordered). Anything else is a client error, never a DB cast error. */
function cursorId(cursor: string | undefined): string | undefined {
  if (cursor === undefined) return undefined;
  if (!UUID.test(cursor)) throw new DomainError("VALIDATION_FAILED", { field: "cursor" });
  return cursor;
}

type ChangeRow = {
  id: string; watchUuid: string; changeId: string; watchUrl: string; title: string | null; diffSummary: string | null;
  receivedAt: Date; status: string; reviewedAt: Date | null; alertId: string | null;
};

function isUniqueViolation(e: unknown): boolean {
  return (e as { code?: unknown })?.code === "P2002";
}

export class PrismaExamAlertsRepository implements ExamAlertsRepository {
  constructor(private readonly prisma: PrismaClient) {}

  private async withExamCodes(rows: ChangeRow[]): Promise<ExamChangeRecord[]> {
    const alertIds = rows.map((r) => r.alertId).filter((x): x is string => !!x);
    const alerts = alertIds.length
      ? await this.prisma.examAlert.findMany({ where: { id: { in: alertIds } }, select: { id: true, exam: { select: { code: true } } } })
      : [];
    const codeOf = new Map(alerts.map((a) => [a.id, a.exam.code]));
    return rows.map((r) => ({ ...r, status: r.status as ExamChangeStatus, examCode: r.alertId ? (codeOf.get(r.alertId) ?? null) : null }));
  }

  async insertChange(i: { watchUuid: string; changeId: string; watchUrl: string; title: string | null; diffSummary: string | null; at: Date }) {
    try {
      await this.prisma.examWatchChange.create({
        data: { watchUuid: i.watchUuid, changeId: i.changeId, watchUrl: i.watchUrl, title: i.title, diffSummary: i.diffSummary, receivedAt: i.at },
      });
      return "created" as const;
    } catch (e) {
      if (isUniqueViolation(e)) return "duplicate" as const;
      throw e;
    }
  }

  async listChanges(status: ExamChangeStatus, cursor: string | undefined, limit: number) {
    const after = cursorId(cursor);
    const rows = await this.prisma.examWatchChange.findMany({
      where: { status, ...(after ? { id: { lt: after } } : {}) },
      orderBy: { id: "desc" },
      take: limit,
    });
    return this.withExamCodes(rows);
  }

  async findChange(id: string) {
    if (!UUID.test(id)) return null;
    const row = await this.prisma.examWatchChange.findUnique({ where: { id } });
    return row ? ((await this.withExamCodes([row]))[0] ?? null) : null;
  }

  async examIdByCode(code: string) {
    const e = await this.prisma.exam.findUnique({ where: { code }, select: { id: true, status: true } });
    return e && e.status === "published" ? e.id : null;
  }

  async approve(i: Parameters<ExamAlertsRepository["approve"]>[0], inTx?: ReviewTxHook) {
    return this.prisma.$transaction(async (tx) => {
      const claimed = await tx.examWatchChange.updateMany({
        where: { id: i.changeId, status: "pending" },
        data: { status: "approved", reviewedBy: i.reviewerId, reviewedAt: i.at },
      });
      if (claimed.count !== 1) return null;
      const alert = await tx.examAlert.create({
        data: {
          examId: i.alert.examId, changeId: i.changeId, kind: i.alert.kind, title: i.alert.title, summary: i.alert.summary,
          officialUrl: i.alert.officialUrl, publishedBy: i.reviewerId, publishedAt: i.at,
        },
      });
      const change = await tx.examWatchChange.update({ where: { id: i.changeId }, data: { alertId: alert.id } });

      let cycleId: string | null = null;
      if (i.stageDate) {
        // The exam's open cycles, newest first; the first one that has this stage gets the official date.
        const cycles = await tx.examAttemptCycle.findMany({ where: { examId: i.alert.examId, status: { not: "closed" } }, orderBy: { code: "desc" } });
        for (const c of cycles) {
          const entries = Array.isArray(c.stageDates) ? (c.stageDates as unknown as StageDateEntry[]) : [];
          const next = applyStageDate(entries, i.stageDate.stageCode, i.stageDate.date);
          if (!next.changed) continue;
          await tx.examAttemptCycle.update({ where: { id: c.id }, data: { stageDates: next.entries as object[], status: "announced" } });
          cycleId = c.id;
          break;
        }
      }
      if (inTx) await inTx(tx, { alertId: alert.id });
      const rec: ExamAlertRecord = { ...alert, kind: alert.kind as ExamAlertKind, examCode: i.alert.examCode };
      return { change: { ...change, status: "approved" as const, examCode: i.alert.examCode }, alert: rec, cycleId };
    });
  }

  async reject(i: { changeId: string; reviewerId: string; at: Date; note: string }, inTx?: ReviewTxHook) {
    const done = await this.prisma.$transaction(async (tx) => {
      const res = await tx.examWatchChange.updateMany({
        where: { id: i.changeId, status: "pending" },
        data: { status: "rejected", reviewedBy: i.reviewerId, reviewedAt: i.at, reviewNote: i.note },
      });
      if (res.count !== 1) return false;
      if (inTx) await inTx(tx, { alertId: null });
      return true;
    });
    if (!done) return null;
    return this.findChange(i.changeId);
  }

  async alertsForUser(userId: string, cursor: string | undefined, limit: number) {
    const after = cursorId(cursor);
    const codes = (await this.prisma.userExamChoice.findMany({ where: { userId }, select: { examCode: true } })).map((c) => c.examCode);
    if (codes.length === 0) return [];
    const rows = await this.prisma.examAlert.findMany({
      where: { exam: { code: { in: codes } }, ...(after ? { id: { lt: after } } : {}) },
      include: { exam: { select: { code: true } } },
      orderBy: { id: "desc" },
      take: limit,
    });
    return rows.map(({ exam, ...a }) => ({ ...a, kind: a.kind as ExamAlertKind, examCode: exam.code }));
  }

  async followersOf(examCode: string) {
    const rows = await this.prisma.userExamChoice.findMany({ where: { examCode }, select: { userId: true } });
    return rows.map((r) => r.userId);
  }
}

/**
 * Shared-secret check for the changedetection.io webhook (security review: constant-time compare).
 * Both sides are hashed first so lengths match and the compare never short-circuits on length.
 */
export function createWebhookSecretVerifier(expected: string): (provided: string | undefined) => boolean {
  const want = createHash("sha256").update(expected, "utf8").digest();
  return (provided) => {
    if (typeof provided !== "string" || provided.length === 0) return false;
    const got = createHash("sha256").update(provided, "utf8").digest();
    return timingSafeEqual(want, got);
  };
}
