import { describe, expect, it } from "vitest";
import { OFFICIAL_CONFIRM_LINE } from "@heymey/contracts";
import { FakeClock } from "@heymey/testing";
import {
  createExamsModule,
  validateExamChoice,
  type ExamChoice,
  type ExamRecord,
  type ExamsRepository,
} from "../../src/modules/exams/index.js";

const USER = "0199f5a0-0000-7000-8000-00000000aaaa";

function exam(code: string, over: Partial<ExamRecord> = {}): ExamRecord {
  return {
    code,
    name: code.toUpperCase(),
    conductingBody: "TNPSC",
    level: "state",
    minQualification: "sslc",
    fullPrep: false,
    description: "d",
    stages: ["Written exam"],
    patternMode: "omr",
    patternQuestions: 200,
    patternMinutes: 180,
    negativeMarking: false,
    officialUrl: "https://www.tnpsc.gov.in/",
    notificationUrl: null,
    status: "published",
    lastCheckedAt: null,
    ...over,
  };
}

function fakeRepo(exams: ExamRecord[]) {
  const choices = new Map<string, ExamChoice[]>();
  const writes: ExamChoice[][] = [];
  const repo: ExamsRepository = {
    listPublished: async () => exams.filter((e) => e.status === "published"),
    findByCode: async (code) => exams.find((e) => e.code === code) ?? null,
    listPublishedWithRules: async () => [],
    getChoices: async (userId) => choices.get(userId) ?? [],
    replaceChoices: async (userId, c) => {
      writes.push(c);
      choices.set(userId, c);
    },
  };
  return { repo, writes };
}

const clock = new FakeClock("2026-10-20T06:00:00.000Z");

describe("validateExamChoice (invariant 10)", () => {
  it("main + up to 2 others", () => {
    expect(validateExamChoice({ mainExamCode: "a", otherExamCodes: ["b", "c"] })).toEqual([
      { examCode: "a", isMain: true },
      { examCode: "b", isMain: false },
      { examCode: "c", isMain: false },
    ]);
    expect(validateExamChoice({ mainExamCode: "a" })).toEqual([{ examCode: "a", isMain: true }]);
  });

  it.each([
    [{ mainExamCode: "a", otherExamCodes: ["b", "c", "d"] }, "at most 2 other exams"],
    [{ mainExamCode: "a", otherExamCodes: ["a"] }, "main exam repeated"],
    [{ mainExamCode: "a", otherExamCodes: ["b", "b"] }, "duplicate exam"],
  ])("refuses %j", (input, reason) => {
    expect(() => validateExamChoice(input)).toThrowError(expect.objectContaining({ code: "VALIDATION_FAILED", details: expect.objectContaining({ reason }) }));
  });
});

describe("exam catalog", () => {
  const exams = [
    exam("ssc-mts", { name: "SSC MTS" }),
    exam("tnpsc-group-4", { name: "TNPSC Group 4", fullPrep: true }),
    exam("tnpsc-group-2", { name: "TNPSC Group 2", fullPrep: true }),
    exam("draft-exam", { name: "AAA Draft", status: "draft" }),
  ];

  it("lists published exams, launch exams first then by name", async () => {
    const api = createExamsModule({ repository: fakeRepo(exams).repo, clock });
    expect((await api.list()).map((e) => e.code)).toEqual(["tnpsc-group-2", "tnpsc-group-4", "ssc-mts"]);
  });

  it("detail carries the official line and pattern", async () => {
    const api = createExamsModule({ repository: fakeRepo(exams).repo, clock });
    const d = await api.get("tnpsc-group-4");
    expect(d.disclaimer).toBe(OFFICIAL_CONFIRM_LINE);
    expect(d.pattern).toEqual({ mode: "omr", questions: 200, durationMinutes: 180, negativeMarking: false });
    expect(d.lastCheckedAt).toBeNull();
  });

  it("unknown or unpublished exam -> EXAM_NOT_FOUND", async () => {
    const api = createExamsModule({ repository: fakeRepo(exams).repo, clock });
    await expect(api.get("nope")).rejects.toMatchObject({ code: "EXAM_NOT_FOUND" });
    await expect(api.get("draft-exam")).rejects.toMatchObject({ code: "EXAM_NOT_FOUND" });
  });

  it("publishedCodes excludes drafts", async () => {
    const api = createExamsModule({ repository: fakeRepo(exams).repo, clock });
    expect([...(await api.publishedCodes())].sort()).toEqual(["ssc-mts", "tnpsc-group-2", "tnpsc-group-4"]);
  });
});

