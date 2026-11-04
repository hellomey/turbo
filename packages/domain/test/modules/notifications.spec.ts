// BOLT-0014 · U-notifications invariants 1-9 (aidlc/construction/units/U-notifications/domain-model.md).
// Blueprint §19.8 Q78 (3 a day, Exam Alerts separate), §6 (quiet hours), §9.10 (no alerts in Exam Hall), §17.1 step 11.
import { describe, expect, it } from "vitest";
import { FakeClock } from "@heymey/testing";
import { DomainError } from "../../src/shared/errors.js";
import {
  clampDailyLimit,
  createNotificationsModule,
  decideSend,
  defaultPrefs,
  inQuietHours,
  istMinuteOfDay,
  NOTIFICATIONS_CONFIG,
  pushTokenMoveAllowed,
  type AlertPrefs,
  type AlertPreferenceRepository,
  type PushTokenRepository,
  type PushTokenRow,
  type SendLogRepository,
  type SendLogRow,
  type SendStatus,
} from "../../src/modules/notifications/index.js";

const U = "0199f5a0-0000-7000-8000-00000000aaaa";
/** 2026-10-22 12:00 IST */
const NOON_IST = new Date("2026-10-22T06:30:00.000Z");
/** 2026-10-22 23:00 IST */
const NIGHT_IST = new Date("2026-10-22T17:30:00.000Z");

const base = { prefs: defaultPrefs(), nonExamCountedToday: 0, hasActiveExamHallAttempt: false, offersConsent: false };

describe("policy: IST minutes and quiet hours (invariant 2)", () => {
  it("istMinuteOfDay converts UTC to Asia/Kolkata", () => {
    expect(istMinuteOfDay(NOON_IST)).toBe(12 * 60);
    expect(istMinuteOfDay(new Date("2026-10-21T18:30:00.000Z"))).toBe(0); // IST midnight
  });

  it("22:00-07:00 crosses midnight: start inclusive, end exclusive", () => {
    const p = defaultPrefs();
    expect(inQuietHours(22 * 60, p)).toBe(true);
    expect(inQuietHours(23 * 60 + 59, p)).toBe(true);
    expect(inQuietHours(0, p)).toBe(true);
    expect(inQuietHours(7 * 60 - 1, p)).toBe(true);
    expect(inQuietHours(7 * 60, p)).toBe(false);
    expect(inQuietHours(21 * 60 + 59, p)).toBe(false);
  });

  it("same-day window, disabled window and empty window", () => {
    const day = { quietEnabled: true, quietStartMinute: 13 * 60, quietEndMinute: 14 * 60 };
    expect(inQuietHours(13 * 60 + 30, day)).toBe(true);
    expect(inQuietHours(14 * 60, day)).toBe(false);
    expect(inQuietHours(23 * 60, { ...day, quietStartMinute: 22 * 60, quietEndMinute: 7 * 60, quietEnabled: false })).toBe(false);
    expect(inQuietHours(600, { quietEnabled: true, quietStartMinute: 600, quietEndMinute: 600 })).toBe(false);
  });

  it("defaults come from NOTIFICATIONS_CONFIG (D-2026-10-22-31)", () => {
    expect(defaultPrefs()).toMatchObject({ quietEnabled: true, quietStartMinute: 1320, quietEndMinute: 420, morningAlertMinute: 450, dailyLimit: 3, offers: false });
    expect(NOTIFICATIONS_CONFIG.senderMode).toBe("log_only");
  });
});

