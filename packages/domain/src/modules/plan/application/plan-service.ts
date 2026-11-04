import type { Plan, PlanDays, PlanItem, PutPlanBody, SyncActionResult, TodayScreen, z } from "@heymey/contracts";
import { istDayKey } from "../../../shared/clock.js";
import { DomainError } from "../../../shared/errors.js";
import { PLAN_CONFIG } from "../domain/config.js";
import { addDays, dayRange, daysBetween, minutesForDay } from "../domain/days.js";
import {
  WELCOME_BACK,
  buildDay,
  canChangeStatus,
  daysLeft,
  missedDays,
  nearestDaysLeft,
  needsRebalance,
  stretchPhase,
  todayCard,
  type ItemDraft,
  type PlanTarget,
  type TopicPick,
} from "../domain/rules.js";
import type { PlanDeps, PlanItemRecord, PlanRecord } from "./ports.js";

export type PlanDto = z.infer<typeof Plan>;
export type PlanItemDto = z.infer<typeof PlanItem>;
export type PlanDaysDto = z.infer<typeof PlanDays>;
export type TodayScreenDto = z.infer<typeof TodayScreen>;
export type PutPlanInput = z.input<typeof PutPlanBody>;
export type SyncResultDto = z.infer<typeof SyncActionResult>;
export interface PlanItemStatusAction {
  clientActionId: string;
  clientAt: string;
  kind: "plan_item_status";
  itemId: string;
  status: "done" | "skipped";
}

const today = (d: PlanDeps) => istDayKey(d.clock.now());
/** Past items looked at by rebalance (= StudyLog/PlanItem retention, logical design "Data"). */
const LOOKBACK_DAYS = 180;

export function toItemDto(i: PlanItemRecord): PlanItemDto {
  return {
    id: i.id,
    day: i.day,
    kind: i.kind,
    examCode: i.examCode,
    topicId: i.topicId,
    title: i.title,
    minutes: i.minutes,
    order: i.order,
    status: i.status,
  };
}

export function toPlanDto(p: PlanRecord, day: string): PlanDto {
  return {
    id: p.id,
    weekdayMinutes: p.weekdayMinutes,
    weekendMinutes: p.weekendMinutes,
    pocketMinutes: p.pocketMinutes,
    balance: p.balance,
    exams: [...p.exams]
      .sort((a, b) => a.priority - b.priority)
      .map((e) => ({ examCode: e.examCode, attemptCycleId: e.attemptCycleId, examDate: e.examDate, priority: e.priority, daysLeft: daysLeft(e.examDate, day) })),
    stretch: stretchPhase(nearestDaysLeft(p.exams, day)),
    starterPathUntil: p.starterPathUntil,
    lastRebalancedAt: p.lastRebalancedAt ? p.lastRebalancedAt.toISOString() : null,
    configVersion: p.configVersion,
  };
}

async function requirePlan(d: PlanDeps, userId: string): Promise<PlanRecord> {
  const plan = await d.repo.findByUser(userId);
  if (!plan) throw new DomainError("PLAN_NOT_FOUND");
  return plan;
}

/** exams -> PlanExam rows: main = priority 1, then 2, 3 (invariant 1). */
async function loadTargets(d: PlanDeps, userId: string): Promise<PlanTarget[]> {
  const t = await d.ports.targets(userId);
  return t.slice(0, 3).map((x, i) => ({ examCode: x.examCode, attemptCycleId: x.attemptCycleId, examDate: x.examDate, priority: i + 1 }));
}

/** New-topic queues per exam: syllabus order, not Lit yet (shared lamps dedup via `planned`). */
async function loadQueues(d: PlanDeps, userId: string, targets: readonly PlanTarget[]): Promise<Map<string, TopicPick[]>> {
  const perExam = await Promise.all(targets.map((t) => d.ports.topicsForExam(t.examCode)));
  const allIds = [...new Set(perExam.flat().map((t) => t.topicId))];
  const lit = allIds.length ? await d.ports.litTopicIds(userId, allIds) : new Set<string>();
  const queues = new Map<string, TopicPick[]>();
  targets.forEach((t, i) => {
    queues.set(
      t.examCode,
      (perExam[i] ?? [])
        .filter((x) => !lit.has(x.topicId))
        .map((x) => ({ topicId: x.topicId, name: x.name, critical: x.priority >= PLAN_CONFIG.criticalPriority })),
    );
  });
  return queues;
}

