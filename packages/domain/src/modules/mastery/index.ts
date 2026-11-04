/**
 * Public API of the `mastery` module. Lit/Steady/Gold rings, dimming schedule, relight, Career Ladder rank.
 * Export use cases and types only. Never export repositories or Prisma models.
 * Design: aidlc/construction/units/U-mastery/. Blueprint §5.1, §5.2, §5.3 rule 4, §39.
 */
import type { PrismaClient } from "@heymey/db";
import type { Clock, EventPublisher } from "../../shared/index.js";
import type { QuestionBank } from "../content/index.js";
import { runDimming, type DimmingRunResult } from "./application/dimming.js";
import type { LearnerPorts, MasteryDeps, MasteryRepository, TopicCatalog } from "./application/ports.js";
import {
  getSummary,
  listStates,
  relightQueue,
  type MasterySummaryDto,
  type RelightQueueDto,
  type TopicStatePageDto,
} from "./application/read.js";
import { completeLesson, startCheck, submitCheck, type AnswerInputDto, type CheckResultDto, type TopicCheckDto } from "./application/study.js";
import { syncMasteryAction, topicStatesFor, type MasterySyncAction, type SyncActionResultDto } from "./application/sync.js";
import type { TopicStateDto } from "./domain/dto.js";
import type { CheckKind } from "./domain/lamp.js";
import { PrismaMasteryRepository } from "./infrastructure/prisma-mastery-repository.js";
import { PrismaMasteryActivity, type MasteryWeekCounts } from "./infrastructure/prisma-mastery-activity.js";

export const MasteryModule = { name: "mastery" } as const;

export { MASTERY_CONFIG } from "./domain/config.js";
export { computeRank, xpOf, rankTitle, countRings, type RingTotals, type RankValue } from "./domain/rank.js";
export {
  applyCheck,
  canStart,
  completeLesson as completeLessonRule,
  dimStep,
  emptyLamp,
  gapAfterLevel,
  istDayStartPlusDays,
  nextCheck,
  ringOf,
  type LampState,
  type CheckKind,
  type DimState,
  type Transition,
} from "./domain/lamp.js";
export { checkSpec, deadlineFor, isExpired, isLate, isTooOld, scoreCheck, goldLimitReached } from "./domain/check.js";
export type { CheckRecord, Commit, CommitResult, LearnerPorts, MasteryRepository, TopicCatalog } from "./application/ports.js";
export type { DimmingRunResult } from "./application/dimming.js";
export type { MasterySyncAction, SyncActionResultDto } from "./application/sync.js";
export type { TopicStateDto } from "./domain/dto.js";
export type { MasterySummaryDto, RelightQueueDto, TopicStatePageDto } from "./application/read.js";
export type { CheckResultDto, TopicCheckDto, AnswerInputDto } from "./application/study.js";

export interface MasteryApi {
  summary(userId: string): Promise<MasterySummaryDto>;
  topicStates(userId: string, q: { examCode: string; since?: string | undefined; cursor?: string | undefined; limit: number }): Promise<TopicStatePageDto>;
  relightQueue(userId: string): Promise<RelightQueueDto>;
  completeLesson(userId: string, topicId: string): Promise<TopicStateDto>;
  startCheck(userId: string, topicId: string, kind: CheckKind): Promise<TopicCheckDto>;
  submitCheck(userId: string, checkId: string, answers: readonly AnswerInputDto[]): Promise<CheckResultDto>;
  /** One offline action of a mastery kind (lesson_complete, topic_check). */
  syncAction(userId: string, action: MasterySyncAction): Promise<SyncActionResultDto>;
  statesOf(userId: string, topicIds: readonly string[]): Promise<TopicStateDto[]>;
  /** `mastery.dimming` job body. */
  runDimming(): Promise<DimmingRunResult>;
}

const noEvents: EventPublisher = { publish: async () => undefined };

export function createMasteryModule(
  deps: ({ prisma: PrismaClient } | { repository: MasteryRepository }) & {
    clock: Clock;
    syllabus: TopicCatalog;
    questions: QuestionBank;
    openableTopics: (topicIds: string[]) => Promise<ReadonlySet<string>>;
    learner: LearnerPorts;
    events?: EventPublisher;
  },
): MasteryApi {
  const d: MasteryDeps = {
    repo: "repository" in deps ? deps.repository : new PrismaMasteryRepository(deps.prisma),
    clock: deps.clock,
    syllabus: deps.syllabus,
    questions: deps.questions,
    openableTopics: deps.openableTopics,
    learner: deps.learner,
    events: deps.events ?? noEvents,
  };
  return {
    summary: (userId) => getSummary(d, userId),
    topicStates: (userId, q) => listStates(d, userId, q),
    relightQueue: (userId) => relightQueue(d, userId),
    completeLesson: (userId, topicId) => completeLesson(d, userId, topicId),
    startCheck: (userId, topicId, kind) => startCheck(d, userId, topicId, kind),
    submitCheck: (userId, checkId, answers) => submitCheck(d, userId, checkId, answers),
    syncAction: (userId, action) => syncMasteryAction(d, userId, action),
    statesOf: (userId, topicIds) => topicStatesFor(d, userId, topicIds),
    runDimming: () => runDimming(d),
  };
}

/** For the worker: only what the dimming job needs. */
export function createMasteryDimming(deps: { prisma: PrismaClient; clock: Clock; events?: EventPublisher }): { run(): Promise<DimmingRunResult> } {
  const repo = new PrismaMasteryRepository(deps.prisma);
  return { run: () => runDimming({ repo, clock: deps.clock, events: deps.events ?? noEvents }) };
}

// ---------------------------------------------------------------- read-only activity view (added by BOLT-0013 for readiness)
export type { MasteryWeekCounts } from "./infrastructure/prisma-mastery-activity.js";

export interface MasteryActivityApi {
  /** Users with any lamp event since `since`, keyset-paged by userId. */
  activeUserIds(q: { since: Date; afterUserId: string | null; limit: number }): Promise<string[]>;
  /** Lamp events of one user in [from, to): lit, Steady steps, Gold, relit. */
  weekCounts(userId: string, from: Date, to: Date): Promise<MasteryWeekCounts>;
}

export function createMasteryActivity(deps: { prisma: PrismaClient }): MasteryActivityApi {
  const a = new PrismaMasteryActivity(deps.prisma);
  return { activeUserIds: (q) => a.activeUserIds(q), weekCounts: (u, f, t) => a.weekCounts(u, f, t) };
}
