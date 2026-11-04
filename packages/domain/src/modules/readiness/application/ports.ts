import type { Clock } from "../../../shared/clock.js";
import type { ExamHallApi } from "../../exam-hall/index.js";
import type { MasteryActivityApi, MasteryApi } from "../../mastery/index.js";
import type { ReportBody } from "../domain/report.js";

/** One row per user, exam and IST day (invariant 7). Values are the full server evidence (not the free-tier view). */
export interface SnapshotRow {
  userId: string;
  examCode: string;
  istDay: string;
  label: string;
  coverage: number | null;
  memory: number | null;
  examPerformance: number | null;
  speed: number | null;
  litPct: number;
  steadyPct: number;
  goldPct: number;
  configVersion: string;
  computedAt: Date;
}

export interface ReportRow {
  id: string;
  userId: string;
  weekStart: string;
  tier: "short" | "full";
  body: ReportBody;
  createdAt: Date;
}

/** Port: readiness storage (ReadinessSnapshot, SundayReport). Adapter: infrastructure/prisma-readiness-repository.ts. */
export interface ReadinessRepository {
  upsertSnapshot(s: SnapshotRow): Promise<void>;
  /** Inclusive IST day keys, ascending by day. */
  snapshotsBetween(userId: string, examCode: string, fromDay: string, toDay: string): Promise<SnapshotRow[]>;
  hasReport(userId: string, weekStart: string): Promise<boolean>;
  /** Unique (userId, weekStart): a second insert returns created = false and the stored row. */
  createReport(r: Omit<ReportRow, "id">): Promise<{ row: ReportRow; created: boolean }>;
  /** Newest first, keyset (createdAt, id) descending. */
  pageReports(userId: string, after: { createdAt: Date; id: string } | null, limit: number): Promise<ReportRow[]>;
  getReport(id: string): Promise<ReportRow | null>;
}

/** Practice evidence (U-practice, BOLT-0010). Until it lands the composition root passes NO_PRACTICE_EVIDENCE. */
export interface PracticeStats {
  /** Median seconds per question in timed practice of this exam; null = no evidence. */
  speed(userId: string, examCode: string): Promise<{ medianSeconds: number } | null>;
  week(userId: string, from: Date, to: Date): Promise<{ answered: number; correct: number; studyMinutes: number } | null>;
}

/** Exam facts readiness needs (from the exams catalogue, wired by the composition root: no new module dependency). */
export interface ExamFacts {
  /** null = unknown exam. */
  examInfo(examCode: string): Promise<{ conductingBody: string; paperSecondsPerQuestion: number | null } | null>;
}

/** Billing read through the composition root (logical design "Composition"). Phase 2: everyone is free. */
export interface ReadinessEntitlements {
  isPro(userId: string): Promise<boolean>;
}

export interface ReadinessDeps {
  repo: ReadinessRepository;
  clock: Clock;
  mastery: Pick<MasteryApi, "summary" | "topicStates">;
  masteryActivity: MasteryActivityApi;
  examHall: Pick<ExamHallApi, "history" | "report">;
  practice: PracticeStats;
  exams: ExamFacts;
  entitlements: ReadinessEntitlements;
}
