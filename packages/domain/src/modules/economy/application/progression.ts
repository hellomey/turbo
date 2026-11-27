import type { CheckInResult, LeaderboardOptIn, MyProgress, WeeklyLeaderboard, z } from "@heymey/contracts";
import { DomainError } from "../../../shared/errors.js";
import { assertGameReward, assertPointsReason } from "../domain/firewall.js";
import { istDayKey, type Clock, type DomainEvent } from "../../../shared/index.js";
import {
  CHECK_IN_REWARD,
  STUDY_DAYS_FOR_TROPHY,
  TROPHY_CODES,
  XP_RULES,
  istWeekRange,
  levelFor,
  trophyTitle,
  type TrophyCode,
  type XpReason,
} from "../domain/progression.js";

/** Port: economy storage for XP awards, Points, trophies and leaderboard opt-in. Adapter: infrastructure/. */
export interface EconomyRepository {
  /** Append one XP award. false = this (userId, sourceKey) was already awarded (idempotent). */
  awardXp(a: { userId: string; amount: number; reason: string; sourceKey: string; at: Date }): Promise<boolean>;
  /** One transaction: Points row + XP row for this IST day. false = already checked in that day. */
  checkIn(a: { userId: string; day: string; xp: number; points: number; at: Date }): Promise<boolean>;
  hasCheckedIn(userId: string, day: string): Promise<boolean>;
  /** Append one Points row. false = this idempotency key was already used. */
  awardPoints(a: { userId: string; delta: number; reason: string; key: string; at: Date }): Promise<boolean>;
  xpTotal(userId: string): Promise<number>;
  pointsBalance(userId: string): Promise<number>;
  trophiesOf(userId: string): Promise<{ code: string; earnedAt: Date }[]>;
  /** false = already had it. */
  awardTrophy(userId: string, code: string, at: Date): Promise<boolean>;
  /** Distinct IST days with learning XP (check-in excluded). */
  studyDays(userId: string): Promise<number>;
  setOptIn(userId: string, optIn: boolean, at: Date): Promise<void>;
  isOptedIn(userId: string): Promise<boolean>;
  /** XP in [from, to) summed per opted-in user, highest first. */
  weeklyXp(from: Date, to: Date, limit: number): Promise<{ userId: string; xp: number }[]>;
}

/** Facts from `users`, passed in by the composition root (economy does not depend on users). */
export interface PeoplePort {
  profile(userId: string): Promise<{ nickname: string | null; isGuest: boolean; hideFromLeaderboards: boolean; deleted: boolean } | null>;
}

/** Facts from `syllabus` + `mastery`, passed in by the composition root. */
export interface LearningPort {
  /** True when every lamp of this topic's subject is lit for the user. */
  subjectFullyLit(userId: string, topicId: string): Promise<boolean>;
}

export interface ProgressionDeps {
  repo: EconomyRepository;
  clock: Clock;
  people: PeoplePort;
  learning: LearningPort;
}

const BOARD_SIZE = 50;
/** Lamp events earn XP once per topic; the rest once per occurrence. */
const LAMP_KINDS = ["lesson_done", "lit", "recall_pass", "relight", "gold"] as const satisfies readonly XpReason[];

export async function getProgress(d: ProgressionDeps, userId: string): Promise<z.infer<typeof MyProgress>> {
  const [xp, points, trophies, checkedInToday] = await Promise.all([
    d.repo.xpTotal(userId),
    d.repo.pointsBalance(userId),
    d.repo.trophiesOf(userId),
    d.repo.hasCheckedIn(userId, istDayKey(d.clock.now())),
  ]);
  return {
    xp,
    ...levelFor(xp),
    points,
    checkedInToday,
    trophies: trophies
      .filter((t): t is { code: TrophyCode; earnedAt: Date } => TROPHY_CODES.includes(t.code as TrophyCode))
      .map((t) => ({ code: t.code, title: trophyTitle(t.code), earnedAt: t.earnedAt.toISOString() })),
  };
}

export async function checkIn(d: ProgressionDeps, userId: string): Promise<z.infer<typeof CheckInResult>> {
  const at = d.clock.now();
  const fresh = await d.repo.checkIn({ userId, day: istDayKey(at), xp: CHECK_IN_REWARD.xp, points: CHECK_IN_REWARD.points, at });
  return fresh ? { awarded: { ...CHECK_IN_REWARD }, alreadyCheckedIn: false } : { awarded: { xp: 0, points: 0 }, alreadyCheckedIn: true };
}

export async function awardTrophy(d: ProgressionDeps, userId: string, code: TrophyCode): Promise<boolean> {
  if (!TROPHY_CODES.includes(code)) throw new DomainError("VALIDATION_FAILED", { trophy: code });
  return d.repo.awardTrophy(userId, code, d.clock.now());
}

async function award(d: ProgressionDeps, userId: string, reason: XpReason, sourceKey: string, at: Date): Promise<boolean> {
  return d.repo.awardXp({ userId, amount: XP_RULES[reason].xp, reason, sourceKey, at });
}

