import { OFFICIAL_CONFIRM_LINE } from "@heymey/contracts";

/**
 * Exam-agnostic catalogue (ADR-0013, §1a, §22): family -> exam -> stage -> paper -> section, versioned marking schemes,
 * attempt cycles. Everything here is DATA; marks are exact fractions. `verified` is true only after a human check.
 * Added by BOLT-0011.
 */
export interface MarksDto {
  numerator: number;
  denominator: number;
}

export interface CatalogueSection {
  code: string;
  name: string;
  order: number;
  questionCount: number;
  attemptLimit: number | null;
  correctMarksNum: number;
  correctMarksDen: number;
  wrongPenaltyNum: number;
  wrongPenaltyDen: number;
  sectionMinutes: number | null;
}

export interface CatalogueScheme {
  version: number;
  status: string;
  durationMinutes: number;
  totalQuestions: number;
  sourceUrl: string;
  verifiedAt: Date | null;
  sections: CatalogueSection[];
}

export type AnswerMode = "objective_omr" | "objective_cbt" | "descriptive";

export interface CataloguePaper {
  id: string;
  code: string;
  name: string;
  order: number;
  answerMode: AnswerMode;
  contentLanguage: string;
  qualifyingOnly: boolean;
  status: string;
  /** Latest published scheme (structure view). */
  scheme: CatalogueScheme | null;
}

export interface CatalogueStage {
  code: string;
  name: string;
  order: number;
  papers: CataloguePaper[];
}

export type DateStatus = "unknown" | "tentative" | "confirmed";

export interface CatalogueCycle {
  id: string;
  code: string;
  name: string;
  status: "announced" | "expected" | "closed";
  stageDates: { stageCode: string; date: string | null; dateStatus: DateStatus }[];
}

export interface CatalogueExam {
  code: string;
  status: string;
  family: { code: string; name: string; rankScope: string } | null;
  stages: CatalogueStage[];
  cycles: CatalogueCycle[];
}

export interface StructureSectionDto {
  code: string;
  name: string;
  order: number;
  questionCount: number;
  attemptLimit: number | null;
  marksPerCorrect: MarksDto;
  penaltyPerWrong: MarksDto;
  minutes: number | null;
}

export interface StructurePaperDto {
  code: string;
  name: string;
  order: number;
  type: "objective" | "descriptive";
  mode: "omr" | "cbt" | "written";
  language: "en" | "ta" | "hi" | "bilingual";
  qualifyingOnly: boolean;
  scheme: {
    version: number;
    durationMinutes: number;
    totalQuestions: number;
    totalMarks: MarksDto;
    sections: StructureSectionDto[];
    verified: boolean;
    sourceUrl: string;
  } | null;
}

export interface ExamStructureDto {
  examCode: string;
  family: { code: string; name: string } | null;
  stages: {
    code: string;
    name: string;
    order: number;
    scheduledDate: string | null;
    dateStatus: DateStatus;
    papers: StructurePaperDto[];
  }[];
  attemptCycles: CatalogueCycle[];
  disclaimer: string;
}

function gcd(a: number, b: number): number {
  let x = Math.abs(a);
  let y = Math.abs(b);
  while (y) [x, y] = [y, x % y];
  return x || 1;
}

/** Reduced exact fraction. A zero/negative denominator or negative numerator is a data error (invariant 2). */
export function marks(num: number, den: number): MarksDto {
  if (!Number.isInteger(num) || !Number.isInteger(den) || den <= 0 || num < 0) throw new RangeError("invalid marks fraction");
  const g = gcd(num, den);
  return { numerator: num / g, denominator: den / g };
}

/** Sum over sections of (questions that count) x marks per correct. */
export function totalMarks(sections: readonly CatalogueSection[]): MarksDto {
  let num = 0;
  let den = 1;
  for (const s of sections) {
    const n = Math.min(s.questionCount, s.attemptLimit ?? s.questionCount) * s.correctMarksNum;
    num = num * s.correctMarksDen + n * den;
    den = den * s.correctMarksDen;
    const g = gcd(num, den);
    num /= g;
    den /= g;
  }
  return marks(num, den);
}

const LANGS = new Set(["en", "ta", "hi", "bilingual"]);

/** The cycle whose dates the stage view shows: the first announced cycle, else the first expected one. */
export function currentCycle(cycles: readonly CatalogueCycle[]): CatalogueCycle | null {
  return cycles.find((c) => c.status === "announced") ?? cycles.find((c) => c.status === "expected") ?? null;
}

function paperMode(mode: AnswerMode): StructurePaperDto["mode"] {
  if (mode === "descriptive") return "written";
  return mode === "objective_cbt" ? "cbt" : "omr";
}

function toPaper(p: CataloguePaper): StructurePaperDto {
  return {
    code: p.code,
    name: p.name,
    order: p.order,
    type: p.answerMode === "descriptive" ? "descriptive" : "objective",
    mode: paperMode(p.answerMode),
    language: (LANGS.has(p.contentLanguage) ? p.contentLanguage : "en") as StructurePaperDto["language"],
    qualifyingOnly: p.qualifyingOnly,
    scheme: p.scheme
      ? {
          version: p.scheme.version,
          durationMinutes: p.scheme.durationMinutes,
          totalQuestions: p.scheme.totalQuestions,
          totalMarks: totalMarks(p.scheme.sections),
          sections: [...p.scheme.sections]
            .sort((a, b) => a.order - b.order)
            .map((s) => ({
              code: s.code,
              name: s.name,
              order: s.order,
              questionCount: s.questionCount,
              attemptLimit: s.attemptLimit,
              marksPerCorrect: marks(s.correctMarksNum, s.correctMarksDen),
              penaltyPerWrong: marks(s.wrongPenaltyNum, s.wrongPenaltyDen),
              minutes: s.sectionMinutes,
            })),
          verified: p.scheme.verifiedAt !== null,
          sourceUrl: p.scheme.sourceUrl,
        }
      : null,
  };
}

export function toStructure(exam: CatalogueExam): ExamStructureDto {
  const cycle = currentCycle(exam.cycles);
  return {
    examCode: exam.code,
    family: exam.family ? { code: exam.family.code, name: exam.family.name } : null,
    stages: [...exam.stages]
      .sort((a, b) => a.order - b.order)
      .map((st) => {
        const date = cycle?.stageDates.find((d) => d.stageCode === st.code);
        return {
          code: st.code,
          name: st.name,
          order: st.order,
          scheduledDate: date?.date ?? null,
          dateStatus: date?.dateStatus ?? "unknown",
          papers: [...st.papers].sort((a, b) => a.order - b.order).map(toPaper),
        };
      }),
    attemptCycles: exam.cycles,
    disclaimer: OFFICIAL_CONFIRM_LINE,
  };
}

/** Exam Hall view of one paper + one exact scheme version (ADR-0012). */
export interface PaperForMockDto {
  examCode: string;
  paperCode: string;
  answerMode: AnswerMode;
  qualifyingOnly: boolean;
  /** Family rank scope label (R6), e.g. "statewide". */
  rankScope: string;
  scheme: CatalogueScheme;
}
