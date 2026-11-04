// BOLT-0013 integration: readiness Prisma adapter + mastery activity view + the Sunday job on REAL PostgreSQL
// (Testcontainers, blueprint §44). Covers invariant 7 (one snapshot per day, one report per IST week: job twice -> one
// report per user), report paging, and that readiness reads mastery/exam-hall only through their public APIs.
import { randomInt, randomUUID } from "node:crypto";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { FakeClock, startPostgres, type StartedDb } from "@heymey/testing";
import { createContentModule, createQuestionBank } from "../../src/modules/content/index.js";
import { createExamHallModule } from "../../src/modules/exam-hall/index.js";
import { createMasteryActivity, createMasteryModule } from "../../src/modules/mastery/index.js";
import { createReadinessModule } from "../../src/modules/readiness/index.js";
import { createSyllabusModule } from "../../src/modules/syllabus/index.js";
import { seeder } from "../../../db/prisma/seed/catalog.js";

let db: StartedDb;
let prisma: PrismaClient;
const PREAMBLE = "0199f5a0-0101-7000-8000-000000000101";
const A = randomUUID();
const B = randomUUID();
const QUIET = randomUUID();

beforeAll(async () => {
  db = await startPostgres();
  prisma = createPrismaClient(db.url);
  await seeder.run(prisma);
});

afterAll(async () => {
  await prisma?.$disconnect();
  await db?.stop();
});

function build(clock: FakeClock, isPro = false) {
  const syllabus = createSyllabusModule({ prisma });
  const content = createContentModule({ prisma, syllabus });
  const mastery = createMasteryModule({
    prisma,
    clock,
    syllabus,
    questions: createQuestionBank({ prisma, randomInt }),
    openableTopics: (ids) => content.topicsWithPublishedLesson(ids),
    learner: { examCodes: async () => ["tnpsc-group-4"], publishedExamCodes: async () => new Set(["tnpsc-group-4"]) },
  });
  return {
    mastery,
    readiness: createReadinessModule({
      prisma,
      clock,
      mastery,
      masteryActivity: createMasteryActivity({ prisma }),
      examHall: createExamHallModule({ prisma, clock }),
      exams: { examInfo: async () => ({ conductingBody: "TNPSC", paperSecondsPerQuestion: 54 }) },
      entitlements: { isPro: async () => isPro },
    }),
  };
}

async function event(userId: string, kind: string, at: string) {
  await prisma.ringEvent.create({ data: { userId, topicId: PREAMBLE, kind, at: new Date(at), source: "online" } });
}

describe("readiness on Postgres (integration)", () => {
  it("mastery activity: active users keyset-paged, week counts by kind in [from, to)", async () => {
    await event(A, "lit", "2026-11-03T04:00:00.000Z");
    await event(A, "recall_pass", "2026-11-04T04:00:00.000Z");
    await event(A, "recall_pass", "2026-11-05T04:00:00.000Z");
    await event(A, "relight", "2026-11-06T04:00:00.000Z");
    await event(A, "lit", "2026-10-20T04:00:00.000Z"); // last week
    await event(B, "gold", "2026-11-07T04:00:00.000Z");
    await event(QUIET, "lit", "2026-09-01T04:00:00.000Z"); // inactive > 14 days
    const act = createMasteryActivity({ prisma });
    const since = new Date("2026-10-25T00:00:00.000Z");
    const all = await act.activeUserIds({ since, afterUserId: null, limit: 10 });
    expect(all).toEqual([A, B].sort());
    expect(await act.activeUserIds({ since, afterUserId: all[0] ?? null, limit: 10 })).toEqual([all[1]]);
    expect(await act.weekCounts(A, new Date("2026-11-01T18:30:00.000Z"), new Date("2026-11-08T18:30:00.000Z"))).toEqual({ lit: 1, steadyEarned: 2, gold: 0, relit: 1 });
  });

  it("Sunday job twice -> exactly one report per active user; list + get read it back", async () => {
    const clock = new FakeClock("2026-11-08T02:30:00.000Z"); // Sunday 08:00 IST
    const { readiness } = build(clock);
    const pushed: string[] = [];
    const first = await readiness.buildSundayReports(async (u) => void pushed.push(u));
    expect(first).toMatchObject({ weekStart: "2026-11-02", users: 2, created: 2, existing: 0, failed: 0 });
    const second = await readiness.buildSundayReports(async (u) => void pushed.push(u));
    expect(second).toMatchObject({ users: 2, created: 0, existing: 2, failed: 0 });
    expect(pushed.sort()).toEqual([A, B].sort());
    expect(await prisma.sundayReport.count({ where: { userId: { in: [A, B, QUIET] } } })).toBe(2);

    const page = await readiness.listReports(A, { limit: 20 });
    expect(page.items).toHaveLength(1);
    const report = await readiness.getReport(A, page.items[0]?.id ?? "");
    expect(report).toMatchObject({ weekStart: "2026-11-02", tier: "short", lampsLit: 1, steadyEarned: 2, relit: 1, mocksTaken: 0, nextWeek: null, accuracyPct: null });
    await expect(readiness.getReport(B, report.id)).rejects.toMatchObject({ code: "REPORT_NOT_FOUND" });
  });

  it("repository: unique (user, week) under a direct double insert; paging newest first", async () => {
    const clock = new FakeClock("2026-11-15T02:30:00.000Z");
    const { readiness } = build(clock, true);
    const C = randomUUID();
    for (const [i, week] of ["2026-10-12", "2026-10-19", "2026-10-26"].entries()) {
      await prisma.sundayReport.create({ data: { userId: C, weekStart: week, tier: "short", body: { lines: [], nextWeek: null }, createdAt: new Date(Date.UTC(2026, 9, 18 + i * 7)) } });
    }
    await expect(prisma.sundayReport.create({ data: { userId: C, weekStart: "2026-10-26", tier: "short", body: {} } })).rejects.toThrow();
    const p1 = await readiness.listReports(C, { limit: 2 });
    expect(p1.items.map((x) => x.weekStart)).toEqual(["2026-10-26", "2026-10-19"]);
    const p2 = await readiness.listReports(C, { limit: 2, cursor: p1.nextCursor ?? "" });
    expect(p2.items.map((x) => x.weekStart)).toEqual(["2026-10-12"]);
    expect(p2.nextCursor).toBeNull();
  });

  it("meter: real mastery lamps -> bars + one snapshot per IST day; Pro trend reads it back", async () => {
    const clock = new FakeClock("2026-11-10T04:30:00.000Z");
    const { readiness } = build(clock, true);
    const U = randomUUID();
    await prisma.userTopicState.create({ data: { userId: U, topicId: PREAMBLE, litAt: clock.now(), steadyLevel: 1, nextDueAt: new Date("2026-11-20T00:00:00.000Z") } });
    const m = await readiness.meter(U, "tnpsc-group-4");
    expect(m.bars[0]?.value).toBeGreaterThan(0);
    expect(m.bars[1]?.value).toBe(100);
    expect(m.bars[2]).toMatchObject({ value: null, locked: false, evidence: "No mocks yet" });
    await readiness.meter(U, "tnpsc-group-4");
    expect(await prisma.readinessSnapshot.count({ where: { userId: U } })).toBe(1);
    const t = await readiness.trend(U, "tnpsc-group-4", 7);
    expect(t.points).toEqual([expect.objectContaining({ day: "2026-11-10", memory: 100, label: m.label })]);
  });
});
