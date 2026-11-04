/** Attempt cycles (ADR-0013, R2). Pure rules over stored cycle data; dates are IST calendar days. */

/** One attempt cycle as stored (ADR-0013). stageDates is data; dates are IST calendar days. */
export interface CycleRecord {
  id: string;
  examCode: string;
  status: string;
  stageDates: { stageCode: string; date: string | null }[];
}

/** The earliest known stage date on or after `today` (both YYYY-MM-DD, so string order = date order). */
export function nextStageDate(cycle: CycleRecord, today: string): string | null {
  const dates = cycle.stageDates.map((s) => s.date).filter((d): d is string => !!d && d >= today);
  dates.sort();
  return dates[0] ?? null;
}

/** The chosen cycle, else the first announced, else the first expected one (same rule as the stage view). */
export function pickCycle(cycles: readonly CycleRecord[], chosenId: string | null | undefined): CycleRecord | null {
  if (chosenId) {
    const chosen = cycles.find((c) => c.id === chosenId);
    if (chosen) return chosen;
  }
  return cycles.find((c) => c.status === "announced") ?? cycles.find((c) => c.status === "expected") ?? null;
}
