import type { SpinPrize, z } from "@heymey/contracts";

/**
 * Daily Spin prize table (BOLT-0115). The ONE table: the draw, GET /v1/games/daily-spin, GET /v1/games/rules and the
 * app all read it, so the odds shown are the odds drawn (FW-027). Changing a weight or prize means a new `version`
 * and founder approval. Prizes are Points or nothing: never Sparks, never XP (XP comes only from learning, FW-025).
 */
export const DAILY_SPIN_ODDS = Object.freeze({
  version: 1,
  prizes: Object.freeze([
    { id: "points_5", label: "5 Points", kind: "points", amount: 5, weight: 40 },
    { id: "points_10", label: "10 Points", kind: "points", amount: 10, weight: 30 },
    { id: "points_20", label: "20 Points", kind: "points", amount: 20, weight: 15 },
    { id: "points_50", label: "50 Points", kind: "points", amount: 50, weight: 5 },
    { id: "none", label: "Better luck tomorrow", kind: "none", amount: 0, weight: 10 },
  ] as const),
});

export type SpinPrizeDto = z.infer<typeof SpinPrize>;
export const SPIN_TOTAL_WEIGHT = DAILY_SPIN_ODDS.prizes.reduce((s, p) => s + p.weight, 0);

const toDto = (p: (typeof DAILY_SPIN_ODDS.prizes)[number]): SpinPrizeDto => ({
  id: p.id,
  label: p.label,
  kind: p.kind,
  amount: p.amount,
  percent: Math.round((p.weight * 10_000) / SPIN_TOTAL_WEIGHT) / 100,
});

/** The published odds, exact percentages, in table order. */
export function spinOdds(): SpinPrizeDto[] {
  return DAILY_SPIN_ODDS.prizes.map(toDto);
}

export function spinPrizeById(id: string): SpinPrizeDto | null {
  const p = DAILY_SPIN_ODDS.prizes.find((x) => x.id === id);
  return p ? toDto(p) : null;
}

/** The prize for a uniform roll in [0, total weight): each prize owns a band as wide as its weight. */
export function drawSpin(roll: number): SpinPrizeDto {
  if (!Number.isInteger(roll) || roll < 0 || roll >= SPIN_TOTAL_WEIGHT) throw new RangeError(`roll ${roll} out of range`);
  let edge = 0;
  for (const p of DAILY_SPIN_ODDS.prizes) {
    edge += p.weight;
    if (roll < edge) return toDto(p);
  }
  /* c8 ignore next */
  throw new RangeError("unreachable");
}
