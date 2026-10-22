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
import type { QuestionReader } from "./domain/question.js";
import { PrismaQuestionReader } from "./infrastructure/prisma-question-reader.js";
import { questionBank, type QuestionBank } from "./application/question-bank.js";
import { PrismaQuestionCandidates } from "./infrastructure/prisma-question-candidates.js";

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

// ---- BOLT-0011 (exam-hall): read-only question access for timed tests. Additive; BOLT-0010 owns the full question flow.
export type { QuestionDto, QuestionKeyDto, QuestionReader, QuestionSourceDto, QuestionWithKey } from "./domain/question.js";

/** Latest published version of each question, with its server-only key (for grading on the server, §34.1). */
export function createQuestionReader(deps: { prisma: PrismaClient }): QuestionReader {
  return new PrismaQuestionReader(deps.prisma);
}

// ---- BOLT-0009 (mastery): server-picked check questions + server grading. Additive.
export type { QuestionBank } from "./application/question-bank.js";
export type { GradedAnswerDto } from "./domain/question.js";
export { isCorrect, shuffle } from "./domain/question.js";

/** Question picking (CSPRNG injected: node:crypto randomInt in apps) and grading for mastery checks. */
export function createQuestionBank(deps: { prisma: PrismaClient; randomInt: (maxExclusive: number) => number }): QuestionBank {
  return questionBank(new PrismaQuestionReader(deps.prisma), new PrismaQuestionCandidates(deps.prisma), deps.randomInt);
}
