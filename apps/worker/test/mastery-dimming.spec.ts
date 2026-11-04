import { describe, expect, it } from "vitest";
import { createMasteryDimmingProcessor } from "../src/processors/mastery-dimming.js";
import { isImplemented } from "../src/processors/index.js";
import { QUEUES } from "../src/queues/registry.js";

describe("mastery.dimming processor (BOLT-0009)", () => {
  it("is implemented, scheduled every 15 minutes, and calls the dimming use case", async () => {
    expect(isImplemented("mastery.dimming")).toBe(true);
    expect(QUEUES.find((q) => q.name === "mastery.dimming")?.repeat).toBe("*/15 * * * *");
    const result = { examined: 3, dimming: 2, dim: 1, steadyLost: 1, conflicts: 0 };
    let calls = 0;
    const run = createMasteryDimmingProcessor({ dimming: { run: async () => (calls++, result) } });
    expect(await run()).toEqual(result);
    expect(calls).toBe(1);
  });
});
