import { DomainError } from "../../../shared/errors.js";
import { istDayKey } from "../../../shared/clock.js";
import { EXAM_HALL_CONFIG } from "./config.js";
import type { MockRecord, PaperView } from "./types.js";

const MINUTE = 60_000;

/** "YYYY-MM" in Asia/Kolkata: the free allowance month (§11, Q12). */
export function istMonthKey(at: Date): string {
  return istDayKey(at).slice(0, 7);
}

/** R4: the answer mode comes from the PAPER, never the exam name. Descriptive papers are refused in Phase 2. */
export function modeForPaper(paper: Pick<PaperView, "answerMode">): "omr" | "cbt" {
  if (paper.answerMode === "descriptive") throw new DomainError("PAPER_TYPE_NOT_SUPPORTED");
  return paper.answerMode === "objective_cbt" ? "cbt" : "omr";
}

/**
 * Can this mock be started now (invariant 10)? Before `opensAt` -> MOCK_NOT_OPEN; at/after `closesAt` -> MOCK_CLOSED.
 * Returns whether the start is inside the LIVE window (State Mock Sunday: opensAt..lateJoinUntil) - only those can be ranked.
 */
export function checkWindow(mock: Pick<MockRecord, "kind" | "opensAt" | "lateJoinUntil" | "closesAt">, now: Date): { live: boolean } {
  if (mock.opensAt && now < mock.opensAt) throw new DomainError("MOCK_NOT_OPEN", { opensAt: mock.opensAt.toISOString() });
  if (mock.closesAt && now >= mock.closesAt) throw new DomainError("MOCK_CLOSED");
  const live =
    mock.kind === "state_mock_sunday" && mock.opensAt !== null && mock.lateJoinUntil !== null && now <= mock.lateJoinUntil;
  return { live };
}

/**
 * Server deadline (invariant 1): start + scheme duration. A live State Mock: min(start + duration, lateJoinUntil + duration),
 * so nobody in the ranked window gets more time than the last on-time joiner.
 */
export function deadlineFor(start: Date, durationMinutes: number, mock: Pick<MockRecord, "lateJoinUntil">, live: boolean): Date {
  const byStart = start.getTime() + durationMinutes * MINUTE;
  if (!live || !mock.lateJoinUntil) return new Date(byStart);
  return new Date(Math.min(byStart, mock.lateJoinUntil.getTime() + durationMinutes * MINUTE));
}

/** After this instant answer saves are ignored and an open attempt is scored as expired (Q25). */
export function graceEnd(deadline: Date): Date {
  return new Date(deadline.getTime() + EXAM_HALL_CONFIG.answerGraceSeconds * 1000);
}

export type SaveVerdict = "on_time" | "late" | "ignored";

/** Invariant 5: within the deadline = on time; up to deadline + grace = kept but unranked; after that = ignored. */
export function classifySave(now: Date, clientAt: Date, deadline: Date): SaveVerdict {
  if (now > graceEnd(deadline)) return "ignored";
  if (now > deadline || clientAt > deadline) return "late";
  return "on_time";
}

/** Whole seconds left on the server timer (never negative). */
export function remainingSeconds(now: Date, deadline: Date): number {
  return Math.max(0, Math.floor((deadline.getTime() - now.getTime()) / 1000));
}

/** Only "full" mocks that are not marked free use the monthly allowance (invariant 4). State Mock and sectional are free. */
export function usesAllowance(mock: Pick<MockRecord, "kind" | "free">): boolean {
  return mock.kind === "full" && !mock.free;
}

/**
 * The next 1st or 3rd Sunday (IST) on or after `now`'s IST day (Q13), as "YYYY-MM-DD".
 * Pure calendar arithmetic on the IST date.
 */
export function nextStateMockSunday(now: Date): string {
  const sundays: readonly number[] = EXAM_HALL_CONFIG.stateMockSunday.sundaysOfMonth;
  const day = new Date(`${istDayKey(now)}T00:00:00.000Z`);
  for (let i = 0; i < 62; i += 1) {
    const d = new Date(day.getTime() + i * 24 * 60 * MINUTE);
    if (d.getUTCDay() === 0 && sundays.includes(Math.floor((d.getUTCDate() - 1) / 7) + 1)) return d.toISOString().slice(0, 10);
  }
  /* c8 ignore next */
  throw new RangeError("no state mock sunday found");
}
