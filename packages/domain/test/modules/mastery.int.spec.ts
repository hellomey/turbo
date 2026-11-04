// Integration: mastery Prisma adapter + content question bank on REAL PostgreSQL (Testcontainers, blueprint §44).
// Covers: rowVersion race, single-submit guard, clientActionId accepted once, scheduler idempotency, paging.
import { randomInt, randomUUID } from "node:crypto";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { FakeClock, startPostgres, type StartedDb } from "@heymey/testing";
import { createContentModule, createQuestionBank } from "../../src/modules/content/index.js";
import { createMasteryDimming, createMasteryModule, emptyLamp } from "../../src/modules/mastery/index.js";
import { PrismaMasteryRepository } from "../../src/modules/mastery/infrastructure/prisma-mastery-repository.js";
import { createSyllabusModule } from "../../src/modules/syllabus/index.js";
import { seeder } from "../../../db/prisma/seed/catalog.js";

let db: StartedDb;
let prisma: PrismaClient;
const PREAMBLE = "0199f5a0-0101-7000-8000-000000000101";
const USER = randomUUID();

async function seedQuestions(topicId: string, n: number) {
  const source = await prisma.source.create({ data: { citation: "Test book p.1", kind: "original" } });
  for (let i = 0; i < n; i++) {
    const q = await prisma.question.create({ data: { topicId, status: "published", difficulty: (i % 5) + 1, pyqExamCode: i === 0 ? "tnpsc-group-4" : null, pyqYear: i === 0 ? 2024 : null } });
    await prisma.questionVersion.create({
      data: {
        questionId: q.id,
        version: 1,
        stem: `Q${i}`,
        options: [
          { id: "a", text: "A" },
          { id: "b", text: "B" },
        ],
        correctOptionIds: ["a"],
        explanationMarkdown: "Because.",
        whyWrong: { b: "B is wrong" },
        sourceId: source.id,
        status: "published",
      },
    });
  }
  // an unpublished one is never picked
  await prisma.question.create({ data: { topicId, status: "draft" } });
}

beforeAll(async () => {
  db = await startPostgres();
  prisma = createPrismaClient(db.url);
  await seeder.run(prisma);
  await seedQuestions(PREAMBLE, 20);
});

afterAll(async () => {
  await prisma?.$disconnect();
  await db?.stop();
});

function build(clock: FakeClock) {
  const syllabus = createSyllabusModule({ prisma });
  const content = createContentModule({ prisma, syllabus });
  return createMasteryModule({
    prisma,
    clock,
    syllabus,
    questions: createQuestionBank({ prisma, randomInt }),
    openableTopics: (ids) => content.topicsWithPublishedLesson(ids),
    learner: { examCodes: async () => ["tnpsc-group-4"], publishedExamCodes: async () => new Set(["tnpsc-group-4", "tnpsc-group-2"]) },
  });
}

