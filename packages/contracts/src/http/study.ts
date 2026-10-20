import { z } from "../zod.js";
import { ExamCode } from "./exams.js";

/** A lamp's three rings (§5.1). Phase 1 serves the map; per-user ring state arrives with `mastery` (Phase 2). */
export const LampRing = z
  .object({
    lit: z.boolean(),
    steadyLevel: z.number().int().min(0).max(4),
    gold: z.boolean(),
    dim: z.enum(["bright", "dimming", "dim"]),
  })
  .openapi("LampRing");

export const StudyMapTopic = z
  .object({
    id: z.uuid(),
    code: z.string(),
    name: z.string(),
    order: z.number().int(),
    /** Other exams that share this lamp (one lamp, many exam colours). */
    examCodes: z.array(ExamCode),
    hasLesson: z.boolean(),
    ring: LampRing,
  })
  .openapi("StudyMapTopic");

export const StudyMap = z
  .object({
    examCode: ExamCode,
    subjects: z.array(
      z.object({
        code: z.string(),
        name: z.string(),
        order: z.number().int(),
        topics: z.array(StudyMapTopic),
      }),
    ),
    totalTopics: z.number().int(),
  })
  .openapi("StudyMap");

export const TextbookRef = z
  .object({
    book: z.string(),
    classLevel: z.number().int().nullable(),
    chapter: z.string().nullable(),
    pages: z.string().nullable(),
    url: z.url().nullable(),
  })
  .openapi("TextbookRef");

export const Lesson = z
  .object({
    id: z.uuid(),
    topicId: z.uuid(),
    title: z.string(),
    bodyMarkdown: z.string(),
    readingMinutes: z.number().int().positive(),
    textbookRefs: z.array(TextbookRef),
    source: z.object({ citation: z.string(), url: z.url().nullable() }),
    version: z.number().int().positive(),
    updatedAt: z.iso.datetime(),
  })
  .openapi("Lesson");

export const GlossaryQuery = z.object({ q: z.string().trim().min(1).max(60).optional() });

export const GlossaryList = z
  .object({ items: z.array(z.object({ term: z.string(), meaning: z.string() })) })
  .openapi("GlossaryList");
