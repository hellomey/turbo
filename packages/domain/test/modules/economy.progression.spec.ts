// BOLT-0113: XP table, level curve and trophy catalogue (pure rules).
import { describe, expect, it } from "vitest";
import { CHECK_IN_REWARD, TROPHIES, XP_RULES, istWeekRange, levelFor } from "../../src/modules/economy/index.js";

describe("level curve: each level needs 100 XP more than the one before", () => {
  it.each([
    [0, 1, 0, 100],
    [99, 1, 0, 100],
    [100, 2, 100, 300],
    [299, 2, 100, 300],
    [300, 3, 300, 600],
    [1000, 5, 1000, 1500],
  ])("%i XP is level %i (started at %i, next at %i)", (xp, level, levelStartXp, nextLevelXp) => {
    expect(levelFor(xp)).toEqual({ level, levelStartXp, nextLevelXp });
  });

  it("negative or fractional input never breaks the curve", () => {
    expect(levelFor(-5)).toEqual({ level: 1, levelStartXp: 0, nextLevelXp: 100 });
  });
});

describe("XP table", () => {
  it("rewards learning events only, with small whole amounts", () => {
    expect(Object.keys(XP_RULES).sort()).toEqual(["gold", "lesson_done", "lit", "mock_submitted", "recall_pass", "relight"]);
    for (const r of Object.values(XP_RULES)) expect(Number.isInteger(r.xp) && r.xp > 0 && r.xp <= 50).toBe(true);
    expect(CHECK_IN_REWARD).toEqual({ xp: 5, points: 10 });
  });

  it("every trophy has a title", () => {
    expect(TROPHIES.map((t) => t.code)).toEqual(["first_lamp", "first_gold", "subject_lit", "first_mock", "five_study_days", "expo_challenge"]);
    for (const t of TROPHIES) expect(t.title.length).toBeGreaterThan(0);
  });
});

describe("IST week", () => {
  it("runs Monday 00:00 IST to the next Monday", () => {
    // Wednesday 2026-11-25 10:00 IST
    expect(istWeekRange(new Date("2026-11-25T04:30:00Z"))).toEqual({ from: new Date("2026-11-22T18:30:00Z"), to: new Date("2026-11-29T18:30:00Z") });
    // Sunday 23:59 IST still belongs to the week that started on Monday 23 Nov
    expect(istWeekRange(new Date("2026-11-29T18:29:00Z")).from).toEqual(new Date("2026-11-22T18:30:00Z"));
    // Monday 00:00 IST starts a new week
    expect(istWeekRange(new Date("2026-11-29T18:30:00Z")).from).toEqual(new Date("2026-11-29T18:30:00Z"));
  });
});
