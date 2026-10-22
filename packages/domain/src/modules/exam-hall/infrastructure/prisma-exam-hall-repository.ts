import { Prisma, type PrismaClient, type Mock, type MockAttempt } from "@heymey/db";
import { DomainError } from "../../../shared/errors.js";
import type { ExamHallRepository, FinishInput, HistoryRow, StartAttemptInput } from "../application/ports.js";
import { frac, type Fraction } from "../domain/fraction.js";
import type { RankRow } from "../domain/ranking.js";
import type { AttemptRecord, AttemptScore, MockRecord, MockSectionRef, SavedAnswer, SectionScore } from "../domain/types.js";

/** Mock sections are typed by Ops: malformed entries are dropped, never guessed. */
export function parseSections(json: unknown): MockSectionRef[] {
  if (!Array.isArray(json)) return [];
  return json.flatMap((s: unknown) => {
    const r = s as { sectionCode?: unknown; questionIds?: unknown } | null;
    if (typeof r?.sectionCode !== "string" || !Array.isArray(r.questionIds)) return [];
    return [{ sectionCode: r.sectionCode, questionIds: r.questionIds.filter((q): q is string => typeof q === "string") }];
  });
}

function toMock(row: Mock): MockRecord {
  return {
    id: row.id,
    code: row.code,
    examCode: row.examCode,
    paperId: row.paperId,
    schemeVersion: row.schemeVersion,
    title: row.title,
    kind: row.kind,
    sections: parseSections(row.sections),
    opensAt: row.opensAt,
    lateJoinUntil: row.lateJoinUntil,
    closesAt: row.closesAt,
    rankPublishAt: row.rankPublishAt,
    free: row.free,
    status: row.status,
  };
}

interface StoredSection {
  code: string;
  name: string;
  correct: number;
  wrong: number;
  unanswered: number;
  score: [number, number];
  maxScore: [number, number];
}

function f(pair: unknown): Fraction {
  return Array.isArray(pair) && typeof pair[0] === "number" && typeof pair[1] === "number" ? frac(pair[0], pair[1]) : frac(0);
}

function toResult(row: MockAttempt): AttemptScore | null {
  if (row.scoreNum === null || row.scoreDen === null) return null;
  const stored = (row.sectionResults ?? { sections: [], maxScore: [0, 1] }) as { sections?: StoredSection[]; maxScore?: [number, number] };
  const sections: SectionScore[] = (stored.sections ?? []).map((s) => ({
    code: s.code,
    name: s.name,
    correct: s.correct,
    wrong: s.wrong,
    unanswered: s.unanswered,
    score: f(s.score),
    maxScore: f(s.maxScore),
  }));
  return {
    score: frac(row.scoreNum, row.scoreDen),
    maxScore: f(stored.maxScore),
    correct: row.correct ?? 0,
    wrong: row.wrong ?? 0,
    unanswered: row.unanswered ?? 0,
    sections,
  };
}

function toAttempt(row: MockAttempt): AttemptRecord {
  return {
    id: row.id,
    userId: row.userId,
    mockId: row.mockId,
    mode: row.mode === "cbt" ? "cbt" : "omr",
    status: row.status,
    startedAt: row.startedAt,
    deadlineAt: row.deadlineAt,
    submittedAt: row.submittedAt,
    ranked: row.ranked,
    schemeVersion: row.schemeVersion,
    istMonth: row.istMonth,
    result: toResult(row),
  };
}

function encodeCursor(row: { startedAt: Date; id: string }): string {
  return Buffer.from(`${row.startedAt.toISOString()}|${row.id}`).toString("base64url");
}

function decodeCursor(cursor: string): { startedAt: Date; id: string } | null {
  const [at, id] = Buffer.from(cursor, "base64url").toString("utf8").split("|");
  const startedAt = new Date(at ?? "");
  return id && !Number.isNaN(startedAt.getTime()) ? { startedAt, id } : null;
}

