import { describe, expect, it } from "vitest";
import { isImplemented } from "../src/processors/index.js";
import { createSundayReportProcessor, sundayReportPush } from "../src/processors/readiness.js";
import { QUEUES } from "../src/queues/registry.js";

describe("readiness.sunday-report processor (BOLT-0013)", () => {
  it("is implemented and scheduled Sunday 08:00 (the scheduler applies Asia/Kolkata)", () => {
    expect(isImplemented("readiness.sunday-report")).toBe(true);
    expect(QUEUES.find((q) => q.name === "readiness.sunday-report")?.repeat).toBe("0 8 * * 0");
  });

  it("calls the one use case and hands each new report to the push hook", async () => {
    const result = { weekStart: "2026-11-02", users: 2, created: 1, existing: 1, failed: 0 };
    const pushes: unknown[] = [];
    const run = createSundayReportProcessor({
      readiness: {
        buildSundayReports: async (onCreated) => {
          await onCreated?.("u1", "r1");
          return result;
        },
      },
      notify: sundayReportPush({ enqueue: async (input) => void pushes.push(input) }),
    });
    expect(await run()).toEqual(result);
    expect(pushes).toEqual([{ userId: "u1", category: "study", templateKey: "readiness.sunday_report", dedupeKey: "sunday-report:r1" }]);
  });
});
