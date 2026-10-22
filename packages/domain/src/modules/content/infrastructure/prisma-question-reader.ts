import type { PrismaClient } from "@heymey/db";
import { sourceOf, type QuestionReader, type QuestionWithKey } from "../domain/question.js";

const LANGS = new Set(["en", "ta", "hi"]);

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

/** Read-only adapter over `Question` + `QuestionVersion` + `Source` (owned by content). */
export class PrismaQuestionReader implements QuestionReader {
  constructor(private readonly prisma: PrismaClient) {}

  async withKeys(questionIds: readonly string[]): Promise<QuestionWithKey[]> {
    if (!questionIds.length) return [];
    const rows = await this.prisma.question.findMany({
      where: { id: { in: [...questionIds] }, status: "published" },
      include: { versions: { where: { status: "published" }, orderBy: { version: "desc" }, take: 1 } },
    });
    const sourceIds = rows.flatMap((r) => (r.versions[0]?.sourceId ? [r.versions[0].sourceId] : []));
    const sources = new Map(
      (sourceIds.length ? await this.prisma.source.findMany({ where: { id: { in: sourceIds } } }) : []).map((s) => [s.id, s]),
    );
    return rows.flatMap((q) => {
      const v = q.versions[0];
      if (!v) return [];
      const src = v.sourceId ? (sources.get(v.sourceId) ?? null) : null;
      const source = sourceOf(src, { examCode: q.pyqExamCode, paperCode: q.pyqPaperCode, year: q.pyqYear, number: q.pyqNumber });
      return [
        {
          question: {
            id: q.id,
            version: v.version,
            topicId: q.topicId,
            kind: q.kind,
            language: (LANGS.has(q.language) ? q.language : "en") as "en" | "ta" | "hi",
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
        },
      ];
    });
  }
}