describe("policy: decideSend", () => {
  it("invariant 1: budget at exactly 3; the 4th non-exam alert is dropped; Exam Alerts never count", () => {
    expect(decideSend({ ...base, category: "study", at: NOON_IST, nonExamCountedToday: 2 })).toBe("queued");
    expect(decideSend({ ...base, category: "study", at: NOON_IST, nonExamCountedToday: 3 })).toBe("dropped_budget");
    expect(decideSend({ ...base, category: "system", at: NOON_IST, nonExamCountedToday: 3 })).toBe("dropped_budget");
    expect(decideSend({ ...base, category: "exam", at: NOON_IST, nonExamCountedToday: 99 })).toBe("queued");
  });

  it("invariant 8: user's lower limit applies; anything above 3 is clamped", () => {
    expect(decideSend({ ...base, category: "study", at: NOON_IST, prefs: { ...defaultPrefs(), dailyLimit: 1 }, nonExamCountedToday: 1 })).toBe("dropped_budget");
    expect(decideSend({ ...base, category: "study", at: NOON_IST, prefs: { ...defaultPrefs(), dailyLimit: 9 }, nonExamCountedToday: 3 })).toBe("dropped_budget");
    expect(clampDailyLimit(9)).toBe(3);
    expect(clampDailyLimit(-1)).toBe(0);
  });

  it("invariant 2: non-exam inside quiet hours is not sent; Exam Alerts are HELD", () => {
    expect(decideSend({ ...base, category: "study", at: NIGHT_IST })).toBe("dropped_quiet");
    expect(decideSend({ ...base, category: "exam", at: NIGHT_IST })).toBe("held_quiet");
  });

  it("invariant 3: offers need the setting AND the consent", () => {
    const on = { ...defaultPrefs(), offers: true };
    expect(decideSend({ ...base, category: "offer", at: NOON_IST })).toBe("dropped_no_consent");
    expect(decideSend({ ...base, category: "offer", at: NOON_IST, prefs: on })).toBe("dropped_no_consent");
    expect(decideSend({ ...base, category: "offer", at: NOON_IST, prefs: on, offersConsent: true })).toBe("queued");
  });

  it("invariant 4: active Exam Hall attempt -> dropped, whatever the category", () => {
    for (const category of ["study", "exam", "offer", "system"] as const) {
      expect(decideSend({ ...base, category, at: NOON_IST, hasActiveExamHallAttempt: true })).toBe("dropped_exam_hall");
    }
  });

  it("switched-off categories are dropped as opted out", () => {
    expect(decideSend({ ...base, category: "study", at: NOON_IST, prefs: { ...defaultPrefs(), studyReminders: false } })).toBe("dropped_opted_out");
    expect(decideSend({ ...base, category: "exam", at: NOON_IST, prefs: { ...defaultPrefs(), examAlerts: false } })).toBe("dropped_opted_out");
  });
});

// ---------------------------------------------------------------- use cases with in-memory fakes

class MemTokens implements PushTokenRepository {
  rows: (PushTokenRow & { userId: string; revoked: boolean })[] = [];
  async upsert(i: { userId: string; deviceId: string; platform: "android" | "ios"; token: string }, canTakeFrom: (o: { userId: string; deviceId: string }) => boolean) {
    const owner = this.rows.find((r) => r.token === i.token);
    if (owner && !(owner.userId === i.userId && owner.deviceId === i.deviceId) && !canTakeFrom(owner)) return "refused" as const;
    this.rows = this.rows.filter((r) => r.token !== i.token && !(r.userId === i.userId && r.deviceId === i.deviceId));
    this.rows.push({ userId: i.userId, deviceId: i.deviceId, platform: i.platform, token: i.token, revoked: false });
    return "ok" as const;
  }
  async remove(userId: string, deviceId: string) {
    const n = this.rows.length;
    this.rows = this.rows.filter((r) => !(r.userId === userId && r.deviceId === deviceId));
    return n !== this.rows.length;
  }
  async removeAllForUser(userId: string) {
    const n = this.rows.length;
    this.rows = this.rows.filter((r) => r.userId !== userId);
    return n - this.rows.length;
  }
  async activeForUser(userId: string) {
    return this.rows.filter((r) => r.userId === userId && !r.revoked);
  }
  async revokeToken(token: string) {
    for (const r of this.rows) if (r.token === token) r.revoked = true;
  }
}

class MemPrefs implements AlertPreferenceRepository {
  map = new Map<string, AlertPrefs>();
  async get(u: string) {
    return this.map.get(u) ?? null;
  }
  async put(u: string, p: AlertPrefs) {
    this.map.set(u, p);
  }
}

