import type { Lesson, z } from "@heymey/contracts";

export type LessonDto = z.infer<typeof Lesson>;
export type TextbookRefDto = LessonDto["textbookRefs"][number];

/** A lesson version as stored (§10.6). Only `published` versions are served (§26.2 rule 5). */
export interface LessonRecord {
  id: string;
  topicId: string;
  version: number;
  title: string;
  bodyMarkdown: string;
  readingMinutes: number;
  sourceCitation: string;
  sourceUrl: string | null;
  status: string;
  updatedAt: Date;
}

/** The highest published version, or null. Pure (the repository may already filter). */
export function latestPublished(versions: readonly LessonRecord[]): LessonRecord | null {
  return versions.filter((v) => v.status === "published").reduce<LessonRecord | null>((best, v) => (!best || v.version > best.version ? v : best), null);
}

export function toLessonDto(lesson: LessonRecord, textbookRefs: TextbookRefDto[]): LessonDto {
  return {
    id: lesson.id,
    topicId: lesson.topicId,
    title: lesson.title,
    bodyMarkdown: lesson.bodyMarkdown,
    readingMinutes: lesson.readingMinutes,
    textbookRefs,
    source: { citation: lesson.sourceCitation, url: lesson.sourceUrl },
    version: lesson.version,
    updatedAt: lesson.updatedAt.toISOString(),
  };
}
