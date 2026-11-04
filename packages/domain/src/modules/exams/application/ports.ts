import type { ExamRecord } from "../domain/exam.js";
import type { ExamWithRule } from "../domain/eligibility.js";
import type { ExamChoice } from "../domain/my-exams.js";
import type { CycleRecord } from "../domain/cycle.js";

/** Port: the exams module's storage. Adapter: infrastructure/prisma-exams-repository.ts. */
export interface ExamsRepository {
  /** Published exams only. */
  listPublished(): Promise<ExamRecord[]>;
  /** Any status; callers check `status`. */
  findByCode(code: string): Promise<ExamRecord | null>;
  /** Published exams, each with its latest PUBLISHED eligibility rule (or null). */
  listPublishedWithRules(): Promise<ExamWithRule[]>;
  getChoices(userId: string): Promise<ExamChoice[]>;
  /** Replace all of the user's choices in ONE transaction. */
  replaceChoices(userId: string, choices: ExamChoice[]): Promise<void>;
  /** BOLT-0012 (R2): attempt cycles of these exams. Optional so Phase 1 fakes stay valid; the Prisma adapter has it. */
  cyclesForExams?(examCodes: string[]): Promise<CycleRecord[]>;
}
