import type { UserExamsBody, z } from "@heymey/contracts";
import { DomainError } from "../../../shared/errors.js";

export type UserExamsInput = z.input<typeof UserExamsBody>;

export interface ExamChoice {
  examCode: string;
  isMain: boolean;
  /** R2 (BOLT-0012): the attempt cycle I prepare for; null = not chosen (the current cycle is used). */
  attemptCycleId?: string | null;
}

export const MAX_OTHER_EXAMS = 2;

/**
 * Main exam + up to 2 more (§17.1 step 4). All codes distinct, main never repeated.
 * Existence (published) is checked by the use case; this is the pure shape rule.
 */
export function validateExamChoice(input: UserExamsInput): ExamChoice[] {
  const others = input.otherExamCodes ?? [];
  if (others.length > MAX_OTHER_EXAMS) {
    throw new DomainError("VALIDATION_FAILED", { field: "otherExamCodes", reason: "at most 2 other exams" });
  }
  if (others.includes(input.mainExamCode)) {
    throw new DomainError("VALIDATION_FAILED", { field: "otherExamCodes", reason: "main exam repeated" });
  }
  if (new Set(others).size !== others.length) {
    throw new DomainError("VALIDATION_FAILED", { field: "otherExamCodes", reason: "duplicate exam" });
  }
  const cycles = input.attemptCycles ?? {};
  const chosen = new Set([input.mainExamCode, ...others]);
  const stray = Object.keys(cycles).filter((code) => !chosen.has(code));
  if (stray.length) {
    throw new DomainError("VALIDATION_FAILED", { field: "attemptCycles", reason: "cycle for an exam that is not chosen" });
  }
  // Without attemptCycles the shape stays exactly as in Phase 1 (no attemptCycleId key).
  const choice = (examCode: string, isMain: boolean): ExamChoice => {
    const id = cycles[examCode];
    return id ? { examCode, isMain, attemptCycleId: id } : { examCode, isMain };
  };
  return [choice(input.mainExamCode, true), ...others.map((examCode) => choice(examCode, false))];
}
