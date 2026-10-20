/* eslint-disable @typescript-eslint/no-non-null-assertion -- tests assert presence right after creating the row */
import { randomUUID } from "node:crypto";
import { describe, expect, it } from "vitest";
import { CONSENT_NOTICE, isAdultOn } from "../../src/modules/users/index.js";
import { ACTOR, identityHarness } from "./auth.fakes.js";

const profile = (dateOfBirth: string) => ({
  dateOfBirth,
  qualification: "degree" as const,
  community: "BC" as const,
  pstm: true,
  specialCategories: [],
});

async function newUser(h: ReturnType<typeof identityHarness>, email = "u@example.com") {
  const { user } = await h.users.findOrCreateByEmail(email);
  await h.roles.grant({ userId: user.id, role: "ASPIRANT", actor: ACTOR });
  return user;
}

describe("users: 18+ rule", () => {
  it("is adult from the 18th birthday", () => {
    expect(isAdultOn("2008-10-20", "2026-10-19")).toBe(false);
    expect(isAdultOn("2008-10-20", "2026-10-20")).toBe(true);
    expect(isAdultOn("2008-02-29", "2026-02-28")).toBe(false);
    expect(isAdultOn("2008-02-29", "2026-03-01")).toBe(true);
    expect(isAdultOn("2030-01-01", "2026-10-20")).toBe(false);
  });

  it("uses today's Asia/Kolkata date: 18:29 UTC is still the 19th, 18:30 UTC is the 20th in IST", async () => {
    const h = identityHarness("2026-10-19T18:29:59.000Z");
    const u = await newUser(h);
    await expect(h.users.putProfile(u.id, profile("2008-10-20"))).rejects.toMatchObject({ code: "UNDER_18" });
    expect(await h.userRepo.getProfile(u.id)).toBeNull();
    h.clock.set("2026-10-19T18:30:00.000Z");
    const me = await h.users.putProfile(u.id, profile("2008-10-20"));
    expect(me.profile).toMatchObject({ dateOfBirth: "2008-10-20", qualification: "degree", community: "BC", pstm: true });
  });
});

describe("users: Me", () => {
  it("returns settings, roles, null profile and no pending deletion for a new user", async () => {
    const h = identityHarness();
    const u = await newUser(h);
    expect(await h.users.getMe(u.id)).toEqual({
      id: u.id,
      email: "u@example.com",
      nickname: null,
      district: null,
      calmMode: false,
      liteMode: null,
      hideFromLeaderboards: false,
      profile: null,
      roles: ["ASPIRANT"],
      deletionScheduledFor: null,
      createdAt: h.clock.now().toISOString(),
    });
  });

  it("updates only the given settings", async () => {
    const h = identityHarness();
    const u = await newUser(h);
    const me = await h.users.updateMe(u.id, { nickname: "Asha K", district: "Madurai", calmMode: true, liteMode: null });
    expect(me).toMatchObject({ nickname: "Asha K", district: "Madurai", calmMode: true, liteMode: null, hideFromLeaderboards: false });
    const me2 = await h.users.updateMe(u.id, { hideFromLeaderboards: true });
    expect(me2).toMatchObject({ nickname: "Asha K", hideFromLeaderboards: true });
    await expect(h.users.updateMe(u.id, {})).resolves.toMatchObject({ nickname: "Asha K" });
  });

  it("unknown user -> NOT_FOUND", async () => {
    const h = identityHarness();
    await expect(h.users.getMe(randomUUID())).rejects.toMatchObject({ code: "NOT_FOUND" });
  });
});

describe("users: consent (DPDP)", () => {
  it("notice: version 2026-10-v2, only core_service required, 5 purposes", () => {
    const h = identityHarness();
    const n = h.users.consentNotice();
    expect(n).toBe(CONSENT_NOTICE);
    expect(n.version).toBe("2026-10-v2");
    expect(n.purposes.map((p) => p.purpose)).toEqual(["core_service", "offers_email", "product_research", "share_with_supporters", "share_with_institution"]);
    expect(n.purposes.filter((p) => p.required).map((p) => p.purpose)).toEqual(["core_service"]);
  });

  it("records one row per choice and returns the latest per purpose", async () => {
    const h = identityHarness();
    const u = await newUser(h);
    expect(await h.users.getConsents(u.id)).toEqual({ noticeVersion: null, choices: [] });
    await h.users.recordConsents(u.id, {
      noticeVersion: "2026-10-v2",
      choices: [
        { purpose: "core_service", granted: true },
        { purpose: "offers_email", granted: true },
      ],
    });
    h.clock.advanceMinutes(1);
    const state = await h.users.recordConsents(u.id, {
      noticeVersion: "2026-10-v2",
      choices: [
        { purpose: "core_service", granted: true },
        { purpose: "offers_email", granted: false },
      ],
    });
    expect(h.consentRepo.rows.get(u.id)).toHaveLength(4);
    expect(state.noticeVersion).toBe("2026-10-v2");
    expect(state.choices.find((c) => c.purpose === "offers_email")).toMatchObject({ granted: false, at: h.clock.now().toISOString() });
  });

  it("refuses a stale notice version, a missing/declined core_service and duplicate purposes", async () => {
    const h = identityHarness();
    const u = await newUser(h);
    await expect(h.users.recordConsents(u.id, { noticeVersion: "old", choices: [{ purpose: "core_service", granted: true }] })).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
    await expect(h.users.recordConsents(u.id, { noticeVersion: "2026-10-v2", choices: [{ purpose: "offers_email", granted: true }] })).rejects.toMatchObject({ code: "CONSENT_REQUIRED" });
    await expect(h.users.recordConsents(u.id, { noticeVersion: "2026-10-v2", choices: [{ purpose: "core_service", granted: false }] })).rejects.toMatchObject({ code: "CONSENT_REQUIRED" });
    await expect(
      h.users.recordConsents(u.id, { noticeVersion: "2026-10-v2", choices: [{ purpose: "core_service", granted: true }, { purpose: "core_service", granted: true }] }),
    ).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
    expect(h.consentRepo.rows.get(u.id)).toBeUndefined();
  });
});

