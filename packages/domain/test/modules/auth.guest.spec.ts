/* eslint-disable @typescript-eslint/no-non-null-assertion -- tests assert presence right after creating the row */
// Guest mode (D-2026-11-27): try the app without an email, then save progress by signing in with email.
import { randomUUID } from "node:crypto";
import { describe, expect, it } from "vitest";
import { ACTOR, identityHarness } from "./auth.fakes.js";

const DAY = 24 * 3600_000;

async function startGuest(h: ReturnType<typeof identityHarness>, deviceId = randomUUID()) {
  const tokens = await h.auth.startGuestSession({ deviceId, platform: "web", ageConfirmed18: true });
  const ctx = (await h.auth.verifyAccessToken(tokens.accessToken))!;
  return { tokens, deviceId, userId: ctx.userId };
}

async function verifyAs(h: ReturnType<typeof identityHarness>, email: string, deviceId: string, callerUserId: string | null) {
  await h.auth.requestOtp({ email, purpose: "login" });
  const res = await h.auth.verifyOtp({ email, code: h.lastCode(email), deviceId, platform: "web", client: "app", callerUserId });
  if (res.kind !== "session") throw new Error("expected session");
  return res;
}

describe("auth: guest session", () => {
  it("refuses anyone who has not confirmed 18+ and creates nothing", async () => {
    const h = identityHarness();
    await expect(h.auth.startGuestSession({ deviceId: randomUUID(), platform: "android", ageConfirmed18: false })).rejects.toMatchObject({ code: "UNDER_18" });
    expect(h.userRepo.rows.size).toBe(0);
  });

  it("creates an ASPIRANT guest with no email and a 30-day session", async () => {
    const h = identityHarness();
    const g = await startGuest(h);
    const me = await h.users.getMe(g.userId);
    expect(me).toMatchObject({ email: null, isGuest: true, roles: ["ASPIRANT"] });
    const session = [...h.mem.sessions.values()][0]!;
    expect(session.expiresAt.getTime() - h.clock.now().getTime()).toBe(30 * DAY);
    expect(session.isDesk).toBe(false);
  });

  it("refuses a device that belongs to an email account", async () => {
    const h = identityHarness();
    const deviceId = randomUUID();
    await verifyAs(h, "asha@example.com", deviceId, null);
    await expect(h.auth.startGuestSession({ deviceId, platform: "web", ageConfirmed18: true })).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
  });

  it("a new guest on the same device replaces the old guest, whose session ends", async () => {
    const h = identityHarness();
    const first = await startGuest(h);
    const second = await startGuest(h, first.deviceId);
    expect(second.userId).not.toBe(first.userId);
    expect(h.mem.devices.get(first.deviceId)!.userId).toBe(second.userId);
    expect(await h.auth.verifyAccessToken(first.tokens.accessToken)).toBeNull();
  });

  it("a guest cannot confirm account deletion by email (there is none)", async () => {
    const h = identityHarness();
    const g = await startGuest(h);
    await expect(h.auth.deleteAccount(g.userId, "123456", ACTOR)).rejects.toMatchObject({ code: "FORBIDDEN" });
  });
});

describe("auth: guest signs in with email", () => {
  it("new email: the same account keeps its progress and becomes a normal 60-day account", async () => {
    const h = identityHarness();
    const g = await startGuest(h);
    await h.users.updateMe(g.userId, { nickname: "Asha" });
    const res = await verifyAs(h, "asha@example.com", g.deviceId, g.userId);
    expect(res).toMatchObject({ isNewUser: false, guestProgress: "kept" });
    const ctx = (await h.auth.verifyAccessToken(res.tokens.accessToken))!;
    expect(ctx.userId).toBe(g.userId);
    expect(await h.users.getMe(g.userId)).toMatchObject({ email: "asha@example.com", isGuest: false, nickname: "Asha" });
    expect(await h.auth.verifyAccessToken(g.tokens.accessToken)).toBeNull();
    const session = [...h.mem.sessions.values()].find((s) => s.id === ctx.sessionId)!;
    expect(session.expiresAt.getTime() - h.clock.now().getTime()).toBe(60 * DAY);
  });

  it("existing email: signs into that account and says the guest progress was not merged", async () => {
    const h = identityHarness();
    const owner = await verifyAs(h, "asha@example.com", randomUUID(), null);
    const ownerId = (await h.auth.verifyAccessToken(owner.tokens.accessToken))!.userId;
    h.clock.advanceMinutes(11);
    const g = await startGuest(h);
    const res = await verifyAs(h, "asha@example.com", g.deviceId, g.userId);
    expect(res).toMatchObject({ isNewUser: false, guestProgress: "not_merged" });
    expect((await h.auth.verifyAccessToken(res.tokens.accessToken))!.userId).toBe(ownerId);
    expect(h.mem.devices.get(g.deviceId)!.userId).toBe(ownerId);
    expect(await h.auth.verifyAccessToken(g.tokens.accessToken)).toBeNull();
    expect((await h.users.getById(g.userId))!.deletionRequestedAt).not.toBeNull();
  });

  it("without a guest token the answer carries no guestProgress", async () => {
    const h = identityHarness();
    const res = await verifyAs(h, "asha@example.com", randomUUID(), null);
    expect(res.guestProgress).toBeUndefined();
  });
});

describe("users: inactive guest cleanup", () => {
  it("guests older than 60 days (30 days past their last possible session) are erased through the deletion path", async () => {
    const h = identityHarness();
    const old = await startGuest(h);
    h.clock.advanceMinutes(31 * 24 * 60);
    const recent = await startGuest(h);
    await verifyAs(h, "asha@example.com", randomUUID(), null);
    h.clock.advanceMinutes(30 * 24 * 60);

    expect(await h.users.scheduleInactiveGuestErasure()).toBe(1);
    const erased = await h.users.eraseDueAccounts();
    expect(erased).toEqual([old.userId]);
    expect((await h.users.getById(recent.userId))!.deletedAt).toBeNull();
    expect((await h.users.findByEmail("asha@example.com"))!.deletedAt).toBeNull();
    expect(await h.users.scheduleInactiveGuestErasure()).toBe(0);
  });
});
