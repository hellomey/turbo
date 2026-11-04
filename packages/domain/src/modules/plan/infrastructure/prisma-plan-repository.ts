import type { Prisma, PrismaClient } from "@heymey/db";
import type { PlanItemRecord, PlanRecord, PlanRepository, PlanSettings, StudyLogEntry } from "../application/ports.js";
import type { ItemDraft, PlanItemKind, PlanItemStatus, PlanTarget, StretchPhase } from "../domain/rules.js";

type PlanRow = Prisma.PlanGetPayload<{ include: { exams: true } }>;
type ItemRow = Prisma.PlanItemGetPayload<object>;

const toDate = (day: string | null) => (day ? new Date(`${day}T00:00:00.000Z`) : null);
const toDay = (d: Date | null) => (d ? d.toISOString().slice(0, 10) : null);

function toPlan(r: PlanRow): PlanRecord {
  return {
    id: r.id,
    userId: r.userId,
    weekdayMinutes: r.weekdayMinutes,
    weekendMinutes: r.weekendMinutes,
    pocketMinutes: r.pocketMinutes,
    balance: r.balance,
    starterPathUntil: r.starterPathUntil,
    stretch: r.stretch as StretchPhase,
    lastActiveIstDay: r.lastActiveIstDay,
    lastRebalancedAt: r.lastRebalancedAt,
    configVersion: r.configVersion,
    exams: r.exams
      .map((e) => ({ examCode: e.examCode, attemptCycleId: e.attemptCycleId, examDate: toDay(e.examDate), priority: e.priority }))
      .sort((a, b) => a.priority - b.priority),
  };
}

function toItem(r: ItemRow): PlanItemRecord {
  return {
    id: r.id,
    planId: r.planId,
    day: r.istDay,
    kind: r.kind as PlanItemKind,
    examCode: r.examCode,
    topicId: r.topicId,
    title: r.title,
    minutes: r.minutes,
    order: r.order,
    status: r.status as PlanItemStatus,
  };
}

function logData(e: StudyLogEntry): Prisma.StudyLogCreateInput {
  return {
    userId: e.userId,
    kind: e.kind,
    topicId: e.topicId,
    minutes: e.minutes,
    at: e.at,
    istDay: e.istDay,
    source: e.source,
    clientActionId: e.clientActionId,
    ...(e.details ? { details: e.details as Prisma.InputJsonValue } : {}),
  };
}

const examRows = (planId: string, exams: PlanTarget[]) =>
  exams.map((e) => ({ planId, examCode: e.examCode, attemptCycleId: e.attemptCycleId, examDate: toDate(e.examDate), priority: e.priority }));

