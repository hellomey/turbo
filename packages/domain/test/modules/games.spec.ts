import { readFileSync } from "node:fs";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import { FakeClock } from "@heymey/testing";
import { createGames, DAILY_SPIN_ODDS, DUEL_RULES, drawSpin, spinOdds } from "../../src/modules/games/index.js";
import { FakeGamesRepo, FakeRewards, fakeQuestions } from "./games.fakes.js";

const U = "0199f5a0-0000-7000-8000-0000000000aa";
const OTHER = "0199f5a0-0000-7000-8000-0000000000bb";
// 10:00 IST on 25 Nov 2026.
const MORNING = "2026-11-25T04:30:00.000Z";

function setup(opts: { at?: string; rolls?: number[]; questions?: number } = {}) {
  const clock = new FakeClock(opts.at ?? MORNING);
  const repo = new FakeGamesRepo();
  const rewards = new FakeRewards();
  const questions = fakeQuestions(opts.questions ?? 5);
  const rolls = [...(opts.rolls ?? [])];
  const asked: number[] = [];
  const games = createGames({
    repository: repo, clock, rewards, questions,
    randomInt: (max) => {
      asked.push(max);
      return rolls.shift() ?? 0;
    },
  });
  return { clock, repo, rewards, questions, games, asked };
}

const allRight = (ids: string[], confidence: 1 | 2 | 3) => ids.map((questionId) => ({ questionId, optionId: "a", confidence }));
const allWrong = (ids: string[], confidence: 1 | 2 | 3) => ids.map((questionId) => ({ questionId, optionId: "b", confidence }));

