// In-memory fakes for the practice use cases (same contract as the Prisma adapter, checked by practice.int.spec.ts).
import { randomUUID } from "node:crypto";
import type { FakeClock } from "@heymey/testing";
import { DomainError, type DomainEvent } from "../../src/shared/index.js";
import type { PracticeContentApi, QuestionDto, QuestionWithKey } from "../../src/modules/content/index.js";
import {
  createPracticeModule,
  type AnswerPlan,
  type AnswerTxState,
  type CommitOutcome,
  type DrillRecord,
  type MistakeRow,
  type NewAnswer,
  type NewSession,
  type PracticeRepository,
  type SessionRecord,
  type StoredAnswer,
  type Tally,
} from "../../src/modules/practice/index.js";

export class MemoryPracticeRepo implements PracticeRepository {
  sessions = new Map<string, SessionRecord>();
  answers = new Map<string, NewAnswer & { id: string; countsToLimit: boolean; studyLogOnly: boolean }>();
  counters = new Map<string, { counted: number; limitSheetShown: boolean }>();
  tallyMap = new Map<string, Tally>();
  drillMap = new Map<string, DrillRecord>();

  async createSession(s: NewSession): Promise<SessionRecord> {
    for (const x of this.sessions.values()) if (x.userId === s.userId && !x.closedAt) x.closedAt = s.startedAt;
    const r: SessionRecord = { id: randomUUID(), userId: s.userId, mode: s.mode, examCode: s.examCode, questionIds: s.questionIds, startedAt: s.startedAt, closedAt: null };
    this.sessions.set(r.id, r);
    return { ...r };
  }
  async getSession(id: string) {
    const s = this.sessions.get(id);
    return s ? { ...s } : null;
  }
  async findAnswer(userId: string, clientActionId: string): Promise<StoredAnswer | null> {
    return this.answers.get(`${userId}|${clientActionId}`) ?? null;
  }
  async commitAnswer(a: NewAnswer, decide: (s: AnswerTxState) => AnswerPlan): Promise<CommitOutcome> {
    const key = `${a.userId}|${a.clientActionId}`;
    const dup = this.answers.get(key);
    if (dup) return { kind: "duplicate", answer: dup };
    const ck = `${a.userId}|${a.istDay}`;
    const c = this.counters.get(ck) ?? { counted: 0, limitSheetShown: false };
    this.counters.set(ck, c);
    const tk = `${a.userId}|${a.topicId}`;
    const hasOpenDrill = [...this.drillMap.values()].some((d) => d.userId === a.userId && d.topicId === a.topicId && d.status === "open");
    const plan = decide({ counted: c.counted, limitSheetShown: c.limitSheetShown, tally: this.tallyMap.get(tk) ?? null, hasOpenDrill });
    if (plan.refuse) {
      const first = !c.limitSheetShown;
      c.limitSheetShown = true;
      return { kind: "refused", sheetFirstTime: first };
    }
    this.answers.set(key, { ...a, id: randomUUID(), countsToLimit: plan.count, studyLogOnly: plan.studyLogOnly });
    if (plan.count) c.counted++;
    if (plan.tally) this.tallyMap.set(tk, plan.tally);
    if (plan.drill) {
      const id = randomUUID();
      this.drillMap.set(id, { id, userId: a.userId, topicId: a.topicId, reason: plan.drill.reason, questionIds: plan.drill.questionIds, status: "open", createdAt: a.answeredAt });
    }
    if (a.sessionId) {
      const s = this.sessions.get(a.sessionId);
      const n = [...this.answers.values()].filter((x) => x.sessionId === a.sessionId).length;
      if (s && !s.closedAt && n >= s.questionIds.length) s.closedAt = a.answeredAt;
    }
    return { kind: "stored", plan };
  }
  async dayCounter(userId: string, istDay: string) {
    const c = this.counters.get(`${userId}|${istDay}`);
    return c ? { ...c } : null;
  }
  async tallies(userId: string) {
    return [...this.tallyMap.entries()].filter(([k]) => k.startsWith(`${userId}|`)).map(([k, t]) => ({ ...t, topicId: k.split("|")[1] as string }));
  }
  async mistakes(userId: string, q: { topicIds?: readonly string[] | undefined; after?: { at: Date; questionId: string } | undefined; take: number }): Promise<MistakeRow[]> {
    const mine = [...this.answers.values()].filter((a) => a.userId === userId && (!q.topicIds || q.topicIds.includes(a.topicId)));
    const last = new Map<string, (typeof mine)[number]>();
    for (const a of mine) {
      const cur = last.get(a.questionId);
      if (!cur || a.answeredAt >= cur.answeredAt) last.set(a.questionId, a);
    }
    return [...last.values()]
      .filter((a) => !a.correct)
      .map((a) => ({
        questionId: a.questionId,
        questionVersion: a.questionVersion,
        topicId: a.topicId,
        chosenOptionIds: a.chosenOptionIds,
        lastWrongAt: a.answeredAt,
        wrongCount: mine.filter((x) => x.questionId === a.questionId && !x.correct).length,
      }))
      .sort((x, y) => y.lastWrongAt.getTime() - x.lastWrongAt.getTime() || y.questionId.localeCompare(x.questionId))
      .filter((r) => !q.after || r.lastWrongAt < q.after.at || (r.lastWrongAt.getTime() === q.after.at.getTime() && r.questionId < q.after.questionId))
      .slice(0, q.take);
  }
  async drills(userId: string) {
    return [...this.drillMap.values()].filter((d) => d.userId === userId);
  }
  async getDrill(id: string) {
    return this.drillMap.get(id) ?? null;
  }
}

