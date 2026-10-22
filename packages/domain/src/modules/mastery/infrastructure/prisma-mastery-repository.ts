import { Prisma, type PrismaClient } from "@heymey/db";
import type { CheckRecord, Commit, CommitResult, MasteryRepository, NewCheck, StatePageQuery } from "../application/ports.js";
import type { CheckKind, LampState } from "../domain/lamp.js";

type StateRow = Awaited<ReturnType<PrismaClient["userTopicState"]["findFirstOrThrow"]>>;
type CheckRow = Awaited<ReturnType<PrismaClient["topicCheck"]["findFirstOrThrow"]>>;

const toState = (r: StateRow): LampState => ({
  userId: r.userId,
  topicId: r.topicId,
  litAt: r.litAt,
  steadyLevel: r.steadyLevel,
  goldAt: r.goldAt,
  nextDueAt: r.nextDueAt,
  dimState: r.dimState,
  dimSince: r.dimSince,
  shieldUntil: r.shieldUntil,
  lessonCompletedAt: r.lessonCompletedAt,
  steadyEarnedAt: r.steadyEarnedAt,
  lastCheckAt: r.lastCheckAt,
  rowVersion: r.rowVersion,
  updatedAt: r.updatedAt,
});

const toCheck = (r: CheckRow): CheckRecord => ({
  id: r.id,
  userId: r.userId,
  topicId: r.topicId,
  kind: r.kind,
  questionIds: r.questionIds,
  passMark: r.passMark,
  issuedAt: r.issuedAt,
  deadlineAt: r.deadlineAt,
  submittedAt: r.submittedAt,
  correct: r.correct,
  passed: r.passed,
  source: r.source,
  configVersion: r.configVersion,
});

/** Marker thrown inside the transaction to roll it back with a known outcome. */
class Abort extends Error {
  constructor(readonly outcome: Exclude<CommitResult, "ok">) {
    super(outcome);
  }
}

const isUniqueViolation = (e: unknown) => e instanceof Prisma.PrismaClientKnownRequestError && e.code === "P2002";

/** Tables owned by mastery only: UserTopicState, TopicCheck, RingEvent, UserRank (§34.8). */
export class PrismaMasteryRepository implements MasteryRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async getState(userId: string, topicId: string): Promise<LampState | null> {
    const r = await this.prisma.userTopicState.findUnique({ where: { userId_topicId: { userId, topicId } } });
    return r ? toState(r) : null;
  }

  async statesFor(userId: string, topicIds: readonly string[]): Promise<LampState[]> {
    if (!topicIds.length) return [];
    const rows = await this.prisma.userTopicState.findMany({ where: { userId, topicId: { in: [...topicIds] } }, orderBy: { topicId: "asc" } });
    return rows.map(toState);
  }

  async pageStates(q: StatePageQuery): Promise<LampState[]> {
    if (!q.topicIds.length) return [];
    const rows = await this.prisma.userTopicState.findMany({
      where: {
        userId: q.userId,
        topicId: { in: [...q.topicIds] },
        ...(q.since ? { updatedAt: { gt: q.since } } : {}),
        ...(q.after
          ? { OR: [{ updatedAt: { gt: q.after.updatedAt } }, { updatedAt: q.after.updatedAt, topicId: { gt: q.after.topicId } }] }
          : {}),
      },
      orderBy: [{ updatedAt: "asc" }, { topicId: "asc" }],
      take: q.limit,
    });
    return rows.map(toState);
  }

  async commit(c: Commit): Promise<CommitResult> {
    try {
      await this.prisma.$transaction(async (tx) => {
        if (c.check) {
          const done = await tx.topicCheck.updateMany({
            where: { id: c.check.id, submittedAt: null },
            data: { submittedAt: c.check.submittedAt, correct: c.check.correct, passed: c.check.passed },
          });
          if (done.count !== 1) throw new Abort("duplicate");
        }
        if (c.state) {
          const { next, expectedVersion } = c.state;
          const data = {
            litAt: next.litAt,
            steadyLevel: next.steadyLevel,
            goldAt: next.goldAt,
            nextDueAt: next.nextDueAt,
            dimState: next.dimState,
            dimSince: next.dimSince,
            shieldUntil: next.shieldUntil,
            lessonCompletedAt: next.lessonCompletedAt,
            steadyEarnedAt: next.steadyEarnedAt,
            lastCheckAt: next.lastCheckAt,
            updatedAt: next.updatedAt,
          };
          if (expectedVersion === null) {
            try {
              await tx.userTopicState.create({ data: { userId: next.userId, topicId: next.topicId, ...data, rowVersion: 0 } });
            } catch (e) {
              if (isUniqueViolation(e)) throw new Abort("conflict");
              throw e;
            }
          } else {
            const n = await tx.userTopicState.updateMany({
              where: { userId: next.userId, topicId: next.topicId, rowVersion: expectedVersion },
              data: { ...data, rowVersion: expectedVersion + 1 },
            });
            if (n.count !== 1) throw new Abort("conflict");
          }
        }
        if (c.events.length) {
          try {
            await tx.ringEvent.createMany({
              data: c.events.map((e) => ({
                userId: e.userId,
                topicId: e.topicId,
                kind: e.kind,
                at: e.at,
                source: e.source,
                clientActionId: e.clientActionId ?? null,
                checkId: e.checkId ?? null,
                ...(e.details ? { details: e.details as Prisma.InputJsonValue } : {}),
              })),
            });
          } catch (e) {
            if (isUniqueViolation(e)) throw new Abort("duplicate");
            throw e;
          }
        }
      });
      return "ok";
    } catch (e) {
      if (e instanceof Abort) return e.outcome;
      throw e;
    }
  }

  async createCheck(c: NewCheck): Promise<CheckRecord> {
    return toCheck(await this.prisma.topicCheck.create({ data: { ...c, questionIds: [...c.questionIds] } }));
  }

  async getCheck(checkId: string): Promise<CheckRecord | null> {
    const r = await this.prisma.topicCheck.findUnique({ where: { id: checkId } });
    return r ? toCheck(r) : null;
  }

  countChecksSince(userId: string, topicId: string, kind: CheckKind, since: Date): Promise<number> {
    return this.prisma.topicCheck.count({ where: { userId, topicId, kind, issuedAt: { gte: since } } });
  }

  async hasClientAction(clientActionId: string): Promise<boolean> {
    return (await this.prisma.ringEvent.count({ where: { clientActionId } })) > 0;
  }

  async dimmingCandidates(q: { now: Date; dimCutoff: Date; limit: number; after: { userId: string; topicId: string } | null }): Promise<LampState[]> {
    const rows = await this.prisma.userTopicState.findMany({
      where: {
        litAt: { not: null },
        OR: [
          { dimState: "bright", nextDueAt: { lte: q.now } },
          { dimState: "dimming", nextDueAt: { lte: q.dimCutoff } },
        ],
        ...(q.after
          ? { AND: [{ OR: [{ userId: { gt: q.after.userId } }, { userId: q.after.userId, topicId: { gt: q.after.topicId } }] }] }
          : {}),
      },
      orderBy: [{ userId: "asc" }, { topicId: "asc" }],
      take: q.limit,
    });
    return rows.map(toState);
  }

  async getRankLevel(userId: string): Promise<number | null> {
    return (await this.prisma.userRank.findUnique({ where: { userId }, select: { level: true } }))?.level ?? null;
  }

  async saveRank(userId: string, r: { level: number; xp: number; familyCode: string | null; configVersion: string }): Promise<void> {
    await this.prisma.userRank.upsert({ where: { userId }, create: { userId, ...r }, update: r });
  }
}
