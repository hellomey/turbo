import { istDayKey } from "../../../shared/clock.js";
import { MASTERY_CONFIG } from "./config.js";

/**
 * A lamp (one syllabus topic) for one user and its rings (blueprint §5.1). Pure rules only: every time comes in as
 * `now` from the server Clock (§18 clock row, §34.1); client time never sets a ring.
 * Design: aidlc/construction/units/U-mastery/domain-model.md (invariants 1-17).
 */
export type DimState = "bright" | "dimming" | "dim";
export type CheckKind = "lit" | "recall" | "relight" | "gold";
export type NextCheck = "lesson" | "lit" | "recall" | "relight" | "gold" | "none";
export type ActionSource = "online" | "offline_sync";

export interface LampState {
  userId: string;
  topicId: string;
  litAt: Date | null;
  steadyLevel: number;
  goldAt: Date | null;
  nextDueAt: Date | null;
  dimState: DimState;
  dimSince: Date | null;
  shieldUntil: Date | null;
  lessonCompletedAt: Date | null;
  steadyEarnedAt: Date | null;
  lastCheckAt: Date | null;
  rowVersion: number;
  updatedAt: Date;
}

/** RingEvent kinds (append-only history, S03 "history stays stored"). */
export type RingEventKind =
  | "lesson_done"
  | "lit"
  | "lit_fail"
  | "recall_pass"
  | "recall_fail"
  | "dimming"
  | "dim"
  | "steady_lost"
  | "relight"
  | "relight_fail"
  | "gold"
  | "gold_fail"
  | "study_log_only";

export interface RingEventDraft {
  kind: RingEventKind;
  details?: Record<string, unknown>;
}

/** Result of a transition: the next state (null = nothing changed) and the history rows to append. */
export interface Transition {
  next: LampState | null;
  events: RingEventDraft[];
}

const DAY_MS = 24 * 60 * 60 * 1000;
const IST_OFFSET_MS = (5 * 60 + 30) * 60_000;

/** IST midnight (as a UTC instant) of the Asia/Kolkata day `days` after the IST day of `at` (§37). */
export function istDayStartPlusDays(at: Date, days: number): Date {
  const [y, m, d] = istDayKey(at).split("-").map(Number) as [number, number, number];
  return new Date(Date.UTC(y, m - 1, d + days) - IST_OFFSET_MS);
}

export function emptyLamp(userId: string, topicId: string, now: Date): LampState {
  return {
    userId,
    topicId,
    litAt: null,
    steadyLevel: 0,
    goldAt: null,
    nextDueAt: null,
    dimState: "bright",
    dimSince: null,
    shieldUntil: null,
    lessonCompletedAt: null,
    steadyEarnedAt: null,
    lastCheckAt: null,
    rowVersion: 0,
    updatedAt: now,
  };
}

/** Gap in IST days after a passed recall that leaves the lamp at `levelAfter` (1..4): 3, 7, 21, then maintenance. */
export function gapAfterLevel(levelAfter: number): number {
  const ladder = MASTERY_CONFIG.recall.ladderDays;
  return levelAfter < ladder.length ? (ladder[levelAfter] as number) : MASTERY_CONFIG.recall.maintenanceDays;
}

export function isDue(s: LampState, now: Date): boolean {
  return s.litAt !== null && s.nextDueAt !== null && now.getTime() >= s.nextDueAt.getTime();
}

/** Which check the lamp offers now (TopicState.nextCheck). */
export function nextCheck(s: LampState, now: Date): NextCheck {
  if (!s.litAt) return s.lessonCompletedAt ? "lit" : "lesson";
  if (s.dimState !== "bright") return "relight";
  if (isDue(s, now)) return "recall";
  return s.goldAt ? "none" : "gold";
}

/** May a check of this kind be STARTED now? (Gold's daily limit is checked by the use case.) */
export function canStart(kind: CheckKind, s: LampState, now: Date): boolean {
  switch (kind) {
    case "lit":
      return s.lessonCompletedAt !== null && s.litAt === null;
    case "recall":
      return s.dimState === "bright" && isDue(s, now);
    case "relight":
      return s.litAt !== null && s.dimState !== "bright";
    case "gold":
      return s.litAt !== null && s.goldAt === null;
  }
}

const touch = (s: LampState, now: Date, patch: Partial<LampState>): LampState => ({ ...s, ...patch, updatedAt: now });

/** S01: finishing the lesson (or mapped textbook pages) opens the Lit check. Repeats change nothing. */
export function completeLesson(s: LampState, now: Date): Transition {
  if (s.lessonCompletedAt) return { next: null, events: [{ kind: "lesson_done", details: { repeat: true } }] };
  return { next: touch(s, now, { lessonCompletedAt: now }), events: [{ kind: "lesson_done" }] };
}