describe("Daily Spin", () => {
  it("publishes exact odds that add up to 100% and prizes that are Points or nothing", () => {
    const { games } = setup();
    const odds = games.rules().dailySpin.prizes;
    expect(odds.map((p) => [p.id, p.percent])).toEqual([["points_5", 40], ["points_10", 30], ["points_20", 15], ["points_50", 5], ["none", 10]]);
    expect(odds.reduce((s, p) => s + p.percent, 0)).toBe(100);
    expect(new Set(odds.map((p) => p.kind))).toEqual(new Set(["points", "none"]));
  });

  it("maps every roll of the CSPRNG to the prize whose weight band holds it", () => {
    expect(drawSpin(0).id).toBe("points_5");
    expect(drawSpin(39).id).toBe("points_5");
    expect(drawSpin(40).id).toBe("points_10");
    expect(drawSpin(69).id).toBe("points_10");
    expect(drawSpin(70).id).toBe("points_20");
    expect(drawSpin(85).id).toBe("points_50");
    expect(drawSpin(90).id).toBe("none");
    expect(drawSpin(99).id).toBe("none");
    expect(() => drawSpin(100)).toThrow();
    expect(() => drawSpin(-1)).toThrow();
  });

  it("gives one spin per IST day: the server draws, credits Points once and stores the spin with its odds version", async () => {
    const { games, repo, rewards, asked } = setup({ rolls: [72] });
    const before = await games.dailySpinState(U);
    expect(before).toMatchObject({ spunToday: false, todaysPrize: null, asleep: false, oddsVersion: DAILY_SPIN_ODDS.version });

    const r = await games.spin(U);
    expect(r).toMatchObject({ prize: { id: "points_20", amount: 20 }, alreadySpun: false, oddsVersion: 1 });
    // Next spin: 5 AM IST tomorrow (games sleep until 5).
    expect(r.nextSpinAt).toBe("2026-11-25T23:30:00.000Z");
    expect(asked).toEqual([100]);
    expect(rewards.awards).toEqual([{ userId: U, game: "daily_spin", amount: 20, sourceKey: `daily_spin:${U}:2026-11-25` }]);
    expect(repo.spins).toMatchObject([{ userId: U, day: "2026-11-25", prizeId: "points_20", amount: 20, roll: 72, oddsVersion: 1 }]);

    const again = await games.spin(U);
    expect(again).toMatchObject({ prize: { id: "points_20" }, alreadySpun: true });
    expect(asked).toEqual([100]);
    expect(rewards.awards).toHaveLength(1);
    expect(await games.dailySpinState(U)).toMatchObject({ spunToday: true, todaysPrize: { id: "points_20" } });
  });

  it("credits nothing for 'Better luck tomorrow'", async () => {
    const { games, rewards } = setup({ rolls: [95] });
    expect((await games.spin(U)).prize).toMatchObject({ id: "none", kind: "none", amount: 0 });
    expect(rewards.awards).toEqual([]);
  });

  it("opens a new spin on the next IST day", async () => {
    const { games, clock } = setup({ rolls: [0, 45] });
    await games.spin(U);
    clock.set("2026-11-26T00:00:00.000Z"); // 05:30 IST next day
    expect((await games.dailySpinState(U)).spunToday).toBe(false);
    expect((await games.spin(U)).prize.id).toBe("points_10");
  });

  it("sleeps 12 AM to 5 AM IST: no spin, and the state says when it opens", async () => {
    const { games } = setup({ at: "2026-11-25T20:30:00.000Z" }); // 02:00 IST on 26 Nov
    expect(await games.dailySpinState(U)).toMatchObject({ asleep: true, nextSpinAt: "2026-11-25T23:30:00.000Z" });
    await expect(games.spin(U)).rejects.toMatchObject({ code: "GAMES_SLEEPING" });
  });

  it("re-credits a spin whose Points write failed, without a second draw", async () => {
    const { games, rewards, asked } = setup({ rolls: [0] });
    const award = rewards.awardPoints.bind(rewards);
    rewards.awardPoints = async () => {
      throw new Error("db down");
    };
    await expect(games.spin(U)).rejects.toThrow("db down");
    rewards.awardPoints = award;
    expect((await games.spin(U)).alreadySpun).toBe(true);
    expect(rewards.awards).toHaveLength(1);
    expect(asked).toEqual([100]);
  });

  it("a spin that loses a race to a parallel request returns the winner's prize", async () => {
    const { games, repo, rewards } = setup({ rolls: [0] });
    const insert = repo.insertSpin.bind(repo);
    repo.insertSpin = async (row) => {
      await insert({ ...row, prizeId: "points_50", amount: 50, roll: 85 }); // the parallel request got there first
      return false;
    };
    expect(await games.spin(U)).toMatchObject({ prize: { id: "points_50" }, alreadySpun: true });
    expect(rewards.awards.map((a) => a.amount)).toEqual([50]);
  });
});

