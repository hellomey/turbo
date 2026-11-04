// BOLT-0014: notifications processors are thin and validate their payloads (blueprint §19.8 Q78, §17.5).
import { describe, expect, it } from "vitest";
import { createExamAlertFanOutProcessor, createPushSendProcessor, createReleaseHeldProcessor } from "../src/processors/notifications.js";
import { createUsersDeletionProcessor } from "../src/processors/users-deletion.js";
import { QUEUES } from "../src/queues/registry.js";

describe("notifications processors", () => {
  it("push.send calls send with the SendLog id; rejects bad payloads", async () => {
    const run = createPushSendProcessor({ notifications: { send: async (id) => `sent:${id}` } });
    expect(await run({ sendLogId: "abc" })).toEqual({ status: "sent:abc" });
    await expect(run({})).rejects.toThrow(/sendLogId/);
  });

  it("exam-alert fan-out joins followers (exams) with notifications", async () => {
    const run = createExamAlertFanOutProcessor({
      followersOf: async (code) => (code === "tnpsc-group-4" ? ["u1", "u2"] : []),
      notifications: { enqueueExamAlert: async (_a, ids) => ({ queued: ids.length }) },
    });
    expect(await run({ alertId: "a1", examCode: "tnpsc-group-4" })).toEqual({ followers: 2, outcomes: { queued: 2 } });
    await expect(run({ alertId: 1 })).rejects.toThrow(/bad payload/);
  });

  it("release-held returns the count", async () => {
    expect(await createReleaseHeldProcessor({ notifications: { releaseHeld: async () => 4 } })()).toEqual({ released: 4 });
  });

  it("account deletion removes push tokens (S16)", async () => {
    const forgotten: string[] = [];
    const run = createUsersDeletionProcessor({
      users: { eraseDueAccounts: async () => ["u1"] },
      sessions: { revokeAllForUser: async () => 1 },
      otps: { purgeOtpCodesFor: async () => 0 },
      pushTokens: { forgetUser: async (id) => (forgotten.push(id), 1) },
    });
    await run();
    expect(forgotten).toEqual(["u1"]);
  });

  it("registry: release-held runs every 15 min; exam-alert has no schedule", () => {
    expect(QUEUES.find((q) => q.name === "notifications.release-held")).toMatchObject({ owner: "notifications", repeat: "*/15 * * * *" });
    expect(QUEUES.find((q) => q.name === "notifications.exam-alert")?.repeat).toBeUndefined();
  });
});
