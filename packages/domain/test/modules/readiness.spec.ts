// BOLT-0013 readiness: domain invariants 1-9 (U-readiness domain model), §19.5 Q41-Q50, §19.10 Q100, §11.
import { describe, expect, it } from "vitest";
import { FakeClock } from "@heymey/testing";
import { ReadinessMeter, SundayReport } from "@heymey/contracts";
import {
  FORBIDDEN_REPORT_WORDS,
  READINESS_CONFIG,
  barValues,
  buildReportBody,
  createReadinessModule,
  istWeekOf,
  labelFor,
  pct,
  readyForFullMocks,
  suggestionFor,
  type Evidence,
  type ReadinessRepository,
  type ReportRow,
  type SnapshotRow,
  type WeekNumbers,
} from "../../src/modules/readiness/index.js";

const U = "0199f5a0-0000-7000-8000-00000000a001";
const OTHER = "0199f5a0-0000-7000-8000-00000000a002";

class MemRepo implements ReadinessRepository {
  snaps = new Map<string, SnapshotRow>();
  reports: ReportRow[] = [];
  seq = 0;
  async upsertSnapshot(s: SnapshotRow) {
    this.snaps.set(`${s.userId}|${s.examCode}|${s.istDay}`, s);
  }
  async snapshotsBetween(userId: string, examCode: string, from: string, to: string) {
    return [...this.snaps.values()].filter((s) => s.userId === userId && s.examCode === examCode && s.istDay >= from && s.istDay <= to).sort((a, b) => a.istDay.localeCompare(b.istDay));
  }
  async hasReport(userId: string, weekStart: string) {
    return this.reports.some((r) => r.userId === userId && r.weekStart === weekStart);
  }
  async createReport(r: Omit<ReportRow, "id">) {
    const found = this.reports.find((x) => x.userId === r.userId && x.weekStart === r.weekStart);
    if (found) return { row: found, created: false };
    const row = { ...r, id: `0199f5a0-0000-7000-8000-${String(++this.seq).padStart(12, "0")}` };
    this.reports.push(row);
    return { row, created: true };
  }
  async pageReports(userId: string, after: { createdAt: Date; id: string } | null, limit: number) {
    return this.reports
      .filter((r) => r.userId === userId)
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime() || b.id.localeCompare(a.id))
      .filter((r) => !after || r.createdAt < after.createdAt || (r.createdAt.getTime() === after.createdAt.getTime() && r.id < after.id))
      .slice(0, limit);
  }
  async getReport(id: string) {
    return this.reports.find((r) => r.id === id) ?? null;
  }
}

type Ring = { lit: boolean; steadyLevel: number; gold: boolean; dim: "bright" | "dimming" | "dim" };

