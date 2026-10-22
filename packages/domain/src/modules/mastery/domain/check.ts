import { MASTERY_CONFIG } from "./config.js";
import type { CheckKind } from "./lamp.js";

/** Size and pass mark of each check kind (§5.1; D-2026-10-22-10, -11, -13, -14). Gold's pass mark is ceil(80% of set). */
export function checkSpec(kind: CheckKind): { questions: number; passMark: number; minDifficulty: number; timed: boolean } {
  switch (kind) {
    case "lit":
      return { ...MASTERY_CONFIG.litCheck, minDifficulty: 1, timed: false };
    case "recall":
      return { questions: MASTERY_CONFIG.recall.questions, passMark: MASTERY_CONFIG.recall.passMark, minDifficulty: 1, timed: false };
    case "relight":
      return { questions: MASTERY_CONFIG.relight.questions, passMark: MASTERY_CONFIG.relight.passMark, minDifficulty: 1, timed: false };
    case "gold": {
      const g = MASTERY_CONFIG.gold;
      return { questions: g.questions, passMark: Math.ceil((g.questions * g.passPercent) / 100), minDifficulty: g.minDifficulty, timed: true };
    }
  }
}

/** Server deadline for a timed check (Gold): issuedAt + questions x secondsPerQuestion. */
export function deadlineFor(kind: CheckKind, issuedAt: Date): Date | null {
  if (!checkSpec(kind).timed) return null;
  const g = MASTERY_CONFIG.gold;
  return new Date(issuedAt.getTime() + g.questions * g.secondsPerQuestion * 1000);
}

/** Untimed checks expire after `checkTtlHours`; timed checks never expire, late answers just count as wrong. */
export function isExpired(check: { deadlineAt: Date | null; issuedAt: Date }, now: Date): boolean {
  if (check.deadlineAt) return false;
  return now.getTime() > check.issuedAt.getTime() + MASTERY_CONFIG.checkTtlHours * 3_600_000;
}

/** Answers that reached the server after deadline + grace are late (§5.1 Gold, invariant 11). */
export function isLate(check: { deadlineAt: Date | null }, now: Date): boolean {
  return check.deadlineAt !== null && now.getTime() > check.deadlineAt.getTime() + MASTERY_CONFIG.gold.lateGraceSeconds * 1000;
}

/**
 * Score a check. `correctIds` = issued questions answered correctly (graded on the server, invariant 15).
 * Late answers count as wrong. Unanswered questions count as wrong. Pass: correct >= passMark.
 */
export function scoreCheck(input: { total: number; passMark: number; correctIds: ReadonlySet<string>; answered: number; late: boolean }): {
  correct: number;
  passed: boolean;
  lateAnswersIgnored: number;
} {
  const correct = input.late ? 0 : Math.min(input.correctIds.size, input.total);
  return { correct, passed: correct >= input.passMark, lateAnswersIgnored: input.late ? input.answered : 0 };
}

/** Gold attempts allowed per lamp per IST day (invariant 11). */
export function goldLimitReached(attemptsToday: number): boolean {
  return attemptsToday >= MASTERY_CONFIG.gold.attemptsPerTopicPerIstDay;
}

/** §39: offline actions older than `offline.maxAgeDays` when synced are a study log only (invariant 14). */
export function isTooOld(clientAt: Date, now: Date): boolean {
  return now.getTime() - clientAt.getTime() > MASTERY_CONFIG.offline.maxAgeDays * 24 * 3_600_000;
}