/** A passed recall at the current level (also used by relight, invariant 10). */
function passRecall(s: LampState, now: Date): LampState {
  const level = Math.min(s.steadyLevel + 1, MASTERY_CONFIG.recall.ladderDays.length);
  return touch(s, now, {
    steadyLevel: level,
    steadyEarnedAt: s.steadyEarnedAt ?? now,
    nextDueAt: istDayStartPlusDays(now, gapAfterLevel(level)),
    dimState: "bright",
    dimSince: null,
    lastCheckAt: now,
  });
}

/**
 * Apply a graded check (invariants 2, 3, 5, 6, 7, 10, 11). Preconditions are re-checked at submit time, so a check
 * that no longer fits the lamp (e.g. a second Lit check after the lamp lit) is kept as a study log only.
 */
export function applyCheck(kind: CheckKind, passed: boolean, s: LampState, now: Date): Transition {
  const logOnly = (reason: string): Transition => ({ next: null, events: [{ kind: "study_log_only", details: { kind, passed, reason } }] });
  switch (kind) {
    case "lit": {
      if (s.litAt) return logOnly("already_lit");
      if (!s.lessonCompletedAt) return logOnly("lesson_not_done");
      if (!passed) return { next: touch(s, now, { lastCheckAt: now }), events: [{ kind: "lit_fail" }] };
      return {
        next: touch(s, now, {
          litAt: now,
          steadyLevel: 0,
          nextDueAt: istDayStartPlusDays(now, MASTERY_CONFIG.recall.ladderDays[0]),
          dimState: "bright",
          dimSince: null,
          lastCheckAt: now,
        }),
        events: [{ kind: "lit" }],
      };
    }
    case "recall": {
      if (!s.litAt) return logOnly("not_lit");
      if (s.dimState !== "bright") return logOnly("needs_relight");
      if (!isDue(s, now)) return logOnly("not_due");
      if (passed) return { next: passRecall(s, now), events: [{ kind: "recall_pass", details: { level: Math.min(s.steadyLevel + 1, 4) } }] };
      const level = Math.max(s.steadyLevel - MASTERY_CONFIG.recall.failStepsBack, 0);
      return {
        next: touch(s, now, { steadyLevel: level, nextDueAt: istDayStartPlusDays(now, MASTERY_CONFIG.recall.failRetryDays), lastCheckAt: now }),
        events: [{ kind: "recall_fail", details: { level } }],
      };
    }
    case "relight": {
      if (!s.litAt || s.dimState === "bright") return logOnly("not_dimming");
      if (!passed) return { next: touch(s, now, { lastCheckAt: now }), events: [{ kind: "relight_fail" }] };
      return { next: passRecall(s, now), events: [{ kind: "relight", details: { from: s.dimState } }] };
    }
    case "gold": {
      if (!s.litAt) return logOnly("not_lit");
      if (s.goldAt) return logOnly("already_gold");
      if (!passed) return { next: touch(s, now, { lastCheckAt: now }), events: [{ kind: "gold_fail" }] };
      return { next: touch(s, now, { goldAt: now, lastCheckAt: now }), events: [{ kind: "gold" }] };
    }
  }
}

/**
 * Dimming job step (invariants 8, 9). Overdue -> dimming (dimSince = nextDueAt); overdue beyond the limit -> dim and the
 * Steady ring is lost (history stays). Gold is never touched. A Revision Shield pauses dimming. null = no change.
 */
export function dimStep(s: LampState, now: Date): Transition {
  if (!s.litAt || !s.nextDueAt || now.getTime() < s.nextDueAt.getTime()) return { next: null, events: [] };
  if (s.shieldUntil && now.getTime() < s.shieldUntil.getTime()) return { next: null, events: [] };
  const dimAt = s.nextDueAt.getTime() + MASTERY_CONFIG.dimming.steadyLostAfterOverdueDays * DAY_MS;
  const events: RingEventDraft[] = [];
  let next: LampState = s;
  if (s.dimState === "bright") {
    next = touch(next, now, { dimState: "dimming", dimSince: s.nextDueAt });
    events.push({ kind: "dimming" });
  }
  if (next.dimState === "dimming" && now.getTime() >= dimAt) {
    events.push({ kind: "dim" });
    if (next.steadyLevel > 0) events.push({ kind: "steady_lost", details: { level: next.steadyLevel } });
    next = touch(next, now, { dimState: "dim", steadyLevel: 0 });
  }
  return events.length ? { next, events } : { next: null, events: [] };
}

/** The ring as the contract shows it (LampRing). */
export function ringOf(s: LampState): { lit: boolean; steadyLevel: number; gold: boolean; dim: DimState } {
  return { lit: s.litAt !== null, steadyLevel: s.steadyLevel, gold: s.goldAt !== null, dim: s.dimState };
}
