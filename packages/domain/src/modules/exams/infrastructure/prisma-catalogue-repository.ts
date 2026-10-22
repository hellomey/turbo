import type { PrismaClient } from "@heymey/db";
import type { CatalogueRepository } from "../application/catalogue.js";
import type { CatalogueCycle, CatalogueExam, CatalogueScheme, DateStatus, PaperForMockDto } from "../domain/structure.js";

const DATE_STATUS = new Set(["unknown", "tentative", "confirmed"]);
const CYCLE_STATUS = new Set(["announced", "expected", "closed"]);

/** Stage dates are typed by humans: malformed entries are dropped, never guessed. */
export function parseStageDates(json: unknown): CatalogueCycle["stageDates"] {
  if (!Array.isArray(json)) return [];
  return json.flatMap((d: unknown) => {
    const r = d as { stageCode?: unknown; date?: unknown; dateStatus?: unknown } | null;
    if (typeof r?.stageCode !== "string") return [];
    const date = typeof r.date === "string" && /^\d{4}-\d{2}-\d{2}$/.test(r.date) ? r.date : null;
    const dateStatus = (typeof r.dateStatus === "string" && DATE_STATUS.has(r.dateStatus) ? r.dateStatus : "unknown") as DateStatus;
    return [{ stageCode: r.stageCode, date, dateStatus }];
  });
}

interface SchemeRow {
  version: number;
  status: string;
  durationMinutes: number;
  totalQuestions: number;
  sourceUrl: string;
  verifiedAt: Date | null;
  sections: {
    code: string;
    name: string;
    order: number;
    questionCount: number;
    attemptLimit: number | null;
    correctMarksNum: number;
    correctMarksDen: number;
    wrongPenaltyNum: number;
    wrongPenaltyDen: number;
    sectionMinutes: number | null;
  }[];
}

function toScheme(s: SchemeRow): CatalogueScheme {
  return {
    version: s.version,
    status: s.status,
    durationMinutes: s.durationMinutes,
    totalQuestions: s.totalQuestions,
    sourceUrl: s.sourceUrl,
    verifiedAt: s.verifiedAt,
    sections: s.sections.map((x) => ({
      code: x.code,
      name: x.name,
      order: x.order,
      questionCount: x.questionCount,
      attemptLimit: x.attemptLimit,
      correctMarksNum: x.correctMarksNum,
      correctMarksDen: x.correctMarksDen,
      wrongPenaltyNum: x.wrongPenaltyNum,
      wrongPenaltyDen: x.wrongPenaltyDen,
      sectionMinutes: x.sectionMinutes,
    })),
  };
}

export class PrismaCatalogueRepository implements CatalogueRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async examStructure(code: string): Promise<CatalogueExam | null> {
    const row = await this.prisma.exam.findUnique({
      where: { code },
      include: {
        family: true,
        examStages: {
          include: {
            papers: {
              where: { status: "published" },
              include: { schemes: { where: { status: "published" }, orderBy: { version: "desc" }, take: 1, include: { sections: true } } },
            },
          },
        },
        attemptCycles: { orderBy: { code: "asc" } },
      },
    });
    if (!row) return null;
    return {
      code: row.code,
      status: row.status,
      family: row.family ? { code: row.family.code, name: row.family.name, rankScope: row.family.rankScope } : null,
      stages: row.examStages.map((st) => ({
        code: st.code,
        name: st.name,
        order: st.order,
        papers: st.papers.map((p) => ({
          id: p.id,
          code: p.code,
          name: p.name,
          order: p.order,
          answerMode: p.answerMode,
          contentLanguage: p.contentLanguage,
          qualifyingOnly: p.qualifyingOnly,
          status: p.status,
          scheme: p.schemes[0] ? toScheme(p.schemes[0]) : null,
        })),
      })),
      cycles: row.attemptCycles.map((c) => ({
        id: c.id,
        code: c.code,
        name: c.name,
        status: (CYCLE_STATUS.has(c.status) ? c.status : "expected") as CatalogueCycle["status"],
        stageDates: parseStageDates(c.stageDates),
      })),
    };
  }

  async paperForMock(paperId: string, schemeVersion: number): Promise<PaperForMockDto | null> {
    const p = await this.prisma.paper.findUnique({
      where: { id: paperId },
      include: {
        stage: { include: { exam: { include: { family: true } } } },
        schemes: { where: { version: schemeVersion }, include: { sections: true } },
      },
    });
    const scheme = p?.schemes[0];
    if (!p || !scheme) return null;
    return {
      examCode: p.stage.exam.code,
      paperCode: p.code,
      answerMode: p.answerMode,
      qualifyingOnly: p.qualifyingOnly,
      rankScope: p.stage.exam.family?.rankScope ?? "statewide",
      scheme: toScheme(scheme),
    };
  }
}
