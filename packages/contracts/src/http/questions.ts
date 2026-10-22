import { z } from "../zod.js";
import { ExamCode } from "./exams.js";

/**
 * Questions as the app sees them (blueprint §19.4 Q31-Q38, §22). Owned by `content`.
 * Exam-agnostic (D-2026-10-22-01): a question belongs to a topic (lamp); PYQ facts (exam, paper, year, number) are data.
 * The correct answer is NEVER sent with a question that is being answered online: it comes back in the answer result.
 */
export const QuestionKind = z
  .enum(["single_choice", "multi_choice", "numeric", "descriptive"])
  .openapi("QuestionKind", { description: "`descriptive` is a future type: stored and listed, not yet answerable (ADR-0013)." });

/** Per-paper content language (D-2026-10-22-01). Interface text is always English. */
export const ContentLanguage = z.enum(["en", "ta", "hi"]).openapi("ContentLanguage");

export const QuestionOption = z.object({ id: z.string().min(1).max(8), text: z.string() }).openapi("QuestionOption");

export const QuestionSource = z
  .object({
    citation: z.string(),
    url: z.url().nullable(),
    /** Set for previous-year questions: "TNPSC Group 4 2024, Q 57". */
    pyq: z
      .object({ examCode: ExamCode, paperCode: z.string().nullable(), year: z.number().int(), questionNumber: z.number().int().nullable() })
      .nullable(),
  })
  .openapi("QuestionSource");

export const Question = z
  .object({
    id: z.uuid(),
    version: z.number().int().positive(),
    topicId: z.uuid(),
    kind: QuestionKind,
    language: ContentLanguage,
    stem: z.string(),
    options: z.array(QuestionOption),
    difficulty: z.number().int().min(1).max(5),
    source: QuestionSource,
    /** Shown when a later change (new rule, amended act) affects this question (§19.4 Q33). */
    affectedNote: z.string().nullable(),
  })
  .openapi("Question");

/** What the server says after grading one answer (§19.4 Q32, Q38). */
export const GradedAnswer = z
  .object({
    questionId: z.uuid(),
    correct: z.boolean(),
    correctOptionIds: z.array(z.string()),
    chosenOptionIds: z.array(z.string()),
    explanationMarkdown: z.string(),
    /** "Why yours was wrong" when the content has it for the chosen option. */
    whyChosenIsWrong: z.string().nullable(),
    source: QuestionSource,
    /** The lamp to relight after a wrong answer. */
    topicId: z.uuid(),
  })
  .openapi("GradedAnswer");

export const AnswerInput = z
  .object({
    questionId: z.uuid(),
    /** Empty = skipped. */
    chosenOptionIds: z.array(z.string().min(1).max(8)).max(8),
  })
  .openapi("AnswerInput");

export const QuestionReportBody = z
  .object({
    questionVersion: z.number().int().positive(),
    reason: z.enum(["wrong_answer", "unclear", "outdated", "typo", "other"]),
    note: z.string().trim().max(500).optional(),
  })
  .openapi("QuestionReportBody");

export const QuestionReportAck = z
  .object({ reportId: z.uuid(), status: z.enum(["received"]) })
  .openapi("QuestionReportAck");

/** Offline content packs (§39): versioned zips on cdn.heymey.app, SHA-256 checked, Wi-Fi only by default. */
export const ContentPack = z
  .object({
    id: z.uuid(),
    code: z.string().openapi({ example: "tnpsc-group-4.polity" }),
    examCode: ExamCode,
    subjectCode: z.string().nullable(),
    version: z.number().int().positive(),
    url: z.url(),
    sha256: z.string().regex(/^[a-f0-9]{64}$/),
    sizeBytes: z.number().int().positive(),
    /** Free users may download only `free` packs (§11 "Offline downloads: Free content"). */
    tier: z.enum(["free", "pro"]),
    locked: z.boolean(),
    publishedAt: z.iso.datetime(),
  })
  .openapi("ContentPack");

export const ContentPackList = z.object({ items: z.array(ContentPack) }).openapi("ContentPackList");
export const ContentPackQuery = z.object({ examCode: ExamCode });
