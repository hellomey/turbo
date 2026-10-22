import { z } from "../zod.js";
import { AnswerInput } from "./questions.js";
import { TopicState } from "./mastery.js";

/**
 * Offline outbox sync (blueprint §39, §34.2). Every study action is written to Drift first, then sent here in batches.
 * The client UUID is the idempotency key: each action is accepted ONCE. The server wins for rings, rank and rewards.
 * Actions older than 7 days when synced become a study log only. Offline actions never earn ranked anything.
 */

const base = { clientActionId: z.uuid(), clientAt: z.iso.datetime() };

export const SyncAction = z
  .discriminatedUnion("kind", [
    z.object({
      ...base,
      kind: z.literal("practice_answer"),
      questionId: z.uuid(),
      questionVersion: z.number().int().positive(),
      chosenOptionIds: z.array(z.string().min(1).max(8)).max(8),
      timeMs: z.number().int().min(0).max(3_600_000),
      mode: z.enum(["practice", "pyq", "mistakes", "drill"]),
    }),
    z.object({ ...base, kind: z.literal("lesson_complete"), topicId: z.uuid(), via: z.enum(["lesson", "textbook"]) }),
    z.object({
      ...base,
      kind: z.literal("topic_check"),
      topicId: z.uuid(),
      /** Gold is timed by the server and is never accepted offline. */
      checkKind: z.enum(["lit", "recall", "relight"]),
      answers: z.array(AnswerInput).min(1).max(10),
    }),
    z.object({ ...base, kind: z.literal("plan_item_status"), itemId: z.uuid(), status: z.enum(["done", "skipped"]) }),
  ])
  .openapi("SyncAction");

export const SYNC_BATCH_MAX = 100;

export const SyncBatchBody = z
  .object({ deviceId: z.string().min(8).max(128), actions: z.array(SyncAction).min(1).max(SYNC_BATCH_MAX) })
  .openapi("SyncBatchBody");

export const SyncActionResult = z
  .object({
    clientActionId: z.uuid(),
    status: z.enum(["accepted", "duplicate", "study_log_only", "rejected"]),
    /** Stable code from ERROR_CODES when rejected. */
    errorCode: z.string().nullable(),
  })
  .openapi("SyncActionResult");

export const SyncBatchResult = z
  .object({
    results: z.array(SyncActionResult),
    /** Authoritative state of every lamp touched by the batch: replace the local rings with these. */
    topicStates: z.array(TopicState),
    serverNow: z.iso.datetime(),
  })
  .openapi("SyncBatchResult");
