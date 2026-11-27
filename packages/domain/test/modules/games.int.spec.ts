// BOLT-0115 integration: games Prisma adapter + economy Points on REAL PostgreSQL (Testcontainers, §44).
// Covers: one Daily Spin per user per IST day under concurrency (one draw stands, one Points row), duel stored with the
// served versions, a concurrent double submit finishes once, daily duel Points summed in the IST day.
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { FakeClock, startPostgres, type StartedDb } from "@heymey/testing";
import { createEconomyProgression } from "../../src/modules/economy/index.js";
import { createGames } from "../../src/modules/games/index.js";
import { fakeQuestions } from "./games.fakes.js";

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

function build(clock: FakeClock) {
  const economy = createEconomyProgression({
    prisma, clock,
    people: { profile: async () => null },
    learning: { subjectFullyLit: async () => false },
  });
  let n = 0;
  const games = createGames({ prisma, clock, rewards: { awardPoints: (a) => economy.awardGamePoints(a) }, questions: fakeQuestions(), randomInt: () => (n++ * 37) % 100 });
  return { games, economy };
}

describe("games on Postgres", () => {
  it("concurrent spins on one IST day draw once and credit Points once", async () => {
    const clock = new FakeClock("2026-11-25T04:30:00.000Z");
    const { games, economy } = build(clock);
    const u = randomUUID();
    const results = await Promise.all(Array.from({ length: 5 }, () => games.spin(u)));
    expect(new Set(results.map((r) => r.prize.id)).size).toBe(1);
    expect(await prisma.dailySpin.count({ where: { userId: u } })).toBe(1);
    const row = await prisma.dailySpin.findFirstOrThrow({ where: { userId: u } });
    expect(row).toMatchObject({ day: "2026-11-25", oddsVersion: 1, prizeId: results[0]?.prize.id });
    expect((await economy.progress(u)).points).toBe(row.amount);
    expect(await prisma.pointsLedger.count({ where: { userId: u } })).toBe(row.amount > 0 ? 1 : 0);
    expect((await games.dailySpinState(u)).spunToday).toBe(true);
  });

  it("a duel keeps the served versions, finishes once under a double submit, and its Points count for the IST day", async () => {
    const clock = new FakeClock("2026-11-25T04:30:00.000Z");
    const { games, economy } = build(clock);
    const u = randomUUID();
    const d = await games.startDuel(u, "g4");
    const stored = await prisma.confidenceDuel.findUniqueOrThrow({ where: { id: d.duelId } });
    expect(stored.questions).toEqual(d.questions.map((q) => ({ questionId: q.id, version: 1 })));
    clock.advance(30_000);
    const answers = d.questions.map((q) => ({ questionId: q.id, optionId: "a", confidence: 3 }));
    const settled = await Promise.allSettled([games.submitDuel(u, d.duelId, { answers }), games.submitDuel(u, d.duelId, { answers })]);
    expect(settled.filter((s) => s.status === "fulfilled")).toHaveLength(1);
    expect(settled.find((s) => s.status === "rejected")).toMatchObject({ reason: { code: "DUEL_ALREADY_SUBMITTED" } });
    expect((await economy.progress(u)).points).toBe(25);
    const next = await games.startDuel(u, "g4");
    expect(next.pointsToday).toBe(25);
    clock.set("2026-11-25T19:00:00.000Z"); // 00:30 IST next day: a new day (and asleep)
    await expect(games.startDuel(u, "g4")).rejects.toMatchObject({ code: "GAMES_SLEEPING" });
  });
});
