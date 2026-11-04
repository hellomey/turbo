import { PRACTICE_CONFIG } from "./config.js";

/**
 * Mistake loop (blueprint §36 practice, §19.6 Q60; U-practice invariant 9): 3 wrong answers on one lamp within 14 days
 * make one concept drill, only for entitled (Pro) users, never a duplicate while one is open. Pure.
 */
export interface Tally {
  wrongCount: number;
  windowStart: Date;
  lastWrongAt: Date;
}

const DAY_MS = 86_400_000;

/** The tally after one more wrong answer at `at`. A wrong answer outside the window starts a new window. */
export function addWrong(prev: Tally | null, at: Date): Tally {
  const windowMs = PRACTICE_CONFIG.mistakeLoop.windowDays * DAY_MS;
  if (!prev || at.getTime() - prev.windowStart.getTime() > windowMs) return { wrongCount: 1, windowStart: at, lastWrongAt: at };
  return { wrongCount: prev.wrongCount + 1, windowStart: prev.windowStart, lastWrongAt: at };
}

/** Whether a drill should be made now. */
export function drillDue(t: Tally, entitled: boolean, hasOpenDrill: boolean): boolean {
  if (PRACTICE_CONFIG.mistakeLoop.proOnly && !entitled) return false;
  return !hasOpenDrill && t.wrongCount >= PRACTICE_CONFIG.mistakeLoop.wrongCount;
}

/** Plain-English reason shown on the drill card. */
export function drillReason(t: Tally): string {
  return `You missed ${t.wrongCount} questions on this topic in the last ${PRACTICE_CONFIG.mistakeLoop.windowDays} days.`;
}

/** A tally still inside its window counts as a weak lamp (returned with each answer, inv. 8). */
export function isWeak(t: Tally, now: Date): boolean {
  return now.getTime() - t.windowStart.getTime() <= PRACTICE_CONFIG.mistakeLoop.windowDays * DAY_MS && t.wrongCount >= 2;
}
