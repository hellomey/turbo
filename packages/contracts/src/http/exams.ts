import { z } from "../zod.js";
import { ProfileAnswers } from "./users.js";
import { Qualification } from "./reference.js";

export const ExamCode = z.string().regex(/^[a-z0-9-]{2,40}$/).openapi("ExamCode");

export const ExamSummary = z
  .object({
    code: ExamCode,
    name: z.string(),
    conductingBody: z.string().openapi({ example: "TNPSC" }),
    level: z.enum(["state", "central"]),
    minQualification: Qualification,
    /** Full preparation content (lessons, PYQs, mocks) exists only for launch exams (§1 decision 16). */
    fullPrep: z.boolean(),
  })
  .openapi("ExamSummary");

export const ExamDetail = ExamSummary.extend({
  description: z.string(),
  stages: z.array(z.string()),
  pattern: z.object({
    mode: z.enum(["omr", "cbt"]),
    questions: z.number().int().nullable(),
    durationMinutes: z.number().int().nullable(),
    negativeMarking: z.boolean(),
  }),
  officialUrl: z.url(),
  notificationUrl: z.url().nullable(),
  lastCheckedAt: z.iso.datetime().nullable(),
  /** Every exam page carries this line (§17.1 step 3). */
  disclaimer: z.string(),
}).openapi("ExamDetail");

export const ExamList = z.object({ items: z.array(ExamSummary) }).openapi("ExamList");

/** Eligibility Checker input (§17.1 steps 1-3, §19.1). Nothing is stored. */
export const EligibilityCheckBody = ProfileAnswers.openapi("EligibilityCheckBody");

export const EligibilityReason = z
  .object({
    code: z.enum([
      "AGE_OK", "AGE_RELAXATION_APPLIED", "AGE_TOO_LOW", "AGE_TOO_HIGH",
      "QUALIFICATION_OK", "QUALIFICATION_TOO_LOW", "DEGREE_SUBJECT_REQUIRED", "PSTM_PREFERENCE",
    ]),
    text: z.string(),
  })
  .openapi("EligibilityReason");

export const ExamEligibility = z
  .object({
    examCode: ExamCode,
    examName: z.string(),
    conductingBody: z.string(),
    eligible: z.boolean(),
    /** 1 = best fit. Ranked by qualification match, launch-exam depth and age headroom. */
    fitRank: z.number().int().positive(),
    reasons: z.array(EligibilityReason),
    ageLimit: z.object({ min: z.number().int(), max: z.number().int().nullable(), asOf: z.iso.date() }),
    officialNotificationUrl: z.url(),
  })
  .openapi("ExamEligibility");

export const EligibilityResult = z
  .object({
    eligibleCount: z.number().int(),
    eligible: z.array(ExamEligibility),
    notEligible: z.array(ExamEligibility),
    disclaimer: z.string(),
  })
  .openapi("EligibilityResult");

export const UserExamsBody = z
  .object({
    mainExamCode: ExamCode,
    /** Optional (added in Phase 2): the attempt cycle per exam code I am preparing for (R2). */
    attemptCycles: z.record(z.string(), z.uuid()).optional(),
    otherExamCodes: z.array(ExamCode).max(2).default([]),
  })
  .openapi("UserExamsBody");

export const UserExams = z
  .object({
    main: ExamSummary.nullable(),
    others: z.array(ExamSummary),
  })
  .openapi("UserExams");

export const OFFICIAL_CONFIRM_LINE = "Always confirm with the official notification.";

// ---------------------------------------------------------------- exam-agnostic catalogue (ADR-0013, D-2026-10-22-01)
// Exam family (TNPSC, UPSC, SSC, Banking, CA, CS) -> exam -> stage -> paper -> section. Patterns and marking are DATA,
// published only after a human check (§26.2 rule 5). Nothing about a real exam is hard-coded.

/** An exact fraction of a mark, e.g. 1/3 or 2/1 (no floats in scoring). */
export const Marks = z
  .object({ numerator: z.number().int().min(0), denominator: z.number().int().positive() })
  .openapi("Marks");

export const PaperType = z
  .enum(["objective", "descriptive"])
  .openapi("PaperType", { description: "`descriptive` papers are listed but cannot be taken in the Exam Hall yet." });

export const MarkingSection = z
  .object({
    code: z.string(),
    name: z.string(),
    order: z.number().int(),
    questionCount: z.number().int().nonnegative(),
    /** Questions the candidate must answer when the paper allows a choice (null = all). */
    attemptLimit: z.number().int().positive().nullable(),
    marksPerCorrect: Marks,
    /** Marks taken off per wrong answer. 0/1 = no negative marking. */
    penaltyPerWrong: Marks,
    /** Sectional time limit, when the paper has one (null = shared paper time). */
    minutes: z.number().int().positive().nullable(),
  })
  .openapi("MarkingSection");

