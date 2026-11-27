import { GAME_LIMITS } from "./limits.js";

/**
 * Confidence Duel scoring (BOLT-0115): a solo round against the clock. Points reward calibration: being sure and right
 * pays most, being sure and wrong pays nothing, and an honest "Not sure" on a miss still earns a little. No row is
 * negative, so a duel can never take Points away. Changing these numbers needs founder approval.
 */
export const DUEL_RULES = Object.freeze({
  questionsPerDuel: 5,
  timeLimitSeconds: 150,
  /** 2 seconds a question: anything faster cannot have read the questions. */
  minSecondsForPoints: 10,
  graceSeconds: GAME_LIMITS.reconnectWindowSeconds,
  dailyPointsCap: 50,
  scoring: Object.freeze([
    { confidence: 1, label: "Not sure", correctPoints: 2, wrongPoints: 1 },
    { confidence: 2, label: "Fairly sure", correctPoints: 3, wrongPoints: 0 },
    { confidence: 3, label: "Certain", correctPoints: 5, wrongPoints: 0 },
  ] as const),
});

export type Confidence = 1 | 2 | 3;

/** Points for one answer. An unanswered question earns 0. */
export function duelPoints(correct: boolean, confidence: Confidence | null): number {
  const row = DUEL_RULES.scoring.find((r) => r.confidence === confidence);
  if (!row) return 0;
  return correct ? row.correctPoints : row.wrongPoints;
}

export type Withheld = "too_fast" | "too_late" | "daily_cap" | null;

/** Points credited for a duel scored `score`, sent `elapsedMs` after it started, with `earnedToday` already credited. */
export function duelAward(score: number, elapsedMs: number, earnedToday: number): { points: number; withheld: Withheld } {
  if (elapsedMs < DUEL_RULES.minSecondsForPoints * 1000) return { points: 0, withheld: "too_fast" };
  if (elapsedMs > (DUEL_RULES.timeLimitSeconds + DUEL_RULES.graceSeconds) * 1000) return { points: 0, withheld: "too_late" };
  const room = Math.max(0, DUEL_RULES.dailyPointsCap - earnedToday);
  return score > room ? { points: room, withheld: "daily_cap" } : { points: score, withheld: null };
}
