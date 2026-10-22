// In-memory fakes for the mastery use cases (same contract as the Prisma adapter, checked by mastery.int.spec.ts).
import { randomUUID } from "node:crypto";
import type { DomainEvent } from "../../src/shared/index.js";
import type { QuestionBank } from "../../src/modules/content/index.js";
import type { TopicRow } from "../../src/modules/syllabus/index.js";
import {
  createMasteryModule,
  type CheckRecord,
  type Commit,
  type CommitResult,
  type LampState,
  type MasteryRepository,
} from "../../src/modules/mastery/index.js";
import type { FakeClock } from "@heymey/testing";

export interface StoredEvent {
  userId: string;
  topicId: string;
  kind: string;
  at: Date;
  source: string;
  clientActionId: string | null;
  checkId: string | null;
  details: Record<string, unknown> | null;
}

export class MemoryMasteryRepo implements MasteryRepository {
  states = new Map<string, LampState>();
  checks = new Map<string, CheckRecord>();
  events: StoredEvent[] = [];
  ranks = new Map<string, { level: number; xp: number }>();
  /** Test hook: run before the next commit (simulate a concurrent writer). */
  beforeCommit: (() => void) | null = null;

  private key = (u: string, t: string) => `${u}|${t}`;

  async getState(userId: string, topicId: string) {
    const s = this.states.get(this.key(userId, topicId));
    return s ? { ...s } : null;
  }
  async statesFor(userId: string, topicIds: readonly string[]) {
    return [...this.states.values()].filter((s) => s.userId === userId && topicIds.includes(s.topicId)).map((s) => ({ ...s }));
  }
  async pageStates(q: Parameters<MasteryRepository["pageStates"]>[0]) {
    return [...this.states.values()]
      .filter((s) => s.userId === q.userId && q.topicIds.includes(s.topicId))
      .filter((s) => !q.since || s.updatedAt > q.since)
      .filter(
        (s) =>
          !q.after ||
          s.updatedAt > q.after.updatedAt ||
          (s.updatedAt.getTime() === q.after.updatedAt.getTime() && s.topicId > q.after.topicId),
      )
      .sort((a, b) => a.updatedAt.getTime() - b.updatedAt.getTime() || a.topicId.localeCompare(b.topicId))
      .slice(0, q.limit)
      .map((s) => ({ ...s }));
  }
  async commit(c: Commit): Promise<CommitResult> {
    const hook = this.beforeCommit;
    this.beforeCommit = null;
    hook?.();
    if (c.check && this.checks.get(c.check.id)?.submittedAt) return "duplicate";
    const ids = c.events.map((e) => e.clientActionId).filter(Boolean);
    if (ids.some((id) => this.events.some((e) => e.clientActionId === id))) return "duplicate";
    if (c.state) {
      const k = this.key(c.state.next.userId, c.state.next.topicId);
      const cur = this.states.get(k);
      if (c.state.expectedVersion === null ? cur : cur?.rowVersion !== c.state.expectedVersion) return "conflict";
    }
    if (c.check) {
      const ch = this.checks.get(c.check.id);
      if (ch) Object.assign(ch, { submittedAt: c.check.submittedAt, correct: c.check.correct, passed: c.check.passed });
    }
    if (c.state) {
      const { next, expectedVersion } = c.state;
      this.states.set(this.key(next.userId, next.topicId), { ...next, rowVersion: expectedVersion === null ? 0 : expectedVersion + 1 });
    }
    for (const e of c.events)
      this.events.push({ ...e, clientActionId: e.clientActionId ?? null, checkId: e.checkId ?? null, details: e.details ?? null });
    return "ok";
  }
  async createCheck(c: Omit<CheckRecord, "id" | "submittedAt" | "correct" | "passed">) {
    const rec: CheckRecord = { ...c, id: randomUUID(), submittedAt: null, correct: null, passed: null };
    this.checks.set(rec.id, rec);
    return { ...rec };
  }
  async getCheck(id: string) {
    const c = this.checks.get(id);
    return c ? { ...c } : null;
  }
  async countChecksSince(userId: string, topicId: string, kind: string, since: Date) {
    return [...this.checks.values()].filter((c) => c.userId === userId && c.topicId === topicId && c.kind === kind && c.issuedAt >= since).length;
  }
  async hasClientAction(id: string) {
    return this.events.some((e) => e.clientActionId === id);
  }
  async dimmingCandidates(q: Parameters<MasteryRepository["dimmingCandidates"]>[0]) {
    return [...this.states.values()]
      .filter(
        (s) =>
          s.litAt &&
          s.nextDueAt &&
          ((s.dimState === "bright" && s.nextDueAt <= q.now) || (s.dimState === "dimming" && s.nextDueAt <= q.dimCutoff)),
      )
      .sort((a, b) => a.userId.localeCompare(b.userId) || a.topicId.localeCompare(b.topicId))
      .filter((s) => !q.after || s.userId > q.after.userId || (s.userId === q.after.userId && s.topicId > q.after.topicId))
      .slice(0, q.limit)
      .map((s) => ({ ...s }));
  }
  async getRankLevel(userId: string) {
    return this.ranks.get(userId)?.level ?? null;
  }
  async saveRank(userId: string, r: { level: number; xp: number }) {
    this.ranks.set(userId, { level: r.level, xp: r.xp });
  }
}

