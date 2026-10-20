import type { PrismaClient } from "@heymey/db";
import type { LessonRepository } from "../application/get-lesson.js";
import type { LessonRecord } from "../domain/lesson.js";

export class PrismaLessonRepository implements LessonRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async publishedVersions(topicId: string): Promise<LessonRecord[]> {
    const rows = await this.prisma.lesson.findMany({
      where: { topicId, status: "published" },
      orderBy: { version: "desc" },
      take: 1,
    });
    return rows.map((r) => ({
      id: r.id,
      topicId: r.topicId,
      version: r.version,
      title: r.title,
      bodyMarkdown: r.bodyMarkdown,
      readingMinutes: r.readingMinutes,
      sourceCitation: r.sourceCitation,
      sourceUrl: r.sourceUrl,
      status: r.status,
      updatedAt: r.updatedAt,
    }));
  }

  async topicsWithPublished(topicIds: string[]): Promise<Set<string>> {
    if (!topicIds.length) return new Set();
    const rows = await this.prisma.lesson.findMany({
      where: { topicId: { in: topicIds }, status: "published" },
      select: { topicId: true },
      distinct: ["topicId"],
    });
    return new Set(rows.map((r) => r.topicId));
  }
}
