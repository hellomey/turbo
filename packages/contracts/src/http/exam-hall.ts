import { z } from "../zod.js";
import { ExamCode, Marks } from "./exams.js";
import { GradedAnswer, Question } from "./questions.js";

/**
 * `exam-hall` (blueprint §9.9, §9.10, §10.6, §19.4 Q36-Q38): OMR/CBT mocks on a SERVER timer, resume, marking from the
 * paper's versioned marking scheme (ADR-0013), free monthly allowance, State Mock Sunday with a statewide rank.
 */

export const MockKind = z.enum(["full", "sectional", "state_mock_sunday"]).openapi("MockKind");
export const MockMode = z.enum(["omr", "cbt"]).openapi("MockMode");

export const MockSummary = z
  .object({
    id: z.uuid(),
    code: z.string(),
    examCode: ExamCode,
    paperCode: z.string(),
    title: z.string(),
    kind: MockKind,
    questionCount: z.number().int().positive(),
    durationMinutes: z.number().int().positive(),
    negativeMarking: z.boolean(),
    /** Scheduled window (State Mock Sunday). null = open any time. */
    opensAt: z.iso.datetime().nullable(),
    lateJoinUntil: z.iso.datetime().nullable(),
    closesAt: z.iso.datetime().nullable(),
    free: z.boolean(),
    /** Free user who used this month's full mock: true (shows "Not now", §13). */
    locked: z.boolean(),
    myLastAttemptId: z.uuid().nullable(),
  })
  .openapi("MockSummary");

export const MockAllowance = z
  .object({
    istMonth: z.string().regex(/^\d{4}-\d{2}$/),
    freeFullMocksUsed: z.number().int().nonnegative(),
    freeFullMocksLimit: z.number().int().nonnegative().nullable(),
  })
  .openapi("MockAllowance");

export const MockList = z
  .object({ items: z.array(MockSummary), allowance: MockAllowance })
  .openapi("MockList");

export const MockListQuery = z.object({ examCode: ExamCode });

export const StartMockBody = z.object({ mode: MockMode }).openapi("StartMockBody");

export const MockSectionView = z
  .object({
    code: z.string(),
    name: z.string(),
    questionIds: z.array(z.uuid()),
    minutes: z.number().int().positive().nullable(),
  })
  .openapi("MockSectionView");

export const SavedMockAnswer = z
  .object({
    questionId: z.uuid(),
    chosenOptionIds: z.array(z.string()),
    markedForReview: z.boolean(),
  })
  .openapi("SavedMockAnswer");

/** Everything the app needs to show or RESUME an attempt (§19.8 Q76). Remaining time comes from the server. */
export const MockAttemptState = z
  .object({
    attemptId: z.uuid(),
    mock: MockSummary,
    mode: MockMode,
    status: z.enum(["in_progress", "submitted", "expired"]),
    startedAt: z.iso.datetime(),
    deadlineAt: z.iso.datetime(),
    serverNow: z.iso.datetime(),
    sections: z.array(MockSectionView),
    questions: z.array(Question),
    answers: z.array(SavedMockAnswer),
    /** false once any answer arrived after the deadline or the attempt was not taken in the live window (§18, §39). */
    ranked: z.boolean(),
  })
  .openapi("MockAttemptState");

export const SaveMockAnswersBody = z
  .object({
    answers: z
      .array(SavedMockAnswer.extend({ clientAt: z.iso.datetime() }))
      .min(1)
      .max(200),
  })
  .openapi("SaveMockAnswersBody");

export const MockAnswersSaved = z
  .object({
    saved: z.number().int().nonnegative(),
    ignoredAfterDeadline: z.number().int().nonnegative(),
    serverNow: z.iso.datetime(),
    remainingSeconds: z.number().int().nonnegative(),
  })
  .openapi("MockAnswersSaved");

export const SectionResult = z
  .object({
    code: z.string(),
    name: z.string(),
    correct: z.number().int().nonnegative(),
    wrong: z.number().int().nonnegative(),
    unanswered: z.number().int().nonnegative(),
    score: Marks,
    maxScore: Marks,
  })
  .openapi("SectionResult");

export const MockReport = z
  .object({
    attemptId: z.uuid(),
    mockId: z.uuid(),
    examCode: ExamCode,
    submittedAt: z.iso.datetime(),
    /** Exact score: correct x mark - wrong x penalty, per the marking scheme version used. */
    score: Marks,
    maxScore: Marks,
    /** Display value rounded to 2 decimals (string to avoid floats). */
    scoreDisplay: z.string(),
    markingSchemeVersion: z.number().int().positive(),
    correct: z.number().int().nonnegative(),
    wrong: z.number().int().nonnegative(),
    unanswered: z.number().int().nonnegative(),
    sections: z.array(SectionResult),
    /** Mistakes linked to lamps (§19.4 Q38). */
    mistakes: z.array(GradedAnswer),
    weakTopicIds: z.array(z.uuid()),
    ranked: z.boolean(),
    /** Free users: the full Pro report is shown blurred (§13 "Proof before payment"). */
    fullReportLocked: z.boolean(),
  })
  .openapi("MockReport");

export const MockAttemptListItem = z
  .object({
    attemptId: z.uuid(),
    mockId: z.uuid(),
    title: z.string(),
    kind: MockKind,
    status: z.enum(["in_progress", "submitted", "expired"]),
    startedAt: z.iso.datetime(),
    scoreDisplay: z.string().nullable(),
  })
  .openapi("MockAttemptListItem");

export const MockAttemptPage = z
  .object({ items: z.array(MockAttemptListItem), nextCursor: z.string().nullable() })
  .openapi("MockAttemptPage");

export const StateMockInfo = z
  .object({
    mock: MockSummary.nullable(),
    /** Next 1st or 3rd Sunday (IST) when no mock is scheduled yet. */
    nextSunday: z.iso.date(),
    rankPublishAt: z.iso.datetime().nullable(),
  })
  .openapi("StateMockInfo");

export const StateMockQuery = z.object({ examCode: ExamCode });

export const StatewideRank = z
  .object({
    mockId: z.uuid(),
    /** Rank among takers of this exam, scoped per family (R6): "statewide" for TNPSC. */
    scopeLabel: z.string(),
    rank: z.number().int().positive(),
    rankedCandidates: z.number().int().positive(),
    /** Percentile as a whole number 0-100 (no fake precision). */
    percentile: z.number().int().min(0).max(100),
    score: Marks,
    publishedAt: z.iso.datetime(),
  })
  .openapi("StatewideRank");
