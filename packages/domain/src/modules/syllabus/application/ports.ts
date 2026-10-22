import type { TextbookRef, z } from "@heymey/contracts";
import type { GlossaryListDto, GlossaryQuerySpec } from "../domain/glossary.js";
import type { TopicRow } from "../domain/study-map.js";

export type TextbookRefDto = z.infer<typeof TextbookRef>;

/** Port: the syllabus module's storage. Adapter: infrastructure/prisma-syllabus-repository.ts. */
export interface SyllabusRepository {
  /** Topics tagged with this exam, each with its subject and ALL of its exam tags. */
  topicsForExam(examCode: string): Promise<TopicRow[]>;
  /** Ordered by term ascending. */
  searchGlossary(spec: GlossaryQuerySpec): Promise<GlossaryListDto["items"]>;
  textbookRefs(topicId: string): Promise<TextbookRefDto[]>;
  /** BOLT-0009: one topic with its subject and exam tags, or null. */
  topicById(topicId: string): Promise<TopicRow | null>;
}

/**
 * What the Study Map needs from OTHER modules. syllabus is a leaf (module.json), so the API composition
 * root passes these in from the exams and content modules' public APIs.
 */
export interface StudyMapPorts {
  publishedExamCodes(): Promise<ReadonlySet<string>>;
  topicsWithLesson(topicIds: string[]): Promise<ReadonlySet<string>>;
}
