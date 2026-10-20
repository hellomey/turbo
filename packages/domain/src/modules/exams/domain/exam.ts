import { OFFICIAL_CONFIRM_LINE, type ExamDetail, type ExamSummary, type Qualification, type z } from "@heymey/contracts";

export type ExamSummaryDto = z.infer<typeof ExamSummary>;
export type ExamDetailDto = z.infer<typeof ExamDetail>;

/** An exam as the exams module stores it (§19.1 Q6). Only `published` exams are ever shown. */
export interface ExamRecord {
  code: string;
  name: string;
  conductingBody: string;
  level: "state" | "central";
  minQualification: Qualification;
  fullPrep: boolean;
  description: string;
  stages: string[];
  patternMode: "omr" | "cbt";
  patternQuestions: number | null;
  patternMinutes: number | null;
  negativeMarking: boolean;
  officialUrl: string;
  notificationUrl: string | null;
  status: string;
  lastCheckedAt: Date | null;
}

export const isPublished = (exam: Pick<ExamRecord, "status">): boolean => exam.status === "published";

/** Exam list order: launch exams (full preparation) first, then by name. */
export function sortExams<T extends Pick<ExamRecord, "fullPrep" | "name">>(exams: readonly T[]): T[] {
  return [...exams].sort((a, b) => (a.fullPrep === b.fullPrep ? a.name.localeCompare(b.name) : a.fullPrep ? -1 : 1));
}

export function toSummary(e: ExamRecord): ExamSummaryDto {
  return {
    code: e.code,
    name: e.name,
    conductingBody: e.conductingBody,
    level: e.level,
    minQualification: e.minQualification,
    fullPrep: e.fullPrep,
  };
}

export function toDetail(e: ExamRecord): ExamDetailDto {
  return {
    ...toSummary(e),
    description: e.description,
    stages: e.stages,
    pattern: {
      mode: e.patternMode,
      questions: e.patternQuestions,
      durationMinutes: e.patternMinutes,
      negativeMarking: e.negativeMarking,
    },
    officialUrl: e.officialUrl,
    notificationUrl: e.notificationUrl,
    lastCheckedAt: e.lastCheckedAt ? e.lastCheckedAt.toISOString() : null,
    disclaimer: OFFICIAL_CONFIRM_LINE,
  };
}
