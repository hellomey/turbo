import type { SyncActionResult, z } from "@heymey/contracts";
import type { ErrorCode } from "@heymey/contracts";
import { checkSpec, isTooOld } from "../domain/check.js";
import { toTopicStateDto, type TopicStateDto } from "../domain/dto.js";
import { applyCheck, completeLesson, type Transition } from "../domain/lamp.js";
import type { MasteryDeps } from "./ports.js";
import { writeLamp } from "./write-lamp.js";

export type SyncActionResultDto = z.infer<typeof SyncActionResult>;

/** The offline study actions mastery owns (§39). practice_answer / plan_item_status belong to practice / plan. */
export type MasterySyncAction =
  | { clientActionId: string; clientAt: string; kind: "lesson_complete"; topicId: string; via: "lesson" | "textbook" }
  | {
      clientActionId: string;
      clientAt: string;
      kind: "topic_check";
      topicId: string;
      checkKind: "lit" | "recall" | "relight";
      answers: { questionId: string; chosenOptionIds: string[] }[];
    };

const result = (clientActionId: string, status: SyncActionResultDto["status"], errorCode: ErrorCode | null = null): SyncActionResultDto => ({
  clientActionId,
  status,
  errorCode,
});

/**
 * One offline action (§39, S18): accepted ONCE per clientActionId (unique RingEvent.clientActionId, inv. 16); older than
 * 7 days -> study log only, no ring change (inv. 14); check answers are re-graded on the server (inv. 15). Offline
 * actions never produce rank-ups or any reward (FW-022): rank is not recomputed here.
 */
export async function syncMasteryAction(deps: MasteryDeps, userId: string, a: MasterySyncAction): Promise<SyncActionResultDto> {
  if (await deps.repo.hasClientAction(a.clientActionId)) return result(a.clientActionId, "duplicate");
  if (!(await deps.syllabus.topic(a.topicId))) return result(a.clientActionId, "rejected", "TOPIC_NOT_FOUND");
  const base = { userId, topicId: a.topicId, source: "offline_sync" as const, clientActionId: a.clientActionId };
  const now = deps.clock.now();

  if (isTooOld(new Date(a.clientAt), now)) {
    const w = await writeLamp(deps, base, () => ({ next: null, events: [{ kind: "study_log_only", details: { action: a.kind, reason: "too_old" } }] }));
    return w.outcome === "duplicate" ? result(a.clientActionId, "duplicate") : result(a.clientActionId, "study_log_only", "SYNC_ACTION_TOO_OLD");
  }

  let decide: (s: Parameters<typeof completeLesson>[0], at: Date) => Transition;
  if (a.kind === "lesson_complete") {
    decide = completeLesson;
  } else {
    const spec = checkSpec(a.checkKind);
    const graded = (await deps.questions.grade(a.answers)).filter((g) => g.topicId === a.topicId);
    if (graded.length < spec.questions) return result(a.clientActionId, "rejected", "VALIDATION_FAILED");
    const correct = Math.min(graded.filter((g) => g.correct).length, spec.questions);
    const passed = correct >= spec.passMark;
    decide = (s, at) => {
      const t = applyCheck(a.checkKind, passed, s, at);
      return { ...t, events: t.events.map((e) => ({ ...e, details: { ...e.details, correct, total: spec.questions } })) };
    };
  }
  const w = await writeLamp(deps, base, decide);
  return w.outcome === "duplicate" ? result(a.clientActionId, "duplicate") : result(a.clientActionId, "accepted");
}

/** Authoritative states of the lamps a batch touched (the app replaces its local rings, §39). */
export async function topicStatesFor(deps: MasteryDeps, userId: string, topicIds: readonly string[]): Promise<TopicStateDto[]> {
  const ids = [...new Set(topicIds)];
  if (!ids.length) return [];
  const now = deps.clock.now();
  return (await deps.repo.statesFor(userId, ids)).map((s) => toTopicStateDto(s, now));
}