function world(opts: {
  total?: number;
  rings?: Ring[];
  follows?: boolean;
  mocks?: { examCode: string; score: number; max: number; status?: "submitted" | "expired" | "in_progress"; startedAt?: string }[];
  isPro?: boolean;
  conductingBody?: string;
  speed?: number | null;
  activeUsers?: string[];
  failUser?: string;
}) {
  const clock = new FakeClock("2026-11-08T02:30:00.000Z"); // Sunday 08:00 IST
  const repo = new MemRepo();
  const rings = opts.rings ?? [];
  const counts = {
    totalLamps: opts.total ?? 10,
    lit: rings.filter((r) => r.lit).length,
    steady: rings.filter((r) => r.steadyLevel > 0).length,
    gold: rings.filter((r) => r.gold).length,
    dimming: rings.filter((r) => r.lit && r.dim === "dimming").length,
    dim: rings.filter((r) => r.lit && r.dim === "dim").length,
  };
  const mocks = (opts.mocks ?? []).map((m, i) => ({ ...m, attemptId: `0199f5a0-0000-7000-8000-0000000b${String(i).padStart(4, "0")}` }));
  const api = createReadinessModule({
    repository: repo,
    clock,
    mastery: {
      summary: async (userId) => {
        if (userId === opts.failUser) throw new Error("boom");
        return {
          rank: { level: 1, title: "t", familyCode: null, xp: 0, xpForThisLevel: 0, xpForNextLevel: 10, note: "n" },
          counts,
          byExam: opts.follows === false ? [] : [{ examCode: "tnpsc-group-4", counts }],
          serverNow: clock.now().toISOString(),
        };
      },
      topicStates: async (_u, q) => {
        const start = q.cursor ? Number(q.cursor) : 0;
        const slice = rings.slice(start, start + 2); // tiny pages to exercise paging
        return {
          items: slice.map((ring, i) => ({ topicId: `t${start + i}`, ring, litAt: null, goldAt: null, lessonCompletedAt: null, nextDueAt: null, nextCheck: "none" as const, updatedAt: clock.now().toISOString() })),
          nextCursor: start + 2 < rings.length ? String(start + 2) : null,
          serverNow: clock.now().toISOString(),
        };
      },
    },
    masteryActivity: {
      activeUserIds: async ({ afterUserId, limit }) => (opts.activeUsers ?? []).filter((u) => !afterUserId || u > afterUserId).slice(0, limit),
      weekCounts: async () => ({ lit: 4, steadyEarned: 3, gold: 1, relit: 2 }),
    },
    examHall: {
      history: async (_u, cursor, limit) => {
        const start = cursor ? Number(cursor) : 0;
        const items = mocks.slice(start, start + limit).map((m) => ({
          attemptId: m.attemptId,
          mockId: m.attemptId,
          title: "Mock",
          kind: "full" as never,
          status: m.status ?? "submitted",
          startedAt: m.startedAt ?? "2026-11-05T04:30:00.000Z",
          scoreDisplay: null,
        }));
        return { items, nextCursor: start + limit < mocks.length ? String(start + limit) : null };
      },
      report: async (_u, attemptId) => {
        const m = mocks.find((x) => x.attemptId === attemptId);
        if (!m) throw new Error("no");
        return { examCode: m.examCode, score: { numerator: m.score * 2, denominator: 2 }, maxScore: { numerator: m.max, denominator: 1 } } as never;
      },
    },
    exams: { examInfo: async (code) => (code === "unknown-exam" ? null : { conductingBody: opts.conductingBody ?? "TNPSC", paperSecondsPerQuestion: 54 }) },
    practice: {
      speed: async () => (opts.speed ? { medianSeconds: opts.speed } : null),
      week: async () => ({ answered: 40, correct: 30, studyMinutes: 95 }),
    },
    entitlements: { isPro: async () => opts.isPro ?? false },
  });
  return { api, repo, clock };
}

const lit = (n: number, steadyLevel = 0, dim: Ring["dim"] = "bright", gold = false): Ring[] => Array.from({ length: n }, () => ({ lit: true, steadyLevel, gold, dim }));
const unlit = (n: number): Ring[] => Array.from({ length: n }, () => ({ lit: false, steadyLevel: 0, gold: false, dim: "bright" }));

describe("readiness bars (invariants 1-2)", () => {
  it("pct floors and clamps; zero whole is 0", () => {
    expect([pct(79, 100), pct(799, 1000), pct(1, 3), pct(5, 0), pct(-1, 5), pct(9, 5)]).toEqual([79, 79, 33, 0, 0, 100]);
  });

  it("no evidence -> every bar null", () => {
    expect(barValues({ lamps: null, mocks: [], speed: null })).toEqual({ coverage: null, memory: null, examPerformance: null, speed: null });
    expect(barValues({ lamps: { total: 0, lit: 0, steady: 0, gold: 0, steadyNotDim: 0 }, mocks: [], speed: null }).coverage).toBeNull();
  });

  it("coverage = lit/total, memory = steady-not-dim/lit, exam = mean of last 3 mocks, speed = paper/median", () => {
    const e: Evidence = {
      lamps: { total: 10, lit: 5, steady: 4, gold: 1, steadyNotDim: 3 },
      mocks: [{ score: 50, max: 100 }, { score: 70, max: 100 }, { score: 90, max: 100 }, { score: 0, max: 100 }],
      speed: { medianSeconds: 60, paperSeconds: 54 },
    };
    expect(barValues(e)).toEqual({ coverage: 50, memory: 60, examPerformance: 70, speed: 90 });
    expect(barValues({ ...e, speed: { medianSeconds: 30, paperSeconds: 54 } }).speed).toBe(100);
    expect(barValues({ ...e, mocks: [{ score: 1, max: 0 }] }).examPerformance).toBeNull();
  });
});