describe("Confidence Duel", () => {
  it("serves published questions without answers, plus the scoring rules", async () => {
    const { games, repo } = setup();
    const d = await games.startDuel(U, "g4");
    expect(d.questions).toHaveLength(5);
    expect(JSON.stringify(d.questions)).not.toMatch(/correctOptionIds|explanation/);
    expect(d.rules).toMatchObject({ questionsPerDuel: 5, timeLimitSeconds: 150, minSecondsForPoints: 10, graceSeconds: 60, dailyPointsCap: 50 });
    expect(d.rules.scoring).toEqual([
      { confidence: 1, label: "Not sure", correctPoints: 2, wrongPoints: 1 },
      { confidence: 2, label: "Fairly sure", correctPoints: 3, wrongPoints: 0 },
      { confidence: 3, label: "Certain", correctPoints: 5, wrongPoints: 0 },
    ]);
    expect(d.pointsToday).toBe(0);
    expect(repo.duels[0]).toMatchObject({ userId: U, examCode: "g4", questions: d.questions.map((q) => ({ questionId: q.id, version: 1 })) });
  });

  it("refuses to start with too few questions, and while games sleep", async () => {
    await expect(setup({ questions: 3 }).games.startDuel(U, "g4")).rejects.toMatchObject({ code: "DUEL_NO_QUESTIONS" });
    await expect(setup({ at: "2026-11-25T19:00:00.000Z" }).games.startDuel(U, "g4")).rejects.toMatchObject({ code: "GAMES_SLEEPING" });
  });

  it("rewards calibration: certain and right scores most, certain and wrong scores 0, never negative", async () => {
    const s = setup();
    const d = await s.games.startDuel(U, "g4");
    const ids = d.questions.map((q) => q.id);
    s.clock.advance(60_000);
    const r = await s.games.submitDuel(U, d.duelId, { answers: [...allRight(ids.slice(0, 2), 3), ...allWrong(ids.slice(2, 4), 3), ...allWrong(ids.slice(4), 1)] });
    expect(r.results.map((x) => [x.correct, x.points])).toEqual([[true, 5], [true, 5], [false, 0], [false, 0], [false, 1]]);
    expect(r.results[0]).toMatchObject({ correctOptionIds: ["a"], chosenOptionId: "a", confidence: 3, explanationMarkdown: "Because 1" });
    expect(r).toMatchObject({ score: 11, pointsAwarded: 11, pointsWithheld: null, pointsToday: 11, dailyPointsCap: 50 });
    expect(s.rewards.awards).toEqual([{ userId: U, game: "confidence_duel", amount: 11, sourceKey: `confidence_duel:${d.duelId}` }]);
  });

  it("counts a missing answer as wrong with 0 Points and ignores answers to questions not in the duel", async () => {
    const s = setup();
    const d = await s.games.startDuel(U, "g4");
    s.clock.advance(30_000);
    const r = await s.games.submitDuel(U, d.duelId, {
      answers: [{ questionId: (d.questions[0]?.id as string), optionId: "a", confidence: 2 }, { questionId: "0199f5a1-0000-7000-8000-00000000ffff", optionId: "a", confidence: 3 }],
    });
    expect(r.results).toHaveLength(5);
    expect(r.results.slice(1).every((x) => x.chosenOptionId === null && x.confidence === null && x.points === 0 && !x.correct)).toBe(true);
    expect(r.score).toBe(3);
  });

  it("uses only the first answer when a question is answered twice", async () => {
    const s = setup();
    const d = await s.games.startDuel(U, "g4");
    s.clock.advance(30_000);
    const q = (d.questions[0]?.id as string);
    const r = await s.games.submitDuel(U, d.duelId, { answers: [{ questionId: q, optionId: "b", confidence: 1 }, { questionId: q, optionId: "a", confidence: 3 }] });
    expect(r.results[0]).toMatchObject({ chosenOptionId: "b", points: 1 });
  });

  it("cheating: answers sent too fast are graded but earn no Points", async () => {
    const s = setup();
    const d = await s.games.startDuel(U, "g4");
    s.clock.advance(9_000);
    const r = await s.games.submitDuel(U, d.duelId, { answers: allRight(d.questions.map((q) => q.id), 3) });
    expect(r).toMatchObject({ score: 25, pointsAwarded: 0, pointsWithheld: "too_fast" });
    expect(s.rewards.awards).toEqual([]);
  });

  it("reconnect: a submit within the 60 s grace after the limit still earns; later earns nothing", async () => {
    const s = setup();
    const d1 = await s.games.startDuel(U, "g4");
    s.clock.advance((150 + 60) * 1000);
    expect((await s.games.submitDuel(U, d1.duelId, { answers: allRight(d1.questions.map((q) => q.id), 1) })).pointsAwarded).toBe(10);
    const d2 = await s.games.startDuel(U, "g4");
    s.clock.advance((150 + 60) * 1000 + 1);
    expect(await s.games.submitDuel(U, d2.duelId, { answers: allRight(d2.questions.map((q) => q.id), 1) })).toMatchObject({ pointsAwarded: 0, pointsWithheld: "too_late" });
  });

  it("cheating: a replayed submit is refused and credits nothing twice", async () => {
    const s = setup();
    const d = await s.games.startDuel(U, "g4");
    s.clock.advance(30_000);
    const body = { answers: allRight(d.questions.map((q) => q.id), 3) };
    await s.games.submitDuel(U, d.duelId, body);
    await expect(s.games.submitDuel(U, d.duelId, body)).rejects.toMatchObject({ code: "DUEL_ALREADY_SUBMITTED" });
    expect(s.rewards.awards).toHaveLength(1);
  });

  it("someone else's duel, or an unknown one, is not found", async () => {
    const s = setup();
    const d = await s.games.startDuel(U, "g4");
    await expect(s.games.submitDuel(OTHER, d.duelId, { answers: [] })).rejects.toMatchObject({ code: "DUEL_NOT_FOUND" });
    await expect(s.games.submitDuel(U, "0199f5a0-0000-7000-8000-00000000dead", { answers: [] })).rejects.toMatchObject({ code: "DUEL_NOT_FOUND" });
  });

  it("caps duel Points at 50 a day (IST): the rest is withheld, and the next day starts fresh", async () => {
    const s = setup();
    const play = async () => {
      const d = await s.games.startDuel(U, "g4");
      s.clock.advance(30_000);
      return s.games.submitDuel(U, d.duelId, { answers: allRight(d.questions.map((q) => q.id), 3) });
    };
    expect((await play()).pointsAwarded).toBe(25);
    expect((await play()).pointsAwarded).toBe(25);
    expect(await play()).toMatchObject({ score: 25, pointsAwarded: 0, pointsWithheld: "daily_cap", pointsToday: 50 });
    expect(s.rewards.awards.reduce((n, a) => n + a.amount, 0)).toBe(50);
    s.clock.set("2026-11-26T04:30:00.000Z");
    expect((await play()).pointsAwarded).toBe(25);
  });

  it("partly capped: credits only what fits under the cap", async () => {
    const s = setup();
    const play = async (conf: 1 | 3) => {
      const d = await s.games.startDuel(U, "g4");
      s.clock.advance(30_000);
      return s.games.submitDuel(U, d.duelId, { answers: allRight(d.questions.map((q) => q.id), conf) });
    };
    await play(3);
    await play(1); // 35
    expect(await play(3)).toMatchObject({ score: 25, pointsAwarded: 15, pointsWithheld: "daily_cap", pointsToday: 50 });
  });

  it("grades against the version that was served", async () => {
    const s = setup();
    const d = await s.games.startDuel(U, "g4");
    (s.questions.bank[0] as (typeof s.questions.bank)[number]).question.version = 2; // a correction published after the duel started
    s.clock.advance(30_000);
    const r = await s.games.submitDuel(U, d.duelId, { answers: allRight(d.questions.map((q) => q.id), 2) });
    // The stale version can no longer be read: that question is left out of the score rather than guessed.
    expect(r.results).toHaveLength(4);
  });
});

