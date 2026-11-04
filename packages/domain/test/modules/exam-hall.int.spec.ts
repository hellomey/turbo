// Integration: exam-hall + exams catalogue + content question reader on REAL PostgreSQL (Testcontainers, §44). BOLT-0011.
// Covers: SEED catalogue, TEST-FAMILY end to end (data, not code), allowance race, resume race, late saves, expire job,
// rank job once with ties, descriptive refusal, structure route data.
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { FakeClock, startPostgres, type StartedDb } from "@heymey/testing";
import { createExamHallModule, type ExamHallApi } from "../../src/modules/exam-hall/index.js";
import { createExamCatalogueModule } from "../../src/modules/exams/index.js";
import { createQuestionReader } from "../../src/modules/content/index.js";
import { seeder as catalog } from "../../../db/prisma/seed/catalog.js";
import { seeder as examHallSeed, seedUuid } from "../../../db/prisma/seed/exam-hall.js";

let db: StartedDb;
let prisma: PrismaClient;
let hall: ExamHallApi;
const clock = new FakeClock("2026-10-22T06:00:00.000Z");
const user = (n: number) => `0199f5a0-0000-7000-8000-${String(n).padStart(12, "0")}`;
let topicId: string;
let testMockId: string;
let stateMockId: string;
let descMockId: string;
const Q = Array.from({ length: 4 }, (_, i) => seedUuid(`int-test:q${i}`));

beforeAll(async () => {
  db = await startPostgres();
  prisma = createPrismaClient(db.url);
  await catalog.run(prisma);
  await examHallSeed.run(prisma);
  await examHallSeed.run(prisma); // idempotent
  hall = createExamHallModule({ prisma, clock });
  topicId = (await prisma.topic.findFirstOrThrow()).id;

  // TEST-FAMILY: a different scheme (2 marks, -1/2), CBT, all from data.
  const fam = await prisma.examFamily.create({ data: { code: "test-family", name: "TEST-FAMILY", rankScope: "test scope", rankTitles: [], status: "published", sourceUrl: "https://x.test/" } });
  const exam = await prisma.exam.create({
    data: {
      code: "test-exam", name: "Test exam", conductingBody: "TEST", level: "central", minQualification: "sslc", description: "fixture",
      stages: [], patternMode: "cbt", officialUrl: "https://x.test/", sourceUrl: "https://x.test/", status: "published", familyId: fam.id,
    },
  });
  const stage = await prisma.examStage.create({ data: { examId: exam.id, code: "prelims", name: "Prelims", order: 1 } });
  const paper = await prisma.paper.create({ data: { stageId: stage.id, code: "p1", name: "P1", order: 1, answerMode: "objective_cbt", status: "published", sourceUrl: "https://x.test/" } });
  const desc = await prisma.paper.create({ data: { stageId: stage.id, code: "essay", name: "Essay", order: 2, answerMode: "descriptive", status: "published", sourceUrl: "https://x.test/" } });
  for (const p of [paper, desc]) {
    await prisma.markingScheme.create({
      data: {
        paperId: p.id, version: 1, durationMinutes: 30, totalQuestions: 4, status: "published", sourceUrl: "https://x.test/",
        sections: { create: [{ code: "S", name: "Section S", order: 1, questionCount: 4, correctMarksNum: 2, wrongPenaltyNum: 1, wrongPenaltyDen: 2 }] },
      },
    });
  }
  for (const [i, id] of Q.entries()) {
    await prisma.question.create({
      data: {
        id, topicId, status: "published", pyqExamCode: i === 0 ? "test-exam" : null, pyqYear: i === 0 ? 2024 : null,
        versions: { create: { version: 1, stem: `Q${i}`, options: [{ id: "A", text: "a" }, { id: "B", text: "b" }, 7], correctOptionIds: ["A"], explanationMarkdown: "x", whyWrong: { B: "trap", C: 3 }, status: "published" } },
      },
    });
  }
  const sections = [{ sectionCode: "S", questionIds: Q }];
  testMockId = (await prisma.mock.create({ data: { code: "test-full", examCode: "test-exam", paperId: paper.id, schemeVersion: 1, title: "Test full", kind: "full", sections, status: "published" } })).id;
  descMockId = (await prisma.mock.create({ data: { code: "test-essay", examCode: "test-exam", paperId: desc.id, schemeVersion: 1, title: "Essay", kind: "sectional", sections, status: "published" } })).id;
  stateMockId = (
    await prisma.mock.create({
      data: {
        code: "test-sunday", examCode: "test-exam", paperId: paper.id, schemeVersion: 1, title: "State Mock", kind: "state_mock_sunday", sections, status: "published",
        opensAt: new Date("2026-11-01T04:30:00Z"), lateJoinUntil: new Date("2026-11-01T05:00:00Z"), closesAt: new Date("2026-11-01T18:29:00Z"), rankPublishAt: new Date("2026-11-01T14:30:00Z"),
      },
    })
  ).id;
});