describe("mastery on Postgres (integration)", () => {
  it("lesson -> lit check -> recall; graded on the server with source + why wrong", async () => {
    const clock = new FakeClock("2026-11-02T04:30:00.000Z");
    const api = build(clock);
    await api.completeLesson(USER, PREAMBLE);
    const c = await api.startCheck(USER, PREAMBLE, "lit");
    expect(c.questions).toHaveLength(3);
    expect(new Set(c.questions.map((q) => q.id)).size).toBe(3);
    expect(JSON.stringify(c)).not.toContain("correctOptionIds");
    const res = await api.submitCheck(USER, c.checkId, [
      { questionId: c.questions[0]!.id, chosenOptionIds: ["a"] }, // eslint-disable-line @typescript-eslint/no-non-null-assertion
      { questionId: c.questions[1]!.id, chosenOptionIds: ["a", "a"] }, // eslint-disable-line @typescript-eslint/no-non-null-assertion
      { questionId: c.questions[2]!.id, chosenOptionIds: ["b"] }, // eslint-disable-line @typescript-eslint/no-non-null-assertion
    ]);
    expect(res).toMatchObject({ passed: true, correct: 2, total: 3 });
    expect(res.graded[2]).toMatchObject({ correct: false, whyChosenIsWrong: "B is wrong", source: { citation: "Test book p.1" } });
    expect(res.topicState.ring.lit).toBe(true);
    expect(await prisma.topicCheck.findUnique({ where: { id: c.checkId } })).toMatchObject({ passed: true, correct: 2 });
    expect(await prisma.userRank.findUnique({ where: { userId: USER } })).toMatchObject({ level: expect.any(Number) });
    await expect(api.submitCheck(USER, c.checkId, [])).rejects.toMatchObject({ code: "CHECK_ALREADY_SUBMITTED" });

    clock.advanceDays(1);
    const r = await api.startCheck(USER, PREAMBLE, "recall");
    const rr = await api.submitCheck(USER, r.checkId, r.questions.map((q) => ({ questionId: q.id, chosenOptionIds: ["a"] })));
    expect(rr.topicState.ring.steadyLevel).toBe(1);

    const page = await api.topicStates(USER, { examCode: "tnpsc-group-4", limit: 1 });
    expect(page.items.map((i) => i.topicId)).toEqual([PREAMBLE]);
    const sum = await api.summary(USER);
    expect(sum.counts.lit).toBe(1);
  });

  it("rowVersion guard: a stale write is a conflict; insert race is a conflict", async () => {
    const repo = new PrismaMasteryRepository(prisma);
    const user = randomUUID();
    const now = new Date("2026-11-02T04:30:00.000Z");
    const s = emptyLamp(user, PREAMBLE, now);
    expect(await repo.commit({ state: { next: s, expectedVersion: null }, events: [] })).toBe("ok");
    expect(await repo.commit({ state: { next: s, expectedVersion: null }, events: [] })).toBe("conflict");
    expect(await repo.commit({ state: { next: { ...s, steadyLevel: 1 }, expectedVersion: 0 }, events: [] })).toBe("ok");
    expect(await repo.commit({ state: { next: { ...s, steadyLevel: 2 }, expectedVersion: 0 }, events: [{ userId: user, topicId: PREAMBLE, kind: "lit", at: now, source: "online" }] })).toBe("conflict");
    expect((await repo.getState(user, PREAMBLE))?.rowVersion).toBe(1);
    expect(await prisma.ringEvent.count({ where: { userId: user } })).toBe(0); // rolled back
  });

  it("clientActionId is accepted once (unique)", async () => {
    const clock = new FakeClock("2026-11-02T04:30:00.000Z");
    const api = build(clock);
    const user = randomUUID();
    const a = { clientActionId: randomUUID(), clientAt: clock.now().toISOString(), kind: "lesson_complete" as const, topicId: PREAMBLE, via: "lesson" as const };
    expect((await api.syncAction(user, a)).status).toBe("accepted");
    expect((await api.syncAction(user, a)).status).toBe("duplicate");
    const repo = new PrismaMasteryRepository(prisma);
    expect(await repo.commit({ events: [{ userId: user, topicId: PREAMBLE, kind: "lesson_done", at: clock.now(), source: "offline_sync", clientActionId: a.clientActionId }] })).toBe("duplicate");
    expect(await repo.hasClientAction(user, a.clientActionId)).toBe(true);
  });

  it("SEC-P2-L2: two users with the same clientActionId are both accepted (dedupe is per user)", async () => {
    const clock = new FakeClock("2026-11-02T04:30:00.000Z");
    const api = build(clock);
    const [u1, u2] = [randomUUID(), randomUUID()];
    const a = { clientActionId: randomUUID(), clientAt: clock.now().toISOString(), kind: "lesson_complete" as const, topicId: PREAMBLE, via: "lesson" as const };
    expect((await api.syncAction(u1, a)).status).toBe("accepted");
    expect((await api.syncAction(u2, a)).status).toBe("accepted");
    expect((await api.syncAction(u2, a)).status).toBe("duplicate");
    expect(await prisma.ringEvent.count({ where: { clientActionId: a.clientActionId } })).toBe(2);
  });

  it("dimming job is idempotent for the same window and pages by key", async () => {
    const clock = new FakeClock("2026-11-02T04:30:00.000Z");
    const user = randomUUID();
    const due = new Date("2026-11-01T18:30:00.000Z");
    await prisma.userTopicState.create({ data: { userId: user, topicId: PREAMBLE, litAt: due, nextDueAt: due, steadyLevel: 2, goldAt: due, updatedAt: due } });
    const job = createMasteryDimming({ prisma, clock });
    const first = await job.run();
    expect(first.dimming).toBeGreaterThanOrEqual(1);
    expect((await job.run()).dimming).toBe(0);
    clock.advanceDays(7);
    const r = await job.run();
    expect(r.steadyLost).toBeGreaterThanOrEqual(1);
    const row = await prisma.userTopicState.findUnique({ where: { userId_topicId: { userId: user, topicId: PREAMBLE } } });
    expect(row).toMatchObject({ dimState: "dim", steadyLevel: 0 });
    expect(row?.goldAt).not.toBeNull();
    expect((await prisma.ringEvent.findMany({ where: { userId: user }, orderBy: { at: "asc" } })).map((e) => e.kind)).toEqual(["dimming", "dim", "steady_lost"]);
    expect((await job.run()).examined).toBe(0);
    const repo = new PrismaMasteryRepository(prisma);
    const after = await repo.dimmingCandidates({ now: clock.now(), dimCutoff: clock.now(), limit: 10, after: { userId: "ffffffff-ffff-7fff-bfff-ffffffffffff", topicId: PREAMBLE } });
    expect(after).toEqual([]);
  });

  it("question bank: too few questions -> [], grade ignores unknown ids", async () => {
    const bank = createQuestionBank({ prisma, randomInt });
    expect(await bank.pick({ topicId: PREAMBLE, count: 50, minDifficulty: 1 })).toEqual([]);
    expect((await bank.pick({ topicId: PREAMBLE, count: 4, minDifficulty: 5 })).every((q) => q.difficulty === 5)).toBe(true);
    expect(await bank.grade([{ questionId: randomUUID(), chosenOptionIds: ["a"] }])).toEqual([]);
  });
});
