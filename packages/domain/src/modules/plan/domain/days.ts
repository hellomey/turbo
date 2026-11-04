/**
 * IST calendar-day arithmetic on "YYYY-MM-DD" keys (§37). A day key is already an Asia/Kolkata date (from `istDayKey`),
 * so the math below runs on UTC midnights of that label and never depends on the server's time zone.
 */
const DAY_MS = 86_400_000;

function toUtc(day: string): number {
  return Date.UTC(Number(day.slice(0, 4)), Number(day.slice(5, 7)) - 1, Number(day.slice(8, 10)));
}

export function addDays(day: string, n: number): string {
  return new Date(toUtc(day) + n * DAY_MS).toISOString().slice(0, 10);
}

/** Whole days from `from` to `to` (negative if `to` is earlier). */
export function daysBetween(from: string, to: string): number {
  return Math.round((toUtc(to) - toUtc(from)) / DAY_MS);
}

/** Saturday or Sunday of that IST date. */
export function isWeekend(day: string): boolean {
  const wd = new Date(toUtc(day)).getUTCDay();
  return wd === 0 || wd === 6;
}

/** Invariant 2: weekday or weekend minutes by IST weekday. */
export function minutesForDay(plan: { weekdayMinutes: number; weekendMinutes: number }, day: string): number {
  return isWeekend(day) ? plan.weekendMinutes : plan.weekdayMinutes;
}

/** Inclusive list of day keys. */
export function dayRange(from: string, to: string): string[] {
  const n = daysBetween(from, to);
  return Array.from({ length: Math.max(0, n + 1) }, (_, i) => addDays(from, i));
}