export const MarkingScheme = z
  .object({
    version: z.number().int().positive(),
    durationMinutes: z.number().int().positive(),
    totalQuestions: z.number().int().nonnegative(),
    totalMarks: Marks,
    sections: z.array(MarkingSection),
    /** "SEED - verify" until a human checks it against the official notification. */
    verified: z.boolean(),
    sourceUrl: z.url(),
  })
  .openapi("MarkingScheme");

export const ExamPaper = z
  .object({
    code: z.string(),
    name: z.string(),
    order: z.number().int(),
    type: PaperType,
    mode: z.enum(["omr", "cbt", "written"]),
    language: z.enum(["en", "ta", "hi", "bilingual"]),
    /** Qualifying-only papers do not add to the merit total. */
    qualifyingOnly: z.boolean(),
    scheme: MarkingScheme.nullable(),
  })
  .openapi("ExamPaper");

export const ExamStage = z
  .object({
    code: z.string(),
    name: z.string(),
    order: z.number().int(),
    /** Official date when announced (YYYY-MM-DD). */
    scheduledDate: z.iso.date().nullable(),
    dateStatus: z.enum(["unknown", "tentative", "confirmed"]),
    papers: z.array(ExamPaper),
  })
  .openapi("ExamStage");

/** A specific sitting of an exam with its own dates (R2, blueprint §1a). Plans target the cycle, not "the exam date". */
export const ExamAttemptCycle = z
  .object({
    id: z.uuid(),
    code: z.string().openapi({ example: "2027" }),
    name: z.string(),
    status: z.enum(["announced", "expected", "closed"]),
    stageDates: z.array(z.object({ stageCode: z.string(), date: z.iso.date().nullable(), dateStatus: z.enum(["unknown", "tentative", "confirmed"]) })),
  })
  .openapi("ExamAttemptCycle");

export const ExamStructure = z
  .object({
    examCode: ExamCode,
    family: z.object({ code: z.string(), name: z.string() }).nullable(),
    stages: z.array(ExamStage),
    attemptCycles: z.array(ExamAttemptCycle),
    disclaimer: z.string(),
  })
  .openapi("ExamStructure");

// ---------------------------------------------------------------- Exam Alerts (§19.1 Q7, §17.5, §20.2)

export const ExamAlert = z
  .object({
    id: z.uuid(),
    examCode: ExamCode,
    kind: z.enum(["notification", "date_change", "admit_card", "result", "answer_key", "other"]),
    title: z.string(),
    summary: z.string(),
    officialUrl: z.url(),
    publishedAt: z.iso.datetime(),
    /** Always OFFICIAL_CONFIRM_LINE. */
    confirmLine: z.string(),
  })
  .openapi("ExamAlert");

/** changedetection.io webhook (§20.2). The shared secret travels in the `x-heymey-webhook-secret` header. */
export const SiteChangeWebhookBody = z
  .object({
    watchUuid: z.uuid(),
    watchUrl: z.url(),
    title: z.string().max(300).optional(),
    /** changedetection's change timestamp or snapshot id; (watchUuid, changeId) is accepted once. */
    changeId: z.string().min(1).max(100),
    diffSummary: z.string().max(20_000).optional(),
  })
  .openapi("SiteChangeWebhookBody");

export const SiteChangeAck = z.object({ received: z.boolean() }).openapi("SiteChangeAck");

export const ExamChangeStatus = z.enum(["pending", "approved", "rejected"]).openapi("ExamChangeStatus");

export const ExamChange = z
  .object({
    id: z.uuid(),
    watchUrl: z.url(),
    examCode: ExamCode.nullable(),
    title: z.string().nullable(),
    diffSummary: z.string().nullable(),
    receivedAt: z.iso.datetime(),
    status: ExamChangeStatus,
    reviewedAt: z.iso.datetime().nullable(),
    alertId: z.uuid().nullable(),
  })
  .openapi("ExamChange");

export const ExamChangeQuery = z.object({
  status: ExamChangeStatus.default("pending"),
  cursor: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export const ApproveExamChangeBody = z
  .object({
    examCode: ExamCode,
    kind: ExamAlert.shape.kind,
    title: z.string().trim().min(5).max(120),
    summary: z.string().trim().min(5).max(500),
    officialUrl: z.url(),
    /** Set when the change moves an exam stage date (fires exams.date_changed). */
    newStageDate: z.object({ stageCode: z.string(), date: z.iso.date() }).optional(),
  })
  .openapi("ApproveExamChangeBody");

export const RejectExamChangeBody = z
  .object({ reason: z.string().trim().min(3).max(300) })
  .openapi("RejectExamChangeBody");

export const ExamAlertPage = z
  .object({ items: z.array(ExamAlert), nextCursor: z.string().nullable() })
  .openapi("ExamAlertPage");

export const ExamChangePage = z
  .object({ items: z.array(ExamChange), nextCursor: z.string().nullable() })
  .openapi("ExamChangePage");

/** Header that carries the changedetection.io shared secret (compared in constant time). */
export const SITE_CHANGE_SECRET_HEADER = "x-heymey-webhook-secret";
