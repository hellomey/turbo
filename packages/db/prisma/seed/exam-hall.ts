// Exam structure catalogue + Exam Hall seed (BOLT-0011, ADR-0013). LOCAL / STAGING ONLY.
// EVERY pattern here is a PLACEHOLDER derived from the Phase 1 seed rows (themselves "SEED DATA - verify"): one stage,
// one paper, one section per exam. Nothing is a verified exam fact: verifiedBy/verifiedAt stay null (API: verified=false),
// and Ops must replace them from the official notification before production (§26.2 rule 5).
// Idempotent: upserts on unique keys; question ids are derived deterministically from a seed label.
import { createHash } from "node:crypto";
import type { PrismaClient } from "@heymey/db";
import { SEED_EXAMS } from "./catalog.js";

const VERIFY = "SEED - verify against the official notification";
const PLACEHOLDER_QUESTIONS = 10;

/** Stable UUID (v5 layout) from a label, so re-running the seed never duplicates rows. */
export function seedUuid(label: string): string {
  const h = createHash("sha1").update(`heymey-seed:${label}`).digest("hex");
  return `${h.slice(0, 8)}-${h.slice(8, 12)}-5${h.slice(13, 16)}-${((parseInt(h.slice(16, 18), 16) & 0x3f) | 0x80).toString(16)}${h.slice(18, 20)}-${h.slice(20, 32)}`;
}

const FAMILIES = [
  { code: "tnpsc", name: "TNPSC", body: "TNPSC", rankScope: "statewide", url: "https://www.tnpsc.gov.in/" },
  { code: "ssc", name: "SSC", body: "SSC", rankScope: "all-India", url: "https://ssc.gov.in/" },
];

/** Placeholder Career Ladder titles (R6): generic, not real ranks. */
const LADDER = Array.from({ length: 11 }, (_, i) => `Level ${i + 1}`);

export const seeder = {
  name: "exam-hall",
  async run(prisma: PrismaClient): Promise<string> {
    const families = new Map<string, string>();
    for (const f of FAMILIES) {
      const row = await prisma.examFamily.upsert({
        where: { code: f.code },
        update: {},
        create: { code: f.code, name: f.name, rankScope: f.rankScope, rankTitles: LADDER, status: "published", sourceUrl: f.url },
      });
      families.set(f.body, row.id);
    }

    let mocks = 0;
    for (const e of SEED_EXAMS) {
      const exam = await prisma.exam.findUnique({ where: { code: e.code } });
      if (!exam) continue;
      const familyId = families.get(e.conductingBody) ?? null;
      if (familyId && !exam.familyId) await prisma.exam.update({ where: { id: exam.id }, data: { familyId } });

      const stage = await prisma.examStage.upsert({
        where: { examId_code: { examId: exam.id, code: "written" } },
        update: {},
        create: { examId: exam.id, code: "written", name: `Written exam (${VERIFY})`, order: 1 },
      });
      const paper = await prisma.paper.upsert({
        where: { stageId_code: { stageId: stage.id, code: "paper-1" } },
        update: {},
        create: {
          stageId: stage.id,
          code: "paper-1",
          name: `Paper 1 (${VERIFY})`,
          order: 1,
          answerMode: e.patternMode === "cbt" ? "objective_cbt" : "objective_omr",
          status: "published",
          sourceUrl: e.officialUrl,
        },
      });
      const questions = e.patternQuestions ?? 100;
      const scheme = await prisma.markingScheme.upsert({
        where: { paperId_version: { paperId: paper.id, version: 1 } },
        update: {},
        create: {
          paperId: paper.id,
          version: 1,
          durationMinutes: e.patternMinutes ?? 60,
          totalQuestions: questions,
          status: "published",
          sourceUrl: e.officialUrl,
        },
      });
      await prisma.paperSection.upsert({
        where: { schemeId_code: { schemeId: scheme.id, code: "general" } },
        update: {},
        create: {
          schemeId: scheme.id,
          code: "general",
          name: `All questions (${VERIFY})`,
          order: 1,
          questionCount: questions,
          correctMarksNum: 1,
          // Placeholder penalty only where the Phase 1 seed row says "negative marking"; the real value must be verified.
          wrongPenaltyNum: e.negativeMarking ? 1 : 0,
          wrongPenaltyDen: e.negativeMarking ? 4 : 1,
        },
      });
      await prisma.examAttemptCycle.upsert({
        where: { examId_code: { examId: exam.id, code: "next" } },
        update: {},
        create: {
          examId: exam.id,
          code: "next",
          name: `Next sitting (${VERIFY})`,
          status: "expected",
          stageDates: [{ stageCode: "written", date: null, dateStatus: "unknown" }],
          sourceUrl: e.officialUrl,
        },
      });

      // One placeholder practice mock per launch exam, if the syllabus seed gave the exam a topic.
      if (!e.fullPrep) continue;
      const tag = await prisma.topicExamTag.findFirst({ where: { examCode: e.code }, orderBy: { topicId: "asc" } });
      if (!tag) continue;
      const ids: string[] = [];
      for (let n = 1; n <= PLACEHOLDER_QUESTIONS; n += 1) {
        const id = seedUuid(`${e.code}:mock-q${n}`);
        ids.push(id);
        await prisma.question.upsert({
          where: { id },
          update: {},
          create: {
            id,
            topicId: tag.topicId,
            status: "published",
            versions: {
              create: {
                version: 1,
                stem: `Placeholder question ${n} for local testing (SEED - not real content). Pick option A.`,
                options: [
                  { id: "A", text: "Option A" },
                  { id: "B", text: "Option B" },
                  { id: "C", text: "Option C" },
                  { id: "D", text: "Option D" },
                ],
                correctOptionIds: ["A"],
                explanationMarkdown: "Placeholder explanation (SEED).",
                status: "published",
              },
            },
          },
        });
      }
      await prisma.mock.upsert({
        where: { code: `seed-${e.code}-full-1` },
        update: {},
        create: {
          code: `seed-${e.code}-full-1`,
          examCode: e.code,
          paperId: paper.id,
          schemeVersion: 1,
          title: "Practice mock 1 (SEED placeholder)",
          kind: "full",
          sections: [{ sectionCode: "general", questionIds: ids }],
          status: "published",
        },
      });
      mocks += 1;
    }
    return `${FAMILIES.length} families, ${SEED_EXAMS.length} exam structures (${VERIFY}), ${mocks} placeholder mocks`;
  },
};
