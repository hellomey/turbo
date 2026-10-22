import { emptyLamp, ringOf, type ActionSource, type LampState, type Transition } from "../domain/lamp.js";
import { MASTERY_CONFIG } from "../domain/config.js";
import type { Commit, MasteryDeps, RingEventRow } from "./ports.js";

export interface LampWrite {
  userId: string;
  topicId: string;
  source: ActionSource;
  clientActionId?: string;
  checkId?: string;
  /** Check result written in the same transaction (single-submit guard, invariant 4). */
  check?: Omit<NonNullable<Commit["check"]>, "submittedAt">;
}

export interface LampWriteResult {
  outcome: "ok" | "duplicate";
  state: LampState;
  changed: boolean;
  now: Date;
}

/**
 * Read -> decide (pure) -> commit in one transaction, guarded by rowVersion; retried on a race with the dimming job
 * (logical design "Scheduler and user write race": rowVersion retry 3x). Every ring time is the server Clock (inv. 1).
 */
export async function writeLamp(deps: MasteryDeps, w: LampWrite, decide: (s: LampState, now: Date) => Transition): Promise<LampWriteResult> {
  for (let attempt = 0; attempt < MASTERY_CONFIG.writeRetries; attempt++) {
    const now = deps.clock.now();
    const stored = await deps.repo.getState(w.userId, w.topicId);
    const current = stored ?? emptyLamp(w.userId, w.topicId, now);
    const t = decide(current, now);
    const events: RingEventRow[] = t.events.map((e, i) => ({
      userId: w.userId,
      topicId: w.topicId,
      kind: e.kind,
      at: now,
      source: w.source,
      clientActionId: i === 0 ? (w.clientActionId ?? null) : null,
      checkId: w.checkId ?? null,
      details: e.details ?? null,
    }));
    const expectedVersion = stored ? stored.rowVersion : null;
    const result = await deps.repo.commit({
      ...(t.next ? { state: { next: t.next, expectedVersion } } : {}),
      events,
      ...(w.check ? { check: { ...w.check, submittedAt: now } } : {}),
    });
    if (result === "duplicate") return { outcome: "duplicate", state: current, changed: false, now };
    if (result === "ok") {
      if (!t.next) return { outcome: "ok", state: current, changed: false, now };
      const state = { ...t.next, rowVersion: expectedVersion === null ? 0 : expectedVersion + 1 };
      await deps.events.publish({
        type: "mastery.lamp_changed",
        occurredAt: now,
        payload: { userId: w.userId, topicId: w.topicId, ring: ringOf(state), source: w.source },
      });
      return { outcome: "ok", state, changed: true, now };
    }
  }
  throw new Error("mastery: lamp write kept conflicting");
}
