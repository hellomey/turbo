import { Prisma, type PrismaClient } from "@heymey/db";
import type {
  AnswerPlan,
  CommitOutcome,
  DrillRecord,
  MistakeRow,
  NewAnswer,
  NewSession,
  PracticeRepository,
  SessionRecord,
  StoredAnswer,
  AnswerTxState,
} from "../application/ports.js";
import type { Tally } from "../domain/mistakes.js";

type AnswerRow = Prisma.PracticeAnswerGetPayload<object>;
type SessionRow = Prisma.PracticeSessionGetPayload<object>;
type DrillRow = Prisma.ConceptDrillGetPayload<object>;

const toAnswer = (r: AnswerRow): StoredAnswer => ({
  id: r.id,
  userId: r.userId,
  clientActionId: r.clientActionId,
  sessionId: r.sessionId,
  questionId: r.questionId,
  questionVersion: r.questionVersion,
  topicId: r.topicId,
  mode: r.mode,
  chosenOptionIds: r.chosenOptionIds,
  correct: r.correct,
  answeredAt: r.answeredAt,
  istDay: r.istDay,
  countsToLimit: r.countsToLimit,
  studyLogOnly: r.studyLogOnly,
});

const toSession = (r: SessionRow): SessionRecord => ({
  id: r.id,
  userId: r.userId,
  mode: r.mode,
  examCode: r.examCode,
  questionIds: r.questionIds,
  startedAt: r.startedAt,
  closedAt: r.closedAt,
});

const toDrill = (r: DrillRow): DrillRecord => ({
  id: r.id,
  userId: r.userId,
  topicId: r.topicId,
  reason: r.reason,
  questionIds: r.questionIds,
  status: r.status === "done" ? "done" : "open",
  createdAt: r.createdAt,
});

const isUniqueViolation = (e: unknown) => e instanceof Prisma.PrismaClientKnownRequestError && e.code === "P2002";

/** Short transactions; generous waits so a burst of parallel answers queues on the row lock instead of failing. */
const TX = { maxWait: 20_000, timeout: 20_000 } as const;

