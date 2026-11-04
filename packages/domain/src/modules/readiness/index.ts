/**
 * Public API of the `readiness` module. Readiness Meter, trends, Sunday Report (derived metrics).
 * Export use cases and types only. Never export repositories or Prisma models.
 * Design: aidlc/construction/units/U-readiness/. Built in BOLT-0013. Blueprint §11, §19.5 Q41-Q50, §19.10 Q100.
 * Reads mastery and exam-hall only through their public APIs (module.json dependsOn); practice, billing and the exam
 * catalogue come in as ports filled by the composition root.
 */
import type { PrismaClient } from "@heymey/db";
import type { Clock } from "../../shared/clock.js";
import { getMeter, getTrend, type ReadinessMeterDto, type ReadinessTrendDto } from "./application/meter.js";
import type { ExamFacts, PracticeStats, ReadinessDeps, ReadinessEntitlements, ReadinessRepository } from "./application/ports.js";
import { buildSundayReports, getReport, listReports, type SundayReportDto, type SundayReportPageDto, type SundayRunResult } from "./application/reports.js";
import { PrismaReadinessRepository } from "./infrastructure/prisma-readiness-repository.js";

export const ReadinessModule = { name: "readiness" } as const;

export { READINESS_CONFIG } from "./domain/config.js";
export { barValues, labelFor, readyForFullMocks, meterBars, coverageDetail, suggestionFor, pct, type Evidence, type BarValues } from "./domain/meter.js";
export { buildReportBody, istWeekOf, FORBIDDEN_REPORT_WORDS, type ReportBody, type WeekNumbers } from "./domain/report.js";
export type { ExamFacts, PracticeStats, ReadinessEntitlements, ReadinessRepository, ReportRow, SnapshotRow } from "./application/ports.js";
export type { ReadinessMeterDto, ReadinessTrendDto } from "./application/meter.js";
export type { SundayReportDto, SundayReportPageDto, SundayRunResult } from "./application/reports.js";

export interface ReadinessApi {
  meter(userId: string, examCode: string): Promise<ReadinessMeterDto>;
  trend(userId: string, examCode: string, days: number): Promise<ReadinessTrendDto>;
  listReports(userId: string, q: { cursor?: string | undefined; limit: number }): Promise<SundayReportPageDto>;
  getReport(userId: string, reportId: string): Promise<SundayReportDto>;
  /** Worker `readiness.sunday-report`. */
  buildSundayReports(onCreated?: (userId: string, reportId: string) => Promise<void>): Promise<SundayRunResult>;
}

/** Until practice (BOLT-0010) is wired: no speed or answer evidence (bars stay null, never fake zeros). */
export const NO_PRACTICE_EVIDENCE: PracticeStats = { speed: async () => null, week: async () => null };

/** Until billing lands (Phase 3) everyone is a free user (§11). */
export const READINESS_FREE_FOR_EVERYONE: ReadinessEntitlements = { isPro: async () => false };

export type ReadinessModuleDeps = ({ prisma: PrismaClient } | { repository: ReadinessRepository }) &
  Omit<ReadinessDeps, "repo" | "practice" | "entitlements"> & {
    clock: Clock;
    exams: ExamFacts;
    practice?: PracticeStats;
    entitlements?: ReadinessEntitlements;
  };

export function createReadinessModule(deps: ReadinessModuleDeps): ReadinessApi {
  const d: ReadinessDeps = {
    repo: "repository" in deps ? deps.repository : new PrismaReadinessRepository(deps.prisma),
    clock: deps.clock,
    mastery: deps.mastery,
    masteryActivity: deps.masteryActivity,
    examHall: deps.examHall,
    exams: deps.exams,
    practice: deps.practice ?? NO_PRACTICE_EVIDENCE,
    entitlements: deps.entitlements ?? READINESS_FREE_FOR_EVERYONE,
  };
  return {
    meter: (u, e) => getMeter(d, u, e),
    trend: (u, e, days) => getTrend(d, u, e, days),
    listReports: (u, q) => listReports(d, u, q),
    getReport: (u, id) => getReport(d, u, id),
    buildSundayReports: (onCreated) => buildSundayReports(d, onCreated),
  };
}
