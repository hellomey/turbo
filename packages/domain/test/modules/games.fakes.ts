import type { QuestionWithKey } from "../../src/modules/content/index.js";
import type { DuelQuestionsPort, DuelRow, GamesRepository, GameRewardsPort, SpinRow } from "../../src/modules/games/index.js";

/** In-memory GamesRepository with the same uniqueness rules as the Prisma adapter. */
export class FakeGamesRepo implements GamesRepository {
  spins: SpinRow[] = [];
  duels: DuelRow[] = [];
  private seq = 0;

  async spinOf(userId: string, day: string) {
    return this.spins.find((s) => s.userId === userId && s.day === day) ?? null;
  }
  async insertSpin(row: SpinRow) {
    if (await this.spinOf(row.userId, row.day)) return false;
    this.spins.push(row);
    return true;
  }
  async createDuel(d: Omit<DuelRow, "id" | "submittedAt" | "pointsAwarded" | "result">) {
    const id = `0199f5a0-0000-7000-8000-${String(++this.seq).padStart(12, "0")}`;
    this.duels.push({ ...d, id, submittedAt: null, pointsAwarded: 0, result: null });
    return id;
  }
  async duel(id: string) {
    return this.duels.find((d) => d.id === id) ?? null;
  }
  async finishDuel(id: string, f: { submittedAt: Date; pointsAwarded: number; result: unknown }) {
    const d = this.duels.find((x) => x.id === id);
    if (!d || d.submittedAt) return false;
    Object.assign(d, f);
    return true;
  }
  async duelPointsBetween(userId: string, from: Date, to: Date) {
    return this.duels.filter((d) => d.userId === userId && d.submittedAt && d.submittedAt >= from && d.submittedAt < to).reduce((s, d) => s + d.pointsAwarded, 0);
  }
}

/** Records every Points award; idempotent per source key like the economy ledger. */
export class FakeRewards implements GameRewardsPort {
  awards: { userId: string; game: string; amount: number; sourceKey: string }[] = [];
  async awardPoints(a: { userId: string; game: string; amount: number; sourceKey: string }) {
    if (this.awards.some((x) => x.sourceKey === a.sourceKey)) return false;
    this.awards.push(a);
    return true;
  }
}

/** Five single-choice questions; option "a" is always right. */
export function fakeQuestions(count = 5): DuelQuestionsPort & { bank: QuestionWithKey[] } {
  const bank: QuestionWithKey[] = Array.from({ length: count }, (_, i) => {
    const id = `0199f5a1-0000-7000-8000-${String(i + 1).padStart(12, "0")}`;
    const source = { citation: "HeyMey original question", url: null, pyq: null };
    return {
      question: {
        id, version: 1, topicId: "0199f5a2-0000-7000-8000-000000000001", kind: "single_choice", language: "en", stem: `Q${i + 1}`,
        options: [{ id: "a", text: "A" }, { id: "b", text: "B" }], difficulty: 2, source, affectedNote: null,
      },
      key: { questionId: id, topicId: "0199f5a2-0000-7000-8000-000000000001", correctOptionIds: ["a"], explanationMarkdown: `Because ${i + 1}`, whyWrong: {}, source },
    } as QuestionWithKey;
  });
  return {
    bank,
    async pick(examCode, n) {
      if (examCode !== "g4") return [];
      return bank.slice(0, n).map((b) => b.question);
    },
    async keys(refs) {
      return bank.filter((b) => refs.some((r) => r.questionId === b.question.id && r.version === b.question.version));
    },
  };
}
