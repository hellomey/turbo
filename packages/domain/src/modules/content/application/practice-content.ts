import type { ContentPack, QuestionReportAck, QuestionReportBody, z } from "@heymey/contracts";
import { DomainError } from "../../../shared/index.js";
import type { TopicRow } from "../../syllabus/index.js";
import { shuffle, type QuestionDto, type QuestionWithKey } from "../domain/question.js";

/**
 * Questions for practice + PYQ Vault, question reports and offline packs (BOLT-0010; blueprint §10.6, §11, §19.4, §39).
 * Content owns the tables; `practice` reaches them only through this API (§34.8). Locking for Free users is decided by
 * the caller (practice / API composition with billing): content only reports facts.
 */
export type ContentPackDto = z.infer<typeof ContentPack>;
export type QuestionReportAckDto = z.infer<typeof QuestionReportAck>;
export type QuestionReportInput = z.infer<typeof QuestionReportBody>;

export interface PackRow {
  id: string;
  code: string;
  examCode: string;
  subjectCode: string | null;
  version: number;
  url: string;
  sha256: string;
  sizeBytes: number;
  tier: "free" | "pro";
  publishedAt: Date;
}

export interface PyqFilter {
  examCode: string;
  topicIds?: readonly string[] | undefined;
  year?: number | undefined;
  difficulty?: number | undefined;
  /** Keyset cursor: order is (year desc, id asc). */
  after?: { year: number; id: string } | undefined;
  take: number;
}

/** Port: read/write over content-owned tables. */
export interface PracticeContentStore {
  candidateIds(q: { topicIds: readonly string[]; pyqExamCode?: string | undefined; pyqYears?: readonly number[] | undefined }): Promise<string[]>;
  latest(ids: readonly string[]): Promise<QuestionWithKey[]>;
  /** A specific version (published or superseded) with its key: grading uses the version answered (inv. 7). */
  atVersion(refs: readonly { questionId: string; version: number }[]): Promise<QuestionWithKey[]>;
  pyqYears(examCode: string): Promise<{ year: number; count: number }[]>;
  pyqPage(f: PyqFilter): Promise<{ question: QuestionDto; year: number }[]>;
  pyqTopicCounts(examCode: string): Promise<{ topicId: string; count: number }[]>;
  questionVersionExists(questionId: string, version: number): Promise<"ok" | "no_question" | "no_version">;
  insertReport(r: { userId: string; questionId: string; questionVersion: number; reason: string; note: string | null }): Promise<string>;
  publishedPacks(examCode: string): Promise<PackRow[]>;
}

export interface PracticeContentApi {
  /** Lamps of an exam narrowed by subject or topic. EXAM_NOT_FOUND (exam has no lamps) / TOPIC_NOT_FOUND. */
  scope(q: { examCode: string; subjectCode?: string | undefined; topicId?: string | undefined }): Promise<string[]>;
  /** Up to `count` random published objective questions (CSPRNG), never `descriptive`. */
  pick(q: { topicIds: readonly string[]; count: number; pyqExamCode?: string | undefined; pyqYears?: readonly number[] | undefined }): Promise<QuestionDto[]>;
  /** Latest published versions, in the order asked; unknown ids are left out. */
  questions(ids: readonly string[]): Promise<QuestionDto[]>;
  atVersion(refs: readonly { questionId: string; version: number }[]): Promise<QuestionWithKey[]>;
  pyqYears(examCode: string): Promise<{ year: number; count: number }[]>;
  pyqPage(f: PyqFilter): Promise<{ question: QuestionDto; year: number }[]>;
  pyqSubjects(examCode: string): Promise<{ code: string; name: string; count: number }[]>;
  report(userId: string, questionId: string, body: QuestionReportInput): Promise<QuestionReportAckDto>;
  /** Latest published version of each pack. Free users get `pro` packs as `locked` (§11 "Offline downloads: Free content"). */
  packs(examCode: string, entitled: boolean): Promise<{ items: ContentPackDto[] }>;
}

export interface PracticeContentDeps {
  store: PracticeContentStore;
  syllabus: { topicsForExam(examCode: string): Promise<TopicRow[]>; topic(topicId: string): Promise<TopicRow | null> };
  randomInt: (maxExclusive: number) => number;
}

export function practiceContent(d: PracticeContentDeps): PracticeContentApi {
  return {
    async scope({ examCode, subjectCode, topicId }) {
      const topics = await d.syllabus.topicsForExam(examCode);
      if (!topics.length) throw new DomainError("EXAM_NOT_FOUND");
      if (topicId) {
        if (!topics.some((t) => t.id === topicId)) throw new DomainError("TOPIC_NOT_FOUND");
        return [topicId];
      }
      if (subjectCode) {
        const ids = topics.filter((t) => t.subject.code === subjectCode).map((t) => t.id);
        if (!ids.length) throw new DomainError("TOPIC_NOT_FOUND");
        return ids;
      }
      return topics.map((t) => t.id);
    },
    async pick({ topicIds, count, pyqExamCode, pyqYears }) {
      if (!topicIds.length || count < 1) return [];
      const ids = await d.store.candidateIds({ topicIds, pyqExamCode, pyqYears });
      const chosen = shuffle(ids, d.randomInt).slice(0, count);
      return orderLike(chosen, (await d.store.latest(chosen)).map((r) => r.question));
    },
    async questions(ids) {
      return orderLike(ids, (await d.store.latest(ids)).map((r) => r.question));
    },
    atVersion: (refs) => d.store.atVersion(refs),
    pyqYears: (examCode) => d.store.pyqYears(examCode),
    pyqPage: (f) => d.store.pyqPage(f),
    async pyqSubjects(examCode) {
      const topics = new Map((await d.syllabus.topicsForExam(examCode)).map((t) => [t.id, t]));
      const subjects = new Map<string, { code: string; name: string; count: number; order: number }>();
      for (const { topicId, count } of await d.store.pyqTopicCounts(examCode)) {
        const t = topics.get(topicId);
        if (!t) continue;
        const s = subjects.get(t.subject.code) ?? { code: t.subject.code, name: t.subject.name, count: 0, order: t.subject.order };
        s.count += count;
        subjects.set(s.code, s);
      }
      return [...subjects.values()].sort((a, b) => a.order - b.order || a.code.localeCompare(b.code)).map(({ code, name, count }) => ({ code, name, count }));
    },
    async report(userId, questionId, body) {
      const found = await d.store.questionVersionExists(questionId, body.questionVersion);
      if (found === "no_question") throw new DomainError("QUESTION_NOT_FOUND");
      if (found === "no_version") throw new DomainError("VALIDATION_FAILED", { field: "questionVersion" });
      const reportId = await d.store.insertReport({ userId, questionId, questionVersion: body.questionVersion, reason: body.reason, note: body.note ?? null });
      return { reportId, status: "received" };
    },
    async packs(examCode, entitled) {
      const latest = new Map<string, PackRow>();
      for (const p of await d.store.publishedPacks(examCode)) {
        const cur = latest.get(p.code);
        if (!cur || p.version > cur.version) latest.set(p.code, p);
      }
      const items = [...latest.values()]
        .sort((a, b) => a.code.localeCompare(b.code))
        .map((p) => ({ ...p, publishedAt: p.publishedAt.toISOString(), locked: p.tier === "pro" && !entitled }));
      return { items };
    },
  };
}

function orderLike(ids: readonly string[], qs: QuestionDto[]): QuestionDto[] {
  const byId = new Map(qs.map((q) => [q.id, q]));
  return ids.flatMap((id) => {
    const q = byId.get(id);
    return q ? [q] : [];
  });
}
