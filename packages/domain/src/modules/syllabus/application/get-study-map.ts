import { DomainError } from "../../../shared/errors.js";
import { buildStudyMap, type StudyMapDto } from "../domain/study-map.js";
import type { StudyMapPorts, SyllabusRepository } from "./ports.js";

/** GET /v1/exams/{code}/study-map (§5.1). The exam must be published, else EXAM_NOT_FOUND. */
export async function getStudyMap(repo: SyllabusRepository, ports: StudyMapPorts, examCode: string): Promise<StudyMapDto> {
  const published = await ports.publishedExamCodes();
  if (!published.has(examCode)) throw new DomainError("EXAM_NOT_FOUND", { code: examCode });
  const topics = await repo.topicsForExam(examCode);
  const withLesson = topics.length ? await ports.topicsWithLesson(topics.map((t) => t.id)) : new Set<string>();
  return buildStudyMap(examCode, topics, published, withLesson);
}
