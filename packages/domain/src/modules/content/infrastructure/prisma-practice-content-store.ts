import type { Prisma, PrismaClient } from "@heymey/db";
import type { PackRow, PracticeContentStore, PyqFilter } from "../application/practice-content.js";
import { sourceOf, type QuestionDto, type QuestionWithKey } from "../domain/question.js";
import { PrismaQuestionReader } from "./prisma-question-reader.js";

const LANGS = new Set(["en", "ta", "hi"]);
const OBJECTIVE = ["single_choice", "multi_choice"] as const;

function options(json: unknown): { id: string; text: string }[] {
  if (!Array.isArray(json)) return [];
  return json.flatMap((o: unknown) => {
    const r = o as { id?: unknown; text?: unknown };
    return typeof r?.id === "string" && typeof r.text === "string" ? [{ id: r.id, text: r.text }] : [];
  });
}

function whyWrong(json: unknown): Record<string, string> {
  if (!json || typeof json !== "object" || Array.isArray(json)) return {};
  return Object.fromEntries(Object.entries(json as Record<string, unknown>).filter((e): e is [string, string] => typeof e[1] === "string"));
}

type QRow = Prisma.QuestionGetPayload<object>;
type VRow = Prisma.QuestionVersionGetPayload<object>;

function toWithKey(q: QRow, v: VRow, src: { citation: string; url: string | null } | null): QuestionWithKey {
  const source = sourceOf(src, { examCode: q.pyqExamCode, paperCode: q.pyqPaperCode, year: q.pyqYear, number: q.pyqNumber });
  return {
    question: {
      id: q.id,
      version: v.version,
      topicId: q.topicId,
      kind: q.kind,
      language: (LANGS.has(q.language) ? q.language : "en") as QuestionDto["language"],
      stem: v.stem,
      options: options(v.options),
      difficulty: Math.min(5, Math.max(1, q.difficulty)),
      source,
      affectedNote: v.affectedNote,
    },
    key: {
      questionId: q.id,
      topicId: q.topicId,
      correctOptionIds: v.correctOptionIds,
      explanationMarkdown: v.explanationMarkdown,
      whyWrong: whyWrong(v.whyWrong),
      source,
    },
  };
}

/** Prisma adapter over content-owned tables (Question, QuestionVersion, Source, QuestionReport, ContentPack). */
export class PrismaPracticeContentStore implements PracticeContentStore {
  private readonly reader: PrismaQuestionReader;

  constructor(private readonly prisma: PrismaClient) {
    this.reader = new PrismaQuestionReader(prisma);
  }

  async candidateIds(q: { topicIds: readonly string[]; pyqExamCode?: string | undefined; pyqYears?: readonly number[] | undefined }): Promise<string[]> {
    const rows = await this.prisma.question.findMany({
      where: {
        topicId: { in: [...q.topicIds] },
        status: "published",
        kind: { in: [...OBJECTIVE] },
        versions: { some: { status: "published" } },
        ...(q.pyqExamCode ? { pyqExamCode: q.pyqExamCode, pyqYear: q.pyqYears ? { in: [...q.pyqYears] } : { not: null } } : {}),
      },
      select: { id: true },
      orderBy: { id: "asc" },
    });
    return rows.map((r) => r.id);
  }

  latest(ids: readonly string[]): Promise<QuestionWithKey[]> {
    return this.reader.withKeys(ids);
  }

  async atVersion(refs: readonly { questionId: string; version: number }[]): Promise<QuestionWithKey[]> {
    if (!refs.length) return [];
    const versions = await this.prisma.questionVersion.findMany({
      where: { OR: refs.map((r) => ({ questionId: r.questionId, version: r.version })), status: { in: ["published", "superseded"] } },
      include: { question: true },
    });
    const sourceIds = [...new Set(versions.flatMap((v) => (v.sourceId ? [v.sourceId] : [])))];
    const sources = new Map((sourceIds.length ? await this.prisma.source.findMany({ where: { id: { in: sourceIds } } }) : []).map((s) => [s.id, s]));
    return versions.map((v) => toWithKey(v.question, v, v.sourceId ? (sources.get(v.sourceId) ?? null) : null));
  }

  async pyqYears(examCode: string): Promise<{ year: number; count: number }[]> {
    const rows = await this.prisma.question.groupBy({
      by: ["pyqYear"],
      where: { pyqExamCode: examCode, pyqYear: { not: null }, status: "published" },
      _count: { _all: true },
      orderBy: { pyqYear: "desc" },
    });
    return rows.flatMap((r) => (r.pyqYear === null ? [] : [{ year: r.pyqYear, count: r._count._all }]));
  }

  async pyqPage(f: PyqFilter): Promise<{ question: QuestionDto; year: number }[]> {
    const where: Prisma.QuestionWhereInput = {
      pyqExamCode: f.examCode,
      status: "published",
      versions: { some: { status: "published" } },
      pyqYear: f.year !== undefined ? f.year : { not: null },
      ...(f.topicIds ? { topicId: { in: [...f.topicIds] } } : {}),
      ...(f.difficulty !== undefined ? { difficulty: f.difficulty } : {}),
      ...(f.after ? { OR: [{ pyqYear: { lt: f.after.year } }, { pyqYear: f.after.year, id: { gt: f.after.id } }] } : {}),
    };
    const rows = await this.prisma.question.findMany({ where, select: { id: true, pyqYear: true }, orderBy: [{ pyqYear: "desc" }, { id: "asc" }], take: f.take });
    const full = new Map((await this.reader.withKeys(rows.map((r) => r.id))).map((r) => [r.question.id, r.question]));
    return rows.flatMap((r) => {
      const q = full.get(r.id);
      return q && r.pyqYear !== null ? [{ question: q, year: r.pyqYear }] : [];
    });
  }

  async pyqTopicCounts(examCode: string): Promise<{ topicId: string; count: number }[]> {
    const rows = await this.prisma.question.groupBy({
      by: ["topicId"],
      where: { pyqExamCode: examCode, pyqYear: { not: null }, status: "published" },
      _count: { _all: true },
    });
    return rows.map((r) => ({ topicId: r.topicId, count: r._count._all }));
  }

  async questionVersionExists(questionId: string, version: number): Promise<"ok" | "no_question" | "no_version"> {
    const q = await this.prisma.question.findUnique({ where: { id: questionId }, select: { status: true } });
    if (!q || q.status === "draft" || q.status === "in_review") return "no_question";
    const v = await this.prisma.questionVersion.findUnique({ where: { questionId_version: { questionId, version } }, select: { id: true } });
    return v ? "ok" : "no_version";
  }

  async insertReport(r: { userId: string; questionId: string; questionVersion: number; reason: string; note: string | null }): Promise<string> {
    const row = await this.prisma.questionReport.create({ data: r, select: { id: true } });
    return row.id;
  }

  async publishedPacks(examCode: string): Promise<PackRow[]> {
    const rows = await this.prisma.contentPack.findMany({ where: { examCode, status: "published", publishedAt: { not: null } } });
    return rows.flatMap((p) =>
      p.publishedAt
        ? [
            {
              id: p.id,
              code: p.code,
              examCode: p.examCode,
              subjectCode: p.subjectCode,
              version: p.version,
              url: p.url,
              sha256: p.sha256,
              sizeBytes: p.sizeBytes,
              tier: p.tier === "pro" ? ("pro" as const) : ("free" as const),
              publishedAt: p.publishedAt,
            },
          ]
        : [],
    );
  }
}
