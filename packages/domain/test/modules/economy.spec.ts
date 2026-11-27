// BOLT-0113: progress, check-in, XP from learning events, trophies, opt-in leaderboard (unit, fakes).
import { describe, expect, it } from "vitest";
import { FakeClock } from "@heymey/testing";
import { DomainError } from "../../src/shared/errors.js";
import { createEconomyProgression } from "../../src/modules/economy/index.js";
import { FakeEconomyRepo, fakePeople } from "./economy.fakes.js";

const U1 = "0199f5a0-0000-7000-8000-000000000001";
const U2 = "0199f5a0-0000-7000-8000-000000000002";
const U3 = "0199f5a0-0000-7000-8000-000000000003";
const G = "0199f5a0-0000-7000-8000-000000000009";
const T1 = "0199f5a0-0000-7000-9000-000000000001";

function make(opts: { fullyLit?: boolean } = {}) {
  const clock = new FakeClock("2026-11-25T04:30:00.000Z"); // Wed 10:00 IST
  const repo = new FakeEconomyRepo();
  const people = fakePeople({ [U1]: { nickname: "Kavi" }, [U2]: { nickname: "Arun" }, [U3]: { nickname: null }, [G]: { nickname: "Guest", isGuest: true } });
  const api = createEconomyProgression({ repository: repo, clock, people, learning: { subjectFullyLit: async () => opts.fullyLit ?? false } });
  return { api, repo, clock };
}

const lamp = (clock: FakeClock, kinds: string[], extra: Record<string, unknown> = {}) => ({
  type: "mastery.lamp_changed",
  occurredAt: clock.now(),
  payload: { userId: U1, topicId: T1, source: "online", kinds, ...extra },
});
const lampOf = (clock: FakeClock, userId: string, kinds: string[]) => ({ ...lamp(clock, kinds), payload: { userId, topicId: T1, source: "online", kinds } });
const mock = (clock: FakeClock, attemptId: string) => ({ type: "exam_hall.mock_submitted", occurredAt: clock.now(), payload: { userId: U1, attemptId, status: "submitted", correct: 3, wrong: 1 } });

describe("progress", () => {
  it("a new user starts at level 1 with nothing", async () => {
    const { api } = make();
    expect(await api.progress(U1)).toEqual({ xp: 0, level: 1, levelStartXp: 0, nextLevelXp: 100, points: 0, checkedInToday: false, trophies: [] });
  });
});

describe("daily check-in", () => {
  it("awards 5 XP + 10 Points once per IST day; a retry or second tap awards nothing", async () => {
    const { api, clock } = make();
    expect(await api.checkIn(U1)).toEqual({ awarded: { xp: 5, points: 10 }, alreadyCheckedIn: false });
    expect(await api.checkIn(U1)).toEqual({ awarded: { xp: 0, points: 0 }, alreadyCheckedIn: true });
    clock.set("2026-11-25T18:29:00.000Z"); // 23:59 IST, same day
    expect((await api.checkIn(U1)).alreadyCheckedIn).toBe(true);
    const p = await api.progress(U1);
    expect([p.xp, p.points, p.checkedInToday]).toEqual([5, 10, true]);
  });

  it("missing days resets nothing: the next check-in just adds", async () => {
    const { api, clock } = make();
    await api.checkIn(U1);
    clock.set("2026-12-01T04:30:00.000Z");
    expect(await api.checkIn(U1)).toEqual({ awarded: { xp: 5, points: 10 }, alreadyCheckedIn: false });
    expect((await api.progress(U1)).points).toBe(20);
  });
});

describe("XP from learning events", () => {
  it("lesson, lit, recall, relight, Gold and a mock earn the table amounts", async () => {
    const { api, clock } = make();
    for (const k of ["lesson_done", "lit", "recall_pass", "relight", "gold"]) await api.onLearningEvent(lamp(clock, [k]));
    await api.onLearningEvent(mock(clock, "a1"));
    expect((await api.progress(U1)).xp).toBe(10 + 25 + 15 + 15 + 50 + 40);
  });

  it("a duplicate event awards once; one-time events stay once per topic or attempt", async () => {
    const { api, clock } = make();
    const e = lamp(clock, ["recall_pass"]);
    await api.onLearningEvent(e);
    await api.onLearningEvent(e);
    await api.onLearningEvent(lamp(clock, ["lit"]));
    await api.onLearningEvent(mock(clock, "a1"));
    clock.advanceDays(1);
    await api.onLearningEvent(lamp(clock, ["lit"]));
    await api.onLearningEvent(mock(clock, "a1"));
    expect((await api.progress(U1)).xp).toBe(15 + 25 + 40);
  });

  it("offline-synced lamp changes, failures and unknown events earn nothing (FW-022)", async () => {
    const { api, clock } = make();
    await api.onLearningEvent(lamp(clock, ["lit"], { source: "offline" }));
    await api.onLearningEvent(lamp(clock, ["lit_fail", "dimming"]));
    await api.onLearningEvent(lamp(clock, []));
    await api.onLearningEvent({ type: "mastery.lamp_changed", occurredAt: clock.now(), payload: { userId: U1, topicId: T1, source: "online" } });
    await api.onLearningEvent({ type: "practice.answered", occurredAt: clock.now(), payload: { userId: U1 } });
    await api.onLearningEvent({ type: "exam_hall.mock_submitted", occurredAt: clock.now(), payload: {} });
    // a blank mock (nothing answered) cannot farm XP
    await api.onLearningEvent({ type: "exam_hall.mock_submitted", occurredAt: clock.now(), payload: { userId: U1, attemptId: "blank", correct: 0, wrong: 0 } });
    expect((await api.progress(U1)).xp).toBe(0);
  });
});

