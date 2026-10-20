/**
 * Public API of the `exams` module. Exams, notifications, eligibility rules, vacancies, cutoffs.
 * Export use cases and types only. Never export repositories or Prisma models.
 * Design: aidlc/construction/units/U-exams/.
 */
import type { PrismaClient } from "@heymey/db";
import type { Clock } from "../../shared/clock.js";
import { checkEligibility } from "./application/check-eligibility.js";
import { getExam, listExams, publishedExamCodes } from "./application/exam-catalog.js";
import { getMyExams, setMyExams, type UserExamsDto } from "./application/my-exams.js";
import type { ExamsRepository } from "./application/ports.js";
import type { Answers, EligibilityResultDto } from "./domain/eligibility.js";
import type { ExamDetailDto, ExamSummaryDto } from "./domain/exam.js";
import type { UserExamsInput } from "./domain/my-exams.js";
import { PrismaExamsRepository } from "./infrastructure/prisma-exams-repository.js";

export const ExamsModule = { name: "exams" } as const;

export type { ExamsRepository } from "./application/ports.js";
export type { ExamRecord, ExamDetailDto, ExamSummaryDto } from "./domain/exam.js";
export type { Answers, EligibilityResultDto, EligibilityRuleRecord, ExamWithRule } from "./domain/eligibility.js";
export type { ExamChoice, UserExamsInput } from "./domain/my-exams.js";
export type { UserExamsDto } from "./application/my-exams.js";
export {
  checkEligibility as evaluateEligibility,
  completedYears,
  ELIGIBILITY_DISCLAIMER,
  formatDate,
} from "./domain/eligibility.js";
export { validateExamChoice, MAX_OTHER_EXAMS } from "./domain/my-exams.js";

export interface ExamsApi {
  list(): Promise<ExamSummaryDto[]>;
  get(code: string): Promise<ExamDetailDto>;
  /** Pure computation over today's IST date; throws UNDER_18. Nothing stored. */
  checkEligibility(answers: Answers): Promise<EligibilityResultDto>;
  publishedCodes(): Promise<Set<string>>;
  getMyExams(userId: string): Promise<UserExamsDto>;
  setMyExams(userId: string, input: UserExamsInput): Promise<UserExamsDto>;
}

export function createExamsModule(
  deps: ({ prisma: PrismaClient } | { repository: ExamsRepository }) & { clock: Clock },
): ExamsApi {
  const repo = "repository" in deps ? deps.repository : new PrismaExamsRepository(deps.prisma);
  return {
    list: () => listExams(repo),
    get: (code) => getExam(repo, code),
    checkEligibility: (answers) => checkEligibility(repo, deps.clock, answers),
    publishedCodes: () => publishedExamCodes(repo),
    getMyExams: (userId) => getMyExams(repo, userId),
    setMyExams: (userId, input) => setMyExams(repo, userId, input),
  };
}