describe("label rules (invariant 3, D-2026-10-22-29 boundary table)", () => {
  const v = (coverage: number | null, memory: number | null, examPerformance: number | null) => ({ coverage, memory, examPerformance, speed: null });
  it.each([
    [v(80, 70, 60), "mock_ready"],
    [v(79, 70, 60), "close"],
    [v(80, 69, 60), "close"],
    [v(80, 70, 59), "close"],
    [v(80, 70, null), "close"],
    [v(60, 50, null), "close"],
    [v(59, 50, null), "building"],
    [v(60, 49, null), "building"],
    [v(60, null, null), "building"],
    [v(20, null, null), "building"],
    [v(19, 100, 100), "not_yet"],
    [v(null, null, null), "not_yet"],
  ] as const)("%o -> %s", (values, label) => {
    expect(labelFor(values, true)).toBe(label);
  });

  it("Q27: exams without label rules this phase stay not_yet", () => {
    expect(labelFor(v(100, 100, 100), false)).toBe("not_yet");
  });

  it("full-mocks badge at coverage 60 + memory 50; null never qualifies", () => {
    expect(readyForFullMocks(v(60, 50, null))).toBe(true);
    expect(readyForFullMocks(v(60, 49, null))).toBe(false);
    expect(readyForFullMocks(v(null, null, null))).toBe(false);
    expect(READINESS_CONFIG.sundayReport.cron).toBe("0 8 * * 0");
  });

  it("suggestions are template text for each state", () => {
    const lamps = { total: 10, lit: 8, steady: 6, gold: 0, steadyNotDim: 6 };
    const ready = v(80, 75, null);
    expect(suggestionFor({ lamps: null, mocks: [], speed: null }, v(null, null, null), true)).toContain("My exams");
    expect(suggestionFor({ lamps: { ...lamps, lit: 0 }, mocks: [], speed: null }, v(0, null, null), true)).toBe("Light a few lamps to see your readiness.");
    expect(suggestionFor({ lamps, mocks: [], speed: null }, v(30, 10, null), true)).toContain("sectional test");
    expect(suggestionFor({ lamps, mocks: [], speed: null }, ready, false)).toContain("Labels for this exam come later");
    expect(suggestionFor({ lamps, mocks: [], speed: null }, ready, true)).toContain("ready for full mocks");
    const three = [{ score: 1, max: 2 }, { score: 1, max: 2 }, { score: 1, max: 2 }];
    expect(suggestionFor({ lamps, mocks: three, speed: null }, ready, true)).toBeNull();
  });
});

