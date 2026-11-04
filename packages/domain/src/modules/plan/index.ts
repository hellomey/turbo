/**
 * Public API of the `plan` module. My Plan, Today Card, auto-rebalance, Final Stretch.
 * Export use cases and types only. Never export repositories or Prisma models.
 * Design: aidlc/construction/units/U-plan/. Blueprint §6, §7, §10.6, §17.1 step 9, §17.3, §19.2 Q11–Q20, §39.
 */
import type { PrismaClient } from "@heymey/db";
import type { Clock, EventPublisher } from "../../shared/index.js";
import type { ExamsApi } from "../exams/index.js";
import type { MasteryApi } from "../mastery/index.js";
import type { SyllabusApi } from "../syllabus/index.js";
import {
  getDays,
  getPlan,
  getToday,
  onDateChanged,
  putPlan,
  rebalance,
  rebalanceDue,
  syncItemStatus,
  updateItem,
  type PlanDaysDto,
  type PlanDto,
  type PlanItemDto,
  type PlanItemStatusAction,
  type PutPlanInput,
  type SyncResultDto,
  type TodayScreenDto,
} from "./application/plan-service.js";
import type { PlanDeps, PlanPorts, PlanRepository } from "./application/ports.js";
import { PrismaPlanRepository } from "./infrastructure/prisma-plan-repository.js";

export const PlanModule = { name: "plan" } as const;

export { PLAN_CONFIG } from "./domain/config.js";
export { addDays, daysBetween, dayRange, isWeekend, minutesForDay } from "./domain/days.js";
export {
  WELCOME_BACK,
  buildDay,
  daysLeft,
  examShares,
  missedDays,
  mixFor,
  nearestDaysLeft,
  needsRebalance,
  stretchPhase,
  todayCard,
  type ItemDraft,
  type Mix,
  type PlanTarget,
  type StretchPhase,
  type TopicPick,
} from "./domain/rules.js";
export type { PlanItemRecord, PlanPorts, PlanRecord, PlanRepository, PlanTopic, StudyLogEntry } from "./application/ports.js";
export type { PlanDaysDto, PlanDto, PlanItemDto, PlanItemStatusAction, PutPlanInput, SyncResultDto, TodayScreenDto } from "./application/plan-service.js";

export interface PlanApi {
  today(userId: string): Promise<TodayScreenDto>;
  get(userId: string): Promise<PlanDto>;
  put(userId: string, input: PutPlanInput): Promise<PlanDto>;
  days(userId: string, from: string, to: string): Promise<PlanDaysDto>;
  updateItem(userId: string, itemId: string, status: "done" | "skipped"): Promise<PlanItemDto>;
  /** POST /v1/me/plan/rebalance: always runs (the user asked). */
  rebalance(userId: string): Promise<PlanDto>;
  /** Offline outbox kind `plan_item_status` (§39). */
  syncAction(userId: string, action: PlanItemStatusAction): Promise<SyncResultDto>;
  /** Worker `plan.rebalance` (02:30 IST). */
  rebalanceDue(): Promise<{ checked: number; rebalanced: number }>;
  /** Worker `exams.date-changed`. */
  onDateChanged(event: { examCode: string; cycleId: string }): Promise<{ plans: number }>;
}

const noEvents: EventPublisher = { publish: async () => undefined };

/** Builds PlanPorts from the public APIs of the modules plan may depend on (module.json: syllabus, mastery, exams). */
export function planPortsFrom(apis: {
  exams: Pick<ExamsApi, "planTargets">;
  syllabus: Pick<SyllabusApi, "topicsForExam">;
  mastery: Pick<MasteryApi, "summary" | "relightQueue" | "statesOf">;
}): PlanPorts {
  return {
    targets: (userId) => apis.exams.planTargets(userId),
    topicsForExam: async (examCode) =>
      (await apis.syllabus.topicsForExam(examCode)).map((t) => ({ topicId: t.id, name: t.name, priority: t.priorities?.[examCode] ?? 0 })),
    litTopicIds: async (userId, topicIds) => new Set((await apis.mastery.statesOf(userId, topicIds)).filter((s) => s.litAt !== null).map((s) => s.topicId)),
    rank: async (userId) => (await apis.mastery.summary(userId)).rank,
    relight: async (userId) => {
      const q = await apis.mastery.relightQueue(userId);
      return { count: q.items.length, minutes: q.totalMinutes };
    },
  };
}

export function createPlanModule(
  deps: ({ prisma: PrismaClient } | { repository: PlanRepository }) & { clock: Clock; ports: PlanPorts; events?: EventPublisher },
): PlanApi {
  const d: PlanDeps = {
    repo: "repository" in deps ? deps.repository : new PrismaPlanRepository(deps.prisma),
    clock: deps.clock,
    ports: deps.ports,
    events: deps.events ?? noEvents,
  };
  return {
    today: (userId) => getToday(d, userId),
    get: (userId) => getPlan(d, userId),
    put: (userId, input) => putPlan(d, userId, input),
    days: (userId, from, to) => getDays(d, userId, from, to),
    updateItem: (userId, itemId, status) => updateItem(d, userId, itemId, status),
    rebalance: async (userId) => (await rebalance(d, userId, { force: true })).plan,
    syncAction: (userId, action) => syncItemStatus(d, userId, action),
    rebalanceDue: () => rebalanceDue(d),
    onDateChanged: (event) => onDateChanged(d, event),
  };
}