class MemLog implements SendLogRepository {
  rows: SendLogRow[] = [];
  private seq = 0;
  async record(input: Omit<SendLogRow, "id" | "status">, decide: (n: number) => SendStatus) {
    const ex = this.rows.find((r) => r.dedupeKey === input.dedupeKey);
    if (ex) return { row: ex, created: false };
    const n = this.rows.filter((r) => r.userId === input.userId && r.istDay === input.istDay && r.category !== "exam" && ["queued", "sent"].includes(r.status)).length;
    const row = { ...input, id: `log-${++this.seq}`, status: decide(n) };
    this.rows.push(row);
    return { row, created: true };
  }
  async get(id: string) {
    return this.rows.find((r) => r.id === id) ?? null;
  }
  async transition(id: string, from: SendStatus, to: SendStatus) {
    const r = this.rows.find((x) => x.id === id && x.status === from);
    if (!r) return false;
    r.status = to;
    return true;
  }
  async listHeld(limit: number) {
    return this.rows.filter((r) => r.status === "held_quiet").slice(0, limit);
  }
}

function setup(at = NOON_IST, consent = false) {
  const clock = new FakeClock(at);
  const tokens = new MemTokens();
  const prefs = new MemPrefs();
  const sendLog = new MemLog();
  const dispatched: string[] = [];
  const sent: string[] = [];
  let senderResult: "sent" | "invalid_token" = "sent";
  const api = createNotificationsModule({
    repositories: { tokens, prefs, sendLog },
    clock,
    consent: { offersGranted: async () => consent },
    sender: { send: async (m) => {
        sent.push(m.deviceId);
        return senderResult;
      },
    },
    dispatcher: { dispatch: async (id) => void dispatched.push(id) },
  });
  return { api, clock, tokens, prefs, sendLog, dispatched, sent, setSender: (r: "sent" | "invalid_token") => (senderResult = r) };
}

describe("tokens (invariant 7)", () => {
  it("register is an upsert per device; delete removes it; forgetUser removes all", async () => {
    const s = setup();
    const ack = await s.api.registerToken(U, { deviceId: "device-0001", platform: "android", token: "t".repeat(20) });
    expect(ack).toEqual({ deviceId: "device-0001", registeredAt: NOON_IST.toISOString() });
    await s.api.registerToken(U, { deviceId: "device-0001", platform: "android", token: "u".repeat(20) });
    await s.api.registerToken(U, { deviceId: "device-0002", platform: "ios", token: "v".repeat(20) });
    expect(s.tokens.rows).toHaveLength(2);
    expect(await s.api.deleteToken(U, "device-0001")).toEqual({ ok: true });
    expect(await s.api.deleteToken(U, "device-0001")).toEqual({ ok: true }); // idempotent
    expect(await s.api.forgetUser(U)).toBe(1);
    expect(s.tokens.rows).toHaveLength(0);
  });

  it("SEC-P2-L1: another user's token moves only with the same deviceId AND a session on that device", async () => {
    const s = setup();
    const V = "00000000-0000-7000-8000-0000000000bb";
    const tok = "w".repeat(20);
    await s.api.registerToken(U, { deviceId: "device-0001", platform: "android", token: tok }, "device-0001");
    await expect(s.api.registerToken(V, { deviceId: "device-0009", platform: "android", token: tok }, "device-0009")).rejects.toMatchObject({ code: "FORBIDDEN" });
    await expect(s.api.registerToken(V, { deviceId: "device-0001", platform: "android", token: tok }, "device-0009")).rejects.toMatchObject({ code: "FORBIDDEN" });
    await expect(s.api.registerToken(V, { deviceId: "device-0001", platform: "android", token: tok })).rejects.toMatchObject({ code: "FORBIDDEN" });
    expect(s.tokens.rows).toEqual([expect.objectContaining({ userId: U, deviceId: "device-0001", token: tok })]);
    await s.api.registerToken(V, { deviceId: "device-0001", platform: "android", token: tok }, "device-0001");
    expect(s.tokens.rows).toEqual([expect.objectContaining({ userId: V, deviceId: "device-0001", token: tok })]);
    expect(pushTokenMoveAllowed({ userId: U, deviceId: "a" }, { userId: U, deviceId: "b", sessionDeviceId: undefined })).toBe(true);
  });
});

