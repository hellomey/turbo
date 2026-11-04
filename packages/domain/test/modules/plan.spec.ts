// BOLT-0012: plan domain invariants 1–11 (U-plan domain model) with FakeClock. §17.3, §19.2 Q11–Q20, §10.6, §39.
import { randomUUID } from "node:crypto";
import { describe, expect, it } from "vitest";
import { FakeClock } from "@heymey/testing";
import { nextStageDate, pickCycle } from "../../src/modules/exams/index.js";
import { validateExamChoice } from "../../src/modules/exams/index.js";
import {
  PLAN_CONFIG,
  WELCOME_BACK,
  addDays,
  buildDay,
  createPlanModule,
  dayRange,
  daysBetween,
  examShares,
  isWeekend,
  minutesForDay,
  missedDays,
  mixFor,
  planPortsFrom,
  stretchPhase,
  todayCard,
  type PlanItemRecord,
  type PlanPorts,
  type PlanRecord,
  type PlanRepository,
  type PlanTarget,
  type StudyLogEntry,
  type TopicPick,
} from "../../src/modules/plan/index.js";

// ------------------------------------------------------------------ fakes

function fakeRepo() {
  const plans = new Map<string, PlanRecord>();
  const items: PlanItemRecord[] = [];
  const logs: StudyLogEntry[] = [];
  const repo: PlanRepository = {
    findByUser: async (userId) => {
      const p = plans.get(userId);
      return p ? { ...p, exams: [...p.exams] } : null;
    },
    save: async (userId, s, exams) => {
      const old = plans.get(userId);
      const p: PlanRecord = {
        id: old?.id ?? randomUUID(),
        userId,
        ...s,
        lastActiveIstDay: old?.lastActiveIstDay ?? null,
        lastRebalancedAt: old?.lastRebalancedAt ?? null,
        exams,
      };
      plans.set(userId, p);
      return { ...p };
    },
    setExams: async (planId, exams, stretch) => {
      for (const p of plans.values()) if (p.id === planId) Object.assign(p, { exams, stretch });
    },
    items: async (planId, from, to) =>
      items.filter((i) => i.planId === planId && i.day >= from && i.day <= to).sort((a, b) => (a.day === b.day ? a.order - b.order : a.day < b.day ? -1 : 1)),
    plannedTopicIds: async (planId) =>
      new Set(items.filter((i) => i.planId === planId && i.topicId && (i.status === "pending" || i.status === "done")).map((i) => i.topicId as string)),
    rebuild: async (planId, fromDay, drafts, moveIds, at) => {
      for (let k = items.length - 1; k >= 0; k--) {
        const i = items[k];
        if (i && i.planId === planId && i.status === "pending" && i.day >= fromDay) items.splice(k, 1);
      }
      for (const i of items) if (moveIds.includes(i.id) && i.status === "pending") i.status = "moved";
      for (const x of drafts) items.push({ ...x, id: randomUUID(), planId, status: "pending" });
      if (at) for (const p of plans.values()) if (p.id === planId) p.lastRebalancedAt = at;
    },
    item: async (id) => {
      const i = items.find((x) => x.id === id);
      if (!i) return null;
      const p = [...plans.values()].find((x) => x.id === i.planId);
      return { ...i, userId: p?.userId ?? "" };
    },
    setItemStatus: async (id, status, _at, day, log) => {
      const i = items.find((x) => x.id === id);
      if (!i) throw new Error("no item");
      const changed = i.status === "pending";
      if (changed) {
        i.status = status;
        for (const p of plans.values()) if (p.id === i.planId) p.lastActiveIstDay = day;
      }
      if (log && (changed || log.clientActionId)) logs.push(log);
      return { ...i };
    },
    appendStudyLog: async (e) => {
      logs.push(e);
    },
    hasClientAction: async (u, id) => logs.some((l) => l.userId === u && l.clientActionId === id),
    usersForCycle: async (code, cycleId) =>
      [...plans.values()].filter((p) => p.exams.some((e) => e.examCode === code && e.attemptCycleId === cycleId)).map((p) => p.userId),
    usersWithPastPending: async (today, after, limit) =>
      [...plans.values()]
        .filter((p) => items.some((i) => i.planId === p.id && i.status === "pending" && i.day < today))
        .map((p) => p.userId)
        .sort()
        .filter((u) => !after || u > after)
        .slice(0, limit),
  };
  return { repo, plans, items, logs };
}

const topics = (prefix: string, n: number, critical: number[] = []) =>
  Array.from({ length: n }, (_, i) => ({ topicId: `${prefix}-${String(i).padStart(3, "0")}`, name: `${prefix} ${i}`, priority: critical.includes(i) ? 2 : 0 }));

interface World {
  targets: { examCode: string; isMain: boolean; attemptCycleId: string | null; examDate: string | null }[];
  topics: Record<string, { topicId: string; name: string; priority: number }[]>;
  lit: Set<string>;
}

