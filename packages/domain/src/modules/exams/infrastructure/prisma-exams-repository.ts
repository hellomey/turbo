import { COMMUNITIES, QUALIFICATIONS, SPECIAL_CATEGORIES, z } from "@heymey/contracts";
import type { Exam, EligibilityRule, PrismaClient } from "@heymey/db";
import type { ExamsRepository } from "../application/ports.js";
import type { ExamRecord } from "../domain/exam.js";
import type { EligibilityRuleRecord, ExamWithRule } from "../domain/eligibility.js";
import type { ExamChoice } from "../domain/my-exams.js";
import type { CycleRecord } from "../domain/cycle.js";

const Qualification = z.enum(QUALIFICATIONS);
const MaxAgeByCommunity = z.partialRecord(z.enum(COMMUNITIES), z.number().int().nonnegative().nullable());
const RelaxationYears = z.partialRecord(z.enum(SPECIAL_CATEGORIES), z.number().int().nonnegative());

function toExamRecord(row: Exam): ExamRecord {
  return {
    code: row.code,
    name: row.name,
    conductingBody: row.conductingBody,
    level: row.level === "central" ? "central" : "state",
    minQualification: Qualification.parse(row.minQualification),
    fullPrep: row.fullPrep,
    description: row.description,
    stages: row.stages,
    patternMode: row.patternMode === "cbt" ? "cbt" : "omr",
    patternQuestions: row.patternQuestions,
    patternMinutes: row.patternMinutes,
    negativeMarking: row.negativeMarking,
    officialUrl: row.officialUrl,
    notificationUrl: row.notificationUrl,
    status: row.status,
    lastCheckedAt: row.lastCheckedAt,
  };
}

/**
 * Rules are data typed by humans. A rule whose JSON does not match the expected shape is NOT used
 * (returns null), so a typo can never make someone wrongly "eligible".
 */
function toRuleRecord(row: EligibilityRule): EligibilityRuleRecord | null {
  const maxAge = MaxAgeByCommunity.safeParse(row.maxAgeByCommunity);
  const relax = RelaxationYears.safeParse(row.relaxationYears);
  const quals = z.array(Qualification).safeParse(row.qualifications);
  if (!maxAge.success || !relax.success || !quals.success) return null;
  return {
    version: row.version,
    status: row.status,
    ageAsOf: row.ageAsOf.toISOString().slice(0, 10),
    minAge: row.minAge,
    maxAgeByCommunity: maxAge.data,
    relaxationYears: relax.data,
    qualifications: quals.data,
    degreeSubjects: row.degreeSubjects,
    pstmNote: row.pstmNote,
  };
}

export class PrismaExamsRepository implements ExamsRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async listPublished(): Promise<ExamRecord[]> {
    const rows = await this.prisma.exam.findMany({ where: { status: "published" }, orderBy: { name: "asc" } });
    return rows.map(toExamRecord);
  }

  async findByCode(code: string): Promise<ExamRecord | null> {
    const row = await this.prisma.exam.findUnique({ where: { code } });
    return row ? toExamRecord(row) : null;
  }

  async listPublishedWithRules(): Promise<ExamWithRule[]> {
    const rows = await this.prisma.exam.findMany({
      where: { status: "published" },
      include: { rules: { where: { status: "published" }, orderBy: { version: "desc" }, take: 1 } },
    });
    return rows.map((row) => {
      const rule = row.rules[0];
      return { exam: toExamRecord(row), rule: rule ? toRuleRecord(rule) : null };
    });
  }

  async getChoices(userId: string): Promise<ExamChoice[]> {
    const rows = await this.prisma.userExamChoice.findMany({ where: { userId }, orderBy: { createdAt: "asc" } });
    return rows.map((r) => (r.attemptCycleId ? { examCode: r.examCode, isMain: r.isMain, attemptCycleId: r.attemptCycleId } : { examCode: r.examCode, isMain: r.isMain }));
  }

  async replaceChoices(userId: string, choices: ExamChoice[]): Promise<void> {
    await this.prisma.$transaction([
      this.prisma.userExamChoice.deleteMany({ where: { userId } }),
      this.prisma.userExamChoice.createMany({ data: choices.map((c) => ({ userId, examCode: c.examCode, isMain: c.isMain, attemptCycleId: c.attemptCycleId ?? null })) }),
    ]);
  }

  /** BOLT-0012: cycles of these exams (any status; the caller picks). stageDates is DATA: [{ stageCode, date }]. */
  async cyclesForExams(examCodes: string[]): Promise<CycleRecord[]> {
    if (!examCodes.length) return [];
    const rows = await this.prisma.examAttemptCycle.findMany({
      where: { exam: { code: { in: examCodes } } },
      include: { exam: { select: { code: true } } },
      orderBy: { code: "asc" },
    });
    return rows.map((r) => ({
      id: r.id,
      examCode: r.exam.code,
      status: r.status,
      stageDates: Array.isArray(r.stageDates)
        ? (r.stageDates as { stageCode?: unknown; date?: unknown }[]).map((d) => ({
            stageCode: String(d.stageCode ?? ""),
            date: typeof d.date === "string" ? d.date : null,
          }))
        : [],
    }));
  }
}
