import type { ApproveExamChangeBody, SiteChangeWebhookBody, z } from "@heymey/contracts";
import type { Prisma } from "@heymey/db";
import { DomainError } from "../../../shared/errors.js";
import type { Clock } from "../../../shared/clock.js";
import type { EventPublisher } from "../../../shared/ports.js";
import {
  assertPending,
  toExamAlertDto,
  toExamChangeDto,
  type ExamAlertDto,
  type ExamAlertKind,
  type ExamAlertRecord,
  type ExamChangeDto,
  type ExamChangeRecord,
  type ExamChangeStatus,
} from "../domain/exam-alerts.js";

/**
 * SEC-P2-M1: runs INSIDE the approve/reject transaction (the composition root writes the Desk audit row here).
 * If it throws, the review is rolled back: nothing approved, no alert, no events/pushes.
 */
export type ReviewTxHook = (tx: Prisma.TransactionClient, outcome: { alertId: string | null }) => Promise<void>;

/** Port: ExamWatchChange + ExamAlert storage (exams owns both tables). */
export interface ExamAlertsRepository {
  /** Insert-if-absent on (watchUuid, changeId). */
  insertChange(input: { watchUuid: string; changeId: string; watchUrl: string; title: string | null; diffSummary: string | null; at: Date }): Promise<"created" | "duplicate">;
  listChanges(status: ExamChangeStatus, cursor: string | undefined, limit: number): Promise<ExamChangeRecord[]>;
  findChange(id: string): Promise<ExamChangeRecord | null>;
  /** Published exam id by code, or null. */
  examIdByCode(code: string): Promise<string | null>;
  /**
   * ONE transaction: guard status=pending, create the ExamAlert, mark approved, optionally set a stage date on the
   * exam's open attempt cycle. Returns null when the change was no longer pending.
   */
  approve(input: {
    changeId: string;
    reviewerId: string;
    at: Date;
    alert: { examId: string; examCode: string; kind: ExamAlertKind; title: string; summary: string; officialUrl: string };
    stageDate?: { stageCode: string; date: string };
  }, inTx?: ReviewTxHook): Promise<{ change: ExamChangeRecord; alert: ExamAlertRecord; cycleId: string | null } | null>;
  reject(input: { changeId: string; reviewerId: string; at: Date; note: string }, inTx?: ReviewTxHook): Promise<ExamChangeRecord | null>;
  alertsForUser(userId: string, cursor: string | undefined, limit: number): Promise<ExamAlertRecord[]>;
  followersOf(examCode: string): Promise<string[]>;
}

export interface ExamAlertsDeps {
  repo: ExamAlertsRepository;
  clock: Clock;
  events: EventPublisher;
  /** Constant-time shared-secret check. Never logs the value. */
  verifySecret: (provided: string | undefined) => boolean;
}

export interface Page<T> {
  items: T[];
  nextCursor: string | null;
}

function page<T extends { id: string }, D>(rows: T[], limit: number, map: (r: T) => D): Page<D> {
  const items = rows.slice(0, limit);
  return { items: items.map(map), nextCursor: rows.length > limit ? (items[items.length - 1]?.id ?? null) : null };
}

/** Invariants 4-6: secret first (nothing stored on 401), replay -> 409, never sends anything. */
export async function receiveSiteChange(d: ExamAlertsDeps, secret: string | undefined, parse: () => z.infer<typeof SiteChangeWebhookBody>) {
  if (!d.verifySecret(secret)) throw new DomainError("WEBHOOK_UNAUTHORIZED");
  const body = parse();
  const res = await d.repo.insertChange({
    watchUuid: body.watchUuid,
    changeId: body.changeId,
    watchUrl: body.watchUrl,
    title: body.title ?? null,
    diffSummary: body.diffSummary ?? null,
    at: d.clock.now(),
  });
  if (res === "duplicate") throw new DomainError("WEBHOOK_REPLAYED");
  return { received: true };
}

export async function listChanges(d: ExamAlertsDeps, q: { status: ExamChangeStatus; cursor?: string | undefined; limit: number }): Promise<Page<ExamChangeDto>> {
  return page(await d.repo.listChanges(q.status, q.cursor, q.limit + 1), q.limit, toExamChangeDto);
}

/** Invariants 7, 8: single use; exactly one alert; events after commit. Role check + audit are in the API. */
export async function approveChange(d: ExamAlertsDeps, reviewerId: string, changeId: string, body: z.infer<typeof ApproveExamChangeBody>, inTx?: ReviewTxHook): Promise<ExamChangeDto> {
  const change = await d.repo.findChange(changeId);
  if (!change) throw new DomainError("NOT_FOUND");
  assertPending(change);
  const examId = await d.repo.examIdByCode(body.examCode);
  if (!examId) throw new DomainError("EXAM_NOT_FOUND");
  const at = d.clock.now();
  const res = await d.repo.approve({
    changeId,
    reviewerId,
    at,
    alert: { examId, examCode: body.examCode, kind: body.kind, title: body.title, summary: body.summary, officialUrl: body.officialUrl },
    ...(body.newStageDate ? { stageDate: body.newStageDate } : {}),
  }, inTx);
  if (!res) throw new DomainError("EXAM_CHANGE_ALREADY_REVIEWED");
  await d.events.publish({ type: "exams.notification_published", occurredAt: at, payload: { alertId: res.alert.id, examCode: body.examCode } });
  if (body.newStageDate && res.cycleId) {
    await d.events.publish({
      type: "exams.date_changed",
      occurredAt: at,
      payload: { examCode: body.examCode, cycleId: res.cycleId, stageCode: body.newStageDate.stageCode, date: body.newStageDate.date },
    });
  }
  return toExamChangeDto(res.change);
}

/** Invariant 10: reject never publishes. */
export async function rejectChange(d: ExamAlertsDeps, reviewerId: string, changeId: string, reason: string, inTx?: ReviewTxHook): Promise<ExamChangeDto> {
  const change = await d.repo.findChange(changeId);
  if (!change) throw new DomainError("NOT_FOUND");
  assertPending(change);
  const res = await d.repo.reject({ changeId, reviewerId, at: d.clock.now(), note: reason }, inTx);
  if (!res) throw new DomainError("EXAM_CHANGE_ALREADY_REVIEWED");
  return toExamChangeDto(res);
}

export async function myExamAlerts(d: ExamAlertsDeps, userId: string, q: { cursor?: string | undefined; limit: number }): Promise<Page<ExamAlertDto>> {
  return page(await d.repo.alertsForUser(userId, q.cursor, q.limit + 1), q.limit, toExamAlertDto);
}