export const EXAM = "tnpsc-group-4";
export const TOPIC_A = "0199f5a0-0101-7000-8000-00000000000a";
export const TOPIC_B = "0199f5a0-0101-7000-8000-00000000000b";

export function makeQuestion(i: number, topicId: string, pyqYear: number | null = null): QuestionWithKey {
  const id = `0199f5a0-0202-7000-8000-${String(i).padStart(12, "0")}`;
  const source = { citation: "HeyMey original question", url: null, pyq: pyqYear ? { examCode: EXAM, paperCode: null, year: pyqYear, questionNumber: i } : null };
  return {
    question: { id, version: 1, topicId, kind: "single_choice", language: "en", stem: `Q${i}`, options: [{ id: "a", text: "A" }, { id: "b", text: "B" }], difficulty: 3, source, affectedNote: null },
    key: { questionId: id, topicId, correctOptionIds: ["a"], explanationMarkdown: "Because.", whyWrong: { b: "B is wrong" }, source },
  };
}

/** Content fake: one exam with two lamps in subject "polity"; PYQs in 2021-2024. */
export class FakeContent implements PracticeContentApi {
  bank: QuestionWithKey[] = [];
  reports: unknown[] = [];
  constructor() {
    for (let i = 0; i < 20; i++) this.bank.push(makeQuestion(i, i % 2 ? TOPIC_B : TOPIC_A, i < 8 ? 2021 + (i % 4) : null));
  }
  private pyqOf(q: QuestionDto) {
    return q.source.pyq;
  }
  async scope(q: { examCode: string; subjectCode?: string | undefined; topicId?: string | undefined }) {
    if (q.examCode !== EXAM) throw new DomainError("EXAM_NOT_FOUND");
    if (q.topicId) {
      if (![TOPIC_A, TOPIC_B].includes(q.topicId)) throw new DomainError("TOPIC_NOT_FOUND");
      return [q.topicId];
    }
    if (q.subjectCode && q.subjectCode !== "polity") throw new DomainError("TOPIC_NOT_FOUND");
    return [TOPIC_A, TOPIC_B];
  }
  async pick(q: { topicIds: readonly string[]; count: number; pyqExamCode?: string | undefined; pyqYears?: readonly number[] | undefined }) {
    return this.bank
      .map((b) => b.question)
      .filter((x) => q.topicIds.includes(x.topicId))
      .filter((x) => !q.pyqExamCode || (this.pyqOf(x) && (!q.pyqYears || q.pyqYears.includes(this.pyqOf(x)?.year ?? 0))))
      .slice(0, q.count);
  }
  async questions(ids: readonly string[]) {
    return ids.flatMap((id) => this.bank.filter((b) => b.question.id === id).map((b) => b.question));
  }
  async atVersion(refs: readonly { questionId: string; version: number }[]) {
    return this.bank.filter((b) => refs.some((r) => r.questionId === b.question.id && r.version === b.question.version));
  }
  async pyqYears() {
    const counts = new Map<number, number>();
    for (const b of this.bank) {
      const y = this.pyqOf(b.question)?.year;
      if (y) counts.set(y, (counts.get(y) ?? 0) + 1);
    }
    return [...counts.entries()].sort((a, b) => b[0] - a[0]).map(([year, count]) => ({ year, count }));
  }
  async pyqPage(f: { examCode: string; topicIds?: readonly string[] | undefined; year?: number | undefined; difficulty?: number | undefined; after?: { year: number; id: string } | undefined; take: number }) {
    return this.bank
      .flatMap((b) => {
        const y = this.pyqOf(b.question)?.year;
        return y ? [{ question: b.question, year: y }] : [];
      })
      .filter((r) => (!f.topicIds || f.topicIds.includes(r.question.topicId)) && (f.year === undefined || r.year === f.year) && (f.difficulty === undefined || r.question.difficulty === f.difficulty))
      .sort((a, b) => b.year - a.year || a.question.id.localeCompare(b.question.id))
      .filter((r) => !f.after || r.year < f.after.year || (r.year === f.after.year && r.question.id > f.after.id))
      .slice(0, f.take);
  }
  async pyqSubjects() {
    return [{ code: "polity", name: "Polity", count: 8 }];
  }
  async report() {
    return { reportId: randomUUID(), status: "received" as const };
  }
  async packs() {
    return { items: [] };
  }
}

export function buildPractice(clock: FakeClock, opts: { entitlement?: "free" | "pro" } = {}) {
  const repo = new MemoryPracticeRepo();
  const content = new FakeContent();
  const events: DomainEvent[] = [];
  const api = createPracticeModule({
    repository: repo,
    clock,
    content,
    billing: { entitlementOf: async () => opts.entitlement ?? "free" },
    events: { publish: async (e) => void events.push(e) },
  });
  return { api, repo, content, events };
}
