/**
 * Public API of the `syllabus` module. Subjects, topics (lamps), textbook mapping, glossary.
 * Export use cases and types only. Never export repositories or Prisma models.
 * syllabus is a leaf: it never imports exams or content. Cross-module data reaches it through StudyMapPorts.
 * Design: aidlc/construction/units/U-syllabus/.
 */
import type { PrismaClient } from "@heymey/db";
import { getStudyMap } from "./application/get-study-map.js";
import type { StudyMapPorts, SyllabusRepository, TextbookRefDto } from "./application/ports.js";
import { searchGlossary } from "./application/search-glossary.js";
import type { GlossaryListDto } from "./domain/glossary.js";
import type { StudyMapDto, TopicRow } from "./domain/study-map.js";
import { PrismaSyllabusRepository } from "./infrastructure/prisma-syllabus-repository.js";

export const SyllabusModule = { name: "syllabus" } as const;

export type { StudyMapPorts, SyllabusRepository, TextbookRefDto } from "./application/ports.js";
export type { StudyMapDto, TopicRow, LampRingDto } from "./domain/study-map.js";
export type { GlossaryListDto, GlossaryQuerySpec } from "./domain/glossary.js";
export { buildStudyMap, UNLIT_RING } from "./domain/study-map.js";
export { glossaryQuery, GLOSSARY_BROWSE_LIMIT, GLOSSARY_SEARCH_LIMIT } from "./domain/glossary.js";

export interface SyllabusApi {
  studyMap(examCode: string, ports: StudyMapPorts): Promise<StudyMapDto>;
  glossary(q?: string | null): Promise<GlossaryListDto>;
  textbookRefs(topicId: string): Promise<TextbookRefDto[]>;
  /** BOLT-0009 (mastery): lamps of one exam, and one lamp by id (null if unknown). */
  topicsForExam(examCode: string): Promise<TopicRow[]>;
  topic(topicId: string): Promise<TopicRow | null>;
}

export function createSyllabusModule(deps: { prisma: PrismaClient } | { repository: SyllabusRepository }): SyllabusApi {
  const repo = "repository" in deps ? deps.repository : new PrismaSyllabusRepository(deps.prisma);
  return {
    studyMap: (examCode, ports) => getStudyMap(repo, ports, examCode),
    glossary: (q) => searchGlossary(repo, q),
    textbookRefs: (topicId) => repo.textbookRefs(topicId),
    topicsForExam: (examCode) => repo.topicsForExam(examCode),
    topic: (topicId) => repo.topicById(topicId),
  };
}
