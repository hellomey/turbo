import type { Clock } from "../../../shared/clock.js";
import { istDayKey } from "../../../shared/clock.js";
import { assertAdult, checkEligibility as engine, type Answers, type EligibilityResultDto } from "../domain/eligibility.js";
import type { ExamsRepository } from "./ports.js";

/**
 * POST /v1/eligibility/check (§17.1 steps 1-3). A pure computation: nothing is stored.
 * The under-18 check uses TODAY in Asia/Kolkata (server clock), before any data is read.
 */
export async function checkEligibility(repo: ExamsRepository, clock: Clock, answers: Answers): Promise<EligibilityResultDto> {
  const today = istDayKey(clock.now());
  assertAdult(answers.dateOfBirth, today);
  return engine(answers, today, await repo.listPublishedWithRules());
}
