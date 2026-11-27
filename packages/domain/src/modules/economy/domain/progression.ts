/**
 * XP, levels, Points from check-in and trophies (BOLT-0113). Pure rules, no I/O.
 *
 * XP is awarded by the server only, for real learning events. It is never bought and never converts into Points,
 * Sparks or anything worth money (FW-021, FW-025). Points are never bought either (FW-023).
 */

/** The XP table. One place, so the amounts stay easy to explain and to review. */
export const XP_RULES = {
  /** Lesson finished for a topic. Once per topic. */
  lesson_done: { xp: 10, once: true },
  /** Lit check passed: a lamp lit for the first time. Once per topic. */
  lit: { xp: 25, once: true },
  /** Recall check passed (one Steady step). Every pass counts; the recall schedule spaces them out. */
  recall_pass: { xp: 15, once: false },
  /** A dim lamp relit. Every relight counts; a lamp only dims after days without recall. */
  relight: { xp: 15, once: false },
  /** Gold earned. Once per topic. */
  gold: { xp: 50, once: true },
  /** An Exam Hall mock finished (submitted or time up). Once per attempt. */
  mock_submitted: { xp: 40, once: true },
} as const;
export type XpReason = keyof typeof XP_RULES;

/** Daily check-in, once per IST day. Missing a day changes nothing. */
export const CHECK_IN_REWARD = { xp: 5, points: 10 } as const;

/** Level L starts at 100 * (L-1) * L / 2 XP: each level needs 100 XP more than the one before. */
const LEVEL_STEP = 100;
const startOf = (level: number) => (LEVEL_STEP * (level - 1) * level) / 2;

export function levelFor(xp: number): { level: number; levelStartXp: number; nextLevelXp: number } {
  let level = 1;
  while (startOf(level + 1) <= xp) level++;
  return { level, levelStartXp: startOf(level), nextLevelXp: startOf(level + 1) };
}

export const TROPHIES = [
  { code: "first_lamp", title: "First lamp lit" },
  { code: "first_gold", title: "First Gold" },
  { code: "subject_lit", title: "A whole subject lit" },
  { code: "first_mock", title: "First mock finished" },
  { code: "five_study_days", title: "Five study days" },
  { code: "expo_challenge", title: "Expo Challenge finished" },
] as const;
export type TrophyCode = (typeof TROPHIES)[number]["code"];
export const TROPHY_CODES: readonly TrophyCode[] = TROPHIES.map((t) => t.code);
export const trophyTitle = (code: TrophyCode): string => TROPHIES.find((t) => t.code === code)?.title ?? code;

/** Study days needed for `five_study_days`. Any five days count; they do not have to be in a row. */
export const STUDY_DAYS_FOR_TROPHY = 5;

const IST_MS = 330 * 60_000;
const DAY_MS = 86_400_000;

/** The IST week (Monday 00:00 IST to the next Monday) that contains `at`, as UTC instants. */
export function istWeekRange(at: Date): { from: Date; to: Date } {
  const ist = at.getTime() + IST_MS;
  const midnight = ist - (ist % DAY_MS);
  const sinceMonday = (new Date(midnight).getUTCDay() + 6) % 7;
  const from = midnight - sinceMonday * DAY_MS - IST_MS;
  return { from: new Date(from), to: new Date(from + 7 * DAY_MS) };
}
