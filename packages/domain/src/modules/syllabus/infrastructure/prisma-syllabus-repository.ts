import type { PrismaClient } from "@heymey/db";
import type { SyllabusRepository, TextbookRefDto } from "../application/ports.js";
import type { GlossaryListDto, GlossaryQuerySpec } from "../domain/glossary.js";
import type { TopicRow } from "../domain/study-map.js";

export class PrismaSyllabusRepository implements SyllabusRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async topicsForExam(examCode: string): Promise<TopicRow[]> {
    const rows = await this.prisma.topic.findMany({
      where: { examTags: { some: { examCode } } },
      include: { subject: true, examTags: true },
      orderBy: [{ order: "asc" }, { code: "asc" }],
    });
    return rows.map((t) => ({
      id: t.id,
      code: t.code,
      name: t.name,
      order: t.order,
      subject: { code: t.subject.code, name: t.subject.name, order: t.subject.order },
      examCodes: t.examTags.map((tag) => tag.examCode),
    }));
  }

  async searchGlossary(spec: GlossaryQuerySpec): Promise<GlossaryListDto["items"]> {
    const rows = await this.prisma.glossaryTerm.findMany({
      where: spec.contains ? { term: { contains: spec.contains, mode: "insensitive" } } : {},
      orderBy: { term: "asc" },
      take: spec.take,
    });
    return rows.map((r) => ({ term: r.term, meaning: r.meaning }));
  }

  async textbookRefs(topicId: string): Promise<TextbookRefDto[]> {
    const rows = await this.prisma.textbookRef.findMany({
      where: { topicId },
      orderBy: [{ classLevel: "asc" }, { book: "asc" }, { chapter: "asc" }],
    });
    return rows.map((r) => ({ book: r.book, classLevel: r.classLevel, chapter: r.chapter, pages: r.pages, url: r.url }));
  }
}
