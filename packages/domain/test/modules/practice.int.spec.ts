// BOLT-0010 integration: practice Prisma adapter + content practice API on REAL PostgreSQL (Testcontainers, blueprint §44).
// Covers: 40 parallel answers -> exactly 30 counted (inv. 1, 3), replay (inv. 6), offline study log, mistakes SQL,
// drills (Pro), PYQ cursor pages + locked years (inv. 10), reports, packs, version-answered grading (inv. 7).
import { randomInt, randomUUID } from "node:crypto";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { FakeClock, startPostgres, type StartedDb } from "@heymey/testing";
import { createPracticeContent, type PracticeContentApi } from "../../src/modules/content/index.js";
import { createPracticeModule } from "../../src/modules/practice/index.js";
import { createSyllabusModule } from "../../src/modules/syllabus/index.js";
import { seeder } from "../../../db/prisma/seed/catalog.js";

let db: StartedDb;
let prisma: PrismaClient;
let content: PracticeContentApi;
const EXAM = "tnpsc-group-4";
const PREAMBLE = "0199f5a0-0101-7000-8000-000000000101";
const qids: string[] = [];

async function seed() {
  const source = await prisma.source.create({ data: { citation: "SEED: test book p.1", kind: "original" } });
  for (let i = 0; i < 40; i++) {
    const pyqYear = i < 12 ? 2019 + (i % 6) : null; // 2019..2024, 2 each
    const q = await prisma.question.create({
      data: { topicId: PREAMBLE, status: "published", difficulty: (i % 5) + 1, pyqExamCode: pyqYear ? EXAM : null, pyqYear, pyqNumber: pyqYear ? i + 1 : null },
    });
    qids.push(q.id);
    await prisma.questionVersion.create({
      data: {
        questionId: q.id,
        version: 1,
        stem: `SEED Q${i}`,
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
  await prisma.question.create({ data: { topicId: PREAMBLE, status: "draft" } });
}

beforeAll(async () => {
  db = await startPostgres();
  prisma = createPrismaClient(db.url);
  await seeder.run(prisma);
  await seed();
  content = createPracticeContent({ prisma, syllabus: createSyllabusModule({ prisma }), randomInt: (m) => randomInt(m) });
});

afterAll(async () => {
  await prisma?.$disconnect();
  await db?.stop();
});

function build(clock: FakeClock, entitlement: "free" | "pro" = "free") {
  return createPracticeModule({ prisma, clock, content, billing: { entitlementOf: async () => entitlement } });
}

const body = (questionId: string, chosen = ["a"]) => ({ clientActionId: randomUUID(), questionId, questionVersion: 1, chosenOptionIds: chosen, timeMs: 900 });

describe("practice on Postgres", () => {
  it("40 parallel answers by one free user -> exactly 30 counted, 10 refused, nothing extra stored", async () => {
    const user = randomUUID();
    const api = build(new FakeClock("2026-10-22T06:00:00.000Z"));
    const s = await api.startSession(user, { mode: "practice", examCode: EXAM, size: 50 });
    expect(s.questions).toHaveLength(40);
    const results = await Promise.allSettled(s.questions.map((q) => api.answer(user, s.sessionId, body(q.id))));
    const ok = results.filter((r) => r.status === "fulfilled");
    const refused = results.filter((r) => r.status === "rejected" && (r.reason as { code?: string }).code === "PRACTICE_DAILY_LIMIT");
    expect([ok.length, refused.length]).toEqual([30, 10]);
    expect(await prisma.practiceAnswer.count({ where: { userId: user } })).toBe(30);
    expect(await prisma.practiceDayCounter.findUnique({ where: { userId_istDay: { userId: user, istDay: "2026-10-22" } } })).toMatchObject({ counted: 30, limitSheetShown: true });
    expect(await api.usage(user)).toMatchObject({ used: 30, limit: 30, limitSheetShownToday: true });
  });

  it("replay of one clientActionId in parallel stores once", async () => {
    const user = randomUUID();
    const api = build(new FakeClock("2026-10-22T06:00:00.000Z"));
    const s = await api.startSession(user, { mode: "practice", examCode: EXAM, size: 5 });
    const b = body(s.questions[0]?.id as string, ["b"]);
    const rs = await Promise.all([api.answer(user, s.sessionId, b), api.answer(user, s.sessionId, b), api.answer(user, s.sessionId, b)]);
    expect(rs.every((r) => r.graded.correct === false)).toBe(true);
    expect(await prisma.practiceAnswer.count({ where: { userId: user } })).toBe(1);
    expect((await api.usage(user)).used).toBe(1);
  });

  it("offline sync: counted on the clamped IST day; over the limit study log only; replays duplicate", async () => {
    const user = randomUUID();
    const clock = new FakeClock("2026-10-22T06:00:00.000Z");
    const api = build(clock);
    const action = (clientAt: string) => ({
      kind: "practice_answer" as const,
      clientActionId: randomUUID(),
      clientAt,
      questionId: qids[20] as string,
      questionVersion: 1,
      chosenOptionIds: ["a"],
      timeMs: 400,
      mode: "practice" as const,
    });
    const statuses: string[] = [];
    for (let i = 0; i < 31; i++) statuses.push((await api.syncAnswer(user, action("2026-10-21T10:00:00.000Z"))).status);
    expect(statuses.filter((s) => s === "accepted")).toHaveLength(30);
    expect(statuses[30]).toBe("study_log_only");
    const a = action("2026-01-01T00:00:00.000Z");
    expect((await api.syncAnswer(user, a)).status).toBe("accepted");
    expect((await api.syncAnswer(user, a)).status).toBe("duplicate");
    expect((await prisma.practiceAnswer.findUnique({ where: { userId_clientActionId: { userId: user, clientActionId: a.clientActionId } } }))?.istDay).toBe("2026-10-15");
    expect(await prisma.practiceAnswer.count({ where: { userId: user, studyLogOnly: true } })).toBe(1);
    expect((await api.usage(user)).used).toBe(0); // today untouched
  });

  it("grades against the version answered after a correction; mistakes page via SQL", async () => {
    const user = randomUUID();
    const clock = new FakeClock("2026-10-22T06:00:00.000Z");
    const api = build(clock);
    const s = await api.startSession(user, { mode: "practice", examCode: EXAM, size: 3 });
    for (const q of s.questions) {
      clock.advanceMinutes(1);
      await api.answer(user, s.sessionId, body(q.id, ["b"]));
    }
    const p1 = await api.mistakes(user, { limit: 2 });
    expect(p1.items.map((i) => i.questionId)).toEqual([s.questions[2]?.id, s.questions[1]?.id]);
    expect(p1.items[0]).toMatchObject({ wrongCount: 1, graded: { correct: false, whyChosenIsWrong: "B is wrong" }, topicId: PREAMBLE });
    const p2 = await api.mistakes(user, { limit: 2, cursor: p1.nextCursor as string });
    expect(p2).toMatchObject({ items: [{ questionId: s.questions[0]?.id }], nextCursor: null });

    // Correction: v2 makes "b" right; the stored v1 answer still grades against v1.
    const target = s.questions[0]?.id as string;
    await prisma.questionVersion.update({ where: { questionId_version: { questionId: target, version: 1 } }, data: { status: "superseded" } });
    await prisma.questionVersion.create({
      data: { questionId: target, version: 2, stem: "v2", options: [{ id: "a", text: "A" }, { id: "b", text: "B" }], correctOptionIds: ["b"], explanationMarkdown: "v2", status: "published" },
    });
    await prisma.question.update({ where: { id: target }, data: { currentVersion: 2 } });
    const again = await api.mistakes(user, { limit: 10 });
    expect(again.items.find((i) => i.questionId === target)?.graded.correctOptionIds).toEqual(["a"]);
    const m = await api.startSession(user, { mode: "mistakes", examCode: EXAM, topicId: PREAMBLE, size: 10 });
    expect(m.questions.find((q) => q.id === target)?.version).toBe(2);
  });

  it("Pro: 3 wrong on one lamp -> one open drill, not duplicated; Free: locked and none", async () => {
    const clock = new FakeClock("2026-10-22T06:00:00.000Z");
    const proUser = randomUUID();
    const pro = build(clock, "pro");
    const s = await pro.startSession(proUser, { mode: "practice", examCode: EXAM, size: 5 });
    for (const q of s.questions) await pro.answer(proUser, s.sessionId, body(q.id, ["b"]));
    const d = await pro.drills(proUser);
    expect(d.locked).toBe(false);
    expect(d.items).toHaveLength(1);
    expect(d.items[0]).toMatchObject({ topicId: PREAMBLE, status: "open", questionCount: 8 });
    const ds = await pro.startSession(proUser, { mode: "drill", examCode: EXAM, drillId: d.items[0]?.id as string, size: 8 });
    expect(ds.questions).toHaveLength(8);

    const freeUser = randomUUID();
    const free = build(clock);
    const fs = await free.startSession(freeUser, { mode: "practice", examCode: EXAM, size: 4 });
    for (const q of fs.questions) await free.answer(freeUser, fs.sessionId, body(q.id, ["b"]));
    expect(await free.drills(freeUser)).toEqual({ items: [], locked: true });
    expect(await prisma.mistakeTally.findUnique({ where: { userId_topicId: { userId: freeUser, topicId: PREAMBLE } } })).toMatchObject({ wrongCount: 4 });
  });

  it("PYQ Vault: cursor pages over (year desc, id), older years locked for Free, facets", async () => {
    const api = build(new FakeClock("2026-10-22T06:00:00.000Z"));
    const user = randomUUID();
    const seen: { year: number | undefined; locked: boolean; stem: string }[] = [];
    let cursor: string | null | undefined;
    do {
      const p = await api.searchPyqs(user, { examCode: EXAM, limit: 5, ...(cursor ? { cursor } : {}) });
      seen.push(...p.items.map((i) => ({ year: i.question.source.pyq?.year, locked: i.locked, stem: i.question.stem })));
      cursor = p.nextCursor;
    } while (cursor);
    expect(seen.map((s) => s.year)).toEqual([2024, 2024, 2023, 2023, 2022, 2022, 2021, 2021, 2020, 2020, 2019, 2019]);
    expect(seen.filter((s) => !s.locked).map((s) => s.year)).toEqual([2024, 2024, 2023, 2023]);
    expect(seen.filter((s) => s.locked).every((s) => s.stem === "")).toBe(true);
    expect((await api.searchPyqs(user, { examCode: EXAM, year: 2020, difficulty: 3, limit: 20 })).items.length).toBeLessThanOrEqual(2);
    const f = await api.pyqFacets(user, EXAM);
    expect(f.years.map((y) => [y.year, y.count, y.locked])).toEqual([
      [2024, 2, false],
      [2023, 2, false],
      [2022, 2, true],
      [2021, 2, true],
      [2020, 2, true],
      [2019, 2, true],
    ]);
    expect(f.subjects).toEqual([expect.objectContaining({ count: 12 })]);
    const ps = await api.startSession(user, { mode: "pyq", examCode: EXAM, size: 50 });
    expect(ps.questions.map((q) => q.source.pyq?.year).sort()).toEqual([2023, 2023, 2024, 2024]);
  });

  it("content: reports and packs on Postgres", async () => {
    const user = randomUUID();
    const ack = await content.report(user, qids[0] as string, { questionVersion: 1, reason: "unclear", note: "Option B reads oddly" });
    expect(ack.status).toBe("received");
    expect(await prisma.questionReport.findUnique({ where: { id: ack.reportId } })).toMatchObject({ userId: user, reason: "unclear" });
    await expect(content.report(user, randomUUID(), { questionVersion: 1, reason: "typo" })).rejects.toMatchObject({ code: "QUESTION_NOT_FOUND" });
    await expect(content.report(user, qids[0] as string, { questionVersion: 7, reason: "typo" })).rejects.toMatchObject({ code: "VALIDATION_FAILED" });

    const base = { examCode: EXAM, url: "https://cdn.heymey.app/p.zip", sha256: "b".repeat(64), sizeBytes: 1024, status: "published", publishedAt: new Date("2026-10-01T00:00:00.000Z") };
    await prisma.contentPack.createMany({
      data: [
        { ...base, code: "tnpsc-group-4.polity", version: 1, tier: "free" },
        { ...base, code: "tnpsc-group-4.polity", version: 2, tier: "free" },
        { ...base, code: "tnpsc-group-4.history", version: 1, tier: "pro" },
        { ...base, code: "tnpsc-group-4.draft", version: 1, tier: "free", status: "draft", publishedAt: null },
      ],
    });
    const list = await content.packs(EXAM, false);
    expect(list.items.map((p) => [p.code, p.version, p.locked])).toEqual([
      ["tnpsc-group-4.history", 1, true],
      ["tnpsc-group-4.polity", 2, false],
    ]);
  });
});