function ports(w: World): PlanPorts {
  return {
    targets: async () => w.targets,
    topicsForExam: async (code) => w.topics[code] ?? [],
    litTopicIds: async (_u, ids) => new Set(ids.filter((id) => w.lit.has(id))),
    rank: async () => ({ step: 1, title: "Aspirant", xp: 0, nextStepXp: 100 }) as never,
    relight: async () => ({ count: 2, minutes: 10 }),
  };
}

function setup(start = "2026-11-02T04:30:00.000Z", world?: Partial<World>) {
  const clock = new FakeClock(start); // Monday 2 Nov 2026, 10:00 IST
  const w: World = {
    targets: [{ examCode: "g4", isMain: true, attemptCycleId: "c-g4", examDate: null }],
    topics: { g4: topics("g4", 120), g2: topics("g2", 60) },
    lit: new Set(),
    ...world,
  };
  const f = fakeRepo();
  const events: { type: string; payload: unknown }[] = [];
  const api = createPlanModule({ repository: f.repo, clock, ports: ports(w), events: { publish: async (e) => void events.push(e) } });
  return { clock, w, f, api, events };
}

const USER = "0199f5a0-0000-7000-8000-000000000001";

// ------------------------------------------------------------------ pure rules

describe("days (IST calendar)", () => {
  it("adds days and counts across months and leap years", () => {
    expect(addDays("2026-12-31", 1)).toBe("2027-01-01");
    expect(addDays("2028-02-28", 1)).toBe("2028-02-29");
    expect(daysBetween("2026-11-02", "2026-12-02")).toBe(30);
    expect(daysBetween("2026-12-02", "2026-11-02")).toBe(-30);
    expect(dayRange("2026-11-02", "2026-11-04")).toEqual(["2026-11-02", "2026-11-03", "2026-11-04"]);
    expect(dayRange("2026-11-04", "2026-11-02")).toEqual([]);
  });

  it("invariant 2: weekday vs weekend minutes by IST weekday", () => {
    const p = { weekdayMinutes: 60, weekendMinutes: 120 };
    expect(isWeekend("2026-11-07")).toBe(true); // Saturday
    expect(isWeekend("2026-11-08")).toBe(true); // Sunday
    expect(isWeekend("2026-11-09")).toBe(false);
    expect(minutesForDay(p, "2026-11-07")).toBe(120);
    expect(minutesForDay(p, "2026-11-06")).toBe(60);
  });
});

describe("Final Stretch phases (invariant 8, boundaries 91/90/61/60/31/30/8/7)", () => {
  it.each([
    [null, "normal"],
    [91, "normal"],
    [90, "d90"],
    [61, "d90"],
    [60, "d60"],
    [31, "d60"],
    [30, "d30"],
    [8, "d30"],
    [7, "d7"],
    [0, "d7"],
  ] as const)("%s days left -> %s", (left, phase) => {
    expect(stretchPhase(left)).toBe(phase);
  });
});

describe("mix by days left + balance dial (invariant 3)", () => {
  it("uses the PLAN_CONFIG row for the days left", () => {
    expect(mixFor(null, 0)).toEqual({ newTopics: 60, relight: 20, pyq: 15, mocks: 5 });
    expect(mixFor(91, 0).newTopics).toBe(60);
    expect(mixFor(90, 0)).toEqual({ newTopics: 45, relight: 25, pyq: 20, mocks: 10 });
    expect(mixFor(31, 0).newTopics).toBe(30);
    expect(mixFor(8, 0).newTopics).toBe(5);
    expect(mixFor(3, 0)).toEqual({ newTopics: 0, relight: 50, pyq: 30, mocks: 20 });
  });

  it("balance moves 10 points per step between new topics and relight, never below 0", () => {
    expect(mixFor(null, 2)).toEqual({ newTopics: 80, relight: 0, pyq: 15, mocks: 5 });
    expect(mixFor(null, -2)).toEqual({ newTopics: 40, relight: 40, pyq: 15, mocks: 5 });
    expect(mixFor(3, -2)).toEqual({ newTopics: 0, relight: 50, pyq: 30, mocks: 20 });
  });
});

