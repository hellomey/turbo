import type { z, MockAttemptListItem, MockAttemptState, MockReport, MockSummary, StatewideRank, StateMockInfo, MockList, MockAnswersSaved } from "@heymey/contracts";
import type { Clock } from "../../../shared/clock.js";
import type { EventPublisher } from "../../../shared/ports.js";
import type { QuestionWithKey } from "../../content/index.js";
import type { Fraction } from "../domain/fraction.js";
import type { RankRow } from "../domain/ranking.js";
import type { AttemptMode, AttemptRecord, AttemptScore, AttemptStatus, MockKind, MockRecord, PaperView, SavedAnswer } from "../domain/types.js";

/** Contract DTOs (one contract, §34.4). */
export type MockSummaryDto = z.infer<typeof MockSummary>;
export type MockListDto = z.infer<typeof MockList>;
export type MockAttemptStateDto = z.infer<typeof MockAttemptState>;
export type MockAnswersSavedDto = z.infer<typeof MockAnswersSaved>;
export type MockReportDto = z.infer<typeof MockReport>;
export type MockAttemptListItemDto = z.infer<typeof MockAttemptListItem>;
export type StateMockInfoDto = z.infer<typeof StateMockInfo>;
export type StatewideRankDto = z.infer<typeof StatewideRank>;

export interface StartAttemptInput {
  userId: string;
  mockId: string;
  mode: AttemptMode;
  startedAt: Date;
  deadlineAt: Date;
  schemeVersion: number;
  istMonth: string;
  /** Ranked only if the start is inside the live window AND this is the user's first attempt of the mock. */
  rankedIfFirst: boolean;
  useAllowance: boolean;
}

export interface FinishInput {
  status: Exclude<AttemptStatus, "in_progress">;
  submittedAt: Date;
  result: AttemptScore;
}

export interface HistoryRow {
  attempt: AttemptRecord;
  title: string;
  kind: MockKind;
}

/** Port: exam-hall storage (Mock, MockAttempt, MockAnswer, MockAllowanceUse, MockRank). Adapter: Prisma. */
export interface ExamHallRepository {
  listPublishedMocks(examCode: string): Promise<MockRecord[]>;
  findMock(id: string): Promise<MockRecord | null>;
  /** The published State Mock Sunday for this exam that has not closed yet (earliest first). */
  nextStateMock(examCode: string, now: Date): Promise<MockRecord | null>;
  findInProgress(userId: string, mockId: string): Promise<AttemptRecord | null>;
  lastAttemptIds(userId: string, mockIds: string[]): Promise<Map<string, string>>;
  allowanceUsed(userId: string, istMonth: string): Promise<boolean>;
  /**
   * ONE transaction, serialised per (user, mock): returns the in-progress attempt if there is one (resume),
   * otherwise records the allowance use (unique per user+month: MOCK_MONTHLY_LIMIT on conflict) and creates the attempt.
   */
  startAttempt(input: StartAttemptInput): Promise<{ attempt: AttemptRecord; resumed: boolean }>;
  findAttempt(id: string): Promise<AttemptRecord | null>;
  answers(attemptId: string): Promise<SavedAnswer[]>;
  /**
   * Upsert answers (a newer clientAt wins per question) only while the attempt is in progress; `unrank` sets ranked=false
   * in the same transaction. Returns null if the attempt is no longer in progress.
   */
  saveAnswers(attemptId: string, answers: SavedAnswer[], unrank: boolean): Promise<number | null>;
  /** Finish once: only an in-progress attempt changes; returns the stored record either way. */
  finishAttempt(attemptId: string, input: FinishInput): Promise<{ attempt: AttemptRecord; changed: boolean }>;
  history(userId: string, cursor: string | null, limit: number): Promise<{ rows: HistoryRow[]; nextCursor: string | null }>;
  /** In-progress attempts whose deadline is before `before` (oldest first). */
  overdueAttemptIds(before: Date, limit: number): Promise<string[]>;
  /** Every in-progress attempt of one mock. */
  openAttempts(mockId: string): Promise<AttemptRecord[]>;
  /** State mocks with rankPublishAt <= now and no rank rows yet. */
  mocksDueForRanks(now: Date): Promise<MockRecord[]>;
  rankedScores(mockId: string): Promise<{ userId: string; score: Fraction }[]>;
  /** Insert-once: existing rows are kept (skip duplicates). Returns rows inserted. */
  insertRanks(mockId: string, rows: RankRow[], publishedAt: Date): Promise<number>;
  ranksPublished(mockId: string): Promise<boolean>;
  findRank(mockId: string, userId: string): Promise<{ rank: number; percentile: number; candidates: number; publishedAt: Date } | null>;
  rankedAttempt(mockId: string, userId: string): Promise<AttemptRecord | null>;
}

/** Port into `exams` (ADR-0012). */
export interface PaperSource {
  paperForMock(paperId: string, schemeVersion: number): Promise<PaperView | null>;
}

/** Port into `content`: questions + server-only keys. */
export interface QuestionSource {
  withKeys(questionIds: readonly string[]): Promise<QuestionWithKey[]>;
}

/** Port into `billing` (Phase 3 builds it). Pro gives the full report and unlimited full mocks (§11), never a rank advantage. */
export interface Entitlements {
  isPro(userId: string): Promise<boolean>;
}

export interface ExamHallDeps {
  repo: ExamHallRepository;
  papers: PaperSource;
  questions: QuestionSource;
  entitlements: Entitlements;
  clock: Clock;
  events?: EventPublisher;
}
