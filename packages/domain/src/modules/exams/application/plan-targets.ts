import { istDayKey, type Clock } from "../../../shared/clock.js";
import { DomainError } from "../../../shared/errors.js";
import { isPublished } from "../domain/exam.js";
import { pickCycle, nextStageDate } from "../domain/cycle.js";
import type { ExamChoice } from "../domain/my-exams.js";
import type { ExamsRepository } from "./ports.js";

export { nextStageDate, pickCycle, type CycleRecord } from "../domain/cycle.js";

/** What `plan` needs per chosen exam (R2: plans hang off the attempt cycle and its next stage date). */
export interface PlanTargetDto {
  examCode: string;
  isMain: boolean;
  attemptCycleId: string | null;
  /** Next stage date (YYYY-MM-DD, IST) on or after today; null = not known yet. */
  examDate: string | null;
}

/** Choices with a cycle id must name a cycle of that exam (PUT /v1/me/exams `attemptCycles`). */
export async function assertCyclesBelong(repo: ExamsRepository, choices: readonly ExamChoice[]): Promise<void> {
  const withCycle = choices.filter((c) => c.attemptCycleId);
  if (!withCycle.length) return;
  const cycles = repo.cyclesForExams ? await repo.cyclesForExams(withCycle.map((c) => c.examCode)) : [];
  const bad = withCycle.filter((c) => !cycles.some((y) => y.id === c.attemptCycleId && y.examCode === c.examCode));
  if (bad.length) {
    throw new DomainError("VALIDATION_FAILED", { field: "attemptCycles", reason: "unknown attempt cycle", codes: bad.map((c) => c.examCode) });
  }
}

/** My exams (published only) with their cycle and next stage date, main first. */
export async function planTargets(repo: ExamsRepository, clock: Clock, userId: string): Promise<PlanTargetDto[]> {
  const [choices, exams] = await Promise.all([repo.getChoices(userId), repo.listPublished()]);
  const published = new Set(exams.filter(isPublished).map((e) => e.code));
  const mine = choices.filter((c) => published.has(c.examCode)).sort((a, b) => Number(b.isMain) - Number(a.isMain));
  const cycles = repo.cyclesForExams ? await repo.cyclesForExams(mine.map((c) => c.examCode)) : [];
  const today = istDayKey(clock.now());
  return mine.map((c) => {
    const cycle = pickCycle(
      cycles.filter((y) => y.examCode === c.examCode),
      c.attemptCycleId,
    );
    return {
      examCode: c.examCode,
      isMain: c.isMain,
      attemptCycleId: cycle?.id ?? null,
      examDate: cycle ? nextStageDate(cycle, today) : null,
    };
  });
}