describe("several exams share one budget (Q24)", () => {
  const t = (examCode: string, priority: number, examDate: string | null): PlanTarget => ({ examCode, priority, examDate, attemptCycleId: null });
  it("one exam gets everything", () => {
    expect([...examShares([t("a", 1, null)], "2026-11-02")]).toEqual([["a", 100]]);
    expect(examShares([], "2026-11-02").size).toBe(0);
  });
  it("main 60, others split 40", () => {
    expect(Object.fromEntries(examShares([t("a", 1, null), t("b", 2, null)], "2026-11-02"))).toEqual({ a: 60, b: 40 });
    expect(Object.fromEntries(examShares([t("a", 1, null), t("b", 2, null), t("c", 3, null)], "2026-11-02"))).toEqual({ a: 60, b: 20, c: 20 });
  });
  it("nearest date inside 60 days gets +15", () => {
    expect(Object.fromEntries(examShares([t("a", 1, "2027-06-01"), t("b", 2, "2026-12-01")], "2026-11-02"))).toEqual({ a: 45, b: 55 });
    expect(Object.fromEntries(examShares([t("a", 1, "2026-12-01"), t("b", 2, "2027-06-01")], "2026-11-02"))).toEqual({ a: 75, b: 25 });
    // outside the window: no boost
    expect(Object.fromEntries(examShares([t("a", 1, "2027-06-01"), t("b", 2, "2027-02-01")], "2026-11-02"))).toEqual({ a: 60, b: 40 });
    const three = examShares([t("a", 1, null), t("b", 2, "2026-11-20"), t("c", 3, null)], "2026-11-02");
    expect([...three.values()].reduce((s, v) => s + v, 0)).toBe(100);
    expect(three.get("b")).toBeGreaterThan(three.get("c") ?? 0);
  });
});

describe("buildDay", () => {
  const queue = (prefix: string, n: number, critical: number[] = []): TopicPick[] =>
    topics(prefix, n, critical).map((x) => ({ topicId: x.topicId, name: x.name, critical: x.priority >= 2 }));
  const base = (over: Partial<Parameters<typeof buildDay>[0]> = {}) => ({
    day: "2026-11-02",
    minutes: 60,
    firstOrder: 0,
    targets: [{ examCode: "g4", attemptCycleId: null, examDate: null, priority: 1 }],
    balance: 0,
    starter: false,
    queues: new Map([["g4", queue("g4", 50)]]),
    planned: new Set<string>(),
    ...over,
  });

  it("invariant 2: never over the day by more than one item; orders follow firstOrder", () => {
    for (const minutes of [15, 30, 45, 60, 90, 120, 240]) {
      const items = buildDay(base({ minutes, firstOrder: 3 }));
      const total = items.reduce((s, i) => s + i.minutes, 0);
      const last = items[items.length - 1]?.minutes ?? 0;
      expect(total - last).toBeLessThan(minutes);
      expect(items.map((i) => i.order)).toEqual(items.map((_, k) => k + 3));
    }
    expect(buildDay(base({ minutes: 0 }))).toEqual([]);
    expect(buildDay(base({ targets: [] }))).toEqual([]);
  });

  it("invariant 4: starter path = lesson + Lit check of the first lamps of the main exam, in order", () => {
    const items = buildDay(base({ starter: true, minutes: 30 }));
    expect(items.map((i) => i.kind)).toEqual(["lesson", "lit_check", "lesson", "lit_check"]);
    expect(items[0]?.topicId).toBe("g4-000");
    expect(items[2]?.topicId).toBe("g4-001");
  });

  it("starter path with no lamp left falls back to the normal mix (never an empty day)", () => {
    const items = buildDay(base({ starter: true, minutes: 30, queues: new Map([["g4", []]]) }));
    expect(items.length).toBeGreaterThan(0);
    expect(items.some((i) => i.kind === "relight")).toBe(true);
  });

  it("normal day: relight, new lessons, past questions (mock folds into pyq when short)", () => {
    const items = buildDay(base({ minutes: 60 }));
    expect(items[0]?.kind).toBe("relight");
    expect(items.some((i) => i.kind === "lesson")).toBe(true);
    expect(items.some((i) => i.kind === "pyq")).toBe(true);
    expect(items.some((i) => i.kind === "mock")).toBe(false);
  });

  it("long day near the exam gets a mock", () => {
    const items = buildDay(base({ minutes: 240, targets: [{ examCode: "g4", attemptCycleId: null, examDate: "2026-11-20", priority: 1 }] }));
    expect(items.some((i) => i.kind === "mock")).toBe(true);
  });

  it("invariant 8: d30 plans only critical new topics; d7 adds the checklist first", () => {
    const q = new Map([["g4", queue("g4", 30, [7])]]);
    const d30 = buildDay(base({ minutes: 120, queues: q, targets: [{ examCode: "g4", attemptCycleId: null, examDate: "2026-11-27", priority: 1 }] }));
    expect(d30.filter((i) => i.kind === "lesson").map((i) => i.topicId)).toEqual(["g4-007"]);
    const d7 = buildDay(base({ minutes: 60, targets: [{ examCode: "g4", attemptCycleId: null, examDate: "2026-11-06", priority: 1 }] }));
    expect(d7[0]?.kind).toBe("checklist");
    expect(d7.some((i) => i.kind === "lesson")).toBe(false);
  });

  it("invariant 9: a shared lamp is planned once across exams", () => {
    const shared = { topicId: "shared-1", name: "Shared", critical: false };
    const planned = new Set<string>();
    const items = buildDay(
      base({
        minutes: 240,
        balance: 2,
        targets: [
          { examCode: "g4", attemptCycleId: null, examDate: null, priority: 1 },
          { examCode: "g2", attemptCycleId: null, examDate: null, priority: 2 },
        ],
        queues: new Map([
          ["g4", [shared, ...queue("g4", 3)]],
          ["g2", [shared, ...queue("g2", 3)]],
        ]),
        planned,
      }),
    );
    expect(items.filter((i) => i.kind === "lesson" && i.topicId === "shared-1")).toHaveLength(1);
    expect(planned.has("shared-1")).toBe(true);
    expect(items.some((i) => i.examCode === "g2" && i.kind === "lesson")).toBe(true);
  });
});

