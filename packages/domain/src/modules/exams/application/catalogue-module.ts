import type { PrismaClient } from "@heymey/db";
import type { PaperForMockDto, ExamStructureDto } from "../domain/structure.js";
import { PrismaCatalogueRepository } from "../infrastructure/prisma-catalogue-repository.js";
import { getExamStructure, type CatalogueRepository } from "./catalogue.js";

/** Public catalogue API (ADR-0013). `paperForMock` is the Exam Hall's view of one paper + scheme version (ADR-0012). */
export interface ExamCatalogueApi {
  structure(code: string): Promise<ExamStructureDto>;
  paperForMock(paperId: string, schemeVersion: number): Promise<PaperForMockDto | null>;
}

export function createExamCatalogueModule(deps: { prisma: PrismaClient } | { repository: CatalogueRepository }): ExamCatalogueApi {
  const repo = "repository" in deps ? deps.repository : new PrismaCatalogueRepository(deps.prisma);
  return {
    structure: (code) => getExamStructure(repo, code),
    paperForMock: (paperId, version) => repo.paperForMock(paperId, version),
  };
}
