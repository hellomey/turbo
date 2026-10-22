import { z } from "../zod.js";
import { ExamCode } from "./exams.js";
import { GradedAnswer, Question } from "./questions.js";

/** `practice` (blueprint §10.6, §11, §19.4): sessions, the free daily limit (IST), mistakes, PYQ Vault. */

export const PracticeMode = z.enum(["practice", "pyq", "mistakes", "drill"]).openapi("PracticeMode");

export const StartPracticeBody = z
  .object({
    mode: PracticeMode,
    examCode: ExamCode,
    subjectCode: z.string().max(60).optional(),
    topicId: z.uuid().optional(),
    drillId: z.uuid().optional(),
    /** Pocket sessions (§19.2 Q15) map to sizes; the server may return fewer. */
    size: z.number().int().min(1).max(50).default(10),
  })
  .openapi("StartPracticeBody");

/** Free-limit state (§11 "30 a day", §37). `limit` null = unlimited. Day = Asia/Kolkata. */
export const PracticeUsage = z
  .object({
    istDay: z.iso.date(),
    used: z.number().int().nonnegative(),
    limit: z.number().int().positive().nullable(),
    resetsAt: z.iso.datetime(),
    /** The limit sheet appears at most once a day (§13). */
    limitSheetShownToday: z.boolean(),
  })
  .openapi("PracticeUsage");

export const PracticeSession = z
  .object({
    sessionId: z.uuid(),
    mode: PracticeMode,
    examCode: ExamCode,
    questions: z.array(Question),
    usage: PracticeUsage,
    startedAt: z.iso.datetime(),
  })
  .openapi("PracticeSession");

export const PracticeAnswerBody = z
  .object({
    /** Client UUID: the same id the outbox would use offline (§39). Accepted once. */
    clientActionId: z.uuid(),
    questionId: z.uuid(),
    questionVersion: z.number().int().positive(),
    chosenOptionIds: z.array(z.string().min(1).max(8)).max(8),
    timeMs: z.number().int().min(0).max(3_600_000),
    confidence: z.enum(["sure", "think_so", "guessing"]).optional(),
  })
  .openapi("PracticeAnswerBody");

export const PracticeAnswerResult = z
  .object({ graded: GradedAnswer, usage: PracticeUsage, weakTopicIds: z.array(z.uuid()) })
  .openapi("PracticeAnswerResult");

export const Mistake = z
  .object({
    questionId: z.uuid(),
    topicId: z.uuid(),
    stem: z.string(),
    wrongCount: z.number().int().positive(),
    lastWrongAt: z.iso.datetime(),
    graded: GradedAnswer,
  })
  .openapi("Mistake");

export const MistakePage = z
  .object({ items: z.array(Mistake), nextCursor: z.string().nullable() })
  .openapi("MistakePage");

/** Mistake loop (§36 practice, §19.6 Q60): a concept drill after repeated mistakes on the same lamp. */
export const ConceptDrill = z
  .object({
    id: z.uuid(),
    topicId: z.uuid(),
    reason: z.string(),
    questionCount: z.number().int().positive(),
    createdAt: z.iso.datetime(),
    status: z.enum(["open", "done"]),
  })
  .openapi("ConceptDrill");

export const ConceptDrillList = z.object({ items: z.array(ConceptDrill), locked: z.boolean() }).openapi("ConceptDrillList");

export const PyqQuery = z.object({
  examCode: ExamCode,
  year: z.coerce.number().int().min(1950).max(2100).optional(),
  subjectCode: z.string().max(60).optional(),
  topicId: z.uuid().optional(),
  difficulty: z.coerce.number().int().min(1).max(5).optional(),
  cursor: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export const PyqItem = z
  .object({
    question: Question,
    /** Older years are Pro for free users (§11). Locked items carry no stem/options text. */
    locked: z.boolean(),
  })
  .openapi("PyqItem");

export const PyqPage = z.object({ items: z.array(PyqItem), nextCursor: z.string().nullable() }).openapi("PyqPage");

export const PyqFacets = z
  .object({
    examCode: ExamCode,
    years: z.array(z.object({ year: z.number().int(), count: z.number().int(), locked: z.boolean() })),
    subjects: z.array(z.object({ code: z.string(), name: z.string(), count: z.number().int() })),
  })
  .openapi("PyqFacets");

export const PyqFacetQuery = z.object({ examCode: ExamCode });
