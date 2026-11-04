import type { UserExams, z } from "@heymey/contracts";
import { DomainError } from "../../../shared/errors.js";
import { isPublished, toSummary } from "../domain/exam.js";
import { validateExamChoice, type UserExamsInput } from "../domain/my-exams.js";
import { assertCyclesBelong } from "./plan-targets.js";
import type { ExamsRepository } from "./ports.js";

export type UserExamsDto = z.infer<typeof UserExams>;

/** GET /v1/me/exams. Exams that were unpublished since the choice are left out. */
export async function getMyExams(repo: ExamsRepository, userId: string): Promise<UserExamsDto> {
  const [choices, exams] = await Promise.all([repo.getChoices(userId), repo.listPublished()]);
  const byCode = new Map(exams.filter(isPublished).map((e) => [e.code, e]));
  const main = choices.find((c) => c.isMain);
  const mainExam = main ? byCode.get(main.examCode) : undefined;
  const others = choices
    .filter((c) => !c.isMain)
    .map((c) => byCode.get(c.examCode))
    .filter((e) => e !== undefined)
    .sort((a, b) => a.name.localeCompare(b.name));
  return { main: mainExam ? toSummary(mainExam) : null, others: others.map(toSummary) };
}

/** PUT /v1/me/exams: validate, check every code is a published exam, replace atomically. */
export async function setMyExams(repo: ExamsRepository, userId: string, input: UserExamsInput): Promise<UserExamsDto> {
  const choices = validateExamChoice(input);
  const published = new Set((await repo.listPublished()).filter(isPublished).map((e) => e.code));
  const missing = choices.map((c) => c.examCode).filter((code) => !published.has(code));
  if (missing.length) throw new DomainError("EXAM_NOT_FOUND", { codes: missing });
  await assertCyclesBelong(repo, choices); // R2: attemptCycles (BOLT-0012)
  await repo.replaceChoices(userId, choices);
  return getMyExams(repo, userId);
}
