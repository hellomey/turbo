import { z } from "../zod.js";
import { ExamCode } from "./exams.js";

/**
 * `readiness` (blueprint §19.5 Q41-Q50, §11): four evidence bars and a plain label. There is NO single overall
 * percentage anywhere in this contract, by design (§19.5 Q46).
 */

export const ReadinessLabel = z.enum(["not_yet", "building", "close", "mock_ready"]).openapi("ReadinessLabel");

export const ReadinessBar = z
  .object({
    key: z.enum(["coverage", "memory", "exam_performance", "speed"]),
    /** Whole-number percent of THIS bar's own evidence. null when locked or no evidence yet. */
    value: z.number().int().min(0).max(100).nullable(),
    locked: z.boolean(),
    evidence: z.string(),
  })
  .openapi("ReadinessBar");

export const ReadinessMeter = z
  .object({
    examCode: ExamCode,
    label: ReadinessLabel,
    bars: z.array(ReadinessBar),
    coverage: z.object({ litPct: z.number().int(), steadyPct: z.number().int(), goldPct: z.number().int() }),
    readyForFullMocks: z.boolean(),
    suggestion: z.string().nullable(),
    computedAt: z.iso.datetime(),
  })
  .openapi("ReadinessMeter");

export const ReadinessQuery = z.object({ examCode: ExamCode });

export const ReadinessTrendQuery = z.object({
  examCode: ExamCode,
  days: z.coerce.number().int().refine((d) => d === 7 || d === 30 || d === 90, "7, 30 or 90").default(30),
});

export const ReadinessTrend = z
  .object({
    examCode: ExamCode,
    days: z.number().int(),
    points: z.array(
      z.object({
        day: z.iso.date(),
        label: ReadinessLabel,
        coverage: z.number().int().nullable(),
        memory: z.number().int().nullable(),
        examPerformance: z.number().int().nullable(),
        speed: z.number().int().nullable(),
      }),
    ),
  })
  .openapi("ReadinessTrend");

export const SundayReportSummary = z
  .object({
    id: z.uuid(),
    weekStart: z.iso.date(),
    tier: z.enum(["short", "full"]),
    createdAt: z.iso.datetime(),
  })
  .openapi("SundayReportSummary");

export const SundayReportPage = z
  .object({ items: z.array(SundayReportSummary), nextCursor: z.string().nullable() })
  .openapi("SundayReportPage");

/** Study proof for the week (§19.5 Q50, §19.10 Q100). Never promises selection. */
export const SundayReport = SundayReportSummary.extend({
  lampsLit: z.number().int(),
  steadyEarned: z.number().int(),
  goldEarned: z.number().int(),
  relit: z.number().int(),
  dimmedNow: z.number().int(),
  questionsAnswered: z.number().int(),
  accuracyPct: z.number().int().min(0).max(100).nullable(),
  mocksTaken: z.number().int(),
  studyMinutes: z.number().int(),
  lines: z.array(z.string()),
  nextWeek: z.array(z.string()).nullable(),
}).openapi("SundayReport");
