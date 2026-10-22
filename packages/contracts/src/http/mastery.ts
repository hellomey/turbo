import { z } from "../zod.js";
import { ExamCode } from "./exams.js";
import { LampRing } from "./study.js";
import { AnswerInput, GradedAnswer, Question } from "./questions.js";

/**
 * `mastery` (blueprint §5.1, §5.2): rings, recall ladder, dimming, relight, Career Ladder.
 * The server decides every ring (§34.1); the app shows what it gets back and replaces its local copy (§39).
 */

/** Authoritative state of one lamp for this user. */
export const TopicState = z
  .object({
    topicId: z.uuid(),
    ring: LampRing,
    litAt: z.iso.datetime().nullable(),
    goldAt: z.iso.datetime().nullable(),
    lessonCompletedAt: z.iso.datetime().nullable(),
    /** When the next recall is due (server time). null = not Lit yet. */
    nextDueAt: z.iso.datetime().nullable(),
    /** Which check the lamp offers now. */
    nextCheck: z.enum(["lesson", "lit", "recall", "relight", "gold", "none"]),
    updatedAt: z.iso.datetime(),
  })
  .openapi("TopicState");

export const TopicStateQuery = z.object({
  examCode: ExamCode,
  /** Only lamps changed after this time (incremental sync into Drift). */
  since: z.iso.datetime().optional(),
  cursor: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(500).default(200),
});

export const TopicStatePage = z
  .object({ items: z.array(TopicState), nextCursor: z.string().nullable(), serverNow: z.iso.datetime() })
  .openapi("TopicStatePage");

/** Career Ladder (§5.2): computed only from ring counts. "Game title. Not an official designation." */
export const Rank = z
  .object({
    level: z.number().int().min(1).max(11),
    /** Rank titles are per exam family data (R6); TN titles for TNPSC. */
    title: z.string(),
    familyCode: z.string().nullable(),
    /** XP = lamp points (D-2026-10-22-16). Not a currency; cannot be bought, spent or converted. */
    xp: z.number().int().nonnegative(),
    xpForThisLevel: z.number().int().nonnegative(),
    xpForNextLevel: z.number().int().nonnegative().nullable(),
    note: z.string(),
  })
  .openapi("Rank");

export const RingCounts = z
  .object({
    totalLamps: z.number().int().nonnegative(),
    lit: z.number().int().nonnegative(),
    steady: z.number().int().nonnegative(),
    gold: z.number().int().nonnegative(),
    dimming: z.number().int().nonnegative(),
    dim: z.number().int().nonnegative(),
  })
  .openapi("RingCounts");

export const MasterySummary = z
  .object({
    rank: Rank,
    counts: RingCounts,
    /** Per exam the user follows (one lamp, many exam colours: counted once in `counts`). */
    byExam: z.array(z.object({ examCode: ExamCode, counts: RingCounts })),
    serverNow: z.iso.datetime(),
  })
  .openapi("MasterySummary");

export const RelightItem = z
  .object({
    topicId: z.uuid(),
    topicName: z.string(),
    subjectCode: z.string(),
    dim: z.enum(["dimming", "dim"]),
    overdueSince: z.iso.datetime(),
    minutes: z.number().int().positive(),
  })
  .openapi("RelightItem");

export const RelightQueue = z
  .object({ items: z.array(RelightItem), totalMinutes: z.number().int().nonnegative() })
  .openapi("RelightQueue");

export const LessonCompleteBody = z
  .object({ via: z.enum(["lesson", "textbook"]) })
  .openapi("LessonCompleteBody");

export const CheckKind = z.enum(["lit", "recall", "relight", "gold"]).openapi("CheckKind");

export const StartCheckBody = z.object({ kind: CheckKind }).openapi("StartCheckBody");

/** A server-issued check: the server picks the questions and, for Gold, sets the deadline. */
export const TopicCheck = z
  .object({
    checkId: z.uuid(),
    topicId: z.uuid(),
    kind: CheckKind,
    questions: z.array(Question),
    passMark: z.number().int().positive(),
    issuedAt: z.iso.datetime(),
    /** Server deadline (Gold is timed). null = untimed. */
    deadlineAt: z.iso.datetime().nullable(),
    serverNow: z.iso.datetime(),
  })
  .openapi("TopicCheck");

export const SubmitCheckBody = z
  .object({ answers: z.array(AnswerInput).min(1).max(50) })
  .openapi("SubmitCheckBody");

export const RankChange = z
  .object({ from: z.number().int().min(1).max(11), to: z.number().int().min(1).max(11), title: z.string(), note: z.string() })
  .openapi("RankChange");

export const CheckResult = z
  .object({
    checkId: z.uuid(),
    kind: CheckKind,
    passed: z.boolean(),
    correct: z.number().int().nonnegative(),
    total: z.number().int().positive(),
    /** Answers that reached the server after the deadline are not counted (§5.1 Gold). */
    lateAnswersIgnored: z.number().int().nonnegative(),
    graded: z.array(GradedAnswer),
    topicState: TopicState,
    rankUp: RankChange.nullable(),
  })
  .openapi("CheckResult");
