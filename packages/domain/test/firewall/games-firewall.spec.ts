// PERMANENT (BOLT-0115). Games pay Points only, through the economy firewall API; the odds shown are the odds drawn;
// no game request takes a stake. Never delete, skip or weaken (blueprint §26.2 rule 3). IDs live in MANIFEST.json.
import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import { FakeClock } from "@heymey/testing";
import { SubmitDuelBody, routes } from "@heymey/contracts";
import { createEconomyProgression } from "../../src/modules/economy/index.js";
import { DAILY_SPIN_ODDS, DUEL_RULES, SPIN_TOTAL_WEIGHT, createGames, drawSpin, duelAward, spinOdds } from "../../src/modules/games/index.js";
import { FakeEconomyRepo, fakePeople } from "../modules/economy.fakes.js";
import { FakeGamesRepo, FakeRewards, fakeQuestions } from "../modules/games.fakes.js";

const firewallError = expect.objectContaining({ code: "FIREWALL_VIOLATION" });
const U = "0199f5a0-0000-7000-8000-000000000001";
const gamesDir = join(import.meta.dirname, "../../src/modules/games");
function code(dir: string): string {
  return readdirSync(dir)
    .flatMap((f) => {
      const p = join(dir, f);
      return statSync(p).isDirectory() ? [code(p)] : p.endsWith(".ts") ? [readFileSync(p, "utf8").replace(/\/\*[\s\S]*?\*\/|\/\/.*$/gm, "")] : [];
    })
    .join("\n");
}

describe("games firewall", () => {
  it("FW-026 Games credit only Points, through the economy firewall API: never Sparks, never XP", async () => {
    const repo = new FakeEconomyRepo();
    const economy = createEconomyProgression({ repository: repo, clock: new FakeClock("2026-11-25T04:30:00.000Z"), people: fakePeople({}), learning: { subjectFullyLit: async () => false } });
    expect(await economy.awardGamePoints({ userId: U, game: "daily_spin", amount: 20, sourceKey: "daily_spin:u:2026-11-25" })).toBe(true);
    expect(await economy.awardGamePoints({ userId: U, game: "daily_spin", amount: 20, sourceKey: "daily_spin:u:2026-11-25" })).toBe(false);
    expect(repo.points.map((p) => [p.reason, p.delta])).toEqual([["game:daily_spin", 20]]);
    expect(repo.xp).toEqual([]);
    for (const amount of [-5, 1.5, Number.NaN]) {
      await expect(economy.awardGamePoints({ userId: U, game: "daily_spin", amount, sourceKey: `x${amount}` })).rejects.toThrow(firewallError);
    }
    await expect(economy.awardGamePoints({ userId: U, game: "", amount: 5, sourceKey: "empty" })).rejects.toThrow(firewallError);
    // The games module has no path to Sparks or XP: it does not name them, and its prize table holds only Points.
    expect(code(gamesDir)).not.toMatch(/sparks|xpAward|awardXp/i);
    expect(new Set(DAILY_SPIN_ODDS.prizes.map((p) => p.kind))).toEqual(new Set(["points", "none"]));
  });

  it("FW-027 The Daily Spin odds published by the API are exactly the table the draw uses", async () => {
    // Every possible CSPRNG roll, counted per prize, gives the published percentage.
    const counts = new Map<string, number>();
    for (let roll = 0; roll < SPIN_TOTAL_WEIGHT; roll++) counts.set(drawSpin(roll).id, (counts.get(drawSpin(roll).id) ?? 0) + 1);
    const published = spinOdds();
    expect(published.reduce((s, p) => s + p.percent, 0)).toBeCloseTo(100, 6);
    for (const p of published) expect(((counts.get(p.id) ?? 0) * 100) / SPIN_TOTAL_WEIGHT).toBeCloseTo(p.percent, 2);
    expect([...counts.keys()].sort()).toEqual(published.map((p) => p.id).sort());
    // Both read endpoints and the spin result serve that same table.
    const games = createGames({ repository: new FakeGamesRepo(), clock: new FakeClock("2026-11-25T04:30:00.000Z"), rewards: new FakeRewards(), questions: fakeQuestions(), randomInt: () => 0 });
    expect(games.rules().dailySpin).toEqual({ oddsVersion: DAILY_SPIN_ODDS.version, spinsPerDay: 1, prizes: published });
    expect((await games.dailySpinState(U)).prizes).toEqual(published);
    expect((await games.spin(U)).odds).toEqual(published);
    expect(Object.isFrozen(DAILY_SPIN_ODDS) && Object.isFrozen(DAILY_SPIN_ODDS.prizes)).toBe(true);
  });

  it("FW-028 No game route or request accepts a stake, entry fee, bet or payment", () => {
    const money = /stake|wager|\bbet\b|fee|sparks|price|payment|purchase|amount/i;
    const spec = JSON.parse(readFileSync(join(import.meta.dirname, "../../../contracts/openapi/openapi.json"), "utf8"));
    const schemas = spec.components.schemas as Record<string, unknown>;
    // Every property name reachable from a request: parameters and body, following $refs.
    const names = (node: unknown, seen = new Set<string>()): string[] => {
      if (!node || typeof node !== "object") return [];
      const o = node as Record<string, unknown>;
      if (typeof o.$ref === "string") {
        const ref = o.$ref.split("/").pop() as string;
        if (seen.has(ref)) return [];
        seen.add(ref);
        return names(schemas[ref], seen);
      }
      const own = o.properties && typeof o.properties === "object" ? Object.keys(o.properties) : [];
      return [...own, ...Object.values(o).flatMap((v) => names(v, seen))];
    };
    const gamePaths = Object.keys(spec.paths).filter((k) => k.startsWith("/v1/games"));
    expect(gamePaths.length).toBeGreaterThanOrEqual(4);
    expect(routes.filter((r) => r.path.startsWith("/v1/games")).every((r) => r.auth !== "desk")).toBe(true);
    for (const path of gamePaths) {
      for (const [method, op] of Object.entries(spec.paths[path] as Record<string, { parameters?: { name: string }[]; requestBody?: unknown }>)) {
        const inputs = [...(op.parameters ?? []).map((x) => x.name), ...names(op.requestBody)];
        expect(inputs.filter((n) => money.test(n)), `${method} ${path}`).toEqual([]);
      }
    }
    // The only game request body is strict: a smuggled stake is refused, not ignored.
    expect(SubmitDuelBody.safeParse({ answers: [{ questionId: U, optionId: "a", confidence: 1 }], stake: 10 }).success).toBe(false);
    expect(SubmitDuelBody.safeParse({ answers: [{ questionId: U, optionId: "a", confidence: 1, sparks: 1 }] }).success).toBe(false);
  });

  it("FW-029 Game Points are capped per day, never negative, and a duel never takes Points away", () => {
    expect(Object.isFrozen(DUEL_RULES) && Object.isFrozen(DUEL_RULES.scoring)).toBe(true);
    for (const r of DUEL_RULES.scoring) expect(Math.min(r.correctPoints, r.wrongPoints)).toBeGreaterThanOrEqual(0);
    for (const earned of [0, 30, 50, 80]) {
      for (const score of [0, 10, 25]) {
        const { points } = duelAward(score, 60_000, earned);
        expect(points).toBeGreaterThanOrEqual(0);
        expect(points + Math.min(earned, DUEL_RULES.dailyPointsCap)).toBeLessThanOrEqual(DUEL_RULES.dailyPointsCap);
      }
    }
  });
});
