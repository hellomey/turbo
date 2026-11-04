import type { SundayRunResult } from "@heymey/domain/modules/readiness";

/**
 * `readiness.sunday-report` (owner: readiness; Sunday 08:00 IST, D-2026-10-22-30; blueprint §19.5 Q50, §11). Calls the one
 * use case. Idempotent: one report per user per IST week (unique), so a rerun or retry creates nothing twice.
 * After a report is stored, the composition root queues a "study" push through notifications (readiness does not
 * depend on notifications; the dedupe key makes the push decided once). Logs counts only, never user ids.
 */
export function createSundayReportProcessor(deps: {
  readiness: { buildSundayReports(onCreated?: (userId: string, reportId: string) => Promise<void>): Promise<SundayRunResult> };
  notify?: (userId: string, reportId: string) => Promise<void>;
}) {
  return async (): Promise<SundayRunResult> => deps.readiness.buildSundayReports(deps.notify);
}

/** The push for a new report: category "study" (budget + quiet hours apply), deduped per report. */
export function sundayReportPush(notifications: {
  enqueue(input: { userId: string; category: "study"; templateKey: string; dedupeKey: string }): Promise<unknown>;
}) {
  return async (userId: string, reportId: string): Promise<void> => {
    await notifications.enqueue({ userId, category: "study", templateKey: "readiness.sunday_report", dedupeKey: `sunday-report:${reportId}` });
  };
}