export const U1 = "0199f5a0-aaaa-7000-8000-000000000001";
export const U2 = "0199f5a0-aaaa-7000-8000-000000000002";
export const topicId = (n: number) => `0199f5a0-0000-7000-8000-${String(n).padStart(12, "0")}`;
export const qid = (topic: number, n: number) => `0199f5a0-${String(topic).padStart(4, "0")}-7000-9000-${String(n).padStart(12, "0")}`;

/** Topics 1..6: 1-4 in exam A, 3-6 in exam B (3 and 4 are shared lamps). */
export function topicRows(): TopicRow[] {
  return [1, 2, 3, 4, 5, 6].map((n) => ({
    id: topicId(n),
    code: `subj.t${n}`,
    name: `Topic ${n}`,
    order: n,
    subject: { code: n <= 3 ? "polity" : "history", name: n <= 3 ? "Polity" : "History", order: n <= 3 ? 1 : 2 },
    examCodes: [...(n <= 4 ? ["exam-a"] : []), ...(n >= 3 ? ["exam-b"] : [])],
  }));
}

/** 20 questions per topic; the correct option of each is "a" (difficulty 1..5 cycling). */
export function fakeBank(): QuestionBank & { picks: number } {
  const bank = {
    picks: 0,
    async pick({ topicId: t, count, minDifficulty }: { topicId: string; count: number; minDifficulty: number }) {
      bank.picks++;
      const n = Number(t.slice(-12));
      if (n === 6) return []; // topic 6 has no questions
      return Array.from({ length: 20 }, (_, i) => ({ i, d: (i % 5) + 1 }))
        .filter((x) => x.d >= minDifficulty)
        .slice(0, count)
        .map((x) => ({
          id: qid(n, x.i),
          version: 1,
          topicId: t,
          kind: "single_choice" as const,
          language: "en" as const,
          stem: `Q${x.i}`,
          options: [
            { id: "a", text: "A" },
            { id: "b", text: "B" },
          ],
          difficulty: x.d,
          source: { citation: "test", url: null, pyq: null },
          affectedNote: null,
        }));
    },
    async grade(answers: readonly { questionId: string; chosenOptionIds: readonly string[] }[]) {
      return answers.map((a) => {
        const topic = Number(a.questionId.slice(9, 13));
        const correct = a.chosenOptionIds.length === 1 && a.chosenOptionIds[0] === "a";
        return {
          questionId: a.questionId,
          correct,
          correctOptionIds: ["a"],
          chosenOptionIds: [...a.chosenOptionIds],
          explanationMarkdown: "because",
          whyChosenIsWrong: null,
          source: { citation: "test", url: null, pyq: null },
          topicId: topicId(topic),
        };
      });
    },
  };
  return bank;
}

export function makeMastery(clock: FakeClock, opts: { exams?: Record<string, string[]>; openable?: (ids: string[]) => Set<string> } = {}) {
  const repo = new MemoryMasteryRepo();
  const rows = topicRows();
  const published: DomainEvent[] = [];
  const bank = fakeBank();
  const exams = opts.exams ?? { [U1]: ["exam-a", "exam-b"], [U2]: ["exam-a"] };
  const api = createMasteryModule({
    repository: repo,
    clock,
    syllabus: {
      topic: async (id) => rows.find((r) => r.id === id) ?? null,
      topicsForExam: async (code) => rows.filter((r) => r.examCodes.includes(code)),
    },
    questions: bank,
    openableTopics: async (ids) => (opts.openable ? opts.openable(ids) : new Set(ids)),
    learner: {
      examCodes: async (u) => exams[u] ?? [],
      publishedExamCodes: async () => new Set(["exam-a", "exam-b"]),
    },
    events: { publish: async (e) => void published.push(e) },
  });
  return { api, repo, published, bank };
}

/** All correct ("a") or all wrong ("b") answers for a check's questions. */
export const answersFor = (questionIds: string[], right: number) =>
  questionIds.map((id, i) => ({ questionId: id, chosenOptionIds: [i < right ? "a" : "b"] }));