describe("my exams", () => {
  const exams = [
    exam("tnpsc-group-4", { name: "TNPSC Group 4", fullPrep: true }),
    exam("tnpsc-group-2", { name: "TNPSC Group 2", fullPrep: true }),
    exam("ssc-mts", { name: "SSC MTS" }),
    exam("draft-exam", { status: "draft" }),
  ];

  it("starts empty", async () => {
    const api = createExamsModule({ repository: fakeRepo(exams).repo, clock });
    expect(await api.getMyExams(USER)).toEqual({ main: null, others: [] });
  });

  it("saves main + others and returns summaries", async () => {
    const { repo, writes } = fakeRepo(exams);
    const api = createExamsModule({ repository: repo, clock });
    const res = await api.setMyExams(USER, { mainExamCode: "tnpsc-group-4", otherExamCodes: ["ssc-mts", "tnpsc-group-2"] });
    expect(res.main?.code).toBe("tnpsc-group-4");
    expect(res.others.map((e) => e.code)).toEqual(["ssc-mts", "tnpsc-group-2"]);
    expect(writes).toHaveLength(1);
  });

  it("replaces previous choices", async () => {
    const { repo } = fakeRepo(exams);
    const api = createExamsModule({ repository: repo, clock });
    await api.setMyExams(USER, { mainExamCode: "tnpsc-group-4", otherExamCodes: ["ssc-mts"] });
    const res = await api.setMyExams(USER, { mainExamCode: "tnpsc-group-2" });
    expect(res).toEqual({ main: expect.objectContaining({ code: "tnpsc-group-2" }), others: [] });
  });

  it("unknown or unpublished exam -> EXAM_NOT_FOUND and nothing written", async () => {
    const { repo, writes } = fakeRepo(exams);
    const api = createExamsModule({ repository: repo, clock });
    await expect(api.setMyExams(USER, { mainExamCode: "tnpsc-group-4", otherExamCodes: ["draft-exam"] })).rejects.toMatchObject({
      code: "EXAM_NOT_FOUND",
      details: { codes: ["draft-exam"] },
    });
    await expect(api.setMyExams(USER, { mainExamCode: "nope" })).rejects.toMatchObject({ code: "EXAM_NOT_FOUND" });
    expect(writes).toHaveLength(0);
  });

  it("invalid shape -> VALIDATION_FAILED before any lookup", async () => {
    const { repo, writes } = fakeRepo(exams);
    const api = createExamsModule({ repository: repo, clock });
    await expect(api.setMyExams(USER, { mainExamCode: "tnpsc-group-4", otherExamCodes: ["tnpsc-group-4"] })).rejects.toMatchObject({
      code: "VALIDATION_FAILED",
    });
    expect(writes).toHaveLength(0);
  });

  it("a chosen exam that is later unpublished is left out", async () => {
    const list = [...exams];
    const { repo } = fakeRepo(list);
    const api = createExamsModule({ repository: repo, clock });
    await api.setMyExams(USER, { mainExamCode: "tnpsc-group-4", otherExamCodes: ["ssc-mts"] });
    list[0] = { ...exams[0], status: "archived" } as ExamRecord;
    expect(await api.getMyExams(USER)).toEqual({ main: null, others: [expect.objectContaining({ code: "ssc-mts" })] });
  });
});