/**
 * Rebuild the rolling horizon from `from` (invariant 7: done items never change). Pending items from `from` on are
 * replaced; done/skipped items stay and use up their day's minutes. `movePastIds` -> status moved (rebalance).
 */
async function rebuild(
  d: PlanDeps,
  plan: PlanRecord,
  from: string,
  moved: { ids: string[]; topicIds: string[] } = { ids: [], topicIds: [] },
  rebalancedAt: Date | null = null,
): Promise<void> {
  const movePastIds = moved.ids;
  const to = addDays(from, PLAN_CONFIG.horizonDays - 1);
  const [existing, plannedAll, queues] = await Promise.all([
    d.repo.items(plan.id, from, to),
    d.repo.plannedTopicIds(plan.id),
    loadQueues(d, plan.userId, plan.exams),
  ]);
  // Pending items from `from` on and moved past items are being replaced: their topics go back into the queue.
  const replaced = new Set([...existing.filter((i) => i.status === "pending").map((i) => i.id), ...movePastIds]);
  const kept = existing.filter((i) => !replaced.has(i.id));
  const planned = new Set(plannedAll);
  const droppedTopics = existing.filter((i) => i.status === "pending" && i.topicId).map((i) => i.topicId as string);
  for (const id of droppedTopics) planned.delete(id);
  for (const id of moved.topicIds) planned.delete(id);
  for (const i of kept) if (i.topicId && i.status === "done") planned.add(i.topicId);

  const drafts: ItemDraft[] = [];
  for (const day of dayRange(from, to)) {
    const onDay = kept.filter((i) => i.day === day);
    const used = onDay.reduce((s, i) => s + i.minutes, 0);
    const firstOrder = onDay.reduce((m, i) => Math.max(m, i.order + 1), 0);
    drafts.push(
      ...buildDay({
        day,
        minutes: minutesForDay(plan, day) - used,
        firstOrder,
        targets: plan.exams,
        balance: plan.balance,
        starter: plan.starterPathUntil !== null && day <= plan.starterPathUntil,
        queues,
        planned,
      }),
    );
  }
  await d.repo.rebuild(plan.id, from, drafts, movePastIds, rebalancedAt);
}

/** PUT /v1/me/plan (§17.1 step 9): settings from the body, exams + dates from `exams` (R2). */
export async function putPlan(d: PlanDeps, userId: string, input: PutPlanInput): Promise<PlanDto> {
  const day = today(d);
  const targets = await loadTargets(d, userId);
  if (!targets.length) throw new DomainError("VALIDATION_FAILED", { field: "exams", reason: "choose your main exam first" });
  const existing = await d.repo.findByUser(userId);
  const plan = await d.repo.save(
    userId,
    {
      weekdayMinutes: input.weekdayMinutes,
      weekendMinutes: input.weekendMinutes,
      pocketMinutes: input.pocketMinutes ?? 10,
      balance: input.balance ?? 0,
      // Invariant 4: a new user gets the 7-day starter path; later changes keep it.
      starterPathUntil: existing ? existing.starterPathUntil : addDays(day, PLAN_CONFIG.starterPathDays - 1),
      stretch: stretchPhase(nearestDaysLeft(targets, day)),
      configVersion: PLAN_CONFIG.version,
    },
    targets,
  );
  await rebuild(d, plan, day);
  return toPlanDto(plan, day);
}

export async function getPlan(d: PlanDeps, userId: string): Promise<PlanDto> {
  return toPlanDto(await requirePlan(d, userId), today(d));
}

/** GET /v1/me/plan/days: at most 62 days; every day in the range is listed (empty days included). */
export async function getDays(d: PlanDeps, userId: string, from: string, to: string): Promise<PlanDaysDto> {
  const span = daysBetween(from, to);
  if (span < 0) throw new DomainError("VALIDATION_FAILED", { field: "to", reason: "to is before from" });
  if (span + 1 > PLAN_CONFIG.maxDaysPerRequest) throw new DomainError("VALIDATION_FAILED", { field: "to", reason: `at most ${PLAN_CONFIG.maxDaysPerRequest} days` });
  const plan = await requirePlan(d, userId);
  const items = await d.repo.items(plan.id, from, to);
  return {
    days: dayRange(from, to).map((day) => ({
      day,
      minutes: minutesForDay(plan, day),
      items: items.filter((i) => i.day === day).sort((a, b) => a.order - b.order).map(toItemDto),
    })),
  };
}

