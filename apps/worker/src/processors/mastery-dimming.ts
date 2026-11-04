import type { DimmingRunResult } from "@heymey/domain/modules/mastery";

/**
 * `mastery.dimming` (owner: mastery, every 15 min IST; blueprint §5.1 Dimming, §17.5 System). Calls the one use case.
 * Idempotent: lamps are guarded by dimState + rowVersion, so a repeated or overlapping run changes no lamp twice.
 * Logs counts only (no ids of users).
 */
export function createMasteryDimmingProcessor(deps: { dimming: { run(): Promise<DimmingRunResult> } }) {
  return async (): Promise<DimmingRunResult> => deps.dimming.run();
}