export class PrismaExamHallRepository implements ExamHallRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async listPublishedMocks(examCode: string): Promise<MockRecord[]> {
    const rows = await this.prisma.mock.findMany({ where: { examCode, status: "published" }, orderBy: [{ opensAt: "asc" }, { code: "asc" }] });
    return rows.map(toMock);
  }

  async findMock(id: string): Promise<MockRecord | null> {
    const row = await this.prisma.mock.findUnique({ where: { id } });
    return row ? toMock(row) : null;
  }

  async nextStateMock(examCode: string, now: Date): Promise<MockRecord | null> {
    const row = await this.prisma.mock.findFirst({
      where: { examCode, status: "published", kind: "state_mock_sunday", OR: [{ closesAt: null }, { closesAt: { gt: now } }] },
      orderBy: { opensAt: "asc" },
    });
    return row ? toMock(row) : null;
  }

  async findInProgress(userId: string, mockId: string): Promise<AttemptRecord | null> {
    const row = await this.prisma.mockAttempt.findFirst({ where: { userId, mockId, status: "in_progress" }, orderBy: { startedAt: "desc" } });
    return row ? toAttempt(row) : null;
  }

  async lastAttemptIds(userId: string, mockIds: string[]): Promise<Map<string, string>> {
    if (!mockIds.length) return new Map();
    const rows = await this.prisma.mockAttempt.findMany({
      where: { userId, mockId: { in: mockIds } },
      orderBy: { startedAt: "asc" },
      select: { id: true, mockId: true },
    });
    return new Map(rows.map((r) => [r.mockId, r.id]));
  }

  async allowanceUsed(userId: string, istMonth: string): Promise<boolean> {
    return (await this.prisma.mockAllowanceUse.count({ where: { userId, istMonth } })) > 0;
  }

  async startAttempt(input: StartAttemptInput): Promise<{ attempt: AttemptRecord; resumed: boolean }> {
    try {
      return await this.prisma.$transaction(async (tx) => {
        // Serialise starts per (user, mock): two parallel taps never create two attempts.
        await tx.$executeRaw`SELECT pg_advisory_xact_lock(hashtext(${`exam-hall:${input.userId}:${input.mockId}`}))`;
        const open = await tx.mockAttempt.findFirst({ where: { userId: input.userId, mockId: input.mockId, status: "in_progress" } });
        if (open) return { attempt: toAttempt(open), resumed: true };
        const before = await tx.mockAttempt.count({ where: { userId: input.userId, mockId: input.mockId } });
        const row = await tx.mockAttempt.create({
          data: {
            userId: input.userId,
            mockId: input.mockId,
            mode: input.mode,
            startedAt: input.startedAt,
            deadlineAt: input.deadlineAt,
            schemeVersion: input.schemeVersion,
            istMonth: input.istMonth,
            ranked: input.rankedIfFirst && before === 0,
          },
        });
        if (input.useAllowance) {
          await tx.mockAllowanceUse.create({ data: { userId: input.userId, istMonth: input.istMonth, attemptId: row.id } });
        }
        return { attempt: toAttempt(row), resumed: false };
      });
    } catch (e) {
      if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === "P2002") throw new DomainError("MOCK_MONTHLY_LIMIT");
      throw e;
    }
  }

  async findAttempt(id: string): Promise<AttemptRecord | null> {
    const row = await this.prisma.mockAttempt.findUnique({ where: { id } });
    return row ? toAttempt(row) : null;
  }

  async answers(attemptId: string): Promise<SavedAnswer[]> {
    const rows = await this.prisma.mockAnswer.findMany({ where: { attemptId } });
    return rows.map((r) => ({
      questionId: r.questionId,
      chosenOptionIds: r.chosenOptionIds,
      markedForReview: r.markedForReview,
      savedAt: r.savedAt,
      clientAt: r.clientAt,
    }));
  }

  async saveAnswers(attemptId: string, answers: SavedAnswer[], unrank: boolean): Promise<number | null> {
    return this.prisma.$transaction(async (tx) => {
      // Row lock: a concurrent submit/expire waits, so no answer lands after scoring.
      const locked = await tx.$queryRaw<{ status: string }[]>`SELECT status::text AS status FROM "MockAttempt" WHERE id = ${attemptId}::uuid FOR UPDATE`;
      if (locked[0]?.status !== "in_progress") return null;
      let saved = 0;
      for (const a of answers) {
        const n = await tx.$executeRaw`
          INSERT INTO "MockAnswer" ("attemptId", "questionId", "chosenOptionIds", "markedForReview", "savedAt", "clientAt")
          VALUES (${attemptId}::uuid, ${a.questionId}::uuid, ${a.chosenOptionIds}::text[], ${a.markedForReview}, ${a.savedAt}, ${a.clientAt})
          ON CONFLICT ("attemptId", "questionId") DO UPDATE SET
            "chosenOptionIds" = EXCLUDED."chosenOptionIds", "markedForReview" = EXCLUDED."markedForReview",
            "savedAt" = EXCLUDED."savedAt", "clientAt" = EXCLUDED."clientAt"
          WHERE "MockAnswer"."clientAt" <= EXCLUDED."clientAt"`;
        saved += n;
      }
      if (unrank) await tx.mockAttempt.update({ where: { id: attemptId }, data: { ranked: false } });
      return saved;
    });
  }

  async finishAttempt(attemptId: string, input: FinishInput): Promise<{ attempt: AttemptRecord; changed: boolean }> {
    const r = input.result;
    const { count } = await this.prisma.mockAttempt.updateMany({
      where: { id: attemptId, status: "in_progress" },
      data: {
        status: input.status,
        submittedAt: input.submittedAt,
        scoreNum: r.score.num,
        scoreDen: r.score.den,
        correct: r.correct,
        wrong: r.wrong,
        unanswered: r.unanswered,
        sectionResults: {
          maxScore: [r.maxScore.num, r.maxScore.den],
          sections: r.sections.map((s) => ({
            code: s.code,
            name: s.name,
            correct: s.correct,
            wrong: s.wrong,
            unanswered: s.unanswered,
            score: [s.score.num, s.score.den],
            maxScore: [s.maxScore.num, s.maxScore.den],
          })),
        },
      },
    });
    const row = await this.prisma.mockAttempt.findUniqueOrThrow({ where: { id: attemptId } });
    return { attempt: toAttempt(row), changed: count === 1 };
  }

  async history(userId: string, cursor: string | null, limit: number): Promise<{ rows: HistoryRow[]; nextCursor: string | null }> {
    const after = cursor ? decodeCursor(cursor) : null;
    const rows = await this.prisma.mockAttempt.findMany({
      where: {
        userId,
        ...(after ? { OR: [{ startedAt: { lt: after.startedAt } }, { startedAt: after.startedAt, id: { lt: after.id } }] } : {}),
      },
      orderBy: [{ startedAt: "desc" }, { id: "desc" }],
      take: limit + 1,
      include: { mock: { select: { title: true, kind: true } } },
    });
    const page = rows.slice(0, limit);
    const last = page.at(-1);
    return {
      rows: page.map((row) => ({ attempt: toAttempt(row), title: row.mock.title, kind: row.mock.kind })),
      nextCursor: rows.length > limit && last ? encodeCursor(last) : null,
    };
  }

  async overdueAttemptIds(before: Date, limit: number): Promise<string[]> {
    const rows = await this.prisma.mockAttempt.findMany({
      where: { status: "in_progress", deadlineAt: { lt: before } },
      orderBy: { deadlineAt: "asc" },
      take: limit,
      select: { id: true },
    });
    return rows.map((r) => r.id);
  }

  async openAttempts(mockId: string): Promise<AttemptRecord[]> {
    return (await this.prisma.mockAttempt.findMany({ where: { mockId, status: "in_progress" } })).map(toAttempt);
  }

  async mocksDueForRanks(now: Date): Promise<MockRecord[]> {
    const rows = await this.prisma.mock.findMany({
      where: { kind: "state_mock_sunday", status: "published", rankPublishAt: { lte: now } },
      orderBy: { rankPublishAt: "asc" },
    });
    const published = new Set(
      (await this.prisma.mockRank.groupBy({ by: ["mockId"], where: { mockId: { in: rows.map((r) => r.id) } } })).map((g) => g.mockId),
    );
    return rows.filter((r) => !published.has(r.id)).map(toMock);
  }

  async rankedScores(mockId: string): Promise<{ userId: string; score: Fraction }[]> {
    const rows = await this.prisma.mockAttempt.findMany({
      where: { mockId, ranked: true, status: { in: ["submitted", "expired"] }, scoreNum: { not: null } },
      select: { userId: true, scoreNum: true, scoreDen: true },
    });
    return rows.map((r) => ({ userId: r.userId, score: frac(r.scoreNum ?? 0, r.scoreDen ?? 1) }));
  }

  async insertRanks(mockId: string, rows: RankRow[], publishedAt: Date): Promise<number> {
    const { count } = await this.prisma.mockRank.createMany({
      data: rows.map((r) => ({ mockId, userId: r.userId, rank: r.rank, percentile: r.percentile, candidates: r.candidates, publishedAt })),
      skipDuplicates: true,
    });
    return count;
  }

  async ranksPublished(mockId: string): Promise<boolean> {
    return (await this.prisma.mockRank.count({ where: { mockId } })) > 0;
  }

  async findRank(mockId: string, userId: string): Promise<{ rank: number; percentile: number; candidates: number; publishedAt: Date } | null> {
    return this.prisma.mockRank.findUnique({
      where: { mockId_userId: { mockId, userId } },
      select: { rank: true, percentile: true, candidates: true, publishedAt: true },
    });
  }

  async rankedAttempt(mockId: string, userId: string): Promise<AttemptRecord | null> {
    const row = await this.prisma.mockAttempt.findFirst({ where: { mockId, userId, ranked: true, status: { in: ["submitted", "expired"] } } });
    return row ? toAttempt(row) : null;
  }
}
