import type { LampRing, StudyMap, z } from "@heymey/contracts";

export type StudyMapDto = z.infer<typeof StudyMap>;
export type LampRingDto = z.infer<typeof LampRing>;

/** One topic (lamp) as stored, with its subject and every exam tag. */
export interface TopicRow {
  id: string;
  code: string;
  name: string;
  order: number;
  subject: { code: string; name: string; order: number };
  examCodes: string[];
}

/** Phase 1: every lamp is unlit. Per-user rings arrive with `mastery` in Phase 2 (D-2026-10-20-14). */
export const UNLIT_RING: LampRingDto = Object.freeze({ lit: false, steadyLevel: 0, gold: false, dim: "bright" }) as LampRingDto;

const byOrder = (a: { order: number; code: string }, b: { order: number; code: string }) =>
  a.order - b.order || a.code.localeCompare(b.code);

/**
 * Group an exam's topics into subjects (islands) and lamps (§5.1). Pure.
 *  - only topics tagged with `examCode` are kept,
 *  - `examCodes` = published exams sharing the lamp (one lamp, many exam colours), sorted,
 *  - `hasLesson` from the content module's answer.
 */
export function buildStudyMap(
  examCode: string,
  topics: readonly TopicRow[],
  publishedExamCodes: ReadonlySet<string>,
  topicsWithLesson: ReadonlySet<string>,
): StudyMapDto {
  const subjects = new Map<string, StudyMapDto["subjects"][number]>();
  const mine = topics.filter((t) => t.examCodes.includes(examCode)).sort(byOrder);
  for (const t of mine) {
    let subject = subjects.get(t.subject.code);
    if (!subject) {
      subject = { code: t.subject.code, name: t.subject.name, order: t.subject.order, topics: [] };
      subjects.set(t.subject.code, subject);
    }
    subject.topics.push({
      id: t.id,
      code: t.code,
      name: t.name,
      order: t.order,
      examCodes: [...new Set(t.examCodes)].filter((c) => publishedExamCodes.has(c)).sort(),
      hasLesson: topicsWithLesson.has(t.id),
      ring: { ...UNLIT_RING },
    });
  }
  return { examCode, subjects: [...subjects.values()].sort(byOrder), totalTopics: mine.length };
}
