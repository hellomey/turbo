import { DomainError } from "../../../shared/errors.js";
import { isPublished, sortExams, toDetail, toSummary, type ExamDetailDto, type ExamSummaryDto } from "../domain/exam.js";
import type { ExamsRepository } from "./ports.js";

/** GET /v1/exams: published only, launch exams first, then by name (§19.1). */
export async function listExams(repo: ExamsRepository): Promise<ExamSummaryDto[]> {
  return sortExams((await repo.listPublished()).filter(isPublished)).map(toSummary);
}

/** GET /v1/exams/{code}: unknown or unpublished -> EXAM_NOT_FOUND. */
export async function getExam(repo: ExamsRepository, code: string): Promise<ExamDetailDto> {
  const exam = await repo.findByCode(code);
  if (!exam || !isPublished(exam)) throw new DomainError("EXAM_NOT_FOUND", { code });
  return toDetail(exam);
}

/** Codes of every published exam (used by the Study Map composition for shared lamps). */
export async function publishedExamCodes(repo: ExamsRepository): Promise<Set<string>> {
  return new Set((await repo.listPublished()).filter(isPublished).map((e) => e.code));
}