/** The only code that touches Plan, PlanExam, PlanItem, StudyLog (module.json "owns"). */
export class PrismaPlanRepository implements PlanRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async findByUser(userId: string): Promise<PlanRecord | null> {
    const r = await this.prisma.plan.findUnique({ where: { userId }, include: { exams: true } });
    return r ? toPlan(r) : null;
  }

  async save(
    userId: string,
    s: PlanSettings & { starterPathUntil: string | null; stretch: StretchPhase; configVersion: string },
    exams: PlanTarget[],
  ): Promise<PlanRecord> {
    const data = {
      weekdayMinutes: s.weekdayMinutes,
      weekendMinutes: s.weekendMinutes,
      pocketMinutes: s.pocketMinutes,
      balance: s.balance,
      starterPathUntil: s.starterPathUntil,
      stretch: s.stretch,
      configVersion: s.configVersion,
    };
    const row = await this.prisma.$transaction(async (tx) => {
      const plan = await tx.plan.upsert({ where: { userId }, create: { userId, ...data }, update: data });
      await tx.planExam.deleteMany({ where: { planId: plan.id } });
      await tx.planExam.createMany({ data: examRows(plan.id, exams) });
      return tx.plan.findUniqueOrThrow({ where: { id: plan.id }, include: { exams: true } });
    });
    return toPlan(row);
  }

  async setExams(planId: string, exams: PlanTarget[], stretch: StretchPhase): Promise<void> {
    await this.prisma.$transaction([
      this.prisma.planExam.deleteMany({ where: { planId } }),
      this.prisma.planExam.createMany({ data: examRows(planId, exams) }),
      this.prisma.plan.update({ where: { id: planId }, data: { stretch } }),
    ]);
  }

  async items(planId: string, from: string, to: string): Promise<PlanItemRecord[]> {
    const rows = await this.prisma.planItem.findMany({
      where: { planId, istDay: { gte: from, lte: to } },
      orderBy: [{ istDay: "asc" }, { order: "asc" }],
    });
    return rows.map(toItem);
  }

  async plannedTopicIds(planId: string): Promise<Set<string>> {
    const rows = await this.prisma.planItem.findMany({
      where: { planId, topicId: { not: null }, status: { in: ["pending", "done"] } },
      select: { topicId: true },
      distinct: ["topicId"],
    });
    return new Set(rows.flatMap((r) => (r.topicId ? [r.topicId] : [])));
  }

  async rebuild(planId: string, fromDay: string, drafts: ItemDraft[], movePastIds: string[], rebalancedAt: Date | null): Promise<void> {
    await this.prisma.$transaction(async (tx) => {
      await tx.planItem.deleteMany({ where: { planId, status: "pending", istDay: { gte: fromDay } } });
      if (movePastIds.length) {
        await tx.planItem.updateMany({ where: { planId, id: { in: movePastIds }, status: "pending" }, data: { status: "moved" } });
      }
      if (drafts.length) {
        await tx.planItem.createMany({
          data: drafts.map((x) => ({
            planId,
            istDay: x.day,
            kind: x.kind,
            examCode: x.examCode,
            topicId: x.topicId,
            title: x.title,
            minutes: x.minutes,
            order: x.order,
          })),
        });
      }
      if (rebalancedAt) await tx.plan.update({ where: { id: planId }, data: { lastRebalancedAt: rebalancedAt } });
    });
  }

  async item(itemId: string): Promise<(PlanItemRecord & { userId: string }) | null> {
    const r = await this.prisma.planItem.findUnique({ where: { id: itemId }, include: { plan: { select: { userId: true } } } });
    return r ? { ...toItem(r), userId: r.plan.userId } : null;
  }

  async setItemStatus(itemId: string, status: "done" | "skipped", at: Date, istDay: string, log: StudyLogEntry | null): Promise<PlanItemRecord> {
    const row = await this.prisma.$transaction(async (tx) => {
      const changed = await tx.planItem.updateMany({
        where: { id: itemId, status: "pending" },
        data: { status, doneAt: status === "done" ? at : null },
      });
      const item = await tx.planItem.findUniqueOrThrow({ where: { id: itemId } });
      if (changed.count) await tx.plan.update({ where: { id: item.planId }, data: { lastActiveIstDay: istDay } });
      // The log row is written even when the item was already closed, so an offline clientActionId is used once.
      if (log && (changed.count || log.clientActionId)) await tx.studyLog.create({ data: logData(log) });
      return item;
    });
    return toItem(row);
  }

  async appendStudyLog(entry: StudyLogEntry): Promise<void> {
    await this.prisma.studyLog.create({ data: logData(entry) });
  }

  async hasClientAction(userId: string, clientActionId: string): Promise<boolean> {
    return (await this.prisma.studyLog.count({ where: { userId, clientActionId } })) > 0;
  }

  async usersForCycle(examCode: string, cycleId: string): Promise<string[]> {
    const rows = await this.prisma.plan.findMany({
      where: { exams: { some: { examCode, attemptCycleId: cycleId } } },
      select: { userId: true },
    });
    return rows.map((r) => r.userId);
  }

  async usersWithPastPending(today: string, afterUserId: string | null, limit: number): Promise<string[]> {
    const rows = await this.prisma.plan.findMany({
      where: { items: { some: { status: "pending", istDay: { lt: today } } }, ...(afterUserId ? { userId: { gt: afterUserId } } : {}) },
      select: { userId: true },
      orderBy: { userId: "asc" },
      take: limit,
    });
    return rows.map((r) => r.userId);
  }
}
