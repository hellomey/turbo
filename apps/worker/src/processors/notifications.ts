/**
 * Notifications processors (BOLT-0014, blueprint §19.8 Q78, §6, §17.5; D-2026-10-22-31, -33).
 * Thin: each calls one use case. Returns counts/ids only (never tokens or personal data).
 */

export interface PushSendDeps {
  notifications: { send(sendLogId: string): Promise<string> };
}

/** `push.send`: data { sendLogId }. Retried by BullMQ; the use case skips rows that are no longer queued. */
export function createPushSendProcessor(deps: PushSendDeps) {
  return async (data: unknown): Promise<{ status: string }> => {
    const id = (data as { sendLogId?: unknown })?.sendLogId;
    if (typeof id !== "string") throw new Error("push.send: missing sendLogId");
    return { status: await deps.notifications.send(id) };
  };
}

export interface ExamAlertFanOutDeps {
  /** exams public API (worker composition root): who follows the exam. */
  followersOf(examCode: string): Promise<string[]>;
  notifications: { enqueueExamAlert(alertId: string, followerIds: readonly string[]): Promise<Record<string, number>> };
}

/**
 * `notifications.exam-alert`: data = `exams.notification_published` payload { alertId, examCode }.
 * The composition root joins exams (followers) and notifications (send rules), so neither module depends on the other.
 * Idempotent: each follower's SendLog row is keyed by alert + user.
 */
export function createExamAlertFanOutProcessor(deps: ExamAlertFanOutDeps) {
  return async (data: unknown): Promise<{ followers: number; outcomes: Record<string, number> }> => {
    const { alertId, examCode } = (data ?? {}) as { alertId?: unknown; examCode?: unknown };
    if (typeof alertId !== "string" || typeof examCode !== "string") throw new Error("notifications.exam-alert: bad payload");
    const followers = await deps.followersOf(examCode);
    return { followers: followers.length, outcomes: await deps.notifications.enqueueExamAlert(alertId, followers) };
  };
}

/** `notifications.release-held` (every 15 min, IST): held Exam Alerts go out once the user's quiet hours end. */
export function createReleaseHeldProcessor(deps: { notifications: { releaseHeld(): Promise<number> } }) {
  return async (): Promise<{ released: number }> => ({ released: await deps.notifications.releaseHeld() });
}
