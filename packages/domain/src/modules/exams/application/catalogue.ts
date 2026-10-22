import { DomainError } from "../../../shared/errors.js";
import { toStructure, type CatalogueExam, type ExamStructureDto, type PaperForMockDto } from "../domain/structure.js";

/** Port: catalogue reads (ADR-0013). Adapter: infrastructure/prisma-catalogue-repository.ts. BOLT-0011. */
export interface CatalogueRepository {
  /** Exam with published papers and each paper's latest PUBLISHED scheme; null if unknown. */
  examStructure(code: string): Promise<CatalogueExam | null>;
  /** One paper with exactly this scheme version (any status: old attempts keep their version), or null. */
  paperForMock(paperId: string, schemeVersion: number): Promise<PaperForMockDto | null>;
}

/** GET /v1/exams/{code}/structure (§1a, §22): published exams only, else EXAM_NOT_FOUND. */
export async function getExamStructure(repo: CatalogueRepository, code: string): Promise<ExamStructureDto> {
  const exam = await repo.examStructure(code);
  if (!exam || exam.status !== "published") throw new DomainError("EXAM_NOT_FOUND", { code });
  return toStructure(exam);
}
