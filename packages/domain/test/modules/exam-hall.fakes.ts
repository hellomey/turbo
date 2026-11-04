// In-memory fakes for exam-hall unit tests (BOLT-0011). Mirrors the Prisma adapter's contract.
import { DomainError } from "../../src/shared/errors.js";
import type { ExamHallRepository, FinishInput, HistoryRow, PaperSource, QuestionSource, StartAttemptInput } from "../../src/modules/exam-hall/application/ports.js";
import { frac, type Fraction } from "../../src/modules/exam-hall/domain/fraction.js";
import type { RankRow } from "../../src/modules/exam-hall/domain/ranking.js";
import type { AttemptRecord, MockRecord, PaperView, SavedAnswer, SchemeSection } from "../../src/modules/exam-hall/domain/types.js";
import type { QuestionWithKey } from "../../src/modules/content/index.js";

let seq = 0;
export const uuid = (n = ++seq) => `0199f5a0-0000-7000-8000-${n.toString(16).padStart(12, "0")}`;

export class FakeExamHallRepo implements ExamHallRepository {
  mocks = new Map<string, MockRecord>();
  attempts = new Map<string, AttemptRecord>();
  answerRows = new Map<string, Map<string, SavedAnswer>>();
  allowance = new Set<string>();
  ranks = new Map<string, Map<string, RankRow & { publishedAt: Date }>>();

  async listPublishedMocks(examCode: string) {
    return [...this.mocks.values()].filter((m) => m.examCode === examCode && m.status === "published");
  }
  async findMock(id: string) {
    return this.mocks.get(id) ?? null;
  }
  async nextStateMock(examCode: string, now: Date) {
    return (
      [...this.mocks.values()]
        .filter((m) => m.examCode === examCode && m.status === "published" && m.kind === "state_mock_sunday" && (!m.closesAt || m.closesAt > now))
        .sort((a, b) => (a.opensAt?.getTime() ?? 0) - (b.opensAt?.getTime() ?? 0))[0] ?? null
    );
  }
  async findInProgress(userId: string, mockId: string) {
    return [...this.attempts.values()].find((a) => a.userId === userId && a.mockId === mockId && a.status === "in_progress") ?? null;
  }
  async lastAttemptIds(userId: string, mockIds: string[]) {
    const m = new Map<string, string>();
    for (const a of this.attempts.values()) if (a.userId === userId && mockIds.includes(a.mockId)) m.set(a.mockId, a.id);
    return m;
  }
  async allowanceUsed(userId: string, istMonth: string) {
    return this.allowance.has(`${userId}|${istMonth}`);
  }
  async startAttempt(input: StartAttemptInput) {
    const open = await this.findInProgress(input.userId, input.mockId);
    if (open) return { attempt: open, resumed: true };
    const key = `${input.userId}|${input.istMonth}`;
    if (input.useAllowance && this.allowance.has(key)) throw new DomainError("MOCK_MONTHLY_LIMIT");
    const before = [...this.attempts.values()].some((a) => a.userId === input.userId && a.mockId === input.mockId);
    const attempt: AttemptRecord = {
      id: uuid(),
      userId: input.userId,
      mockId: input.mockId,
      mode: input.mode,
      status: "in_progress",
      startedAt: input.startedAt,
      deadlineAt: input.deadlineAt,
      submittedAt: null,
      ranked: input.rankedIfFirst && !before,
      schemeVersion: input.schemeVersion,
      istMonth: input.istMonth,
      result: null,
    };
    this.attempts.set(attempt.id, attempt);
    if (input.useAllowance) this.allowance.add(key);
    return { attempt, resumed: false };
  }
  async findAttempt(id: string) {
    const a = this.attempts.get(id);
    return a ? { ...a } : null;
  }
  async answers(attemptId: string) {
    return [...(this.answerRows.get(attemptId)?.values() ?? [])];
  }
  async saveAnswers(attemptId: string, answers: SavedAnswer[], unrank: boolean) {
    const a = this.attempts.get(attemptId);
    if (!a || a.status !== "in_progress") return null;
    const rows = this.answerRows.get(attemptId) ?? new Map<string, SavedAnswer>();
    let saved = 0;
    for (const x of answers) {
      const prev = rows.get(x.questionId);
      if (!prev || prev.clientAt <= x.clientAt) {
        rows.set(x.questionId, x);
        saved += 1;
      }
    }
    this.answerRows.set(attemptId, rows);
    if (unrank) a.ranked = false;
    return saved;
  }
  async finishAttempt(attemptId: string, input: FinishInput) {
    const a = this.attempts.get(attemptId);
    if (!a) throw new Error("missing");
    if (a.status !== "in_progress") return { attempt: { ...a }, changed: false };
    Object.assign(a, { status: input.status, submittedAt: input.submittedAt, result: input.result });
    return { attempt: { ...a }, changed: true };
  }
  async history(userId: string, cursor: string | null, limit: number) {
    const all = [...this.attempts.values()].filter((a) => a.userId === userId).sort((x, y) => y.startedAt.getTime() - x.startedAt.getTime());
    const start = cursor ? Number(cursor) : 0;
    const rows: HistoryRow[] = all.slice(start, start + limit).map((attempt) => {
      const m = this.mocks.get(attempt.mockId);
      return { attempt, title: m?.title ?? "", kind: m?.kind ?? "full" };
    });
    return { rows, nextCursor: start + limit < all.length ? String(start + limit) : null };
  }
  async overdueAttemptIds(before: Date, limit: number) {
    return [...this.attempts.values()].filter((a) => a.status === "in_progress" && a.deadlineAt < before).slice(0, limit).map((a) => a.id);
  }
  async openAttempts(mockId: string) {
    return [...this.attempts.values()].filter((a) => a.mockId === mockId && a.status === "in_progress");
  }
  async mocksDueForRanks(now: Date) {
    return [...this.mocks.values()].filter(
      (m) => m.kind === "state_mock_sunday" && m.status === "published" && m.rankPublishAt && m.rankPublishAt <= now && !this.ranks.has(m.id),
    );
  }
  async rankedScores(mockId: string) {
    return [...this.attempts.values()]
      .filter((a) => a.mockId === mockId && a.ranked && a.status !== "in_progress" && a.result)
      .map((a) => ({ userId: a.userId, score: a.result?.score as Fraction }));
  }
  async insertRanks(mockId: string, rows: RankRow[], publishedAt: Date) {
    const m = this.ranks.get(mockId) ?? new Map();
    let n = 0;
    for (const r of rows) {
      if (m.has(r.userId)) continue;
      m.set(r.userId, { ...r, publishedAt });
      n += 1;
    }
    this.ranks.set(mockId, m);
    return n;
  }
  async ranksPublished(mockId: string) {
    return (this.ranks.get(mockId)?.size ?? 0) > 0;
  }
  async findRank(mockId: string, userId: string) {
    return this.ranks.get(mockId)?.get(userId) ?? null;
  }
  async rankedAttempt(mockId: string, userId: string) {
    return [...this.attempts.values()].find((a) => a.mockId === mockId && a.userId === userId && a.ranked && a.status !== "in_progress") ?? null;
  }
}

