import { PLAN_CONFIG } from "./config.js";
import { daysBetween } from "./days.js";

/** Pure plan rules (U-plan domain model, invariants 2–9). No I/O, no clock: callers pass IST day keys. */

export type StretchPhase = "normal" | "d90" | "d60" | "d30" | "d7";
export type PlanItemKind = "lesson" | "lit_check" | "relight" | "practice" | "pyq" | "gold" | "mock" | "mistake_review" | "checklist";
export type PlanItemStatus = "pending" | "done" | "skipped" | "moved";

export interface PlanTarget {
  examCode: string;
  attemptCycleId: string | null;
  /** Next stage date (IST day) or null when not known. */
  examDate: string | null;
  /** 1 = main exam. */
  priority: number;
}

export interface Mix {
  newTopics: number;
  relight: number;
  pyq: number;
  mocks: number;
}

export interface ItemDraft {
  day: string;
  kind: PlanItemKind;
  examCode: string | null;
  topicId: string | null;
  title: string;
  minutes: number;
  order: number;
}

export interface TopicPick {
  topicId: string;
  name: string;
  /** TopicExamTag.priority >= criticalPriority (§17.3). */
  critical: boolean;
}

/** Days left from `day` to the exam date; null = no date (no countdown, invariant "No exam date"). */
export function daysLeft(examDate: string | null, day: string): number | null {
  return examDate ? Math.max(0, daysBetween(day, examDate)) : null;
}

/** Days left to the nearest dated exam, or null. */
export function nearestDaysLeft(targets: readonly PlanTarget[], day: string): number | null {
  const left = targets.map((t) => daysLeft(t.examDate, day)).filter((d): d is number => d !== null);
  return left.length ? Math.min(...left) : null;
}

/** Invariant 8: ≤90 d90, ≤60 d60, ≤30 d30, ≤7 d7; no date = normal. */
export function stretchPhase(left: number | null): StretchPhase {
  const s = PLAN_CONFIG.stretchDays;
  if (left === null) return "normal";
  if (left <= s.d7) return "d7";
  if (left <= s.d30) return "d30";
  if (left <= s.d60) return "d60";
  if (left <= s.d90) return "d90";
  return "normal";
}

/** Invariant 3: mix row by days left (null = the farthest row), then the balance dial (-2..+2) moves new <-> relight. */
export function mixFor(left: number | null, balance: number): Mix {
  const rows = PLAN_CONFIG.mixByDaysLeft;
  const row = (left === null ? rows[0] : rows.find((r) => left >= r.minDaysLeft)) ?? rows[rows.length - 1];
  if (!row) throw new Error("PLAN_CONFIG.mixByDaysLeft is empty");
  const pool = row.newTopics + row.relight;
  const newTopics = Math.min(pool, Math.max(0, row.newTopics + balance * PLAN_CONFIG.balanceStepPercent));
  return { newTopics, relight: pool - newTopics, pyq: row.pyq, mocks: row.mocks };
}

/**
 * Invariant 9 / Q24: one daily budget. Main exam gets `mainSharePercent`, the others split the rest; the exam with the
 * nearest date inside `nearestDateWindowDays` gets `nearestDateBoostPercent` more, taken from the others in proportion.
 * Integer percents that add up to 100 (rounding remainder goes to the main exam).
 */
export function examShares(targets: readonly PlanTarget[], day: string): Map<string, number> {
  const cfg = PLAN_CONFIG.multiExam;
  const sorted = [...targets].sort((a, b) => a.priority - b.priority);
  const out = new Map<string, number>();
  const main = sorted[0];
  if (!main) return out;
  if (sorted.length === 1) return out.set(main.examCode, 100);
  const others = sorted.slice(1);
  const raw = new Map<string, number>([[main.examCode, cfg.mainSharePercent]]);
  for (const o of others) raw.set(o.examCode, (100 - cfg.mainSharePercent) / others.length);

  let nearest: PlanTarget | null = null;
  let best = Infinity;
  for (const t of sorted) {
    const left = daysLeft(t.examDate, day);
    if (left !== null && left <= cfg.nearestDateWindowDays && left < best) {
      best = left;
      nearest = t;
    }
  }
  if (nearest) {
    const boost = cfg.nearestDateBoostPercent;
    const rest = 100 - (raw.get(nearest.examCode) ?? 0);
    for (const [code, pct] of raw) {
      raw.set(code, code === nearest.examCode ? pct + boost : pct - (boost * pct) / rest);
    }
  }
  let total = 0;
  for (const [code, pct] of raw) {
    const v = Math.floor(pct);
    out.set(code, v);
    total += v;
  }
  out.set(main.examCode, (out.get(main.examCode) ?? 0) + (100 - total));
  return out;
}

