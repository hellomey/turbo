/**
 * Public API of the `economy` module. Currencies with the money/game FIREWALL, cosmetics, check-in,
 * seasons, Season Pass. Export use cases and types only. Never export repositories or Prisma models.
 *
 * NOTE: `games` may import the firewall + Points/Trophy awarding from here, but never anything that
 * credits Sparks. dependency-cruiser enforces that games/** cannot import economy/application/sparks*.
 */
export const EconomyModule = { name: "economy" } as const;

export {
  CURRENCIES,
  MONEY_BACKED,
  GAME_REWARD_CURRENCIES,
  SPARKS_SOURCES,
  EARNED_SPARKS_MONTHLY_CAP,
  MONEY_VALUE_ITEMS,
  assertConversionAllowed,
  assertGameEntry,
  assertGameReward,
  assertSparksSource,
  assertPointsReason,
  POINTS_REASON_PREFIXES,
  remainingEarnedSparks,
} from "./domain/firewall.js";
export type { Currency, SparksSource, GameReward, GameEntryPayment } from "./domain/firewall.js";

export {
  XP_RULES,
  CHECK_IN_REWARD,
  TROPHIES,
  TROPHY_CODES,
  STUDY_DAYS_FOR_TROPHY,
  levelFor,
  istWeekRange,
  trophyTitle,
} from "./domain/progression.js";
export type { XpReason, TrophyCode } from "./domain/progression.js";

import type { PrismaClient } from "@heymey/db";
import type { Clock, DomainEvent } from "../../shared/index.js";
import * as progression from "./application/progression.js";
import type { EconomyRepository, LearningPort, PeoplePort } from "./application/progression.js";
import type { TrophyCode } from "./domain/progression.js";
import { PrismaEconomyRepository } from "./infrastructure/prisma-economy-repository.js";

export type { EconomyRepository, LearningPort, PeoplePort } from "./application/progression.js";

/** XP, Points, check-in, trophies and the opt-in leaderboard (BOLT-0113). */
export interface EconomyProgressionApi {
  progress(userId: string): ReturnType<typeof progression.getProgress>;
  checkIn(userId: string): ReturnType<typeof progression.checkIn>;
  weeklyLeaderboard(userId: string): ReturnType<typeof progression.weeklyLeaderboard>;
  setOptIn(userId: string, optIn: boolean): ReturnType<typeof progression.setOptIn>;
  /** Subscriber for learning events (mastery.lamp_changed, exam_hall.mock_submitted). Idempotent per source event. */
  onLearningEvent(event: DomainEvent): Promise<void>;
  /**
   * Award a trophy by code (e.g. `expo_challenge` when the Expo Challenge is finished). Idempotent: returns false if
   * the user already has it. Trophies are badges only: they carry no Points, Sparks or anything worth money.
   */
  awardTrophy(userId: string, code: TrophyCode): Promise<boolean>;
  /** Games -> economy firewall API: Points only, positive integer, idempotent per sourceKey. false = already credited. */
  awardGamePoints(a: { userId: string; game: string; amount: number; sourceKey: string }): Promise<boolean>;
}

export function createEconomyProgression(
  deps: ({ prisma: PrismaClient } | { repository: EconomyRepository }) & { clock: Clock; people: PeoplePort; learning: LearningPort },
): EconomyProgressionApi {
  const d: progression.ProgressionDeps = {
    repo: "repository" in deps ? deps.repository : new PrismaEconomyRepository(deps.prisma),
    clock: deps.clock,
    people: deps.people,
    learning: deps.learning,
  };
  return {
    progress: (userId) => progression.getProgress(d, userId),
    checkIn: (userId) => progression.checkIn(d, userId),
    weeklyLeaderboard: (userId) => progression.weeklyLeaderboard(d, userId),
    setOptIn: (userId, optIn) => progression.setOptIn(d, userId, optIn),
    onLearningEvent: (e) => progression.onLearningEvent(d, e),
    awardTrophy: (userId, code) => progression.awardTrophy(d, userId, code),
    awardGamePoints: (a) => progression.awardGamePoints(d, a),
  };
}