export const section = (code: string, over: Partial<SchemeSection> = {}): SchemeSection => ({
  code,
  name: `Section ${code}`,
  order: 1,
  questionCount: 4,
  attemptLimit: null,
  marksPerCorrect: frac(1),
  penaltyPerWrong: frac(0),
  minutes: null,
  ...over,
});

export class FakePapers implements PaperSource {
  papers = new Map<string, PaperView>();
  add(paperId: string, version: number, view: PaperView) {
    this.papers.set(`${paperId}|${version}`, view);
  }
  async paperForMock(paperId: string, version: number) {
    return this.papers.get(`${paperId}|${version}`) ?? null;
  }
}

export class FakeQuestions implements QuestionSource {
  items = new Map<string, QuestionWithKey>();
  add(id: string, topicId: string, correct: string[], whyWrong: Record<string, string> = {}) {
    const source = { citation: "Test", url: null, pyq: null };
    this.items.set(id, {
      question: { id, version: 1, topicId, kind: "single_choice", language: "en", stem: `Q ${id}`, options: [{ id: "A", text: "A" }, { id: "B", text: "B" }], difficulty: 3, source, affectedNote: null },
      key: { questionId: id, topicId, correctOptionIds: correct, explanationMarkdown: "Because.", whyWrong, source },
    });
  }
  async withKeys(ids: readonly string[]) {
    return ids.flatMap((id) => (this.items.has(id) ? [this.items.get(id) as QuestionWithKey] : []));
  }
}