export interface DayInput {
  day: string;
  /** Minutes still free on this day (daily minutes minus done/skipped items already there). */
  minutes: number;
  /** First order number to use (after existing items). */
  firstOrder: number;
  targets: readonly PlanTarget[];
  balance: number;
  /** Day is inside the 7-day starter path (invariant 4). */
  starter: boolean;
  /** New-topic queues per exam in syllabus order (not Lit, not yet planned). Consumed by this call. */
  queues: Map<string, TopicPick[]>;
  /** Topic ids already planned anywhere (shared lamps planned once, invariant 9). Updated by this call. */
  planned: Set<string>;
}

const M = PLAN_CONFIG.itemMinutes;

function takeTopic(input: DayInput, examCode: string, criticalOnly: boolean): TopicPick | null {
  const q = input.queues.get(examCode) ?? [];
  while (q.length) {
    const t = q[0];
    if (!t) break;
    if (input.planned.has(t.topicId)) {
      q.shift();
      continue;
    }
    if (criticalOnly && !t.critical) {
      // Not critical: skip it for this phase only (kept for later if dates move).
      const idx = q.findIndex((x) => x.critical && !input.planned.has(x.topicId));
      if (idx < 0) return null;
      const [pick] = q.splice(idx, 1);
      if (!pick) return null;
      input.planned.add(pick.topicId);
      return pick;
    }
    q.shift();
    input.planned.add(t.topicId);
    return t;
  }
  return null;
}

function lessonPair(day: string, examCode: string, t: TopicPick): Omit<ItemDraft, "order">[] {
  return [
    { day, kind: "lesson", examCode, topicId: t.topicId, title: `Lesson: ${t.name}`, minutes: M.lesson },
    { day, kind: "lit_check", examCode, topicId: t.topicId, title: `Lit check: ${t.name}`, minutes: M.litCheck },
  ];
}

/** New-topic items for `budget` minutes across exams by share. Returns minutes not used (no topic left). */
function newTopicItems(input: DayInput, budget: number, shares: Map<string, number>, criticalOnly: boolean, out: Omit<ItemDraft, "order">[]): number {
  const pair = M.lesson + M.litCheck;
  let left = budget;
  for (const [examCode, pct] of [...shares].sort((a, b) => b[1] - a[1])) {
    let examBudget = Math.floor((budget * pct) / 100);
    while (examBudget > 0 && left > 0) {
      const t = takeTopic(input, examCode, criticalOnly);
      if (!t) break;
      out.push(...lessonPair(input.day, examCode, t));
      examBudget -= pair;
      left -= pair;
    }
  }
  // Rounding / one exam ran out: let any exam with topics use what is left.
  for (const examCode of shares.keys()) {
    while (left > 0) {
      const t = takeTopic(input, examCode, criticalOnly);
      if (!t) break;
      out.push(...lessonPair(input.day, examCode, t));
      left -= pair;
    }
  }
  return Math.max(0, left);
}

/**
 * Builds one day (invariants 2–4, 8, 9). Order: Final Stretch checklist (d7), relight, new topics, past questions, mock.
 * The day never goes over its minutes by more than one item (invariant 2): items are taken in order while time is left.
 */