describe("missed days + Today Card (invariants 5, 6)", () => {
  const it_ = (day: string, status: PlanItemRecord["status"], order = 0) => ({ day, status, order });
  it("counts past days with pending items and nothing done", () => {
    const items = [it_("2026-11-01", "pending"), it_("2026-10-31", "pending"), it_("2026-10-31", "done"), it_("2026-10-30", "pending"), it_("2026-11-02", "pending"), it_("2026-10-29", "skipped")];
    expect(missedDays(items, "2026-11-02")).toEqual(["2026-10-30", "2026-11-01"]);
  });
  it("Today Card = first pending of today by order", () => {
    const items = [it_("2026-11-02", "done", 0), it_("2026-11-02", "pending", 2), it_("2026-11-02", "pending", 1), it_("2026-11-03", "pending", 0)];
    expect(todayCard(items, "2026-11-02")?.order).toBe(1);
    expect(todayCard([], "2026-11-02")).toBeNull();
  });
});

// ------------------------------------------------------------------ use cases

describe("plan use cases (FakeClock)", () => {
  it("invariant 1: needs a main exam; one plan per user; ≤ 3 exams with priority 1 first", async () => {
    const { api, w } = setup();
    w.targets = [];
    await expect(api.put(USER, { weekdayMinutes: 60, weekendMinutes: 120 })).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
    await expect(api.get(USER)).rejects.toMatchObject({ code: "PLAN_NOT_FOUND" });
    await expect(api.days(USER, "2026-11-02", "2026-11-03")).rejects.toMatchObject({ code: "PLAN_NOT_FOUND" });
    await expect(api.rebalance(USER)).rejects.toMatchObject({ code: "PLAN_NOT_FOUND" });
    w.targets = [
      { examCode: "g4", isMain: true, attemptCycleId: "c1", examDate: "2027-06-01" },
      { examCode: "g2", isMain: false, attemptCycleId: null, examDate: null },
      { examCode: "x", isMain: false, attemptCycleId: null, examDate: null },
      { examCode: "y", isMain: false, attemptCycleId: null, examDate: null },
    ];
    const p = await api.put(USER, { weekdayMinutes: 60, weekendMinutes: 120 });
    expect(p.exams.map((e) => [e.examCode, e.priority])).toEqual([
      ["g4", 1],
      ["g2", 2],
      ["x", 3],
    ]);
    expect(p.exams[0]?.daysLeft).toBe(211);
    expect(p.exams[1]?.daysLeft).toBeNull();
    expect(p.pocketMinutes).toBe(10);
    expect(p.balance).toBe(0);
    expect(p.configVersion).toBe(PLAN_CONFIG.version);
    const again = await api.put(USER, { weekdayMinutes: 30, weekendMinutes: 30, balance: 1 });
    expect(again.id).toBe(p.id);
    expect(again.starterPathUntil).toBe(p.starterPathUntil);
  });

  it("invariant 4: new plan = 7-day starter path, then the mix; 14-day horizon", async () => {
    const { api } = setup();
    const p = await api.put(USER, { weekdayMinutes: 60, weekendMinutes: 90 });
    expect(p.starterPathUntil).toBe("2026-11-08");
    const days = await api.days(USER, "2026-11-02", "2026-11-16");
    expect(days.days).toHaveLength(15);
    const d1 = days.days[0];
    expect(d1?.items.every((i) => i.kind === "lesson" || i.kind === "lit_check")).toBe(true);
    expect(d1?.items[0]?.topicId).toBe("g4-000");
    expect(days.days[7]?.items.some((i) => i.kind === "relight")).toBe(true); // day 8: normal mix
    expect(days.days[14]?.items).toEqual([]); // outside the horizon
    expect(days.days[5]?.minutes).toBe(90); // Saturday 7 Nov
    // no lamp is planned twice
    const lessons = days.days.flatMap((d) => d.items.filter((i) => i.kind === "lesson").map((i) => i.topicId));
    expect(new Set(lessons).size).toBe(lessons.length);
  });

  it("Lit lamps are not planned again", async () => {
    const { api, w } = setup();
    w.lit = new Set(["g4-000", "g4-001"]);
    await api.put(USER, { weekdayMinutes: 60, weekendMinutes: 60 });
    const d = await api.days(USER, "2026-11-02", "2026-11-02");
    expect(d.days[0]?.items[0]?.topicId).toBe("g4-002");
  });

  it("days: max 62 per request; to before from refused", async () => {
    const { api } = setup();
    await api.put(USER, { weekdayMinutes: 60, weekendMinutes: 60 });
    await expect(api.days(USER, "2026-11-02", "2027-01-03")).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
    await expect(api.days(USER, "2026-11-02", "2026-11-01")).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
    expect((await api.days(USER, "2026-11-02", "2027-01-02")).days).toHaveLength(62);
  });

  it("Today without a plan: hasPlan false, rank + relight + pocket sessions", async () => {
    const { api, clock } = setup();
    const t = await api.today(USER);
    expect(t).toMatchObject({ hasPlan: false, todayCard: null, stretch: "normal", welcomeBack: null, day: "2026-11-02", pocketSessions: [5, 10, 15] });
    expect(t.relight).toEqual({ count: 2, minutes: 10 });
    expect(t.serverNow).toBe(clock.now().toISOString());
  });

  it("Today: the IST day (18:30 UTC is the next day) and the first pending item", async () => {
    const { api, clock } = setup("2026-11-02T18:29:00.000Z");
    await api.put(USER, { weekdayMinutes: 60, weekendMinutes: 60 });
    expect((await api.today(USER)).day).toBe("2026-11-02");
    clock.set("2026-11-02T18:30:00.000Z");
    const t = await api.today(USER);
    expect(t.day).toBe("2026-11-03");
    expect(t.todayCard?.day).toBe("2026-11-03");
    expect(t.hasPlan).toBe(true);
  });

  it("invariant 10: item status is owner-only, idempotent, and done writes the study log", async () => {
    const { api, f } = setup();
    await api.put(USER, { weekdayMinutes: 60, weekendMinutes: 60 });
    const card = (await api.today(USER)).todayCard;
    if (!card) throw new Error("no card");
    await expect(api.updateItem("someone-else", card.id, "done")).rejects.toMatchObject({ code: "NOT_FOUND" });
    await expect(api.updateItem(USER, randomUUID(), "done")).rejects.toMatchObject({ code: "NOT_FOUND" });
    expect((await api.updateItem(USER, card.id, "done")).status).toBe("done");
    expect((await api.updateItem(USER, card.id, "skipped")).status).toBe("done"); // done never changes
    expect(f.logs).toHaveLength(1);
    expect(f.logs[0]).toMatchObject({ source: "online", kind: card.kind, minutes: card.minutes });
    const next = (await api.today(USER)).todayCard;
    expect(next?.id).not.toBe(card.id);
    if (!next) throw new Error("no next");
    expect((await api.updateItem(USER, next.id, "skipped")).status).toBe("skipped");
    expect(f.logs).toHaveLength(1);
  });

  it("invariant 6: 2 missed days -> kind rebalance once per IST day; topics come back first", async () => {
    const { api, clock, f, events } = setup();
    await api.put(USER, { weekdayMinutes: 60, weekendMinutes: 60 });
    const firstTopic = (await api.days(USER, "2026-11-02", "2026-11-02")).days[0]?.items[0]?.topicId;
    clock.advanceDays(1);
    let t = await api.today(USER); // one missed day: nothing moves
    expect(t.welcomeBack).toBeNull();
    clock.advanceDays(1);
    t = await api.today(USER);
    expect(t.welcomeBack).toBe(WELCOME_BACK);
    expect(t.welcomeBack?.toLowerCase()).not.toContain("streak");
    expect(t.todayCard?.topicId).toBe(firstTopic);
    expect(f.items.filter((i) => i.status === "moved").length).toBeGreaterThan(0);
    expect(f.items.some((i) => i.status === "pending" && i.day < "2026-11-04")).toBe(false);
    expect(events.map((e) => e.type)).toEqual(["plan.rebalanced"]);
    const before = f.items.length;
    const again = await api.today(USER); // same day: no second rebalance
    expect(again.welcomeBack).toBe(WELCOME_BACK);
    expect(f.items.length).toBe(before);
    expect(events).toHaveLength(1);
  });

  it("user rebalance always runs; done items never change (invariant 7)", async () => {
    const { api, f } = setup();
    await api.put(USER, { weekdayMinutes: 60, weekendMinutes: 60 });
    const card = (await api.today(USER)).todayCard;
    if (!card) throw new Error("no card");
    await api.updateItem(USER, card.id, "done");
    const p = await api.rebalance(USER);
    expect(p.lastRebalancedAt).not.toBeNull();
    expect(f.items.find((i) => i.id === card.id)?.status).toBe("done");
    const today = await api.days(USER, "2026-11-02", "2026-11-02");
    expect(today.days[0]?.items[0]?.id).toBe(card.id);
    // the done lamp is not planned again
    const all = await api.days(USER, "2026-11-02", "2026-11-15");
    expect(all.days.flatMap((d) => d.items).filter((i) => i.topicId === card.topicId && i.kind === card.kind)).toHaveLength(1);
  });

  it("rolling horizon: Today tops up only the missing days", async () => {
    const { api, clock } = setup();
    await api.put(USER, { weekdayMinutes: 60, weekendMinutes: 60 });
    const first = (await api.days(USER, "2026-11-02", "2026-11-15")).days.map((d) => d.items.map((i) => i.id));
    clock.advanceDays(1);
    // mark today's items done so no rebalance is due
    await api.today(USER);
    const after = await api.days(USER, "2026-11-03", "2026-11-16");
    expect(after.days[0]?.items.map((i) => i.id)).toEqual(first[1]);
    expect(after.days[13]?.items.length).toBeGreaterThan(0);
  });

  it("Final Stretch shows on Today and the plan", async () => {
    const { api, w } = setup("2026-11-02T04:30:00.000Z", {
      targets: [{ examCode: "g4", isMain: true, attemptCycleId: "c-g4", examDate: "2026-11-20" }],
    });
    const p = await api.put(USER, { weekdayMinutes: 60, weekendMinutes: 60 });
    expect(p.stretch).toBe("d30");
    expect((await api.today(USER)).stretch).toBe("d30");
    expect(w.targets).toHaveLength(1);
  });

  it("several exams: g2 gets lessons too, and its date boost applies", async () => {
    const { api } = setup("2026-11-02T04:30:00.000Z", {
      targets: [
        { examCode: "g4", isMain: true, attemptCycleId: null, examDate: null },
        { examCode: "g2", isMain: false, attemptCycleId: null, examDate: "2026-12-15" },
      ],
    });
    await api.put(USER, { weekdayMinutes: 120, weekendMinutes: 120 });
    const d = await api.days(USER, "2026-11-09", "2026-11-09"); // after the starter path
    const lessons = d.days[0]?.items.filter((i) => i.kind === "lesson") ?? [];
    expect(lessons.some((i) => i.examCode === "g2")).toBe(true);
  });

  it("exams.date_changed refreshes the date and rebuilds future days only", async () => {
    const { api, w } = setup("2026-11-02T04:30:00.000Z", {
      targets: [{ examCode: "g4", isMain: true, attemptCycleId: "c-g4", examDate: "2027-06-01" }],
    });
    await api.put(USER, { weekdayMinutes: 60, weekendMinutes: 60 });
    w.targets = [{ examCode: "g4", isMain: true, attemptCycleId: "c-g4", examDate: "2026-11-25" }];
    expect(await api.onDateChanged({ examCode: "g4", cycleId: "c-g4" })).toEqual({ plans: 1 });
    expect(await api.onDateChanged({ examCode: "g4", cycleId: "other" })).toEqual({ plans: 0 });
    const p = await api.get(USER);
    expect(p.exams[0]?.examDate).toBe("2026-11-25");
    expect(p.stretch).toBe("d30");
  });

  it("nightly rebalanceDue: only users with 2 missed days, once per day", async () => {
    const { api, clock } = setup();
    await api.put(USER, { weekdayMinutes: 60, weekendMinutes: 60 });
    clock.advanceDays(2);
    expect(await api.rebalanceDue()).toEqual({ checked: 1, rebalanced: 1 });
    expect(await api.rebalanceDue()).toEqual({ checked: 0, rebalanced: 0 });
  });

  it("offline plan_item_status (§39): once per clientActionId, too old -> study log only", async () => {
    const { api, clock, f } = setup();
    await api.put(USER, { weekdayMinutes: 60, weekendMinutes: 60 });
    const card = (await api.today(USER)).todayCard;
    if (!card) throw new Error("no card");
    const a = { clientActionId: randomUUID(), clientAt: clock.now().toISOString(), kind: "plan_item_status" as const, itemId: card.id, status: "done" as const };
    expect(await api.syncAction(USER, a)).toEqual({ clientActionId: a.clientActionId, status: "accepted", errorCode: null });
    expect(await api.syncAction(USER, a)).toMatchObject({ status: "duplicate" });
    expect(f.items.find((i) => i.id === card.id)?.status).toBe("done");
    // already closed item: accepted, nothing changes
    const b = { ...a, clientActionId: randomUUID(), status: "skipped" as const };
    expect(await api.syncAction(USER, b)).toMatchObject({ status: "accepted" });
    expect(f.items.find((i) => i.id === card.id)?.status).toBe("done");
    // unknown / not mine
    expect(await api.syncAction(USER, { ...a, clientActionId: randomUUID(), itemId: randomUUID() })).toMatchObject({ status: "rejected", errorCode: "NOT_FOUND" });
    expect(await api.syncAction("other", { ...a, clientActionId: randomUUID() })).toMatchObject({ status: "rejected" });
    // too old
    const other = (await api.days(USER, "2026-11-03", "2026-11-03")).days[0]?.items[0];
    if (!other) throw new Error("no item");
    const old = { ...a, clientActionId: randomUUID(), itemId: other.id, clientAt: "2026-10-20T04:30:00.000Z" };
    expect(await api.syncAction(USER, old)).toMatchObject({ status: "study_log_only", errorCode: "SYNC_ACTION_TOO_OLD" });
    expect(f.items.find((i) => i.id === other.id)?.status).toBe("pending");
    // future client clock is clamped to server time
    const fut = { ...a, clientActionId: randomUUID(), itemId: other.id, clientAt: "2030-01-01T00:00:00.000Z" };
    expect(await api.syncAction(USER, fut)).toMatchObject({ status: "accepted" });
    expect(f.logs.find((l) => l.clientActionId === fut.clientActionId)?.at.toISOString()).toBe(clock.now().toISOString());
  });

  it("SEC-P2-L2: another user's clientActionId does not block mine (dedupe is per user)", async () => {
    const { api, clock, f } = setup();
    await api.put(USER, { weekdayMinutes: 60, weekendMinutes: 60 });
    const card = (await api.today(USER)).todayCard;
    if (!card) throw new Error("no card");
    const shared = randomUUID();
    f.logs.push({ userId: "attacker", kind: "plan_item_status", topicId: null, minutes: 0, at: clock.now(), istDay: "2026-11-04", source: "offline_sync", clientActionId: shared });
    const a = { clientActionId: shared, clientAt: clock.now().toISOString(), kind: "plan_item_status" as const, itemId: card.id, status: "done" as const };
    expect(await api.syncAction(USER, a)).toMatchObject({ status: "accepted" });
    expect(await api.syncAction(USER, a)).toMatchObject({ status: "duplicate" });
  });

  it("a unique-key race on clientActionId is reported as duplicate", async () => {
    const { api, f, clock } = setup();
    await api.put(USER, { weekdayMinutes: 60, weekendMinutes: 60 });
    const card = (await api.today(USER)).todayCard;
    if (!card) throw new Error("no card");
    f.repo.setItemStatus = async () => {
      throw Object.assign(new Error("unique"), { code: "P2002" });
    };
    const a = { clientActionId: randomUUID(), clientAt: clock.now().toISOString(), kind: "plan_item_status" as const, itemId: card.id, status: "done" as const };
    expect(await api.syncAction(USER, a)).toMatchObject({ status: "duplicate" });
    f.repo.setItemStatus = async () => {
      throw new Error("db down");
    };
    await expect(api.syncAction(USER, { ...a, clientActionId: randomUUID() })).rejects.toThrow("db down");
  });
});

