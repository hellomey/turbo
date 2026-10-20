import { describe, expect, it } from "vitest";
import { createEmailOtpProcessor } from "../src/processors/email-otp.js";
import { IMPLEMENTED_QUEUES, bullConnection, isImplemented } from "../src/processors/index.js";
import { createUsersDeletionProcessor } from "../src/processors/users-deletion.js";
import { QUEUES } from "../src/queues/registry.js";

describe("email.otp processor", () => {
  const sent: { from: string; to: string; subject: string; text: string }[] = [];
  const run = createEmailOtpProcessor({ transport: { sendMail: async (m) => void sent.push(m) }, from: "HeyMey <no-reply@mail.heymey.app>" });

  it("sends the plain-text login code email", async () => {
    await run({ to: "asha@example.com", code: "482913", purpose: "login" });
    expect(sent.at(-1)).toEqual({
      from: "HeyMey <no-reply@mail.heymey.app>",
      to: "asha@example.com",
      subject: "Your HeyMey code",
      text: "Your HeyMey code is 482913. It expires in 10 minutes. Never share this code with anyone. If you did not ask for this, ignore this email.",
    });
    expect(Object.keys(sent.at(-1)!)).not.toContain("html"); // eslint-disable-line @typescript-eslint/no-non-null-assertion
  });

  it("delete_account variant says it confirms deletion; no links", async () => {
    await run({ to: "asha@example.com", code: "000123", purpose: "delete_account" });
    const text = sent.at(-1)?.text ?? "";
    expect(text).toContain("Your HeyMey code is 000123.");
    expect(text).toContain("confirms deleting your HeyMey account");
    expect(text).not.toMatch(/https?:\/\/|www\./);
  });

  it("rejects malformed jobs (so BullMQ records a failure) and sends nothing", async () => {
    const before = sent.length;
    await expect(run({ to: "a@b.c", code: "12", purpose: "login" })).rejects.toThrow("malformed");
    await expect(run(null)).rejects.toThrow();
    await expect(run({ to: "a@b.c", code: "123456", purpose: "other" })).rejects.toThrow();
    expect(sent.length).toBe(before);
  });
});

describe("users.deletion processor", () => {
  it("erases due accounts then revokes their sessions as the system", async () => {
    const revoked: [string, string, unknown][] = [];
    const run = createUsersDeletionProcessor({
      users: { eraseDueAccounts: async () => ["u1", "u2"] },
      sessions: { revokeAllForUser: async (id, reason, actor) => (revoked.push([id, reason, actor]), 1) },
    });
    expect(await run()).toEqual({ erased: 2 });
    expect(revoked).toEqual([
      ["u1", "deleted", { userId: null, role: "SYSTEM" }],
      ["u2", "deleted", { userId: null, role: "SYSTEM" }],
    ]);
  });

  it("nothing due: no revocations", async () => {
    let calls = 0;
    const run = createUsersDeletionProcessor({
      users: { eraseDueAccounts: async () => [] },
      sessions: { revokeAllForUser: async () => ++calls },
    });
    expect(await run()).toEqual({ erased: 0 });
    expect(calls).toBe(0);
  });
});

describe("queue wiring", () => {
  it("only registered queues are implemented; users.deletion is the daily IST job", () => {
    for (const q of IMPLEMENTED_QUEUES) expect(QUEUES.map((x) => x.name)).toContain(q);
    expect(isImplemented("email.otp")).toBe(true);
    expect(isImplemented("push.send")).toBe(false);
    expect(QUEUES.find((q) => q.name === "users.deletion")).toMatchObject({ owner: "users", repeat: "0 3 * * *" });
    expect(QUEUES.find((q) => q.name === "email.otp")).toMatchObject({ owner: "auth" });
  });

  it("builds BullMQ connection options from the Valkey URL", () => {
    expect(bullConnection("redis://127.0.0.1:4582")).toEqual({ host: "127.0.0.1", port: 4582, maxRetriesPerRequest: null });
    expect(bullConnection("redis://:s%40cret@valkey")).toEqual({ host: "valkey", port: 6379, password: "s@cret", maxRetriesPerRequest: null });
  });
});
