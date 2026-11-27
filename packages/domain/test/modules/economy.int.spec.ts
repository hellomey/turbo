// BOLT-0113 integration: economy Prisma adapter on REAL PostgreSQL (Testcontainers, §44).
// Covers: check-in once per IST day under concurrency (one Points row), XP award idempotent per source key,
// study days in IST, weekly XP only for opted-in users, trophies once.
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { FakeClock, startPostgres, type StartedDb } from "@heymey/testing";
import { createEconomyProgression } from "../../src/modules/economy/index.js";

let db: StartedDb;
let prisma: PrismaClient;

beforeAll(async () => {
  db = await startPostgres();
  prisma = createPrismaClient(db.url);
});

afterAll(async () => {
  await prisma?.$disconnect();
  await db?.stop();
});

function build(clock: FakeClock, names: Record<string, string> = {}) {
  return createEconomyProgression({
    prisma,
    clock,
    people: { profile: async (id) => ({ nickname: names[id] ?? null, isGuest: false, hideFromLeaderboards: false, deleted: false }) },
    learning: { subjectFullyLit: async () => true },
  });
}

describe("economy progression on Postgres", () => {
  it("a duplicated or concurrent check-in gives exactly one Points row and one XP row", async () => {
    const clock = new FakeClock("2026-11-25T04:30:00.000Z");
    const api = build(clock);
    const u = randomUUID();
    const results = await Promise.all(Array.from({ length: 5 }, () => api.checkIn(u)));
    expect(results.filter((r) => !r.alreadyCheckedIn)).toHaveLength(1);
    expect(await prisma.pointsLedger.count({ where: { userId: u } })).toBe(1);
    expect(await prisma.xpAward.count({ where: { userId: u } })).toBe(1);
    expect(await api.progress(u)).toMatchObject({ xp: 5, points: 10, checkedInToday: true });
  });

  it("learning XP is idempotent per source event and trophies land once", async () => {
    const clock = new FakeClock("2026-11-25T04:30:00.000Z");
    const api = build(clock);
    const u = randomUUID();
    const e = { type: "mastery.lamp_changed", occurredAt: clock.now(), payload: { userId: u, topicId: randomUUID(), source: "online", kinds: ["lit"] } };
    await api.onLearningEvent(e);
    await api.onLearningEvent(e);
    const p = await api.progress(u);
    expect(p.xp).toBe(25);
    expect(p.trophies.map((t) => t.code).sort()).toEqual(["first_lamp", "subject_lit"]);
  });

  it("study days count IST days with learning XP; five earns the trophy", async () => {
    const clock = new FakeClock("2026-11-01T18:00:00.000Z"); // 23:30 IST
    const api = build(clock);
    const u = randomUUID();
    for (let d = 0; d < 5; d++) {
      await api.onLearningEvent({ type: "exam_hall.mock_submitted", occurredAt: clock.now(), payload: { userId: u, attemptId: randomUUID(), correct: 1, wrong: 0 } });
      clock.advanceDays(1);
    }
    expect((await api.progress(u)).trophies.map((t) => t.code)).toContain("five_study_days");
  });

  it("weekly leaderboard sums this IST week's XP for opted-in users only", async () => {
    await prisma.xpAward.deleteMany({});
    const clock = new FakeClock("2026-11-25T04:30:00.000Z");
    const a = randomUUID();
    const b = randomUUID();
    const c = randomUUID();
    const api = build(clock, { [a]: "Kavi", [b]: "Arun", [c]: "Hidden" });
    await api.setOptIn(a, true);
    await api.setOptIn(b, true);
    await api.setOptIn(b, false);
    for (const u of [a, b, c]) {
      await api.onLearningEvent({ type: "exam_hall.mock_submitted", occurredAt: clock.now(), payload: { userId: u, attemptId: randomUUID(), correct: 1, wrong: 0 } });
    }
    await prisma.xpAward.create({ data: { userId: a, amount: 999, reason: "lit", sourceKey: "last-week", createdAt: new Date("2026-11-22T18:29:59.000Z") } });
    const board = await api.weeklyLeaderboard(a);
    expect(board.optedIn).toBe(true);
    expect(board.entries).toEqual([{ rank: 1, displayName: "Kavi", xp: 40, isMe: true }]);
  });
});
