import { MASTERY_CONFIG } from "./config.js";
import type { LampState } from "./lamp.js";

/**
 * Career Ladder (blueprint §5.2, §5.3 rule 4; D-2026-10-22-15, -16). Rank and XP are PURE functions of ring counts and
 * the lamp count only: no entitlement, purchase, Sparks or study-hours input exists in these signatures (FW-020).
 * XP is not a currency: it has no ledger and no conversion path (FW-021).
 */
export interface RingTotals {
  /** Lamps in the user's syllabus (union of their exams, each shared lamp once). */
  totalLamps: number;
  lit: number;
  /** Sum of steadyLevel over lamps (each step is worth XP). */
  steadySteps: number;
  gold: number;
}

export interface RankValue {
  level: number;
  xp: number;
  xpForThisLevel: number;
  xpForNextLevel: number | null;
}

export const MAX_STEADY_LEVEL = MASTERY_CONFIG.recall.ladderDays.length;
const XP_PER_LAMP_MAX = MASTERY_CONFIG.xp.lit + MAX_STEADY_LEVEL * MASTERY_CONFIG.xp.perSteadyStep + MASTERY_CONFIG.xp.gold;

export function xpOf(t: Omit<RingTotals, "totalLamps">): number {
  return t.lit * MASTERY_CONFIG.xp.lit + t.steadySteps * MASTERY_CONFIG.xp.perSteadyStep + t.gold * MASTERY_CONFIG.xp.gold;
}

const threshold = (maxXp: number, percent: number) => Math.ceil((maxXp * percent) / 100);

export function computeRank(t: RingTotals): RankValue {
  const xp = xpOf(t);
  const maxXp = t.totalLamps * XP_PER_LAMP_MAX;
  const steps = MASTERY_CONFIG.rankThresholdPercent;
  let index = 0;
  if (maxXp > 0) {
    for (let i = 0; i < steps.length; i++) if (xp * 100 >= (steps[i] as number) * maxXp) index = i;
  }
  const nextPercent = steps[index + 1];
  return {
    level: index + 1,
    xp,
    xpForThisLevel: threshold(maxXp, steps[index] as number),
    xpForNextLevel: nextPercent === undefined || maxXp === 0 ? null : threshold(maxXp, nextPercent),
  };
}

export function rankTitle(level: number, titles: readonly string[] = MASTERY_CONFIG.defaultRankTitles): string {
  return titles[level - 1] ?? MASTERY_CONFIG.defaultRankTitles[level - 1] ?? "Aspirant";
}

export interface CountsDto {
  totalLamps: number;
  lit: number;
  steady: number;
  gold: number;
  dimming: number;
  dim: number;
}

/** Ring counts over a set of lamps. Only states whose topic is in `topicIds` count (shared lamps once, invariant 13). */
export function countRings(states: readonly LampState[], topicIds: ReadonlySet<string>): CountsDto & { steadySteps: number } {
  const c = { totalLamps: topicIds.size, lit: 0, steady: 0, gold: 0, dimming: 0, dim: 0, steadySteps: 0 };
  for (const s of states) {
    if (!topicIds.has(s.topicId)) continue;
    if (s.litAt) c.lit++;
    if (s.steadyLevel > 0) c.steady++;
    c.steadySteps += s.steadyLevel;
    if (s.goldAt) c.gold++;
    if (s.litAt && s.dimState === "dimming") c.dimming++;
    if (s.litAt && s.dimState === "dim") c.dim++;
  }
  return c;
}
