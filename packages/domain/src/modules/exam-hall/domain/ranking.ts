import { compare, type Fraction } from "./fraction.js";

export interface RankInput {
  userId: string;
  score: Fraction;
}

export interface RankRow {
  userId: string;
  rank: number;
  percentile: number;
  candidates: number;
}

/**
 * Invariant 12: highest score first; equal scores share a rank (1, 1, 3); percentile is a whole number:
 * the share of ranked candidates you scored at or above, rounded down (top = 100).
 */
export function rankAttempts(inputs: readonly RankInput[]): RankRow[] {
  const sorted = [...inputs].sort((a, b) => compare(b.score, a.score) || a.userId.localeCompare(b.userId));
  const n = sorted.length;
  const rows: RankRow[] = [];
  sorted.forEach((s, i) => {
    const prev = rows[i - 1];
    const prevInput = sorted[i - 1];
    const rank = prev && prevInput && compare(prevInput.score, s.score) === 0 ? prev.rank : i + 1;
    rows.push({ userId: s.userId, rank, percentile: Math.floor((100 * (n - rank + 1)) / n), candidates: n });
  });
  return rows;
}
