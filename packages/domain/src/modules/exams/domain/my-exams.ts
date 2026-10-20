import type { UserExamsBody, z } from "@heymey/contracts";
import { DomainError } from "../../../shared/errors.js";

export type UserExamsInput = z.input<typeof UserExamsBody>;

export interface ExamChoice {
  examCode: string;
  isMain: boolean;
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
  return [{ examCode: input.mainExamCode, isMain: true }, ...others.map((examCode) => ({ examCode, isMain: false }))];
}
