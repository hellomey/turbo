/**
 * Sunday Report rules (blueprint §19.5 Q50, §19.10 Q100, §11; D-2026-10-22-30). Pure. Template text only in Phase 2:
 * every line is built from server numbers; nothing ever promises selection (U-readiness invariant 8).
 */
import { istDayKey } from "../../../shared/clock.js";

const DAY_MS = 24 * 60 * 60 * 1000;
const IST_OFFSET_MS = (5 * 60 + 30) * 60_000;

/** IST Monday (YYYY-MM-DD) of the IST week that contains `at`, and the week's [from, to) instants. Sunday ends the week. */
export function istWeekOf(at: Date): { weekStart: string; from: Date; to: Date } {
  const day = istDayKey(at);
  const utcMidnightOfDay = new Date(`${day}T00:00:00.000Z`);
  const back = (utcMidnightOfDay.getUTCDay() + 6) % 7; // Monday = 0 ... Sunday = 6
  const from = new Date(utcMidnightOfDay.getTime() - IST_OFFSET_MS - back * DAY_MS);
  return { weekStart: istDayKey(from), from, to: new Date(from.getTime() + 7 * DAY_MS) };
}

export interface WeekNumbers {
  lampsLit: number;
  steadyEarned: number;
  goldEarned: number;
  relit: number;
  dimmedNow: number;
  questionsAnswered: number;
  correct: number;
  mocksTaken: number;
  studyMinutes: number;
}

export interface ReportBody {
  lampsLit: number;
  steadyEarned: number;
  goldEarned: number;
  relit: number;
  dimmedNow: number;
  questionsAnswered: number;
  accuracyPct: number | null;
  mocksTaken: number;
  studyMinutes: number;
  lines: string[];
  nextWeek: string[] | null;
}

const plural = (n: number, one: string, many: string) => `${n} ${n === 1 ? one : many}`;

/** Words that would promise an outcome. The copy test asserts no line ever contains one (§19.10 Q100). */
export const FORBIDDEN_REPORT_WORDS: readonly RegExp[] = [/select/i, /guarantee/i, /sure to pass/i, /will pass/i, /clear the exam/i, /cut-?off/i];

/** Short (free) = this week's numbers; full (Pro) adds next week's plan (§11). */
export function buildReportBody(n: WeekNumbers, tier: "short" | "full"): ReportBody {
  const accuracyPct = n.questionsAnswered > 0 ? Math.floor((n.correct * 100) / n.questionsAnswered) : null;
  const lines: string[] = [];
  const active = n.lampsLit + n.steadyEarned + n.goldEarned + n.relit + n.questionsAnswered + n.mocksTaken > 0;
  if (!active) lines.push("A quiet week. One short lesson today is a good restart.");
  else {
    lines.push(`This week you lit ${plural(n.lampsLit, "lamp", "lamps")} and earned ${plural(n.steadyEarned, "Steady step", "Steady steps")}.`);
    if (n.goldEarned > 0) lines.push(`You earned ${plural(n.goldEarned, "Gold ring", "Gold rings")}.`);
    if (n.relit > 0) lines.push(`You relit ${plural(n.relit, "lamp", "lamps")}.`);
    if (n.questionsAnswered > 0)
      lines.push(`You answered ${plural(n.questionsAnswered, "question", "questions")}${accuracyPct === null ? "" : ` and got ${accuracyPct}% right`}.`);
    if (n.mocksTaken > 0) lines.push(`You took ${plural(n.mocksTaken, "mock", "mocks")}.`);
  }
  if (n.dimmedNow > 0) lines.push(`${plural(n.dimmedNow, "lamp is", "lamps are")} dimming or dim now.`);
  lines.push("This report shows your study. It does not predict your result.");

  let nextWeek: string[] | null = null;
  if (tier === "full") {
    nextWeek = [];
    if (n.dimmedNow > 0) nextWeek.push(`Relight your ${plural(n.dimmedNow, "dim lamp", "dim lamps")} first.`);
    nextWeek.push(`Light ${Math.max(n.lampsLit, 3)} new lamps.`);
    nextWeek.push(n.mocksTaken > 0 ? "Take one full mock and read its report." : "Take one sectional test.");
  }
  return {
    lampsLit: n.lampsLit,
    steadyEarned: n.steadyEarned,
    goldEarned: n.goldEarned,
    relit: n.relit,
    dimmedNow: n.dimmedNow,
    questionsAnswered: n.questionsAnswered,
    accuracyPct,
    mocksTaken: n.mocksTaken,
    studyMinutes: n.studyMinutes,
    lines,
    nextWeek,
  };
}
