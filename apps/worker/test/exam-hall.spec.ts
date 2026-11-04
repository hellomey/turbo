// BOLT-0011: exam-hall worker processors call one use case each; both queues are registered and scheduled.
import { describe, expect, it } from "vitest";
import { createExamHallExpireProcessor, createExamHallRanksProcessor } from "../src/processors/exam-hall.js";
import { isImplemented } from "../src/processors/index.js";
import { QUEUES } from "../src/queues/registry.js";

describe("exam-hall processors", () => {
  it("expire and publish-ranks delegate to the module", async () => {
    expect(await createExamHallExpireProcessor({ expireOverdue: async () => ({ expired: 3 }) })()).toEqual({ expired: 3 });
    expect(await createExamHallRanksProcessor({ publishRanks: async () => ({ mocks: 1, rows: 9 }) })()).toEqual({ mocks: 1, rows: 9 });
  });

  it("queues are registered with their schedules and implemented", () => {
    expect(QUEUES.find((q) => q.name === "exam-hall.expire")).toMatchObject({ owner: "exam-hall", repeat: "*/5 * * * *" });
    expect(QUEUES.find((q) => q.name === "exam-hall.publish-ranks")).toMatchObject({ owner: "exam-hall", repeat: "*/10 * * * *" });
    expect(isImplemented("exam-hall.expire") && isImplemented("exam-hall.publish-ranks")).toBe(true);
  });
});