describe("Game rules", () => {
  it("say there is no stake and prizes are Points only", () => {
    const r = setup().games.rules();
    expect(r).toMatchObject({ stake: "none", prizeCurrencies: ["POINTS"], sleep: { from: "00:00", to: "05:00", timeZone: "Asia/Kolkata" } });
    expect(r.dailySpin.spinsPerDay).toBe(1);
  });
});

describe("marketing /rules page", () => {
  it("states the same odds, scoring and limits the server uses", () => {
    const page = readFileSync(join(import.meta.dirname, "../../../../apps/marketing/app/rules/page.tsx"), "utf8");
    for (const p of spinOdds()) expect(page, p.label).toContain(`{ label: "${p.label}", percent: ${p.percent} }`);
    expect(page).toContain(`odds table version ${DAILY_SPIN_ODDS.version}`);
    for (const r of DUEL_RULES.scoring) expect(page, r.label).toContain(`{ label: "${r.label}", right: ${r.correctPoints}, wrong: ${r.wrongPoints} }`);
    expect(page).toContain(`up to ${DUEL_RULES.dailyPointsCap} Points a day`);
    expect(page).toContain(`${DUEL_RULES.timeLimitSeconds}-second clock`);
    expect(page).toContain(`within ${DUEL_RULES.minSecondsForPoints} seconds`);
    expect(page).toContain(`${DUEL_RULES.graceSeconds} extra seconds`);
    expect(page).toContain("<DraftNotice />");
  });
});
