// Integration: exams repository + use cases against REAL PostgreSQL (Testcontainers, blueprint §44).
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { FakeClock, startPostgres, type StartedDb } from "@heymey/testing";
import { createExamsModule } from "../../src/modules/exams/index.js";
import { seeder } from "../../../db/prisma/seed/catalog.js";

let db: StartedDb;
let prisma: PrismaClient;
const clock = new FakeClock("2026-10-20T06:00:00.000Z");
const USER = "0199f5a0-0000-7000-8000-00000000beef";

beforeAll(async () => {
  db = await startPostgres();
  prisma = createPrismaClient(db.url);
  await seeder.run(prisma);
  // An unpublished exam and an unpublished newer rule must never be used.
  await prisma.exam.create({
    data: {
      code: "draft-exam", name: "AAA Draft", conductingBody: "TNPSC", level: "state", minQualification: "sslc",
      description: "draft", stages: [], patternMode: "omr", officialUrl: "https://www.tnpsc.gov.in/", sourceUrl: "https://www.tnpsc.gov.in/",
      status: "draft",
    },
  });
  const g4 = await prisma.exam.findUniqueOrThrow({ where: { code: "tnpsc-group-4" } });
  await prisma.eligibilityRule.create({
    data: {
      examId: g4.id, version: 2, ageAsOf: new Date("2026-07-01"), minAge: 99, maxAgeByCommunity: { OC: 100 }, relaxationYears: {},
      qualifications: ["sslc"], degreeSubjects: [], status: "draft", sourceUrl: "https://www.tnpsc.gov.in/",
    },
  });
});

afterAll(async () => {
  await prisma?.$disconnect();
  await db?.stop();
});

const api = () => createExamsModule({ prisma, clock });

describe("exams (integration)", () => {
  it("lists published exams only, launch exams first", async () => {
    expect((await api().list()).map((e) => e.code)).toEqual(["tnpsc-group-2", "tnpsc-group-2a", "tnpsc-group-4", "ssc-chsl", "ssc-mts"]);
  });

  it("detail and EXAM_NOT_FOUND for drafts", async () => {
    expect(await api().get("tnpsc-group-4")).toMatchObject({
      fullPrep: true,
      minQualification: "sslc",
      pattern: { mode: "omr", questions: 200, durationMinutes: 180, negativeMarking: false },
    });
    await expect(api().get("draft-exam")).rejects.toMatchObject({ code: "EXAM_NOT_FOUND" });
  });

  it("eligibility uses the latest PUBLISHED rule (draft v2 with minAge 99 ignored)", async () => {
    const res = await api().checkEligibility({
      dateOfBirth: "2000-01-15", qualification: "sslc", community: "BC", pstm: true, specialCategories: [],
    });
    const g4 = res.eligible.find((e) => e.examCode === "tnpsc-group-4");
    expect(g4?.ageLimit).toEqual({ min: 18, max: 42, asOf: "2026-07-01" });
    expect(g4?.reasons.map((r) => r.code)).toContain("PSTM_PREFERENCE");
    expect(res.notEligible.map((e) => e.examCode).sort()).toEqual(["ssc-chsl", "tnpsc-group-2", "tnpsc-group-2a"]);
  });

  it("my exams: replaced atomically", async () => {
    await api().setMyExams(USER, { mainExamCode: "tnpsc-group-4", otherExamCodes: ["tnpsc-group-2", "ssc-mts"] });
    const res = await api().setMyExams(USER, { mainExamCode: "tnpsc-group-2a", otherExamCodes: ["tnpsc-group-4"] });
    expect(res.main?.code).toBe("tnpsc-group-2a");
    expect(res.others.map((e) => e.code)).toEqual(["tnpsc-group-4"]);
    expect(await prisma.userExamChoice.count({ where: { userId: USER } })).toBe(2);
    await expect(api().setMyExams(USER, { mainExamCode: "draft-exam" })).rejects.toMatchObject({ code: "EXAM_NOT_FOUND" });
    expect(await prisma.userExamChoice.count({ where: { userId: USER } })).toBe(2);
  });
});