/**
 * Rebalance (invariant 6): pending items of past days -> moved; their topics come back first in the rebuilt days.
 * `force` = the user asked (POST); the system only runs after 2 missed days and once per IST day.
 */
export async function rebalance(d: PlanDeps, userId: string, opts: { force: boolean }): Promise<{ plan: PlanDto; moved: number; ran: boolean }> {
  const plan = await requirePlan(d, userId);
  const day = today(d);
  const now = d.clock.now();
  const past = await d.repo.items(plan.id, addDays(day, -LOOKBACK_DAYS), addDays(day, -1));
  const alreadyToday = plan.lastRebalancedAt !== null && istDayKey(plan.lastRebalancedAt) === day;
  if (!opts.force && (alreadyToday || !needsRebalance(past, day))) return { plan: toPlanDto(plan, day), moved: 0, ran: false };

  const targets = await loadTargets(d, userId);
  const refreshed: PlanRecord = targets.length ? { ...plan, exams: targets } : plan;
  if (targets.length) await d.repo.setExams(plan.id, targets, stretchPhase(nearestDaysLeft(targets, day)));
  const pendingPast = past.filter((i) => i.status === "pending");
  const moveIds = pendingPast.map((i) => i.id);
  const missed = missedDays(past, day).length;
  await rebuild(d, refreshed, day, { ids: moveIds, topicIds: pendingPast.flatMap((i) => (i.topicId ? [i.topicId] : [])) }, now);
  if (moveIds.length) {
    await d.events.publish({ type: "plan.rebalanced", occurredAt: now, payload: { userId, istDay: day, moved: moveIds.length, missedDays: missed } });
  }
  return { plan: toPlanDto({ ...refreshed, lastRebalancedAt: now }, day), moved: moveIds.length, ran: true };
}

/** GET /v1/me/today (§10.6, Q16): one clear next action. Tops up the rolling horizon and runs a due rebalance. */
export async function getToday(d: PlanDeps, userId: string): Promise<TodayScreenDto> {
  const day = today(d);
  const [rank, relight] = await Promise.all([d.ports.rank(userId), d.ports.relight(userId)]);
  const base = {
    day,
    rank,
    relight,
    pocketSessions: [...PLAN_CONFIG.pocketMinutes],
    serverNow: d.clock.now().toISOString(),
  };
  let plan = await d.repo.findByUser(userId);
  if (!plan) return { ...base, todayCard: null, stretch: "normal", welcomeBack: null, hasPlan: false };

  const r = await rebalance(d, userId, { force: false });
  if (!r.ran) {
    const horizonEnd = addDays(day, PLAN_CONFIG.horizonDays - 1);
    const ahead = await d.repo.items(plan.id, day, horizonEnd);
    const last = ahead.reduce<string | null>((m, i) => (m === null || i.day > m ? i.day : m), null);
    // Rolling horizon: only the missing days are added, so the days already shown stay as they are.
    if (last === null) await rebuild(d, plan, day);
    else if (last < horizonEnd) await rebuild(d, plan, addDays(last, 1));
  }
  plan = await requirePlan(d, userId);
  const items = await d.repo.items(plan.id, day, day);
  const card = todayCard(items, day);
  const welcome = plan.lastRebalancedAt !== null && istDayKey(plan.lastRebalancedAt) === day && (r.moved > 0 || (await movedRecently(d, plan.id, day)));
  return {
    ...base,
    todayCard: card ? toItemDto(card) : null,
    stretch: stretchPhase(nearestDaysLeft(plan.exams, day)),
    welcomeBack: welcome ? WELCOME_BACK : null,
    hasPlan: true,
  };
}

async function movedRecently(d: PlanDeps, planId: string, day: string): Promise<boolean> {
  const past = await d.repo.items(planId, addDays(day, -PLAN_CONFIG.horizonDays), addDays(day, -1));
  return past.some((i) => i.status === "moved");
}

