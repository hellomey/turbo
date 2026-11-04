// Money/game firewall for the Career Ladder (blueprint §5.2, §5.3 rule 4, §39). Add, never delete or weaken.
import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import { FakeClock } from "@heymey/testing";
import { computeRank, xpOf } from "../../src/modules/mastery/index.js";
import { U1, answersFor, makeMastery, topicId } from "../modules/mastery.fakes.js";

const masteryDir = join(import.meta.dirname, "../../src/modules/mastery");
/** Source code without comments (comments explain the firewall and name the forbidden words). */
const stripComments = (src: string) => src.replace(/\/\*[\s\S]*?\*\//g, "").replace(/^\s*\/\/.*$/gm, "");
const sources = (dir: string): string[] =>
  readdirSync(dir).flatMap((f) => {
    const p = join(dir, f);
    return statSync(p).isDirectory() ? sources(p) : p.endsWith(".ts") ? [stripComments(readFileSync(p, "utf8"))] : [];
  });

describe("money / game firewall: Career Ladder", () => {
  it("FW-020 rank comes only from ring counts; entitlement or purchase input cannot change it", () => {
    const totals = { totalLamps: 40, lit: 12, steadySteps: 9, gold: 3 };
    const withPro = { ...totals, pro: true, sparks: 5000, entitlement: "pro_yearly" } as typeof totals;
    expect(computeRank(withPro)).toEqual(computeRank(totals));
    expect(computeRank.length).toBe(1);
    const code = sources(masteryDir).join("\n");
    expect(code).not.toMatch(/\b(billing|entitlement|economy|sparks|purchase|studyHours|focusHours)\b/i);
  });

  it("FW-021 XP has no ledger and no conversion path to Points or Sparks", () => {
    expect(xpOf({ lit: 1, steadySteps: 1, gold: 1 })).toBe(35);
    const code = sources(masteryDir).join("\n");
    expect(code).not.toMatch(/ledger|points|convert/i);
    const json = JSON.parse(readFileSync(join(masteryDir, "module.json"), "utf8")) as { dependsOn: string[]; owns: string[] };
    expect(json.dependsOn).not.toContain("economy");
    expect(json.dependsOn).not.toContain("billing");
    expect(json.owns.join(",")).not.toMatch(/ledger/i);
  });

  it("FW-022 offline-synced actions never produce ranked rewards (no rank-up, study progress only)", async () => {
    const clock = new FakeClock("2026-11-02T04:30:00.000Z");
    const { api, published } = makeMastery(clock);
    const T = topicId(1);
    await api.syncAction(U1, { clientActionId: "0199f5a0-cccc-7000-8000-000000000001", clientAt: clock.now().toISOString(), kind: "lesson_complete", topicId: T, via: "lesson" });
    const qs = Array.from({ length: 3 }, (_, i) => `0199f5a0-0001-7000-9000-${String(i).padStart(12, "0")}`);
    const r = await api.syncAction(U1, {
      clientActionId: "0199f5a0-cccc-7000-8000-000000000002",
      clientAt: clock.now().toISOString(),
      kind: "topic_check",
      topicId: T,
      checkKind: "lit",
      answers: answersFor(qs, 3),
    });
    expect(r.status).toBe("accepted");
    expect(Object.keys(r).sort()).toEqual(["clientActionId", "errorCode", "status"]);
    expect(published.some((e) => e.type === "mastery.rank_up")).toBe(false);
  });
});