describe("trophies", () => {
  it("first lamp, first Gold, subject lit and first mock, each once", async () => {
    const { api, clock } = make({ fullyLit: true });
    await api.onLearningEvent(lamp(clock, ["lit"]));
    await api.onLearningEvent(lamp(clock, ["gold"]));
    await api.onLearningEvent(mock(clock, "a1"));
    await api.onLearningEvent(mock(clock, "a2"));
    const t = (await api.progress(U1)).trophies;
    expect(t.map((x) => x.code).sort()).toEqual(["first_gold", "first_lamp", "first_mock", "subject_lit"]);
    expect(t.find((x) => x.code === "first_lamp")).toEqual({ code: "first_lamp", title: "First lamp lit", earnedAt: clock.now().toISOString() });
  });

  it("subject_lit waits until the whole subject is lit", async () => {
    const { api, clock } = make({ fullyLit: false });
    await api.onLearningEvent(lamp(clock, ["relight"]));
    expect((await api.progress(U1)).trophies).toEqual([]);
  });

  it("five study days, not in a row, earn five_study_days; check-in alone does not count", async () => {
    const { api, clock } = make();
    for (let d = 0; d < 9; d++) {
      clock.set(new Date(Date.parse("2026-11-01T04:30:00.000Z") + d * 86_400_000));
      await api.checkIn(U1);
      if (d % 2 === 0) await api.onLearningEvent(lamp(clock, ["recall_pass"]));
      const has = (await api.progress(U1)).trophies.some((t) => t.code === "five_study_days");
      expect(has, `day ${d}`).toBe(d >= 8);
    }
  });

  it("awardTrophy is idempotent and rejects unknown codes", async () => {
    const { api } = make();
    expect(await api.awardTrophy(U1, "expo_challenge")).toBe(true);
    expect(await api.awardTrophy(U1, "expo_challenge")).toBe(false);
    await expect(api.awardTrophy(U1, "free_sparks" as never)).rejects.toThrow(DomainError);
  });
});

describe("weekly leaderboard (opt-in only)", () => {
  it("is empty by default: nobody is listed until they opt in", async () => {
    const { api, clock } = make();
    await api.onLearningEvent(lamp(clock, ["lit"]));
    expect(await api.weeklyLeaderboard(U1)).toEqual({
      weekStart: "2026-11-22T18:30:00.000Z",
      weekEnd: "2026-11-29T18:30:00.000Z",
      optedIn: false,
      entries: [],
    });
  });

  it("shows opted-in users by nickname, this week's XP only, ties share a rank; no guests, nameless or hidden users", async () => {
    const { api, repo, clock } = make();
    for (const u of [U1, U2, U3]) expect((await api.setOptIn(u, true)).optIn).toBe(true);
    repo.optIns.set(G, true); // even if a guest row slipped in, the board leaves it out
    await api.onLearningEvent(lamp(clock, ["lit"]));
    await api.onLearningEvent(lampOf(clock, U2, ["lit"]));
    await api.onLearningEvent(lampOf(clock, U3, ["gold"]));
    await api.onLearningEvent(lampOf(clock, G, ["gold"]));
    await repo.awardXp({ userId: U1, amount: 500, reason: "lit", sourceKey: "old", at: new Date("2026-11-20T00:00:00Z") });
    const board = await api.weeklyLeaderboard(U2);
    expect(board.optedIn).toBe(true);
    expect(board.entries).toEqual([
      { rank: 1, displayName: "Kavi", xp: 25, isMe: false },
      { rank: 1, displayName: "Arun", xp: 25, isMe: true },
    ]);
    await api.onLearningEvent(lampOf(clock, U2, ["recall_pass"]));
    expect((await api.weeklyLeaderboard(U1)).entries.map((e) => [e.rank, e.displayName, e.isMe])).toEqual([
      [1, "Arun", false],
      [2, "Kavi", true],
    ]);
  });

  it("guests cannot opt in but can always opt out; listed says whether the board can show me", async () => {
    const { api } = make();
    await expect(api.setOptIn(G, true)).rejects.toMatchObject({ code: "GUEST_NOT_ALLOWED" });
    expect(await api.setOptIn(G, false)).toEqual({ optIn: false, listed: false });
    expect(await api.setOptIn(U3, true)).toEqual({ optIn: true, listed: false });
    expect(await api.setOptIn(U1, true)).toEqual({ optIn: true, listed: true });
  });
});