describe("planPortsFrom (composition through public APIs)", () => {
  it("maps exams, syllabus priorities and mastery Lit / rank / relight", async () => {
    const p = planPortsFrom({
      exams: { planTargets: async () => [{ examCode: "g4", isMain: true, attemptCycleId: null, examDate: null }] },
      syllabus: {
        topicsForExam: async () => [
          { id: "t1", code: "a", name: "A", order: 1, subject: { code: "s", name: "S", order: 1 }, examCodes: ["g4"], priorities: { g4: 2 } },
          { id: "t2", code: "b", name: "B", order: 2, subject: { code: "s", name: "S", order: 1 }, examCodes: ["g4"] },
        ],
      },
      mastery: {
        summary: async () => ({ rank: { r: 1 } }) as never,
        relightQueue: async () => ({ items: [{}, {}] as never, totalMinutes: 12 }),
        statesOf: async (_u, ids) => ids.map((id) => ({ topicId: id, litAt: id === "t1" ? "2026-11-01T00:00:00.000Z" : null }) as never),
      },
    });
    expect(await p.targets("u")).toHaveLength(1);
    expect(await p.topicsForExam("g4")).toEqual([
      { topicId: "t1", name: "A", priority: 2 },
      { topicId: "t2", name: "B", priority: 0 },
    ]);
    expect([...(await p.litTopicIds("u", ["t1", "t2"]))]).toEqual(["t1"]);
    expect(await p.rank("u")).toEqual({ r: 1 });
    expect(await p.relight("u")).toEqual({ count: 2, minutes: 12 });
  });
});

