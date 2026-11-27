import { z } from "../zod.js";
import { ExamCode } from "./exams.js";
import { Question } from "./questions.js";

/**
 * `games`: Daily Spin and solo Confidence Duel (BOLT-0115). Games are free: no request here takes a stake, an entry
 * fee or anything bought. Prizes are Points only (never Sparks, never anything worth money). Odds come from the
 * server's versioned table and are the exact table the draw uses (FW-026, FW-027).
 */

export const SpinPrize = z
  .object({
    id: z.string(),
    label: z.string(),
    /** `points` credits `amount` Points; `none` is "Better luck tomorrow". */
    kind: z.enum(["points", "none"]),
    amount: z.number().int().min(0),
    /** Exact chance of this prize, in percent (all prizes add up to 100). */
    percent: z.number().min(0).max(100),
  })
  .openapi("SpinPrize");

export const DailySpinState = z
  .object({
    oddsVersion: z.number().int().positive(),
    prizes: z.array(SpinPrize),
    spunToday: z.boolean(),
    todaysPrize: SpinPrize.nullable(),
    /** When the next free spin opens: 5 AM IST (games sleep 12 AM to 5 AM). */
    nextSpinAt: z.iso.datetime(),
    asleep: z.boolean(),
  })
  .openapi("DailySpinState");

export const DailySpinResult = z
  .object({
    prize: SpinPrize,
    oddsVersion: z.number().int().positive(),
    odds: z.array(SpinPrize),
    nextSpinAt: z.iso.datetime(),
    /** True when today's spin had already happened: the same prize is returned and nothing is credited again. */
    alreadySpun: z.boolean(),
  })
  .openapi("DailySpinResult");

export const DuelConfidence = z.number().int().min(1).max(3).openapi("DuelConfidence");

export const DuelScoringRow = z
  .object({ confidence: DuelConfidence, label: z.string(), correctPoints: z.number().int().min(0), wrongPoints: z.number().int().min(0) })
  .openapi("DuelScoringRow");

export const DuelRules = z
  .object({
    questionsPerDuel: z.number().int().positive(),
    timeLimitSeconds: z.number().int().positive(),
    /** Answers sent sooner than this after the duel started earn no Points (too fast to have read the questions). */
    minSecondsForPoints: z.number().int().min(0),
    /** Extra time after the limit for a dropped connection. Later than this earns no Points. */
    graceSeconds: z.number().int().min(0),
    dailyPointsCap: z.number().int().positive(),
    scoring: z.array(DuelScoringRow),
  })
  .openapi("DuelRules");

export const ConfidenceDuelQuery = z.object({ examCode: ExamCode }).openapi("ConfidenceDuelQuery");

export const ConfidenceDuel = z
  .object({
    duelId: z.uuid(),
    examCode: z.string(),
    startedAt: z.iso.datetime(),
    /** Published practice questions. No answers: the server grades. */
    questions: z.array(Question),
    rules: DuelRules,
    pointsToday: z.number().int().min(0),
  })
  .openapi("ConfidenceDuel");

export const SubmitDuelBody = z
  .object({
    answers: z
      .array(z.object({ questionId: z.uuid(), optionId: z.string().min(1).max(64), confidence: DuelConfidence }).strict())
      .min(1)
      .max(10),
  })
  .strict()
  .openapi("SubmitDuelBody");

export const DuelAnswerResult = z
  .object({
    questionId: z.uuid(),
    correct: z.boolean(),
    correctOptionIds: z.array(z.string()),
    /** null when the question was not answered (counts as wrong, 0 Points). */
    chosenOptionId: z.string().nullable(),
    confidence: DuelConfidence.nullable(),
    explanationMarkdown: z.string(),
    points: z.number().int().min(0),
  })
  .openapi("DuelAnswerResult");

export const DuelResult = z
  .object({
    duelId: z.uuid(),
    results: z.array(DuelAnswerResult),
    /** What the answers scored by the rules. */
    score: z.number().int().min(0),
    /** Points actually credited (score, less anything over today's cap; 0 when withheld). */
    pointsAwarded: z.number().int().min(0),
    pointsWithheld: z.enum(["too_fast", "too_late", "daily_cap"]).nullable(),
    pointsToday: z.number().int().min(0),
    dailyPointsCap: z.number().int().positive(),
  })
  .openapi("DuelResult");

export const GameRules = z
  .object({
    /** Every game prize is one of these. Never Sparks or anything worth money. */
    prizeCurrencies: z.array(z.literal("POINTS")),
    /** Games never take a stake or entry fee. */
    stake: z.literal("none"),
    sleep: z.object({ from: z.string(), to: z.string(), timeZone: z.literal("Asia/Kolkata") }),
    dailySpin: z.object({ oddsVersion: z.number().int().positive(), spinsPerDay: z.number().int().positive(), prizes: z.array(SpinPrize) }),
    confidenceDuel: DuelRules,
  })
  .openapi("GameRules");
