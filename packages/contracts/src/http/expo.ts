import { z } from "../zod.js";

/** Stall (CLAUDE.md section 8): the 10-question expo challenge and the one-per-user sticker code. BOLT-0112. */

export const ExpoChallenge = z
  .object({
    challengeId: z.uuid(),
    /** Never carries the correct answers; grading happens on submit. */
    questions: z.array(
      z.object({
        id: z.uuid(),
        stem: z.string(),
        options: z.array(z.object({ id: z.string(), text: z.string() })),
      }),
    ),
    secondsPerQuestion: z.number().int().positive(),
  })
  .openapi("ExpoChallenge");

export const SubmitExpoChallengeBody = z
  .object({
    answers: z
      .array(
        z.object({
          questionId: z.uuid(),
          /** null = no answer in time. */
          optionId: z.string().min(1).max(16).nullable(),
          ms: z.number().int().min(0).max(600_000),
        }),
      )
      .max(50),
  })
  .openapi("SubmitExpoChallengeBody");

/** Sticker codes look like HM-7KQX: 4 characters from an alphabet without 0, O, 1 or I. */
export const StickerCode = z.string().regex(/^HM-[2-9A-HJ-NP-Z]{4}$/).openapi("StickerCodeValue");

export const ExpoChallengeResult = z
  .object({
    score: z.number().int().min(0),
    total: z.number().int().min(0),
    results: z.array(
      z.object({ questionId: z.uuid(), correct: z.boolean(), correctOptionId: z.string(), explanation: z.string() }),
    ),
    stickerCode: StickerCode.nullable(),
  })
  .openapi("ExpoChallengeResult");

export const MyStickerCode = z.object({ code: StickerCode.nullable(), redeemed: z.boolean() }).openapi("MyStickerCode");

export const RedeemStickerCodeBody = z
  /** Case and spaces are forgiven: " hm-7kqx " is read as HM-7KQX. */
  .object({ code: z.string().min(1).max(32) })
  .openapi("RedeemStickerCodeBody");

export const StickerCodeRedeemed = z
  .object({ redeemed: z.literal(true), redeemedAt: z.iso.datetime() })
  .openapi("StickerCodeRedeemed");
