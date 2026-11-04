// exams catalogue (BOLT-0011, ADR-0013): structure view, exact marks, current cycle. U-exams Phase 2 invariants 1-2.
import { describe, expect, it } from "vitest";
import { createExamCatalogueModule, currentCycle, marks, totalMarks, type CatalogueExam, type CatalogueSection } from "../../src/modules/exams/index.js";
import { parseStageDates } from "../../src/modules/exams/infrastructure/prisma-catalogue-repository.js";

const sec = (over: Partial<CatalogueSection> = {}): CatalogueSection => ({
  code: "S", name: "S", order: 1, questionCount: 100, attemptLimit: null,
  correctMarksNum: 3, correctMarksDen: 2, wrongPenaltyNum: 1, wrongPenaltyDen: 2, sectionMinutes: null, ...over,
});

const exam = (over: Partial<CatalogueExam> = {}): CatalogueExam => ({
  code: "test-exam",
  status: "published",
  family: { code: "test-family", name: "TEST-FAMILY", rankScope: "test scope" },
  stages: [
    {
      code: "mains", name: "Mains", order: 2,
      papers: [{ id: "p2", code: "essay", name: "Essay", order: 1, answerMode: "descriptive", contentLanguage: "xx", qualifyingOnly: false, status: "published", scheme: null }],
    },
    {
      code: "prelims", name: "Prelims", order: 1,
      papers: [
        { id: "p1b", code: "csat", name: "CSAT", order: 2, answerMode: "objective_cbt", contentLanguage: "bilingual", qualifyingOnly: true, status: "published",
          scheme: { version: 1, status: "published", durationMinutes: 120, totalQuestions: 80, sourceUrl: "https://x.test/", verifiedAt: new Date(), sections: [sec({ questionCount: 80 })] } },
        { id: "p1a", code: "gs", name: "GS", order: 1, answerMode: "objective_omr", contentLanguage: "en", qualifyingOnly: false, status: "published",
          scheme: { version: 3, status: "published", durationMinutes: 180, totalQuestions: 100, sourceUrl: "https://x.test/", verifiedAt: null,
            sections: [sec({ order: 2, code: "B", attemptLimit: 50, correctMarksNum: 1, correctMarksDen: 3 }), sec({ code: "A" })] } },
      ],
    },
  ],
  cycles: [
    { id: "c0", code: "2025", name: "2025", status: "closed", stageDates: [{ stageCode: "prelims", date: "2025-06-01", dateStatus: "confirmed" }] },
    { id: "c1", code: "2027", name: "2027", status: "expected", stageDates: [{ stageCode: "prelims", date: "2027-05-30", dateStatus: "tentative" }] },
  ],
  ...over,
});

describe("exam structure (ADR-0013)", () => {
  it("orders stages/papers, maps modes, exact marks, verified flag, cycle dates", async () => {
    const api = createExamCatalogueModule({ repository: { examStructure: async () => exam(), paperForMock: async () => null } });
    const s = await api.structure("test-exam");
    expect(s.family).toEqual({ code: "test-family", name: "TEST-FAMILY" });
    expect(s.stages.map((x) => x.code)).toEqual(["prelims", "mains"]);
    const [gs, csat] = s.stages[0]?.papers ?? [];
    expect(gs).toMatchObject({ code: "gs", type: "objective", mode: "omr", language: "en" });
    expect(gs?.scheme?.sections.map((x) => x.code)).toEqual(["A", "B"]);
    expect(gs?.scheme?.sections[0]?.marksPerCorrect).toEqual({ numerator: 3, denominator: 2 });
    expect(gs?.scheme?.totalMarks).toEqual({ numerator: 500, denominator: 3 }); // 100 x 3/2 + 50 x 1/3
    expect(gs?.scheme?.verified).toBe(false);
    expect(csat).toMatchObject({ mode: "cbt", language: "bilingual", qualifyingOnly: true, scheme: { verified: true } });
    expect(s.stages[1]?.papers[0]).toMatchObject({ type: "descriptive", mode: "written", language: "en", scheme: null });
    expect(s.stages[0]).toMatchObject({ scheduledDate: "2027-05-30", dateStatus: "tentative" });
    expect(s.stages[1]).toMatchObject({ scheduledDate: null, dateStatus: "unknown" });
    expect(s.disclaimer).toBe("Always confirm with the official notification.");
    expect(await api.paperForMock("x", 1)).toBeNull();
  });

  it("unknown or unpublished exam -> EXAM_NOT_FOUND; no family", async () => {
    const draft = createExamCatalogueModule({ repository: { examStructure: async () => exam({ status: "draft" }), paperForMock: async () => null } });
    await expect(draft.structure("test-exam")).rejects.toMatchObject({ code: "EXAM_NOT_FOUND" });
    const none = createExamCatalogueModule({ repository: { examStructure: async () => null, paperForMock: async () => null } });
    await expect(none.structure("x")).rejects.toMatchObject({ code: "EXAM_NOT_FOUND" });
    const noFamily = createExamCatalogueModule({ repository: { examStructure: async () => exam({ family: null, cycles: [] }), paperForMock: async () => null } });
    expect((await noFamily.structure("test-exam")).family).toBeNull();
  });

  it("marks reject bad data; current cycle prefers announced", () => {
    expect(() => marks(1, 0)).toThrow(RangeError);
    expect(() => marks(-1, 1)).toThrow(RangeError);
    expect(marks(0, 5)).toEqual({ numerator: 0, denominator: 1 });
    expect(totalMarks([])).toEqual({ numerator: 0, denominator: 1 });
    const cycles = exam().cycles;
    expect(currentCycle(cycles)?.id).toBe("c1");
    expect(currentCycle([...cycles, { id: "c2", code: "x", name: "x", status: "announced", stageDates: [] }])?.id).toBe("c2");
    expect(currentCycle([])).toBeNull();
  });

  it("stage dates typed by humans: malformed entries dropped", () => {
    expect(parseStageDates([{ stageCode: "a", date: "2027-1-1", dateStatus: "nope" }, { date: "x" }, null, { stageCode: "b", date: "2027-01-02", dateStatus: "confirmed" }])).toEqual([
      { stageCode: "a", date: null, dateStatus: "unknown" },
      { stageCode: "b", date: "2027-01-02", dateStatus: "confirmed" },
    ]);
    expect(parseStageDates({})).toEqual([]);
  });
});