describe("users: deletion grace period and erasure", () => {
  it("keeps the first request date; cancel clears it", async () => {
    const h = identityHarness();
    const u = await newUser(h);
    const first = await h.users.requestDeletion(u.id, ACTOR);
    h.clock.advanceDays(2);
    expect(await h.users.requestDeletion(u.id, ACTOR)).toEqual(first);
    expect(await h.users.cancelDeletion(u.id)).toBe(true);
    expect(await h.users.cancelDeletion(u.id)).toBe(false);
    expect(await h.users.cancelDeletion(randomUUID())).toBe(false);
  });

  it("erases only accounts past 7 days, removes personal data, is idempotent and audited without personal data", async () => {
    const h = identityHarness();
    const u = await newUser(h, "gone@example.com");
    const keep = await newUser(h, "keep@example.com");
    await h.users.updateMe(u.id, { nickname: "Gone", district: "Salem" });
    await h.users.putProfile(u.id, profile("1999-01-01"));
    await h.users.recordConsents(u.id, { noticeVersion: "2026-10-v2", choices: [{ purpose: "core_service", granted: true }] });
    await h.users.requestDeletion(u.id, ACTOR);
    h.clock.advanceDays(1);
    await h.users.requestDeletion(keep.id, ACTOR);

    h.clock.advanceDays(6);
    h.clock.advance(-1);
    expect(await h.users.eraseDueAccounts()).toEqual([]);
    h.clock.advance(1);
    expect(await h.users.eraseDueAccounts()).toEqual([u.id]);
    const erased = (await h.users.getById(u.id))!;
    expect(erased).toMatchObject({ email: `deleted+${u.id}@invalid.heymey.app`, nickname: null, district: null });
    expect(erased.deletedAt).not.toBeNull();
    expect(await h.userRepo.getProfile(u.id)).toBeNull();
    expect(h.consentRepo.rows.get(u.id)).toBeUndefined();
    expect(await h.users.eraseDueAccounts()).toEqual([]);
    expect(h.auditRows.filter((a) => a.action === "users.erased")).toHaveLength(1);
    expect(JSON.stringify(h.auditRows)).not.toContain("gone@example.com");
    await expect(h.users.getMe(u.id)).rejects.toMatchObject({ code: "NOT_FOUND" });
    expect(await h.users.findByEmail("gone@example.com")).toBeNull();
  });
});

describe("users: erasure safety (SEC-M3)", () => {
  it("beforeErase runs with the real email BEFORE it is replaced; a cancel in between skips the erase entirely", async () => {
    const h = identityHarness();
    const a = await newUser(h, "a@example.com");
    const b = await newUser(h, "b@example.com");
    await h.users.putProfile(b.id, profile("1999-01-01"));
    await h.users.requestDeletion(a.id, ACTOR);
    await h.users.requestDeletion(b.id, ACTOR);
    h.clock.advanceDays(8);
    const seen: { id: string; email: string; current: string | undefined }[] = [];
    const erased = await h.users.eraseDueAccounts({
      beforeErase: async (u) => {
        seen.push({ ...u, current: (await h.users.getById(u.id))?.email });
        // b signs in (cancels the deletion) between dueForErasure and erase.
        if (u.id === b.id) await h.users.cancelDeletion(b.id);
      },
    });
    expect(seen).toEqual([
      { id: a.id, email: "a@example.com", current: "a@example.com" },
      { id: b.id, email: "b@example.com", current: "b@example.com" },
    ]);
    expect(erased).toEqual([a.id]);
    expect((await h.users.getById(b.id))!).toMatchObject({ email: "b@example.com", deletedAt: null, deletionRequestedAt: null });
    expect(await h.userRepo.getProfile(b.id)).not.toBeNull();
    expect(h.auditRows.filter((x) => x.action === "users.erased").map((x) => x.target)).toEqual([`user:${a.id}`]);
  });
});
