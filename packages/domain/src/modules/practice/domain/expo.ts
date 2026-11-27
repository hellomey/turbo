/** Stall rules (CLAUDE.md section 8, BOLT-0112). Pure. */

export const EXPO_CONFIG = {
  /** Content set loaded by packages/db/prisma/seed/aptitude-content.ts (Source.setName). */
  setName: "expo-challenge-1",
  questionCount: 10,
  secondsPerQuestion: 20,
  ttlMs: 15 * 60_000,
  /** Attempts at a fresh random code before giving up (32^4 = 1,048,576 codes). */
  codeAttempts: 8,
} as const;

/** No 0, O, 1 or I: staff read these aloud from a phone screen. */
export const STICKER_ALPHABET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";
const CODE_RE = /^HM-[2-9A-HJ-NP-Z]{4}$/;

export const STICKER_REDEEM_ROLES = ["OPS", "ADMIN", "SUPPORT_AGENT"] as const;

export type StickerReason = "expo_challenge" | "first_lamp";

/** `randomInt(maxExclusive)` must be a CSPRNG in apps (node:crypto). */
export function newStickerCode(randomInt: (maxExclusive: number) => number): string {
  let s = "HM-";
  for (let i = 0; i < 4; i++) s += STICKER_ALPHABET[randomInt(STICKER_ALPHABET.length)];
  return s;
}

/** " hm-7kqx " -> "HM-7KQX"; anything not in the code format -> null. */
export function normalizeStickerCode(raw: string): string | null {
  const s = raw.trim().toUpperCase();
  return CODE_RE.test(s) ? s : null;
}

export function canRedeemStickerCodes(roles: readonly string[]): boolean {
  return roles.some((r) => (STICKER_REDEEM_ROLES as readonly string[]).includes(r));
}

export interface ExpoKey {
  correctOptionIds: readonly string[];
  explanationMarkdown: string;
}

export interface ExpoGraded {
  score: number;
  total: number;
  results: { questionId: string; correct: boolean; correctOptionId: string; explanation: string }[];
}

/** One result per challenge question, in challenge order. Missing, null or foreign answers are wrong. */
export function gradeExpo(
  questionIds: readonly string[],
  keys: ReadonlyMap<string, ExpoKey>,
  answers: readonly { questionId: string; optionId: string | null }[],
): ExpoGraded {
  const chosen = new Map(answers.map((a) => [a.questionId, a.optionId]));
  const results = questionIds.flatMap((questionId) => {
    const key = keys.get(questionId);
    if (!key) return [];
    const correctOptionId = key.correctOptionIds[0] ?? "";
    const pick = chosen.get(questionId) ?? null;
    return [{ questionId, correct: pick !== null && pick === correctOptionId, correctOptionId, explanation: key.explanationMarkdown }];
  });
  return { score: results.filter((r) => r.correct).length, total: results.length, results };
}
