import { describe, expect, it } from "vitest";
import { createPlanDateChangedProcessor, createPlanRebalanceProcessor } from "../src/processors/plan.js";
import { isImplemented } from "../src/processors/index.js";
import { QUEUES } from "../src/queues/registry.js";

describe("plan processors (BOLT-0012)", () => {
  it("plan.rebalance is implemented, runs 02:30 IST and calls rebalanceDue", async () => {
    expect(isImplemented("plan.rebalance")).toBe(true);
    expect(QUEUES.find((q) => q.name === "plan.rebalance")?.repeat).toBe("30 2 * * *");
    const run = createPlanRebalanceProcessor({ rebalanceDue: async () => ({ checked: 4, rebalanced: 1 }) });
    expect(await run()).toEqual({ checked: 4, rebalanced: 1 });
  });

  it("exams.date-changed passes examCode + cycleId to plan and refuses a bad payload", async () => {
    expect(isImplemented("exams.date-changed")).toBe(true);
    const seen: unknown[] = [];
    const run = createPlanDateChangedProcessor({ onDateChanged: async (e) => (seen.push(e), { plans: 2 }) });
    const cycleId = "0199f5a0-0000-7000-8000-000000000001";
    expect(await run({ examCode: "tnpsc-group-4", cycleId, stageCode: "written", date: "2027-06-01" })).toEqual({ plans: 2 });
    expect(seen).toEqual([{ examCode: "tnpsc-group-4", cycleId }]);
    await expect(run({ examCode: "x", cycleId: "nope" })).rejects.toThrow("bad payload");
    await expect(run(null)).rejects.toThrow("bad payload");
  });
});
