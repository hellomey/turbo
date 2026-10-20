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
