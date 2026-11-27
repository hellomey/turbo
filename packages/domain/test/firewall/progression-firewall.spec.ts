// PERMANENT (BOLT-0113). Points are never bought; check-in and games never credit Sparks; XP comes only from learning.
// Never delete, skip or weaken (blueprint §26.2 rule 3). IDs live in MANIFEST.json.
import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import { CHECK_IN_REWARD, XP_RULES, assertPointsReason, assertSparksSource } from "../../src/modules/economy/index.js";
import { FakeClock } from "@heymey/testing";
import { createEconomyProgression } from "../../src/modules/economy/index.js";
import { FakeEconomyRepo, fakePeople } from "../modules/economy.fakes.js";

const firewallError = expect.objectContaining({ code: "FIREWALL_VIOLATION" });
const modules = join(__dirname, "../../src/modules");
function sources(dir: string): string[] {
  return readdirSync(dir).flatMap((f) => {
    const p = join(dir, f);
    return statSync(p).isDirectory() ? sources(p) : p.endsWith(".ts") ? [readFileSync(p, "utf8")] : [];
  });
}

describe("progression firewall", () => {
  it("FW-023 Points can never be bought: no purchase, store or Sparks reason is accepted, and billing never touches Points", () => {
    for (const reason of ["purchase", "razorpay", "google_play", "store:pro", "sparks", "convert:sparks", "game:", "", "CHECK_IN"]) {
      expect(() => assertPointsReason(reason), reason).toThrow(firewallError);
    }
    for (const reason of ["check_in", "game:daily-spin", "help_answer", "spend:avatar-frame"]) expect(() => assertPointsReason(reason)).not.toThrow();
    expect(sources(join(modules, "billing")).join("\n")).not.toMatch(/points|xpAward|userTrophy/i);
  });

  it("FW-024 Daily check-in and games never credit Sparks", async () => {
    for (const source of ["check_in", "game", "game:daily-spin", "trophy", "leaderboard"]) expect(() => assertSparksSource(source)).toThrow(firewallError);
    expect(Object.keys(CHECK_IN_REWARD).sort()).toEqual(["points", "xp"]);
    const progression = [
      ...sources(join(modules, "economy/application")),
      readFileSync(join(modules, "economy/domain/progression.ts"), "utf8"),
      ...sources(join(modules, "economy/infrastructure")),
    ].join("\n");
    expect(progression).not.toMatch(/sparksLedger|SparksSource|sparks_credited/i);
    // A check-in writes only Points and XP.
    const repo = new FakeEconomyRepo();
    const api = createEconomyProgression({ repository: repo, clock: new FakeClock("2026-11-25T04:30:00.000Z"), people: fakePeople({}), learning: { subjectFullyLit: async () => false } });
    await api.checkIn("0199f5a0-0000-7000-8000-000000000001");
    expect(repo.points.map((p) => p.reason)).toEqual(["check_in"]);
  });

  it("FW-025 XP is awarded only for learning events and check-in, never for a purchase or a game stake", () => {
    expect(Object.keys(XP_RULES).sort()).toEqual(["gold", "lesson_done", "lit", "mock_submitted", "recall_pass", "relight"]);
    expect(JSON.stringify(XP_RULES)).not.toMatch(/purchase|sparks|stake|buy|game|store/i);
  });
});