async function afterStudy(d: ProgressionDeps, userId: string, at: Date): Promise<void> {
  if ((await d.repo.studyDays(userId)) >= STUDY_DAYS_FOR_TROPHY) await d.repo.awardTrophy(userId, "five_study_days", at);
}

/**
 * In-process subscriber for learning events (mastery.lamp_changed with `kinds`, exam_hall.mock_submitted). Only
 * online actions earn XP: offline-synced ones are study progress only (FW-022). Every award has a stable source key,
 * so a re-delivered event awards nothing.
 */
export async function onLearningEvent(d: ProgressionDeps, e: DomainEvent): Promise<void> {
  const p = (e.payload ?? {}) as Record<string, unknown>;
  const userId = typeof p.userId === "string" ? p.userId : null;
  if (!userId) return;
  const at = e.occurredAt;
  if (e.type === "exam_hall.mock_submitted") {
    // A blank mock (nothing answered) earns nothing, so starting and submitting empty mocks cannot farm XP.
    if (typeof p.attemptId !== "string" || (Number(p.correct) || 0) + (Number(p.wrong) || 0) === 0) return;
    if (await award(d, userId, "mock_submitted", `mock_submitted:${p.attemptId}`, at)) {
      await d.repo.awardTrophy(userId, "first_mock", at);
      await afterStudy(d, userId, at);
    }
    return;
  }
  if (e.type !== "mastery.lamp_changed" || p.source !== "online" || typeof p.topicId !== "string" || !Array.isArray(p.kinds)) return;
  const topicId = p.topicId;
  let awarded = false;
  for (const kind of LAMP_KINDS) {
    if (!p.kinds.includes(kind)) continue;
    const key = XP_RULES[kind].once ? `${kind}:${topicId}` : `${kind}:${topicId}:${at.toISOString()}`;
    if (await award(d, userId, kind, key, at)) awarded = true;
  }
  if (!awarded) return;
  if (p.kinds.includes("lit")) await d.repo.awardTrophy(userId, "first_lamp", at);
  if (p.kinds.includes("gold")) await d.repo.awardTrophy(userId, "first_gold", at);
  if ((p.kinds.includes("lit") || p.kinds.includes("relight")) && (await d.learning.subjectFullyLit(userId, topicId))) {
    await d.repo.awardTrophy(userId, "subject_lit", at);
  }
  await afterStudy(d, userId, at);
}

function listable(p: Awaited<ReturnType<PeoplePort["profile"]>>): p is { nickname: string; isGuest: false; hideFromLeaderboards: false; deleted: false } {
  return !!p && !p.isGuest && !p.deleted && !p.hideFromLeaderboards && !!p.nickname;
}

export async function setOptIn(d: ProgressionDeps, userId: string, optIn: boolean): Promise<z.infer<typeof LeaderboardOptIn>> {
  const profile = await d.people.profile(userId);
  if (optIn && (!profile || profile.isGuest)) throw new DomainError("GUEST_NOT_ALLOWED", { feature: "leaderboard" });
  await d.repo.setOptIn(userId, optIn, d.clock.now());
  return { optIn, listed: optIn && listable(profile) };
}

/** Only real, opted-in, named, non-guest users. Equal XP shares a rank. Never padded. */
export async function weeklyLeaderboard(d: ProgressionDeps, userId: string): Promise<z.infer<typeof WeeklyLeaderboard>> {
  const { from, to } = istWeekRange(d.clock.now());
  const [rows, optedIn] = await Promise.all([d.repo.weeklyXp(from, to, BOARD_SIZE * 2), d.repo.isOptedIn(userId)]);
  const entries: z.infer<typeof WeeklyLeaderboard>["entries"] = [];
  for (const r of rows) {
    if (entries.length >= BOARD_SIZE) break;
    const p = await d.people.profile(r.userId);
    if (!listable(p)) continue;
    const prev = entries.at(-1);
    entries.push({ rank: prev && prev.xp === r.xp ? prev.rank : entries.length + 1, displayName: p.nickname, xp: r.xp, isMe: r.userId === userId });
  }
  return { weekStart: from.toISOString(), weekEnd: to.toISOString(), optedIn, entries };
}

/**
 * The games -> economy firewall API (BOLT-0115). A game may credit Points only: the amount must be a positive integer
 * reward (assertGameReward) and the ledger reason is "game:<game>" (assertPointsReason). Never Sparks, never XP.
 * Idempotent per sourceKey.
 */
export async function awardGamePoints(d: ProgressionDeps, a: { userId: string; game: string; amount: number; sourceKey: string }): Promise<boolean> {
  assertGameReward({ kind: "currency", currency: "POINTS", amount: a.amount });
  if (a.amount === 0) return false;
  const reason = `game:${a.game}`;
  assertPointsReason(reason);
  return d.repo.awardPoints({ userId: a.userId, delta: a.amount, reason, key: `game:${a.sourceKey}`, at: d.clock.now() });
}
