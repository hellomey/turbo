/**
 * Readiness Meter rules (blueprint §19.5 Q41-Q48, §11; U-readiness domain model invariants 1-5, 9). Pure: no I/O, no clock.
 * Four evidence bars and a plain label. There is NEVER one overall percentage (§19.5 Q46, invariant 4).
 */
import { READINESS_CONFIG } from "./config.js";

export type BarKey = "coverage" | "memory" | "exam_performance" | "speed";
export type ReadinessLabel = "not_yet" | "building" | "close" | "mock_ready";

/** What the server knows about one user and one exam. Every count comes from another module's public API. */
export interface Evidence {
  /** null = the user does not follow this exam (no lamps to measure). */
  lamps: { total: number; lit: number; steady: number; gold: number; steadyNotDim: number } | null;
  /** Last submitted mocks of this exam, newest first: score and maximum as plain numbers. */
  mocks: { score: number; max: number }[];
  /** Median seconds per question in timed practice vs the paper's seconds per question. null = no evidence yet. */
  speed: { medianSeconds: number; paperSeconds: number } | null;
}

export interface BarValues {
  coverage: number | null;
  memory: number | null;
  examPerformance: number | null;
  speed: number | null;
}

/** Whole percent, rounded DOWN so a threshold is only met when it is really met. */
export function pct(part: number, whole: number): number {
  if (whole <= 0) return 0;
  return Math.max(0, Math.min(100, Math.floor((part * 100) / whole)));
}

/** Invariants 1-2. A bar with no evidence is null (never 0 pretending to be data). */
export function barValues(e: Evidence): BarValues {
  const l = e.lamps;
  const coverage = l && l.total > 0 ? pct(l.lit, l.total) : null;
  const memory = l && l.lit > 0 ? pct(l.steadyNotDim, l.lit) : null;
  const mocks = e.mocks.slice(0, READINESS_CONFIG.examPerformanceLastMocks).filter((m) => m.max > 0);
  const examPerformance = mocks.length ? Math.floor(mocks.reduce((s, m) => s + pct(m.score, m.max), 0) / mocks.length) : null;
  const speed = e.speed && e.speed.medianSeconds > 0 && e.speed.paperSeconds > 0 ? pct(e.speed.paperSeconds, e.speed.medianSeconds) : null;
  return { coverage, memory, examPerformance, speed };
}

const meets = (value: number | null, min: number | null) => min === null || (value !== null && value >= min);

/**
 * Invariant 3: rules top-down from READINESS_CONFIG.labels; a bar with no evidence never satisfies a threshold.
 * Invariant 9 (Q27, D-2026-10-22-29): only exams with label rules in this phase (TN) get a label above not_yet.
 */
export function labelFor(v: BarValues, labelled: boolean): ReadinessLabel {
  if (!labelled) return "not_yet";
  for (const rule of READINESS_CONFIG.labels) {
    if (meets(v.coverage, rule.minCoverage) && meets(v.memory, rule.minMemory) && meets(v.examPerformance, rule.minExamPerformance)) return rule.label;
  }
  return "not_yet";
}

/** Q14 "Ready for full mocks" badge. */
export function readyForFullMocks(v: BarValues): boolean {
  const b = READINESS_CONFIG.fullMocksBadge;
  return meets(v.coverage, b.minCoverage) && meets(v.memory, b.minMemory);
}

/** One next step, template text only (§19.5 Q48: sectional tests are suggested). Never promises selection. */
export function suggestionFor(e: Evidence, v: BarValues, labelled: boolean): string | null {
  if (!e.lamps) return "Add this exam to My exams to see your readiness.";
  if (e.lamps.lit === 0) return "Light a few lamps to see your readiness.";
  if (!readyForFullMocks(v)) return "Take a sectional test on your weakest subject.";
  if (!labelled) return "Labels for this exam come later. Your bars are real.";
  if (e.mocks.length < READINESS_CONFIG.examPerformanceLastMocks) return "You are ready for full mocks. Take one this week.";
  return null;
}

function evidenceText(key: BarKey, e: Evidence): string {
  const l = e.lamps;
  switch (key) {
    case "coverage":
      return l ? `${l.lit} of ${l.total} lamps lit` : "No lamps yet";
    case "memory":
      return l && l.lit > 0 ? `${l.steadyNotDim} of ${l.lit} lit lamps are Steady and not dim` : "Light a lamp first";
    case "exam_performance": {
      const n = Math.min(e.mocks.length, READINESS_CONFIG.examPerformanceLastMocks);
      return n === 0 ? "No mocks yet" : `Average of your last ${n} mock${n === 1 ? "" : "s"}`;
    }
    case "speed":
      return e.speed
        ? `${Math.round(e.speed.medianSeconds)} s per question; the paper gives ${Math.round(e.speed.paperSeconds)} s`
        : "No timed practice yet";
  }
}

export interface MeterBar {
  key: BarKey;
  value: number | null;
  locked: boolean;
  evidence: string;
}

/** Invariant 5: free users see Coverage + Memory; the other two are locked with value null. */
export function meterBars(e: Evidence, v: BarValues, isPro: boolean): MeterBar[] {
  const free: readonly string[] = READINESS_CONFIG.freeBars;
  const values: Record<BarKey, number | null> = { coverage: v.coverage, memory: v.memory, exam_performance: v.examPerformance, speed: v.speed };
  return (["coverage", "memory", "exam_performance", "speed"] as const).map((key) => {
    const locked = !isPro && !free.includes(key);
    return { key, value: locked ? null : values[key], locked, evidence: locked ? "Part of HeyMey Pro." : evidenceText(key, e) };
  });
}

/** Coverage detail (§19.5 Q42): Lit / Steady / Gold percent of the whole syllabus. */
export function coverageDetail(e: Evidence): { litPct: number; steadyPct: number; goldPct: number } {
  const l = e.lamps;
  if (!l || l.total === 0) return { litPct: 0, steadyPct: 0, goldPct: 0 };
  return { litPct: pct(l.lit, l.total), steadyPct: pct(l.steady, l.total), goldPct: pct(l.gold, l.total) };
}
