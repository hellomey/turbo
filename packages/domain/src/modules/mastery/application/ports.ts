import type { Clock, EventPublisher } from "../../../shared/index.js";
import type { QuestionBank } from "../../content/index.js";
import type { TopicRow } from "../../syllabus/index.js";
import type { ActionSource, CheckKind, LampState, RingEventKind } from "../domain/lamp.js";

/** A server-issued check as stored (`TopicCheck`). */
export interface CheckRecord {
  id: string;
  userId: string;
  topicId: string;
  kind: CheckKind;
  questionIds: string[];
  passMark: number;
  issuedAt: Date;
  deadlineAt: Date | null;
  submittedAt: Date | null;
  correct: number | null;
  passed: boolean | null;
  source: ActionSource;
  configVersion: string;
}

export type NewCheck = Omit<CheckRecord, "id" | "submittedAt" | "correct" | "passed">;

export interface RingEventRow {
  userId: string;
  topicId: string;
  kind: RingEventKind;
  at: Date;
  source: ActionSource;
  clientActionId?: string | null;
  checkId?: string | null;
  details?: Record<string, unknown> | null;
}

/**
 * One atomic write (one DB transaction): optional lamp state (optimistic, guarded by rowVersion), the append-only
 * history rows, and optionally the check result (single-submit guard: only if not submitted yet).
 */
export interface Commit {
  /** expectedVersion null = the row must not exist yet (insert). The repository stores rowVersion = expected + 1. */
  state?: { next: LampState; expectedVersion: number | null };
  events: RingEventRow[];
  check?: { id: string; submittedAt: Date; correct: number; passed: boolean };
}

/** ok | conflict (rowVersion race: reload and retry) | duplicate (check already submitted or clientActionId seen). */
export type CommitResult = "ok" | "conflict" | "duplicate";

export interface StatePageQuery {
  userId: string;
  topicIds: readonly string[];
  since: Date | null;
  after: { updatedAt: Date; topicId: string } | null;
  limit: number;
}

/** Port: the mastery module's storage. Adapter: infrastructure/prisma-mastery-repository.ts. */
export interface MasteryRepository {
  getState(userId: string, topicId: string): Promise<LampState | null>;
  statesFor(userId: string, topicIds: readonly string[]): Promise<LampState[]>;
  /** Ordered by (updatedAt, topicId) ascending. */
  pageStates(q: StatePageQuery): Promise<LampState[]>;
  commit(c: Commit): Promise<CommitResult>;
  createCheck(c: NewCheck): Promise<CheckRecord>;
  getCheck(checkId: string): Promise<CheckRecord | null>;
  countChecksSince(userId: string, topicId: string, kind: CheckKind, since: Date): Promise<number>;
  hasClientAction(clientActionId: string): Promise<boolean>;
  /**
   * Lit lamps the dimming job may change, keyset-paged by (userId, topicId): bright with nextDueAt <= now, or dimming
   * with nextDueAt <= dimCutoff (= now - steadyLostAfterOverdueDays).
   */
  dimmingCandidates(q: { now: Date; dimCutoff: Date; limit: number; after: { userId: string; topicId: string } | null }): Promise<LampState[]>;
  getRankLevel(userId: string): Promise<number | null>;
  saveRank(userId: string, r: { level: number; xp: number; familyCode: string | null; configVersion: string }): Promise<void>;
}

/** What mastery needs from syllabus (its declared dependency). */
export type TopicCatalog = {
  topic(topicId: string): Promise<TopicRow | null>;
  topicsForExam(examCode: string): Promise<TopicRow[]>;
};

/**
 * Facts from modules mastery does NOT depend on, passed in by the composition root (apps/api, apps/worker), like the
 * syllabus StudyMapPorts. No new module dependency (logical design "Composition").
 */
export interface LearnerPorts {
  /** The user's followed exam codes (main first). */
  examCodes(userId: string): Promise<string[]>;
  publishedExamCodes(): Promise<ReadonlySet<string>>;
}

export interface MasteryDeps {
  repo: MasteryRepository;
  clock: Clock;
  syllabus: TopicCatalog;
  questions: QuestionBank;
  /** Which topics the user can open (Phase 2 stub: topics with published content, invariant 17). */
  openableTopics(topicIds: string[]): Promise<ReadonlySet<string>>;
  learner: LearnerPorts;
  events: EventPublisher;
}