describe("settings (invariant 8)", () => {
  it("first read returns config defaults", async () => {
    expect(await setup().api.getSettings(U)).toEqual({
      studyReminders: true, examAlerts: true, offers: false,
      quietHours: { enabled: true, startMinute: 1320, endMinute: 420 }, morningAlertMinute: 450, dailyLimit: 3,
    });
  });

  it("offers on without consent -> CONSENT_REQUIRED; with consent it saves", async () => {
    const body = { ...(await setup().api.getSettings(U)), offers: true };
    await expect(setup().api.putSettings(U, body)).rejects.toMatchObject({ code: "CONSENT_REQUIRED" });
    await expect(setup().api.putSettings(U, body)).rejects.toBeInstanceOf(DomainError);
    const s = setup(NOON_IST, true);
    expect((await s.api.putSettings(U, { ...body, dailyLimit: 2 })).offers).toBe(true);
    expect((await s.api.getSettings(U)).dailyLimit).toBe(2);
  });
});

describe("enqueue / send / release", () => {
  it("invariant 6: same dedupeKey is decided once and dispatched once", async () => {
    const s = setup();
    const a = await s.api.enqueue({ userId: U, category: "study", templateKey: "study", dedupeKey: "k1" });
    const b = await s.api.enqueue({ userId: U, category: "study", templateKey: "study", dedupeKey: "k1" });
    expect(a).toMatchObject({ status: "queued", created: true });
    expect(b).toMatchObject({ id: a.id, created: false });
    expect(s.dispatched).toEqual([a.id]);
  });

  it("invariant 1 end to end: 3 study alerts queued, the 4th dropped; exam alerts still go", async () => {
    const s = setup();
    const out = [];
    for (let i = 0; i < 4; i++) out.push((await s.api.enqueue({ userId: U, category: "study", templateKey: "s", dedupeKey: `s${i}` })).status);
    expect(out).toEqual(["queued", "queued", "queued", "dropped_budget"]);
    expect(await s.api.enqueueExamAlert("alert-1", [U])).toEqual({ queued: 1 });
  });

  it("offer alert needs consent at send time", async () => {
    const s = setup(NOON_IST, true);
    s.prefs.map.set(U, { ...defaultPrefs(), offers: true });
    expect((await s.api.enqueue({ userId: U, category: "offer", templateKey: "o", dedupeKey: "o1" })).status).toBe("queued");
  });

  it("Exam Alert at night is held, then released after 07:00 IST by releaseHeld", async () => {
    const s = setup(NIGHT_IST);
    expect(await s.api.enqueueExamAlert("alert-2", [U], async () => false)).toEqual({ held_quiet: 1 });
    expect(s.dispatched).toEqual([]);
    expect(await s.api.releaseHeld()).toBe(0); // still quiet
    s.clock.set(new Date("2026-10-23T01:30:00.000Z")); // 07:00 IST
    expect(await s.api.releaseHeld()).toBe(1);
    expect(s.dispatched).toHaveLength(1);
    expect(await s.api.releaseHeld()).toBe(0);
  });

  it("send delivers to every active device; dead token is revoked; no device -> failed; non-queued skipped", async () => {
    const s = setup();
    await s.api.registerToken(U, { deviceId: "device-0001", platform: "android", token: "t".repeat(20) });
    const q = await s.api.enqueue({ userId: U, category: "system", templateKey: "x", dedupeKey: "x1" });
    expect(await s.api.send(q.id)).toBe("sent");
    expect(await s.api.send(q.id)).toBe("skipped");
    expect(await s.api.send("missing")).toBe("skipped");
    s.setSender("invalid_token");
    const q2 = await s.api.enqueue({ userId: U, category: "system", templateKey: "x", dedupeKey: "x2" });
    expect(await s.api.send(q2.id)).toBe("failed");
    expect(s.tokens.rows[0]?.revoked).toBe(true);
  });

  it("send without a sender is a wiring error", async () => {
    const api = createNotificationsModule({
      repositories: { tokens: new MemTokens(), prefs: new MemPrefs(), sendLog: new MemLog() },
      clock: new FakeClock(NOON_IST),
      consent: { offersGranted: async () => false },
    });
    await expect(api.send("x")).rejects.toThrow(/PushSender/);
  });
});