describe("meter use case (invariants 4, 5, 7, 9)", () => {
  const rings = [...lit(4, 1), ...lit(2, 2, "dim"), ...lit(2, 0), ...unlit(2)]; // 8 lit of 10, 4 steady-not-dim
  it("free user: two bars, two locked with null, label from all evidence, no overall percentage, snapshot stored", async () => {
    const { api, repo } = world({ rings, mocks: [{ examCode: "tnpsc-group-4", score: 70, max: 100 }], speed: 60 });
    const m = await api.meter(U, "tnpsc-group-4");
    expect(ReadinessMeter.parse(m)).toBeTruthy();
    expect(m.bars.map((b) => [b.key, b.value, b.locked])).toEqual([
      ["coverage", 80, false],
      ["memory", 50, false],
      ["exam_performance", null, true],
      ["speed", null, true],
    ]);
    expect(m.bars[2]?.evidence).toBe("Part of HeyMey Pro.");
    expect(m.label).toBe("close");
    expect(m.coverage).toEqual({ litPct: 80, steadyPct: 60, goldPct: 0 });
    expect(m.readyForFullMocks).toBe(true);
    expect(Object.keys(m).sort()).toEqual(["bars", "computedAt", "coverage", "examCode", "label", "readyForFullMocks", "suggestion"]);
    expect(JSON.stringify(m)).not.toMatch(/overall|total_?pct|readinessPct|score"/i);
    const snap = [...repo.snaps.values()][0];
    expect(snap).toMatchObject({ istDay: "2026-11-08", label: "close", coverage: 80, memory: 50, examPerformance: 70, speed: 90 });
  });

  it("Pro user sees all four bars with evidence text; other exam mocks are ignored", async () => {
    const { api } = world({
      rings,
      isPro: true,
      speed: 60,
      mocks: [
        { examCode: "ssc-cgl", score: 10, max: 100 },
        { examCode: "tnpsc-group-4", score: 60, max: 100, status: "expired" },
        { examCode: "tnpsc-group-4", score: 80, max: 100 },
      ],
    });
    const m = await api.meter(U, "tnpsc-group-4");
    expect(m.bars.map((b) => b.value)).toEqual([80, 50, 80, 90]);
    expect(m.bars.map((b) => b.evidence)).toEqual([
      "8 of 10 lamps lit",
      "4 of 8 lit lamps are Steady and not dim",
      "Average of your last 1 mock",
      "60 s per question; the paper gives 54 s",
    ]);
  });

  it("not following the exam: bars null, label not_yet, no snapshot", async () => {
    const { api, repo } = world({ follows: false, isPro: true });
    const m = await api.meter(U, "tnpsc-group-4");
    expect(m.label).toBe("not_yet");
    expect(m.bars.map((b) => b.value)).toEqual([null, null, null, null]);
    expect(m.bars.map((b) => b.evidence)).toEqual(["No lamps yet", "Light a lamp first", "No mocks yet", "No timed practice yet"]);
    expect(repo.snaps.size).toBe(0);
  });

  it("Q27: a non-TN exam shows bars with label not_yet", async () => {
    const { api } = world({ rings: lit(10, 3), conductingBody: "SSC" });
    const m = await api.meter(U, "tnpsc-group-4");
    expect(m.bars[0]?.value).toBe(100);
    expect(m.label).toBe("not_yet");
  });

  it("unknown exam -> EXAM_NOT_FOUND", async () => {
    const { api } = world({});
    await expect(api.meter(U, "unknown-exam")).rejects.toMatchObject({ code: "EXAM_NOT_FOUND" });
  });

  it("stops after the last 3 matching mocks", async () => {
    const mocks = Array.from({ length: 30 }, () => ({ examCode: "tnpsc-group-4", score: 90, max: 100 }));
    const { api } = world({ rings: lit(10, 3), isPro: true, mocks });
    const m = await api.meter(U, "tnpsc-group-4");
    expect(m.bars[2]?.evidence).toBe("Average of your last 3 mocks");
    expect(m.label).toBe("mock_ready");
  });
});

describe("trend (invariant 6)", () => {
  it("free user -> PRO_REQUIRED", async () => {
    const { api } = world({});
    await expect(api.trend(U, "tnpsc-group-4", 7)).rejects.toMatchObject({ code: "PRO_REQUIRED" });
  });

  it("Pro: one point per IST day in the window, upserted once per day", async () => {
    const { api, clock } = world({ rings: lit(3, 1), isPro: true });
    await api.meter(U, "tnpsc-group-4");
    await api.meter(U, "tnpsc-group-4"); // same day: one row
    clock.advanceDays(1);
    await api.meter(U, "tnpsc-group-4");
    clock.advanceDays(10);
    await api.meter(U, "tnpsc-group-4");
    const t7 = await api.trend(U, "tnpsc-group-4", 7);
    expect(t7.points.map((p) => p.day)).toEqual(["2026-11-19"]);
    const t30 = await api.trend(U, "tnpsc-group-4", 30);
    expect(t30.points.map((p) => p.day)).toEqual(["2026-11-08", "2026-11-09", "2026-11-19"]);
    expect(t30.points[0]).toEqual({ day: "2026-11-08", label: "building", coverage: 30, memory: 100, examPerformance: null, speed: null });
  });
});

describe("Sunday Report (invariants 7, 8)", () => {
  const n: WeekNumbers = { lampsLit: 4, steadyEarned: 3, goldEarned: 1, relit: 2, dimmedNow: 2, questionsAnswered: 40, correct: 30, mocksTaken: 1, studyMinutes: 95 };

  it("IST week starts Monday; Sunday belongs to the week before", () => {
    expect(istWeekOf(new Date("2026-11-08T02:30:00.000Z")).weekStart).toBe("2026-11-02"); // Sun 08:00 IST
    expect(istWeekOf(new Date("2026-11-08T18:29:00.000Z")).weekStart).toBe("2026-11-02"); // Sun 23:59 IST
    expect(istWeekOf(new Date("2026-11-08T18:30:00.000Z")).weekStart).toBe("2026-11-09"); // Mon 00:00 IST
    expect(istWeekOf(new Date("2026-11-02T00:00:00.000Z")).from.toISOString()).toBe("2026-11-01T18:30:00.000Z");
  });

  it("short vs full; template lines from numbers; never promises selection", () => {
    const short = buildReportBody(n, "short");
    expect(short.nextWeek).toBeNull();
    expect(short.accuracyPct).toBe(75);
    expect(short.lines).toContain("This week you lit 4 lamps and earned 3 Steady steps.");
    const full = buildReportBody(n, "full");
    expect(full.nextWeek).toEqual(["Relight your 2 dim lamps first.", "Light 4 new lamps.", "Take one full mock and read its report."]);
    const quiet = buildReportBody({ ...n, lampsLit: 0, steadyEarned: 0, goldEarned: 0, relit: 0, dimmedNow: 1, questionsAnswered: 0, correct: 0, mocksTaken: 0 }, "full");
    expect(quiet.accuracyPct).toBeNull();
    expect(quiet.lines[0]).toContain("quiet week");
    expect(quiet.nextWeek).toEqual(["Relight your 1 dim lamp first.", "Light 3 new lamps.", "Take one sectional test."]);
    for (const body of [short, full, quiet, buildReportBody({ ...n, goldEarned: 1, relit: 1, mocksTaken: 1, dimmedNow: 1, questionsAnswered: 1, correct: 1 }, "full")]) {
      for (const line of [...body.lines, ...(body.nextWeek ?? [])]) for (const w of FORBIDDEN_REPORT_WORDS) expect(line).not.toMatch(w);
    }
  });

  it("job: one report per active user per week; rerun creates nothing; failures counted, batch continues", async () => {
    const pushed: string[] = [];
    const { api, repo } = world({ activeUsers: [U, OTHER, "0199f5a0-0000-7000-8000-00000000a003"], failUser: OTHER, isPro: true, mocks: [
      { examCode: "tnpsc-group-4", score: 1, max: 2, startedAt: "2026-11-07T04:30:00.000Z" },
      { examCode: "tnpsc-group-4", score: 1, max: 2, startedAt: "2026-10-30T04:30:00.000Z" },
    ] });
    const first = await api.buildSundayReports(async (userId) => void pushed.push(userId));
    expect(first).toEqual({ weekStart: "2026-11-02", users: 3, created: 2, existing: 0, failed: 1 });
    const again = await api.buildSundayReports(async (userId) => void pushed.push(userId));
    expect(again).toEqual({ weekStart: "2026-11-02", users: 3, created: 0, existing: 2, failed: 1 });
    expect(pushed).toEqual([U, "0199f5a0-0000-7000-8000-00000000a003"]);
    const mine = repo.reports.find((r) => r.userId === U);
    expect(mine?.tier).toBe("full");
    expect(mine?.body).toMatchObject({ lampsLit: 4, steadyEarned: 3, goldEarned: 1, relit: 2, questionsAnswered: 40, accuracyPct: 75, mocksTaken: 1, studyMinutes: 95 });
  });

  it("list (owner, newest first, cursor) and get (owner only, SundayReport shape)", async () => {
    const { api, repo, clock } = world({ activeUsers: [U] });
    await api.buildSundayReports();
    clock.advanceDays(7);
    await api.buildSundayReports();
    clock.advanceDays(7);
    await api.buildSundayReports();
    expect(repo.reports).toHaveLength(3);
    const p1 = await api.listReports(U, { limit: 2 });
    expect(p1.items.map((i) => i.weekStart)).toEqual(["2026-11-16", "2026-11-09"]);
    const p2 = await api.listReports(U, { limit: 2, cursor: p1.nextCursor ?? "" });
    expect(p2).toEqual({ items: [expect.objectContaining({ weekStart: "2026-11-02", tier: "short" })], nextCursor: null });
    await expect(api.listReports(U, { limit: 2, cursor: "bad" })).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
    const id = p2.items[0]?.id ?? "";
    const r = await api.getReport(U, id);
    expect(SundayReport.parse(r).nextWeek).toBeNull();
    await expect(api.getReport(OTHER, id)).rejects.toMatchObject({ code: "REPORT_NOT_FOUND" });
    await expect(api.getReport(U, "0199f5a0-0000-7000-8000-0000000fffff")).rejects.toMatchObject({ code: "REPORT_NOT_FOUND" });
  });
});
