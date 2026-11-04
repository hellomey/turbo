import type { Rank, z } from "@heymey/contracts";
import type { Clock, EventPublisher } from "../../../shared/index.js";
import type { ItemDraft, PlanItemKind, PlanItemStatus, PlanTarget, StretchPhase } from "../domain/rules.js";

/** Stored plan (one per user, invariant 1). */
export interface PlanRecord {
  id: string;
  userId: string;
  weekdayMinutes: number;
  weekendMinutes: number;
  pocketMinutes: number;
  balance: number;
  starterPathUntil: string | null;
  stretch: StretchPhase;
  lastActiveIstDay: string | null;
  lastRebalancedAt: Date | null;
  configVersion: string;
  exams: PlanTarget[];
}

export interface PlanItemRecord {
  id: string;
  planId: string;
  day: string;
  kind: PlanItemKind;
  examCode: string | null;
  topicId: string | null;
  title: string;
  minutes: number;
  order: number;
  status: PlanItemStatus;
}

export interface StudyLogEntry {
  userId: string;
  kind: string;
  topicId: string | null;
  minutes: number;
  at: Date;
  istDay: string;
  source: "online" | "offline_sync";
  clientActionId: string | null;
  details?: Record<string, unknown>;
}

export type PlanSettings = Pick<PlanRecord, "weekdayMinutes" | "weekendMinutes" | "pocketMinutes" | "balance">;

/** Port: the plan module's tables (Plan, PlanExam, PlanItem, StudyLog). Adapter: infrastructure/prisma-plan-repository.ts. */
export interface PlanRepository {
  findByUser(userId: string): Promise<PlanRecord | null>;
  /** Create or update settings + replace exams in one transaction. */
  save(userId: string, settings: PlanSettings & { starterPathUntil: string | null; stretch: StretchPhase; configVersion: string }, exams: PlanTarget[]): Promise<PlanRecord>;
  setExams(planId: string, exams: PlanTarget[], stretch: StretchPhase): Promise<void>;
  items(planId: string, from: string, to: string): Promise<PlanItemRecord[]>;
  /** Pending + done items' topic ids (any day): topics already planned. */
  plannedTopicIds(planId: string): Promise<Set<string>>;
  /** ONE transaction: delete pending items with day >= fromDay, mark `movePastIds` as moved, insert drafts. */
  rebuild(planId: string, fromDay: string, drafts: ItemDraft[], movePastIds: string[], rebalancedAt: Date | null): Promise<void>;
  /** Item with its owner; null if unknown. */
  item(itemId: string): Promise<(PlanItemRecord & { userId: string }) | null>;
  /**
   * ONE transaction: change status only if the item is still pending (race safe), set lastActiveIstDay, append the
   * study log row. Returns the item as stored afterwards.
   */
  setItemStatus(itemId: string, status: "done" | "skipped", at: Date, istDay: string, log: StudyLogEntry | null): Promise<PlanItemRecord>;
  appendStudyLog(entry: StudyLogEntry): Promise<void>;
  hasClientAction(userId: string, clientActionId: string): Promise<boolean>;
  /** Users whose plan targets this attempt cycle (exams.date_changed). */
  usersForCycle(examCode: string, cycleId: string): Promise<string[]>;
  /** Users with pending items before `today` (nightly rebalance), paged by user id. */
  usersWithPastPending(today: string, afterUserId: string | null, limit: number): Promise<string[]>;
}

/** What plan reads from other modules (through their public APIs, wired in the composition root). */
export interface PlanTopic {
  topicId: string;
  name: string;
  priority: number;
}

export interface PlanPorts {
  /** exams: my exams with attempt cycle + next stage date, main first. */
  targets(userId: string): Promise<{ examCode: string; isMain: boolean; attemptCycleId: string | null; examDate: string | null }[]>;
  /** syllabus: lamps of one exam in syllabus order, with TopicExamTag.priority for that exam. */
  topicsForExam(examCode: string): Promise<PlanTopic[]>;
  /** mastery: which of these topics are already Lit. */
  litTopicIds(userId: string, topicIds: string[]): Promise<Set<string>>;
  /** mastery: Career Ladder rank (for Today). */
  rank(userId: string): Promise<z.infer<typeof Rank>>;
  /** mastery: relight queue size. */
  relight(userId: string): Promise<{ count: number; minutes: number }>;
}

export interface PlanDeps {
  repo: PlanRepository;
  clock: Clock;
  ports: PlanPorts;
  events: EventPublisher;
}
