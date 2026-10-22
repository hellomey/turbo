import { OFFICIAL_CONFIRM_LINE, type ExamAlert, type ExamChange, type z } from "@heymey/contracts";
import { DomainError } from "../../../shared/errors.js";

/** Exam Alerts (blueprint §19.1 Q7, §17.5, §20.2; INT-002-S17; D-2026-10-22-32). Pure rules, no I/O. */

export type ExamAlertDto = z.infer<typeof ExamAlert>;
export type ExamChangeDto = z.infer<typeof ExamChange>;
export type ExamAlertKind = ExamAlertDto["kind"];
export type ExamChangeStatus = "pending" | "approved" | "rejected";

/** Roles that may approve or reject a site change (D-2026-10-22-32). REVIEWER etc. are refused. */
export const EXAM_CHANGE_REVIEW_ROLES = ["OPS", "ADMIN"] as const;

export interface ExamChangeRecord {
  id: string;
  watchUuid: string;
  changeId: string;
  watchUrl: string;
  title: string | null;
  diffSummary: string | null;
  receivedAt: Date;
  status: ExamChangeStatus;
  reviewedAt: Date | null;
  alertId: string | null;
  /** Exam of the published alert (null while pending / rejected). */
  examCode: string | null;
}

export interface ExamAlertRecord {
  id: string;
  examCode: string;
  kind: ExamAlertKind;
  title: string;
  summary: string;
  officialUrl: string;
  publishedAt: Date;
}

/** Invariant 7: single use. */
export function assertPending(change: Pick<ExamChangeRecord, "status">): void {
  if (change.status !== "pending") throw new DomainError("EXAM_CHANGE_ALREADY_REVIEWED");
}

export function canReviewExamChanges(roles: readonly string[]): boolean {
  return roles.some((r) => (EXAM_CHANGE_REVIEW_ROLES as readonly string[]).includes(r));
}

/** Invariant 9: every alert carries the official URL and the confirm line. */
export function toExamAlertDto(a: ExamAlertRecord): ExamAlertDto {
  return {
    id: a.id,
    examCode: a.examCode,
    kind: a.kind,
    title: a.title,
    summary: a.summary,
    officialUrl: a.officialUrl,
    publishedAt: a.publishedAt.toISOString(),
    confirmLine: OFFICIAL_CONFIRM_LINE,
  };
}

export function toExamChangeDto(c: ExamChangeRecord): ExamChangeDto {
  return {
    id: c.id,
    watchUrl: c.watchUrl,
    examCode: c.examCode,
    title: c.title,
    diffSummary: c.diffSummary,
    receivedAt: c.receivedAt.toISOString(),
    status: c.status,
    reviewedAt: c.reviewedAt?.toISOString() ?? null,
    alertId: c.alertId,
  };
}

export interface StageDateEntry {
  stageCode: string;
  date: string | null;
  dateStatus?: string;
  [k: string]: unknown;
}

/** Sets one stage's date in an attempt cycle's `stageDates` (announced = confirmed by an official notification). */
export function applyStageDate(entries: readonly StageDateEntry[], stageCode: string, date: string): { entries: StageDateEntry[]; changed: boolean } {
  let changed = false;
  const out = entries.map((e) => {
    if (e.stageCode !== stageCode) return e;
    changed = true;
    return { ...e, date, dateStatus: "announced" };
  });
  return { entries: out, changed };
}
