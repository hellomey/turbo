/**
 * `plan.rebalance` (owner: plan, 02:30 IST) and `exams.date-changed` (owner: plan, event-driven). BOLT-0012,
 * U-plan logical design "Background work". Each calls one plan use case. Idempotent: rebalance runs once per user per
 * IST day (Plan.lastRebalancedAt), and a date change only rebuilds pending future days (done items never change).
 * Logs counts only, never user ids.
 */
export interface PlanJobs {
  rebalanceDue(): Promise<{ checked: number; rebalanced: number }>;
  onDateChanged(event: { examCode: string; cycleId: string }): Promise<{ plans: number }>;
}

export function createPlanRebalanceProcessor(plan: Pick<PlanJobs, "rebalanceDue">) {
  return async (): Promise<{ checked: number; rebalanced: number }> => plan.rebalanceDue();
}

/** Payload published by exams (exams.date_changed): { examCode, cycleId, stageCode, date }. */
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function parseDateChanged(data: unknown): { examCode: string; cycleId: string } {
  const d = (data ?? {}) as { examCode?: unknown; cycleId?: unknown };
  if (typeof d.examCode !== "string" || !d.examCode || typeof d.cycleId !== "string" || !UUID.test(d.cycleId)) {
    throw new Error("exams.date-changed: bad payload");
  }
  return { examCode: d.examCode, cycleId: d.cycleId };
}

export function createPlanDateChangedProcessor(plan: Pick<PlanJobs, "onDateChanged">) {
  return async (data: unknown): Promise<{ plans: number }> => {
    return plan.onDateChanged(parseDateChanged(data));
  };
}
