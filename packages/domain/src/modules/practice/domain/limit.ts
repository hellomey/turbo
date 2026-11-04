import type { PracticeMode, PracticeUsage, z } from "@heymey/contracts";
import { istDayKey } from "../../../shared/index.js";
import { PRACTICE_CONFIG } from "./config.js";

/**
 * The free daily limit (blueprint §11 "30 a day", §13 limit sheet, §37 IST days; U-practice invariants 1-5, 12).
 * Pure: the caller passes server time. The phone clock never changes the count (inv. 2).
 */
export type PracticeModeValue = z.infer<typeof PracticeMode>;
export type PracticeUsageDto = z.infer<typeof PracticeUsage>;
export type Entitlement = "free" | "pro";

const DAY_MS = 86_400_000;
const IST_OFFSET_MS = (5 * 60 + 30) * 60_000;

/** Only `practice` and `pyq` answers count (Q8). Mistakes and drills never touch the counter (inv. 4). */
export function isCountedMode(mode: PracticeModeValue): boolean {
  return (PRACTICE_CONFIG.countedModes as readonly string[]).includes(mode);
}

/** `null` = unlimited (Pro). */
export function dailyLimitFor(entitlement: Entitlement): number | null {
  return entitlement === "pro" ? null : PRACTICE_CONFIG.freeDailyLimit;
}

/** The next Asia/Kolkata midnight after `now`: when the free questions open again. */
export function nextIstMidnight(now: Date): Date {
  const istMs = now.getTime() + IST_OFFSET_MS;
  const startOfIstDay = Math.floor(istMs / DAY_MS) * DAY_MS;
  return new Date(startOfIstDay + DAY_MS - IST_OFFSET_MS);
}

/**
 * When an answer happened, as the server judges it (inv. 2, 5): online = server now; offline = clientAt clamped to
 * [now - offlineClampDays, now] so a wrong phone clock cannot move answers into the future or far past.
 */
export function judgedAnswerTime(now: Date, clientAt?: Date | null): Date {
  if (!clientAt || Number.isNaN(clientAt.getTime())) return now;
  const min = now.getTime() - PRACTICE_CONFIG.offlineClampDays * DAY_MS;
  return new Date(Math.min(now.getTime(), Math.max(min, clientAt.getTime())));
}

export type CountDecision = "uncounted" | "count" | "over_limit";

/** What a new answer does to the day's counter, given how many are already counted (inv. 1, 3, 4). */
export function decideCount(mode: PracticeModeValue, alreadyCounted: number, limit: number | null): CountDecision {
  if (!isCountedMode(mode)) return "uncounted";
  if (limit !== null && alreadyCounted >= limit) return "over_limit";
  return "count";
}

/** The `PracticeUsage` the app shows (§11, §13). Always for today's IST day. */
export function usageOf(now: Date, today: { counted: number; limitSheetShown: boolean } | null, limit: number | null): PracticeUsageDto {
  return {
    istDay: istDayKey(now),
    used: today?.counted ?? 0,
    limit,
    resetsAt: nextIstMidnight(now).toISOString(),
    limitSheetShownToday: today?.limitSheetShown ?? false,
  };
}
