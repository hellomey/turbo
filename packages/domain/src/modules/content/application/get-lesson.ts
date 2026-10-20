import { DomainError } from "../../../shared/errors.js";
import { latestPublished, toLessonDto, type LessonDto, type LessonRecord, type TextbookRefDto } from "../domain/lesson.js";

/** Port: lesson storage. Adapter: infrastructure/prisma-lesson-repository.ts. */
export interface LessonRepository {
  /** Published versions of one topic's lesson (any order). */
  publishedVersions(topicId: string): Promise<LessonRecord[]>;
  /** Of these topic ids, the ones that have at least one published lesson. */
  topicsWithPublished(topicIds: string[]): Promise<Set<string>>;
}

/** Textbook refs come from the syllabus module (content -> syllabus is declared in module.json). */
export interface TextbookRefSource {
  textbookRefs(topicId: string): Promise<TextbookRefDto[]>;
}

/**
 * GET /v1/topics/{topicId}/lesson (§10.6, §19.3). Latest published version, else LESSON_NOT_FOUND.
 * No Pro gating in Phase 1 (D-2026-10-20-13).
 */
export async function getLesson(repo: LessonRepository, syllabus: TextbookRefSource, topicId: string): Promise<LessonDto> {
  const lesson = latestPublished(await repo.publishedVersions(topicId));
  if (!lesson) throw new DomainError("LESSON_NOT_FOUND", { topicId });
  return toLessonDto(lesson, await syllabus.textbookRefs(topicId));
}
