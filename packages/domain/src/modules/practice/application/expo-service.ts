import type { ExpoChallengeResult, MyStickerCode, StickerCodeRedeemed, SubmitExpoChallengeBody, ExpoChallenge, z } from "@heymey/contracts";
import type { Prisma } from "@heymey/db";
import { DomainError, type Clock } from "../../../shared/index.js";
import { shuffle, type QuestionWithKey } from "../../content/index.js";
import { EXPO_CONFIG, gradeExpo, newStickerCode, normalizeStickerCode, type StickerReason } from "../domain/expo.js";

/** Ports of the stall use cases (BOLT-0112). Adapter: infrastructure/prisma-expo-repository.ts. */

export interface ExpoChallengeRecord {
  id: string;
  userId: string;
  questionIds: string[];
  createdAt: Date;
  expiresAt: Date;
  submittedAt: Date | null;
}

export type RedeemOutcome = { kind: "ok"; redeemedAt: Date } | { kind: "not_found" } | { kind: "already" };

/** Runs inside the redeem transaction (the audit row). If it throws, the code stays unredeemed. */
export type RedeemTxHook = (tx: Prisma.TransactionClient) => Promise<void>;

export interface ExpoRepository {
  createChallenge(c: Omit<ExpoChallengeRecord, "id" | "submittedAt">): Promise<string>;
  getChallenge(id: string): Promise<ExpoChallengeRecord | null>;
  /** Conditional: false when already submitted (single submit, race-safe). */
  markSubmitted(id: string, at: Date, score: number): Promise<boolean>;
  stickerCodeOf(userId: string): Promise<{ code: string; redeemedAt: Date | null } | null>;
  insertStickerCode(userId: string, code: string, reason: StickerReason, at: Date): Promise<"ok" | "user_has_code" | "code_taken">;
  /** Marks the code used and runs `inTx` (the audit row) in the same transaction. */
  redeem(code: string, by: string, at: Date, inTx?: RedeemTxHook): Promise<RedeemOutcome>;
}

export interface ExpoQuestions {
  publishedIdsInSet(setName: string): Promise<string[]>;
  withKeys(questionIds: readonly string[]): Promise<QuestionWithKey[]>;
}

export interface ExpoDeps {
  repo: ExpoRepository;
  questions: ExpoQuestions;
  lamps: { hasLitLamp(userId: string): Promise<boolean> };
  clock: Clock;
  randomInt: (maxExclusive: number) => number;
}

export type ExpoChallengeDto = z.infer<typeof ExpoChallenge>;
export type ExpoChallengeResultDto = z.infer<typeof ExpoChallengeResult>;
export type SubmitExpoChallengeInput = z.infer<typeof SubmitExpoChallengeBody>;
export type MyStickerCodeDto = z.infer<typeof MyStickerCode>;
export type StickerCodeRedeemedDto = z.infer<typeof StickerCodeRedeemed>;

export async function startChallenge(d: ExpoDeps, userId: string): Promise<ExpoChallengeDto> {
  const ids = await d.questions.publishedIdsInSet(EXPO_CONFIG.setName);
  const picked = shuffle(ids, d.randomInt).slice(0, EXPO_CONFIG.questionCount);
  const byId = new Map((await d.questions.withKeys(picked)).map((q) => [q.question.id, q.question]));
  const questions = picked.flatMap((id) => {
    const q = byId.get(id);
    return q ? [{ id: q.id, stem: q.stem, options: q.options.map((o) => ({ id: o.id, text: o.text })) }] : [];
  });
  if (!questions.length) throw new DomainError("EXPO_CHALLENGE_UNAVAILABLE");
  const now = d.clock.now();
  const challengeId = await d.repo.createChallenge({
    userId,
    questionIds: questions.map((q) => q.id),
    createdAt: now,
    expiresAt: new Date(now.getTime() + EXPO_CONFIG.ttlMs),
  });
  return { challengeId, questions, secondsPerQuestion: EXPO_CONFIG.secondsPerQuestion };
}

export async function submitChallenge(
  d: ExpoDeps,
  userId: string,
  challengeId: string,
  body: SubmitExpoChallengeInput,
): Promise<ExpoChallengeResultDto> {
  const c = await d.repo.getChallenge(challengeId);
  if (!c || c.userId !== userId) throw new DomainError("EXPO_CHALLENGE_NOT_FOUND");
  if (c.submittedAt) throw new DomainError("EXPO_CHALLENGE_ALREADY_SUBMITTED");
  const now = d.clock.now();
  if (now.getTime() > c.expiresAt.getTime()) throw new DomainError("EXPO_CHALLENGE_EXPIRED");

  const keys = new Map((await d.questions.withKeys(c.questionIds)).map((q) => [q.key.questionId, q.key]));
  const graded = gradeExpo(c.questionIds, keys, body.answers);
  if (!(await d.repo.markSubmitted(c.id, now, graded.score))) throw new DomainError("EXPO_CHALLENGE_ALREADY_SUBMITTED");
  const stickerCode = await ensureStickerCode(d, userId, "expo_challenge");
  return { ...graded, stickerCode };
}

export async function myStickerCode(d: ExpoDeps, userId: string): Promise<MyStickerCodeDto> {
  const existing = await d.repo.stickerCodeOf(userId);
  if (existing) return { code: existing.code, redeemed: existing.redeemedAt !== null };
  if (!(await d.lamps.hasLitLamp(userId))) return { code: null, redeemed: false };
  return { code: await ensureStickerCode(d, userId, "first_lamp"), redeemed: false };
}

export async function redeemStickerCode(
  d: ExpoDeps,
  staffUserId: string,
  rawCode: string,
  inTx?: RedeemTxHook,
): Promise<StickerCodeRedeemedDto> {
  const code = normalizeStickerCode(rawCode);
  if (!code) throw new DomainError("STICKER_CODE_NOT_FOUND");
  const r = await d.repo.redeem(code, staffUserId, d.clock.now(), inTx);
  if (r.kind === "not_found") throw new DomainError("STICKER_CODE_NOT_FOUND");
  if (r.kind === "already") throw new DomainError("STICKER_CODE_ALREADY_REDEEMED");
  return { redeemed: true, redeemedAt: r.redeemedAt.toISOString() };
}

/** One code per user; a code collision draws again. */
async function ensureStickerCode(d: ExpoDeps, userId: string, reason: StickerReason): Promise<string> {
  for (let i = 0; i < EXPO_CONFIG.codeAttempts; i++) {
    const existing = await d.repo.stickerCodeOf(userId);
    if (existing) return existing.code;
    const code = newStickerCode(d.randomInt);
    const r = await d.repo.insertStickerCode(userId, code, reason, d.clock.now());
    if (r === "ok") return code;
  }
  throw new Error("sticker code space exhausted");
}
