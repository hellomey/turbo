/**
 * Public API of the `content` module. Lessons, questions, versions, sources, explanations, corrections, reports.
 * Export use cases and types only. Never export repositories or Prisma models.
 * Design: aidlc/construction/units/U-content/.
 */
import type { PrismaClient } from "@heymey/db";
import type { SyllabusApi } from "../syllabus/index.js";
import { getLesson, type LessonRepository } from "./application/get-lesson.js";
import type { LessonDto } from "./domain/lesson.js";
import { PrismaLessonRepository } from "./infrastructure/prisma-lesson-repository.js";

export const ContentModule = { name: "content" } as const;

export type { LessonRepository, TextbookRefSource } from "./application/get-lesson.js";
export type { LessonDto, LessonRecord } from "./domain/lesson.js";
export { latestPublished } from "./domain/lesson.js";

export interface ContentApi {
  lesson(topicId: string): Promise<LessonDto>;
  /** For the Study Map's `hasLesson` flags. */
  topicsWithPublishedLesson(topicIds: string[]): Promise<Set<string>>;
}

export function createContentModule(
  deps: ({ prisma: PrismaClient } | { repository: LessonRepository }) & { syllabus: Pick<SyllabusApi, "textbookRefs"> },
): ContentApi {
  const repo = "repository" in deps ? deps.repository : new PrismaLessonRepository(deps.prisma);
  return {
    lesson: (topicId) => getLesson(repo, deps.syllabus, topicId),
    topicsWithPublishedLesson: (ids) => repo.topicsWithPublished(ids),
  };
}
