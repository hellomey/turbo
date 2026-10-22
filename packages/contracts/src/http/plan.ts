import { z } from "../zod.js";
import { ExamCode } from "./exams.js";
import { Rank } from "./mastery.js";

/** `plan` (blueprint §17.1 step 9, §17.3, §19.2 Q11-Q20, §19.10 Q93-Q97, §10.6 Today). */

export const PlanItemKind = z
  .enum(["lesson", "lit_check", "relight", "practice", "pyq", "gold", "mock", "mistake_review", "checklist"])
  .openapi("PlanItemKind");

export const PlanItemStatus = z.enum(["pending", "done", "skipped", "moved"]).openapi("PlanItemStatus");

export const PlanItem = z
  .object({
    id: z.uuid(),
    day: z.iso.date(),
    kind: PlanItemKind,
    examCode: ExamCode.nullable(),
    topicId: z.uuid().nullable(),
    title: z.string(),
    minutes: z.number().int().positive(),
    order: z.number().int(),
    status: PlanItemStatus,
  })
  .openapi("PlanItem");

export const StretchPhase = z
  .enum(["normal", "d90", "d60", "d30", "d7"])
  .openapi("StretchPhase", { description: "Final Stretch phase from days left to the nearest exam (§17.3)." });

export const PlanExam = z
  .object({
    examCode: ExamCode,
    /** Plans hang off the attempt cycle (R2). null = no cycle chosen yet. */
    attemptCycleId: z.uuid().nullable(),
    /** Next stage date of that cycle. */
    examDate: z.iso.date().nullable(),
    priority: z.number().int().min(1).max(3),
    daysLeft: z.number().int().nullable(),
  })
  .openapi("PlanExam");

export const Plan = z
  .object({
    id: z.uuid(),
    weekdayMinutes: z.number().int(),
    weekendMinutes: z.number().int(),
    pocketMinutes: z.number().int().min(5).max(15).multipleOf(5),
    /** -2 (more revision) .. +2 (more new topics) (§19.2 Q20). */
    balance: z.number().int().min(-2).max(2),
    exams: z.array(PlanExam),
    stretch: StretchPhase,
    starterPathUntil: z.iso.date().nullable(),
    lastRebalancedAt: z.iso.datetime().nullable(),
    configVersion: z.string(),
  })
  .openapi("Plan");

export const PutPlanBody = z
  .object({
    weekdayMinutes: z.number().int().min(15).max(720),
    weekendMinutes: z.number().int().min(15).max(720),
    pocketMinutes: z.number().int().min(5).max(15).multipleOf(5).default(10),
    balance: z.number().int().min(-2).max(2).default(0),
  })
  .openapi("PutPlanBody");

export const PlanDaysQuery = z.object({ from: z.iso.date(), to: z.iso.date() });

export const PlanDays = z
  .object({ days: z.array(z.object({ day: z.iso.date(), minutes: z.number().int(), items: z.array(PlanItem) })) })
  .openapi("PlanDays");

export const UpdatePlanItemBody = z
  .object({ status: z.enum(["done", "skipped"]) })
  .openapi("UpdatePlanItemBody");

/** The Today screen (§10.6 Today, §10.7 Calm Mode). One clear "do this now" card (§19.2 Q16). */
export const TodayScreen = z
  .object({
    day: z.iso.date(),
    rank: Rank,
    todayCard: PlanItem.nullable(),
    relight: z.object({ count: z.number().int().nonnegative(), minutes: z.number().int().nonnegative() }),
    pocketSessions: z.array(z.number().int().min(5).max(15).multipleOf(5)),
    stretch: StretchPhase,
    /** Kind words after missed days (never "streak lost", §7). */
    welcomeBack: z.string().nullable(),
    hasPlan: z.boolean(),
    serverNow: z.iso.datetime(),
  })
  .openapi("TodayScreen");