describe("exams: attempt cycles for plan (R2)", () => {
  const cycle = (id: string, status: string, dates: (string | null)[]) => ({ id, examCode: "g4", status, stageDates: dates.map((date, i) => ({ stageCode: `s${i}`, date })) });
  it("next stage date is the earliest date on or after today", () => {
    expect(nextStageDate(cycle("c", "announced", ["2026-10-01", "2026-12-01", "2026-11-15", null]), "2026-11-02")).toBe("2026-11-15");
    expect(nextStageDate(cycle("c", "announced", ["2026-11-02"]), "2026-11-02")).toBe("2026-11-02");
    expect(nextStageDate(cycle("c", "announced", ["2026-10-01", null]), "2026-11-02")).toBeNull();
  });
  it("picks the chosen cycle, else announced, else expected", () => {
    const cs = [cycle("e", "expected", []), cycle("a", "announced", []), cycle("x", "closed", [])];
    expect(pickCycle(cs, "x")?.id).toBe("x");
    expect(pickCycle(cs, "missing")?.id).toBe("a");
    expect(pickCycle(cs, null)?.id).toBe("a");
    expect(pickCycle([cycle("e", "expected", [])], undefined)?.id).toBe("e");
    expect(pickCycle([], null)).toBeNull();
  });
  it("PUT /v1/me/exams attemptCycles: only for chosen exams", () => {
    expect(validateExamChoice({ mainExamCode: "a", otherExamCodes: ["b"], attemptCycles: { a: "0199f5a0-0000-7000-8000-0000000000aa" } })).toEqual([
      { examCode: "a", isMain: true, attemptCycleId: "0199f5a0-0000-7000-8000-0000000000aa" },
      { examCode: "b", isMain: false },
    ]);
    expect(() => validateExamChoice({ mainExamCode: "a", attemptCycles: { z: "0199f5a0-0000-7000-8000-0000000000aa" } })).toThrowError(
      expect.objectContaining({ code: "VALIDATION_FAILED" }),
    );
  });
});

