import type { ExamCatalogueApi, PaperForMockDto } from "../../exams/index.js";
import type { PaperSource } from "../application/ports.js";
import { frac } from "../domain/fraction.js";
import type { PaperView } from "../domain/types.js";

/** Maps the `exams` catalogue view (raw num/den) into exact fractions for scoring (ADR-0012). */
export function toPaperView(p: PaperForMockDto): PaperView {
  return {
    examCode: p.examCode,
    paperCode: p.paperCode,
    answerMode: p.answerMode,
    qualifyingOnly: p.qualifyingOnly,
    rankScope: p.rankScope,
    scheme: {
      version: p.scheme.version,
      status: p.scheme.status,
      durationMinutes: p.scheme.durationMinutes,
      totalQuestions: p.scheme.totalQuestions,
      sections: p.scheme.sections.map((s) => ({
        code: s.code,
        name: s.name,
        order: s.order,
        questionCount: s.questionCount,
        attemptLimit: s.attemptLimit,
        marksPerCorrect: frac(s.correctMarksNum, s.correctMarksDen),
        penaltyPerWrong: frac(s.wrongPenaltyNum, s.wrongPenaltyDen),
        minutes: s.sectionMinutes,
      })),
    },
  };
}

export function examsPaperSource(catalogue: Pick<ExamCatalogueApi, "paperForMock">): PaperSource {
  return {
    async paperForMock(paperId, version) {
      const p = await catalogue.paperForMock(paperId, version);
      return p ? toPaperView(p) : null;
    },
  };
}
