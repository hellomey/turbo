import { MASTERY_CONFIG } from "../domain/config.js";
import { dimStep, ringOf } from "../domain/lamp.js";
import type { MasteryDeps, RingEventRow } from "./ports.js";

export interface DimmingRunResult {
  examined: number;
  dimming: number;
  dim: number;
  steadyLost: number;
  conflicts: number;
}

/**
 * `mastery.dimming` (every 15 min, §5.1 Dimming, §17.5 System; inv. 8, 9). Batches of `dimmingBatch` rows; each lamp is
 * written with a rowVersion guard, so a second run for the same window, or a race with a user write, changes no lamp
 * twice (a lost race is skipped and picked up by the next run). Gold is never touched.
 */
export async function runDimming(deps: Pick<MasteryDeps, "repo" | "clock" | "events">): Promise<DimmingRunResult> {
  const now = deps.clock.now();
  const dimCutoff = new Date(now.getTime() - MASTERY_CONFIG.dimming.steadyLostAfterOverdueDays * 24 * 3_600_000);
  const out: DimmingRunResult = { examined: 0, dimming: 0, dim: 0, steadyLost: 0, conflicts: 0 };
  let after: { userId: string; topicId: string } | null = null;
  for (;;) {
    const batch = await deps.repo.dimmingCandidates({ now, dimCutoff, limit: MASTERY_CONFIG.dimmingBatch, after });
    for (const s of batch) {
      out.examined++;
      const t = dimStep(s, now);
      if (!t.next) continue;
      const events: RingEventRow[] = t.events.map((e) => ({ userId: s.userId, topicId: s.topicId, kind: e.kind, at: now, source: "online", details: e.details ?? null }));
      const res = await deps.repo.commit({ state: { next: t.next, expectedVersion: s.rowVersion }, events });
      if (res !== "ok") {
        out.conflicts++;
        continue;
      }
      for (const e of t.events) {
        if (e.kind === "dimming") out.dimming++;
        if (e.kind === "dim") out.dim++;
        if (e.kind === "steady_lost") out.steadyLost++;
      }
      await deps.events.publish({
        type: "mastery.lamp_changed",
        occurredAt: now,
        payload: { userId: s.userId, topicId: s.topicId, ring: ringOf(t.next), source: "dimming" },
      });
    }
    const last = batch.at(-1);
    if (batch.length < MASTERY_CONFIG.dimmingBatch || !last) break;
    after = { userId: last.userId, topicId: last.topicId };
  }
  return out;
}