describe("exams.planTargets + attemptCycles check (R2, FakeClock)", () => {
  const exam = (code: string) => ({ code, status: "published" }) as never;
  const C1 = "0199f5a0-0000-7000-8000-0000000000c1";
  function repo(withCycles = true) {
    let choices: { examCode: string; isMain: boolean; attemptCycleId?: string | null }[] = [];
    const r = {
      listPublished: async () => [exam("g4"), exam("g2")],
      findByCode: async () => null,
      listPublishedWithRules: async () => [],
      getChoices: async () => choices,
      replaceChoices: async (_u: string, c: typeof choices) => {
        choices = c;
      },
      ...(withCycles
        ? {
            cyclesForExams: async () => [
              { id: C1, examCode: "g4", status: "expected", stageDates: [{ stageCode: "prelims", date: "2027-06-01" }] },
              { id: "c-now", examCode: "g4", status: "announced", stageDates: [{ stageCode: "prelims", date: "2026-10-01" }, { stageCode: "mains", date: "2026-12-01" }] },
            ],
          }
        : {}),
    };
    return r;
  }

  it("main first, chosen cycle wins, else the announced cycle; unpublished exams left out", async () => {
    const { createExamsModule } = await import("../../src/modules/exams/index.js");
    const r = repo();
    const exams = createExamsModule({ repository: r as never, clock: new FakeClock("2026-11-02T04:30:00.000Z") });
    await r.replaceChoices("u", [
      { examCode: "gone", isMain: false },
      { examCode: "g2", isMain: false },
      { examCode: "g4", isMain: true },
    ]);
    expect(await exams.planTargets("u")).toEqual([
      { examCode: "g4", isMain: true, attemptCycleId: "c-now", examDate: "2026-12-01" },
      { examCode: "g2", isMain: false, attemptCycleId: null, examDate: null },
    ]);
    await exams.setMyExams("u", { mainExamCode: "g4", attemptCycles: { g4: C1 } });
    expect(await exams.planTargets("u")).toEqual([{ examCode: "g4", isMain: true, attemptCycleId: C1, examDate: "2027-06-01" }]);
  });

  it("an unknown cycle or a cycle of another exam is refused; no cycle repo = no targets dates", async () => {
    const { createExamsModule } = await import("../../src/modules/exams/index.js");
    const exams = createExamsModule({ repository: repo() as never, clock: new FakeClock("2026-11-02T04:30:00.000Z") });
    await expect(exams.setMyExams("u", { mainExamCode: "g2", attemptCycles: { g2: C1 } })).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
    const bare = createExamsModule({ repository: repo(false) as never, clock: new FakeClock("2026-11-02T04:30:00.000Z") });
    await expect(bare.setMyExams("u", { mainExamCode: "g4", attemptCycles: { g4: C1 } })).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
    await bare.setMyExams("u", { mainExamCode: "g4" });
    expect(await bare.planTargets("u")).toEqual([{ examCode: "g4", isMain: true, attemptCycleId: null, examDate: null }]);
  });
});