afterAll(async () => {
  await prisma?.$disconnect();
  await db?.stop();
});

describe("exam-hall (integration)", () => {
  it("SEED catalogue: structure for every seed exam, verified=false; placeholder mock playable", async () => {
    const s = await createExamCatalogueModule({ prisma }).structure("tnpsc-group-4");
    expect(s.family).toEqual({ code: "tnpsc", name: "TNPSC" });
    expect(s.stages[0]?.papers[0]?.scheme).toMatchObject({ verified: false, totalQuestions: 200, durationMinutes: 180 });
    expect(s.attemptCycles[0]?.stageDates).toEqual([{ stageCode: "written", date: null, dateStatus: "unknown" }]);
    const list = await hall.listMocks(user(1), "tnpsc-group-4");
    expect(list.items).toHaveLength(1);
    const a = await hall.start(user(1), list.items[0]?.id as string, "omr");
    expect(a.questions).toHaveLength(10);
    await hall.saveAnswers(user(1), a.attemptId, [{ questionId: a.questions[0]?.id as string, chosenOptionIds: ["A"], markedForReview: true, clientAt: clock.now().toISOString() }]);
    expect((await hall.submit(user(1), a.attemptId)).scoreDisplay).toBe("1.00");
    expect(await prisma.mock.count({ where: { code: { startsWith: "seed-" } } })).toBe(3); // seed ran twice: no duplicates
  });

  it("TEST-FAMILY end to end with its own scheme; question reader maps source and drops bad options", async () => {
    const a = await hall.start(user(2), testMockId, "cbt");
    expect(a.mode).toBe("cbt");
    expect(a.questions[0]?.options).toHaveLength(2);
    expect(a.questions[0]?.source.pyq).toMatchObject({ examCode: "test-exam", year: 2024 });
    const at = clock.now().toISOString();
    await hall.saveAnswers(user(2), a.attemptId, [
      { questionId: Q[0] as string, chosenOptionIds: ["A"], markedForReview: false, clientAt: at },
      { questionId: Q[1] as string, chosenOptionIds: ["A"], markedForReview: false, clientAt: at },
      { questionId: Q[2] as string, chosenOptionIds: ["B"], markedForReview: false, clientAt: at },
    ]);
    const r = await hall.submit(user(2), a.attemptId);
    expect(r).toMatchObject({ score: { numerator: 7, denominator: 2 }, maxScore: { numerator: 8, denominator: 1 }, scoreDisplay: "3.50" });
    expect(r.mistakes[0]).toMatchObject({ questionId: Q[2], whyChosenIsWrong: "trap", topicId });
    expect(await hall.submit(user(2), a.attemptId)).toEqual(r);
    expect((await createQuestionReader({ prisma }).withKeys([])).length).toBe(0);
  });

  it("descriptive paper refused", async () => {
    await expect(hall.start(user(3), descMockId, "omr")).rejects.toMatchObject({ code: "PAPER_TYPE_NOT_SUPPORTED" });
  });

  it("allowance race: two parallel starts of two full mocks -> exactly one", async () => {
    const other = await prisma.mock.create({
      data: { code: "test-full-2", examCode: "test-exam", paperId: (await prisma.mock.findUniqueOrThrow({ where: { id: testMockId } })).paperId, schemeVersion: 1, title: "Test full 2", kind: "full", sections: [{ sectionCode: "S", questionIds: Q }], status: "published" },
    });
    const res = await Promise.allSettled([hall.start(user(4), testMockId, "cbt"), hall.start(user(4), other.id, "cbt")]);
    expect(res.filter((r) => r.status === "fulfilled")).toHaveLength(1);
    expect(res.find((r) => r.status === "rejected")).toMatchObject({ reason: { code: "MOCK_MONTHLY_LIMIT" } });
    expect(await prisma.mockAllowanceUse.count({ where: { userId: user(4) } })).toBe(1);
    expect((await hall.listMocks(user(4), "test-exam")).items.find((i) => i.kind === "full")?.locked).toBe(true);
  });

  it("resume race: parallel starts of one mock -> one attempt", async () => {
    const res = await Promise.all([hall.start(user(5), testMockId, "cbt"), hall.start(user(5), testMockId, "cbt"), hall.start(user(5), testMockId, "cbt")]);
    expect(new Set(res.map((r) => r.attemptId)).size).toBe(1);
    expect(await prisma.mockAttempt.count({ where: { userId: user(5) } })).toBe(1);
  });

  it("late saves: older clientAt never overwrites; after deadline unranked; after grace ignored; expire job", async () => {
    clock.set("2026-10-22T06:00:00.000Z");
    const a = await hall.start(user(6), testMockId, "cbt");
    const t = (min: number) => new Date(clock.now().getTime() + min * 60_000).toISOString();
    await hall.saveAnswers(user(6), a.attemptId, [{ questionId: Q[0] as string, chosenOptionIds: ["A"], markedForReview: false, clientAt: t(1) }]);
    await hall.saveAnswers(user(6), a.attemptId, [{ questionId: Q[0] as string, chosenOptionIds: ["B"], markedForReview: false, clientAt: t(0) }]);
    expect((await hall.get(user(6), a.attemptId)).answers[0]?.chosenOptionIds).toEqual(["A"]);
    clock.advanceMinutes(31);
    expect((await hall.saveAnswers(user(6), a.attemptId, [{ questionId: Q[1] as string, chosenOptionIds: ["A"], markedForReview: false, clientAt: t(0) }])).saved).toBe(1);
    expect((await prisma.mockAttempt.findUniqueOrThrow({ where: { id: a.attemptId } })).ranked).toBe(false);
    clock.advanceMinutes(5);
    expect(await hall.expireOverdue()).toMatchObject({ expired: expect.any(Number) });
    const row = await prisma.mockAttempt.findUniqueOrThrow({ where: { id: a.attemptId } });
    expect(row).toMatchObject({ status: "expired", correct: 2, scoreNum: 4, scoreDen: 1 });
    expect(await hall.expireOverdue()).toEqual({ expired: 0 });
    const h = await hall.history(user(6), null, 1);
    expect(h.items[0]).toMatchObject({ attemptId: a.attemptId, status: "expired", scoreDisplay: "4.00" });
  });

  it("history cursor pages", async () => {
    clock.set("2026-10-23T06:00:00.000Z");
    const ids: string[] = [];
    for (let i = 0; i < 3; i += 1) {
      const m = await prisma.mock.create({ data: { code: `test-sec-${i}`, examCode: "test-exam", paperId: (await prisma.mock.findUniqueOrThrow({ where: { id: testMockId } })).paperId, schemeVersion: 1, title: `Sec ${i}`, kind: "sectional", sections: [{ sectionCode: "S", questionIds: Q }], status: "published" } });
      ids.push((await hall.start(user(7), m.id, "cbt")).attemptId);
      clock.advanceMinutes(1);
    }
    const p1 = await hall.history(user(7), null, 2);
    expect(p1.items.map((x) => x.attemptId)).toEqual([ids[2], ids[1]]);
    const p2 = await hall.history(user(7), p1.nextCursor, 2);
    expect(p2.items.map((x) => x.attemptId)).toEqual([ids[0]]);
    expect(p2.nextCursor).toBeNull();
  });

  it("State Mock Sunday: ranked takers, ties share rank, published once at rankPublishAt", async () => {
    clock.set("2026-11-01T04:35:00Z");
    expect((await hall.stateMockSunday("test-exam")).mock?.id).toBe(stateMockId);
    const answers = (ids: string[]) => ids.map((q) => ({ questionId: q, chosenOptionIds: ["A"], markedForReview: false, clientAt: clock.now().toISOString() }));
    const a = await hall.start(user(10), stateMockId, "cbt");
    const b = await hall.start(user(11), stateMockId, "cbt");
    const c = await hall.start(user(12), stateMockId, "cbt");
    await hall.saveAnswers(user(10), a.attemptId, answers([Q[0] as string, Q[1] as string]));
    await hall.saveAnswers(user(11), b.attemptId, answers([Q[2] as string, Q[3] as string]));
    await hall.saveAnswers(user(12), c.attemptId, answers([Q[0] as string]));
    await hall.submit(user(10), a.attemptId);
    await hall.submit(user(11), b.attemptId);
    // user 12 never submits: scored at the deadline by the rank job, still ranked.
    clock.set("2026-11-01T06:00:00Z");
    const late = await hall.start(user(13), stateMockId, "cbt");
    expect(late.ranked).toBe(false);
    await expect(hall.statewideRank(user(10), stateMockId)).rejects.toMatchObject({ code: "RANK_NOT_READY" });
    clock.set("2026-11-01T14:30:00Z");
    expect(await hall.publishRanks()).toEqual({ mocks: 1, rows: 3 });
    expect(await hall.publishRanks()).toEqual({ mocks: 0, rows: 0 });
    expect(await prisma.mockRank.count({ where: { mockId: stateMockId } })).toBe(3);
    expect(await hall.statewideRank(user(10), stateMockId)).toMatchObject({ rank: 1, rankedCandidates: 3, percentile: 100, scopeLabel: "test scope" });
    expect((await hall.statewideRank(user(11), stateMockId)).rank).toBe(1);
    expect(await hall.statewideRank(user(12), stateMockId)).toMatchObject({ rank: 3, percentile: 33 });
    await expect(hall.statewideRank(user(13), stateMockId)).rejects.toMatchObject({ code: "NOT_FOUND" });
  });
});