/** POST /v1/me/plan/items/{id}/status: owner only; only a pending item changes (invariant 10). */
export async function updateItem(d: PlanDeps, userId: string, itemId: string, status: "done" | "skipped"): Promise<PlanItemDto> {
  const item = await d.repo.item(itemId);
  if (!item || item.userId !== userId) throw new DomainError("NOT_FOUND", { itemId });
  if (!canChangeStatus(item.status)) return toItemDto(item);
  const now = d.clock.now();
  const day = istDayKey(now);
  const log =
    status === "done"
      ? { userId, kind: item.kind, topicId: item.topicId, minutes: item.minutes, at: now, istDay: day, source: "online" as const, clientActionId: null, details: { planItemId: item.id } }
      : null;
  return toItemDto(await d.repo.setItemStatus(itemId, status, now, day, log));
}

const result = (clientActionId: string, status: SyncResultDto["status"], errorCode: SyncResultDto["errorCode"] = null): SyncResultDto => ({
  clientActionId,
  status,
  errorCode,
});

/**
 * Offline `plan_item_status` (§39, invariant 10): once per (userId, clientActionId) (SEC-P2-L2); applies if
 * the item still exists and is pending; older than 7 days -> study history only.
 */
export async function syncItemStatus(d: PlanDeps, userId: string, a: PlanItemStatusAction): Promise<SyncResultDto> {
  if (await d.repo.hasClientAction(userId, a.clientActionId)) return result(a.clientActionId, "duplicate");
  const item = await d.repo.item(a.itemId);
  if (!item || item.userId !== userId) return result(a.clientActionId, "rejected", "NOT_FOUND");
  const now = d.clock.now();
  const clientAt = new Date(a.clientAt);
  const at = clientAt.getTime() <= now.getTime() ? clientAt : now; // never trust a future client clock
  const log = {
    userId,
    kind: "plan_item_status",
    topicId: item.topicId,
    minutes: a.status === "done" ? item.minutes : 0,
    at,
    istDay: istDayKey(at),
    source: "offline_sync" as const,
    clientActionId: a.clientActionId,
    details: { planItemId: item.id, status: a.status },
  };
  try {
    if (now.getTime() - at.getTime() > PLAN_CONFIG.offlineMaxAgeDays * 86_400_000) {
      await d.repo.appendStudyLog(log);
      return result(a.clientActionId, "study_log_only", "SYNC_ACTION_TOO_OLD");
    }
    if (!canChangeStatus(item.status)) {
      await d.repo.appendStudyLog(log);
      return result(a.clientActionId, "accepted");
    }
    await d.repo.setItemStatus(item.id, a.status, now, istDayKey(now), log);
    return result(a.clientActionId, "accepted");
  } catch (e) {
    if (isUniqueViolation(e)) return result(a.clientActionId, "duplicate");
    throw e;
  }
}

function isUniqueViolation(e: unknown): boolean {
  return typeof e === "object" && e !== null && "code" in e && (e as { code: unknown }).code === "P2002";
}

/** Worker `exams.date-changed`: refresh dates for plans on that cycle and rebuild from today (invariant 7). */
export async function onDateChanged(d: PlanDeps, ev: { examCode: string; cycleId: string }): Promise<{ plans: number }> {
  const users = await d.repo.usersForCycle(ev.examCode, ev.cycleId);
  const day = today(d);
  for (const userId of users) {
    const plan = await d.repo.findByUser(userId);
    if (!plan) continue;
    const targets = await loadTargets(d, userId);
    if (!targets.length) continue;
    await d.repo.setExams(plan.id, targets, stretchPhase(nearestDaysLeft(targets, day)));
    await rebuild(d, { ...plan, exams: targets }, day);
  }
  return { plans: users.length };
}

/** Worker `plan.rebalance` (02:30 IST): every user with past pending items; rebalance runs once per IST day. */
export async function rebalanceDue(d: PlanDeps, pageSize = 200): Promise<{ checked: number; rebalanced: number }> {
  const day = today(d);
  let after: string | null = null;
  let checked = 0;
  let rebalanced = 0;
  for (;;) {
    const users = await d.repo.usersWithPastPending(day, after, pageSize);
    if (!users.length) break;
    for (const userId of users) {
      checked++;
      if ((await rebalance(d, userId, { force: false })).ran) rebalanced++;
    }
    after = users[users.length - 1] ?? null;
    if (users.length < pageSize) break;
  }
  return { checked, rebalanced };
}
