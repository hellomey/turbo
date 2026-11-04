import type { SundayReport, SundayReportPage, z } from "@heymey/contracts";
import { DomainError } from "../../../shared/errors.js";
import { READINESS_CONFIG } from "../domain/config.js";
import { buildReportBody, istWeekOf, type WeekNumbers } from "../domain/report.js";
import type { ReadinessDeps, ReportRow } from "./ports.js";

export type SundayReportDto = z.infer<typeof SundayReport>;
export type SundayReportPageDto = z.infer<typeof SundayReportPage>;

const DAY_MS = 24 * 60 * 60 * 1000;

const summaryOf = (r: ReportRow) => ({ id: r.id, weekStart: r.weekStart, tier: r.tier, createdAt: r.createdAt.toISOString() });

const encodeCursor = (r: ReportRow) => Buffer.from(`${r.createdAt.toISOString()}|${r.id}`).toString("base64url");

function decodeCursor(cursor: string): { createdAt: Date; id: string } {
  const [at, id] = Buffer.from(cursor, "base64url").toString("utf8").split("|");
  const createdAt = new Date(at ?? "");
  if (!id || Number.isNaN(createdAt.getTime())) throw new DomainError("VALIDATION_FAILED", { issues: [{ path: "cursor", message: "Invalid cursor" }] });
  return { createdAt, id };
}

/** GET /v1/me/sunday-reports: the owner's reports, newest first. */
export async function listReports(d: ReadinessDeps, userId: string, q: { cursor?: string | undefined; limit: number }): Promise<SundayReportPageDto> {
  const rows = await d.repo.pageReports(userId, q.cursor ? decodeCursor(q.cursor) : null, q.limit + 1);
  const page = rows.slice(0, q.limit);
  const last = page.at(-1);
  return { items: page.map(summaryOf), nextCursor: rows.length > q.limit && last ? encodeCursor(last) : null };
}

/** GET /v1/me/sunday-reports/{id}: owner only; another user's report is REPORT_NOT_FOUND (no existence leak). */
export async function getReport(d: ReadinessDeps, userId: string, reportId: string): Promise<SundayReportDto> {
  const r = await d.repo.getReport(reportId);
  if (!r || r.userId !== userId) throw new DomainError("REPORT_NOT_FOUND");
  return { ...summaryOf(r), ...r.body };
}

/** Submitted mocks started in [from, to), from exam-hall's history (newest first). */
async function mocksTaken(d: ReadinessDeps, userId: string, from: Date, to: Date): Promise<number> {
  let n = 0;
  let cursor: string | null = null;
  do {
    const page = await d.examHall.history(userId, cursor, 50);
    for (const item of page.items) {
      const at = new Date(item.startedAt);
      if (at < from) return n;
      if (at < to && item.status === "submitted") n++;
    }
    cursor = page.nextCursor;
  } while (cursor);
  return n;
}

/** This week's numbers for one user, from mastery, practice and exam-hall public APIs only. */
export async function weekNumbers(d: ReadinessDeps, userId: string, from: Date, to: Date): Promise<WeekNumbers> {
  const [lamps, summary, practice, mocks] = await Promise.all([
    d.masteryActivity.weekCounts(userId, from, to),
    d.mastery.summary(userId),
    d.practice.week(userId, from, to),
    mocksTaken(d, userId, from, to),
  ]);
  return {
    lampsLit: lamps.lit,
    steadyEarned: lamps.steadyEarned,
    goldEarned: lamps.gold,
    relit: lamps.relit,
    dimmedNow: summary.counts.dimming + summary.counts.dim,
    questionsAnswered: practice?.answered ?? 0,
    correct: practice?.correct ?? 0,
    mocksTaken: mocks,
    studyMinutes: practice?.studyMinutes ?? 0,
  };
}

export interface SundayRunResult {
  weekStart: string;
  users: number;
  created: number;
  existing: number;
  failed: number;
}

/**
 * Worker `readiness.sunday-report` (Sunday 08:00 IST, D-2026-10-22-30; §19.5 Q50, §11). Users with lamp activity in the
 * last 14 days, in batches of 500. One report per user per IST week (unique): a rerun creates nothing twice.
 * One failing user never stops the batch. `onCreated` lets the composition root queue the push (readiness does not
 * depend on notifications).
 */
export async function buildSundayReports(
  d: ReadinessDeps,
  onCreated?: (userId: string, reportId: string) => Promise<void>,
): Promise<SundayRunResult> {
  const now = d.clock.now();
  const { weekStart, from } = istWeekOf(now);
  const cfg = READINESS_CONFIG.sundayReport;
  const since = new Date(now.getTime() - cfg.activeWithinDays * DAY_MS);
  const result: SundayRunResult = { weekStart, users: 0, created: 0, existing: 0, failed: 0 };
  let after: string | null = null;
  for (;;) {
    const ids = await d.masteryActivity.activeUserIds({ since, afterUserId: after, limit: cfg.batchSize });
    for (const userId of ids) {
      result.users++;
      try {
        if (await d.repo.hasReport(userId, weekStart)) {
          result.existing++;
          continue;
        }
        const [numbers, isPro] = await Promise.all([weekNumbers(d, userId, from, now), d.entitlements.isPro(userId)]);
        const tier = isPro ? "full" : "short";
        const { row, created } = await d.repo.createReport({ userId, weekStart, tier, body: buildReportBody(numbers, tier), createdAt: now });
        if (!created) {
          result.existing++;
          continue;
        }
        result.created++;
        if (onCreated) await onCreated(userId, row.id);
      } catch {
        result.failed++;
      }
    }
    if (ids.length < cfg.batchSize) break;
    after = ids[ids.length - 1] ?? null;
  }
  return result;
}