export function buildDay(input: DayInput): ItemDraft[] {
  if (input.minutes <= 0) return [];
  const main = [...input.targets].sort((a, b) => a.priority - b.priority)[0];
  if (!main) return [];
  const drafts: Omit<ItemDraft, "order">[] = [];

  if (input.starter) {
    // Starter path: lessons + Lit checks of the first lamps of the main exam, in syllabus order.
    newTopicItems(input, input.minutes, new Map([[main.examCode, 100]]), false, drafts);
  }
  // No lamp left for the starter path: the day falls back to the normal mix (never an empty plan day).
  if (!drafts.length) {
    const left = nearestDaysLeft(input.targets, input.day);
    const phase = stretchPhase(left);
    const mix = mixFor(left, input.balance);
    const shares = examShares(input.targets, input.day);
    const m = input.minutes;
    const newB = Math.floor((m * mix.newTopics) / 100);
    let pyqB = Math.floor((m * mix.pyq) / 100);
    let mockB = Math.floor((m * mix.mocks) / 100);
    let relB = m - newB - pyqB - mockB;

    if (phase === "d7") {
      const c = Math.min(M.checklist, m);
      drafts.push({ day: input.day, kind: "checklist", examCode: main.examCode, topicId: null, title: "Final Stretch checklist", minutes: c });
      relB -= c;
    }
    const newDrafts: Omit<ItemDraft, "order">[] = [];
    const unused = newTopicItems(input, newB, shares, phase === "d30" || phase === "d7", newDrafts);
    relB += unused;
    if (mockB < M.mockMin) {
      pyqB += mockB;
      mockB = 0;
    }
    if (relB >= M.minBlock) {
      drafts.push({ day: input.day, kind: "relight", examCode: null, topicId: null, title: "Relight your dimming lamps", minutes: relB });
    } else {
      pyqB += Math.max(0, relB);
    }
    drafts.push(...newDrafts);
    if (pyqB >= M.minBlock) {
      for (const [examCode, pct] of [...shares].sort((a, b) => b[1] - a[1])) {
        const mins = Math.floor((pyqB * pct) / 100);
        if (mins >= M.minBlock) drafts.push({ day: input.day, kind: "pyq", examCode, topicId: null, title: "Past questions", minutes: mins });
      }
    }
    if (mockB > 0) drafts.push({ day: input.day, kind: "mock", examCode: main.examCode, topicId: null, title: "Mock test", minutes: mockB });
  }

  const out: ItemDraft[] = [];
  let used = 0;
  for (const d of drafts) {
    if (used >= input.minutes) break;
    out.push({ ...d, order: input.firstOrder + out.length });
    used += d.minutes;
  }
  return out;
}

export interface ItemLike {
  day: string;
  status: PlanItemStatus;
}

/** Invariant 6: past days that had pending items and nothing done. */
export function missedDays(items: readonly ItemLike[], today: string): string[] {
  const byDay = new Map<string, { pending: boolean; done: boolean }>();
  for (const i of items) {
    if (i.day >= today) continue;
    const d = byDay.get(i.day) ?? { pending: false, done: false };
    if (i.status === "pending") d.pending = true;
    if (i.status === "done") d.done = true;
    byDay.set(i.day, d);
  }
  return [...byDay].filter(([, d]) => d.pending && !d.done).map(([day]) => day).sort();
}

/** Invariant 6: rebalance runs after `rebalanceAfterMissedDays` missed plan days. */
export function needsRebalance(items: readonly ItemLike[], today: string): boolean {
  return missedDays(items, today).length >= PLAN_CONFIG.rebalanceAfterMissedDays;
}

/** Invariant 5: the Today Card is the first pending item of today by order. */
export function todayCard<T extends ItemLike & { order: number }>(items: readonly T[], today: string): T | null {
  return [...items].filter((i) => i.day === today && i.status === "pending").sort((a, b) => a.order - b.order)[0] ?? null;
}

/** Kind words after a rebalance (§7: never "streak lost"). */
export const WELCOME_BACK = "Welcome back. We moved your plan forward so today is easy to start.";

/** Invariant 10: a status change applies only to a pending item; anything else keeps the item as it is. */
export function canChangeStatus(status: PlanItemStatus): boolean {
  return status === "pending";
}