/** Tables owned by practice only: PracticeSession, PracticeAnswer, PracticeDayCounter, MistakeTally, ConceptDrill (§34.8). */
export class PrismaPracticeRepository implements PracticeRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async createSession(s: NewSession): Promise<SessionRecord> {
    const row = await this.prisma.$transaction(async (tx) => {
      await tx.practiceSession.updateMany({ where: { userId: s.userId, closedAt: null }, data: { closedAt: s.startedAt } });
      return tx.practiceSession.create({ data: { ...s } });
    }, TX);
    return toSession(row);
  }

  async getSession(id: string): Promise<SessionRecord | null> {
    const r = await this.prisma.practiceSession.findUnique({ where: { id } });
    return r ? toSession(r) : null;
  }

  async findAnswer(userId: string, clientActionId: string): Promise<StoredAnswer | null> {
    const r = await this.prisma.practiceAnswer.findUnique({ where: { userId_clientActionId: { userId, clientActionId } } });
    return r ? toAnswer(r) : null;
  }

  async commitAnswer(a: NewAnswer, decide: (s: AnswerTxState) => AnswerPlan): Promise<CommitOutcome> {
    try {
      return await this.prisma.$transaction(async (tx): Promise<CommitOutcome> => {
        // Row lock on (user, IST day): every answer of this user on this day queues here, so the limit cannot be raced (inv. 3).
        await tx.$executeRaw`INSERT INTO "PracticeDayCounter" ("userId", "istDay", "counted", "limitSheetShown")
          VALUES (${a.userId}::uuid, ${a.istDay}, 0, false) ON CONFLICT DO NOTHING`;
        const [c] = await tx.$queryRaw<{ counted: number; limitSheetShown: boolean }[]>`
          SELECT "counted", "limitSheetShown" FROM "PracticeDayCounter"
          WHERE "userId" = ${a.userId}::uuid AND "istDay" = ${a.istDay} FOR UPDATE`;
        const dup = await tx.practiceAnswer.findUnique({ where: { userId_clientActionId: { userId: a.userId, clientActionId: a.clientActionId } } });
        if (dup) return { kind: "duplicate", answer: toAnswer(dup) };

        const t = await tx.mistakeTally.findUnique({ where: { userId_topicId: { userId: a.userId, topicId: a.topicId } } });
        const tally: Tally | null = t ? { wrongCount: t.wrongCount, windowStart: t.windowStart, lastWrongAt: t.lastWrongAt } : null;
        const open = await tx.conceptDrill.findFirst({ where: { userId: a.userId, topicId: a.topicId, status: "open" }, select: { id: true } });
        const counted = c?.counted ?? 0;
        const limitSheetShown = c?.limitSheetShown ?? false;
        const plan = decide({ counted, limitSheetShown, tally, hasOpenDrill: open !== null });

        if (plan.refuse) {
          if (!limitSheetShown) {
            await tx.practiceDayCounter.update({ where: { userId_istDay: { userId: a.userId, istDay: a.istDay } }, data: { limitSheetShown: true } });
          }
          return { kind: "refused", sheetFirstTime: !limitSheetShown };
        }

        await tx.practiceAnswer.create({
          data: {
            clientActionId: a.clientActionId,
            userId: a.userId,
            sessionId: a.sessionId,
            questionId: a.questionId,
            questionVersion: a.questionVersion,
            topicId: a.topicId,
            mode: a.mode,
            chosenOptionIds: a.chosenOptionIds,
            correct: a.correct,
            timeMs: a.timeMs,
            confidence: a.confidence,
            answeredAt: a.answeredAt,
            istDay: a.istDay,
            countsToLimit: plan.count,
            studyLogOnly: plan.studyLogOnly,
            source: a.source,
          },
        });
        if (plan.count) {
          await tx.practiceDayCounter.update({ where: { userId_istDay: { userId: a.userId, istDay: a.istDay } }, data: { counted: { increment: 1 } } });
        }
        if (plan.tally) {
          const data = { wrongCount: plan.tally.wrongCount, windowStart: plan.tally.windowStart, lastWrongAt: plan.tally.lastWrongAt };
          await tx.mistakeTally.upsert({
            where: { userId_topicId: { userId: a.userId, topicId: a.topicId } },
            create: { userId: a.userId, topicId: a.topicId, ...data },
            update: data,
          });
        }
        if (plan.drill) {
          await tx.conceptDrill.create({ data: { userId: a.userId, topicId: a.topicId, reason: plan.drill.reason, questionIds: plan.drill.questionIds, createdAt: a.answeredAt } });
        }
        if (a.sessionId) {
          const s = await tx.practiceSession.findUnique({ where: { id: a.sessionId }, select: { questionIds: true, closedAt: true } });
          const answered = await tx.practiceAnswer.count({ where: { sessionId: a.sessionId } });
          if (s && !s.closedAt && answered >= s.questionIds.length) {
            await tx.practiceSession.update({ where: { id: a.sessionId }, data: { closedAt: a.answeredAt } });
          }
        }
        return { kind: "stored", plan };
      }, TX);
    } catch (e) {
      // Same clientActionId raced on another day's counter row: the unique (userId, clientActionId) wins once (inv. 6).
      if (isUniqueViolation(e)) {
        const dup = await this.findAnswer(a.userId, a.clientActionId);
        if (dup) return { kind: "duplicate", answer: dup };
      }
      throw e;
    }
  }

  async dayCounter(userId: string, istDay: string): Promise<{ counted: number; limitSheetShown: boolean } | null> {
    const r = await this.prisma.practiceDayCounter.findUnique({ where: { userId_istDay: { userId, istDay } } });
    return r ? { counted: r.counted, limitSheetShown: r.limitSheetShown } : null;
  }

  async tallies(userId: string): Promise<(Tally & { topicId: string })[]> {
    const rows = await this.prisma.mistakeTally.findMany({ where: { userId } });
    return rows.map((r) => ({ topicId: r.topicId, wrongCount: r.wrongCount, windowStart: r.windowStart, lastWrongAt: r.lastWrongAt }));
  }

  async mistakes(
    userId: string,
    q: { topicIds?: readonly string[] | undefined; after?: { at: Date; questionId: string } | undefined; take: number },
  ): Promise<MistakeRow[]> {
    const topicFilter = q.topicIds ? Prisma.sql`AND "topicId" = ANY(${[...q.topicIds]}::uuid[])` : Prisma.empty;
    const afterFilter = q.after
      ? Prisma.sql`AND (l."answeredAt" < ${q.after.at} OR (l."answeredAt" = ${q.after.at} AND l."questionId" < ${q.after.questionId}::uuid))`
      : Prisma.empty;
    const rows = await this.prisma.$queryRaw<
      { questionId: string; questionVersion: number; topicId: string; chosenOptionIds: string[]; answeredAt: Date; wrongCount: number }[]
    >`
      WITH last AS (
        SELECT DISTINCT ON ("questionId") "questionId", "questionVersion", "topicId", "chosenOptionIds", "correct", "answeredAt"
        FROM "PracticeAnswer"
        WHERE "userId" = ${userId}::uuid ${topicFilter}
        ORDER BY "questionId", "answeredAt" DESC, "createdAt" DESC
      )
      SELECT l."questionId", l."questionVersion", l."topicId", l."chosenOptionIds", l."answeredAt",
        (SELECT count(*) FROM "PracticeAnswer" w WHERE w."userId" = ${userId}::uuid AND w."questionId" = l."questionId" AND NOT w."correct")::int AS "wrongCount"
      FROM last l
      WHERE NOT l."correct" ${afterFilter}
      ORDER BY l."answeredAt" DESC, l."questionId" DESC
      LIMIT ${q.take}`;
    return rows.map((r) => ({
      questionId: r.questionId,
      questionVersion: r.questionVersion,
      topicId: r.topicId,
      chosenOptionIds: r.chosenOptionIds,
      lastWrongAt: r.answeredAt,
      wrongCount: r.wrongCount,
    }));
  }

  async drills(userId: string): Promise<DrillRecord[]> {
    const rows = await this.prisma.conceptDrill.findMany({ where: { userId }, orderBy: [{ createdAt: "desc" }, { id: "desc" }], take: 50 });
    return rows.map(toDrill);
  }

  async getDrill(id: string): Promise<DrillRecord | null> {
    const r = await this.prisma.conceptDrill.findUnique({ where: { id } });
    return r ? toDrill(r) : null;
  }
}
