/**
 * Public API of the `games` module. Spin, Slot, Duel, Clue Poker, District Quest, Memory Pits,
 * Tiger Trap; odds; leagues. Export use cases and types only. Never export repositories or Prisma models.
 */
import type { PrismaClient } from "@heymey/db";
import * as games from "./application/games.js";
import type { GamesRepository } from "./application/games.js";
import { PrismaGamesRepository } from "./infrastructure/prisma-games-repository.js";

export const GamesModule = { name: "games" } as const;

export { GAME_LIMITS, gamesAreSleeping } from "./domain/limits.js";
export { DAILY_SPIN_ODDS, SPIN_TOTAL_WEIGHT, drawSpin, spinOdds } from "./domain/daily-spin.js";
export { DUEL_RULES, duelAward, duelPoints } from "./domain/confidence-duel.js";
export type { DuelQuestionsPort, DuelRow, GameRewardsPort, GamesRepository, SpinRow } from "./application/games.js";

/** Daily Spin, solo Confidence Duel and the published rules (BOLT-0115). Server-authoritative; no stake anywhere. */
export interface GamesApi {
  rules(): ReturnType<typeof games.rules>;
  dailySpinState(userId: string): ReturnType<typeof games.dailySpinState>;
  spin(userId: string): ReturnType<typeof games.spin>;
  startDuel(userId: string, examCode: string): ReturnType<typeof games.startDuel>;
  submitDuel(userId: string, duelId: string, body: Parameters<typeof games.submitDuel>[3]): ReturnType<typeof games.submitDuel>;
}

export function createGames(deps: ({ prisma: PrismaClient } | { repository: GamesRepository }) & Omit<games.GamesDeps, "repo">): GamesApi {
  const d: games.GamesDeps = {
    repo: "repository" in deps ? deps.repository : new PrismaGamesRepository(deps.prisma),
    clock: deps.clock,
    rewards: deps.rewards,
    questions: deps.questions,
    randomInt: deps.randomInt,
  };
  return {
    rules: () => games.rules(),
    dailySpinState: (userId) => games.dailySpinState(d, userId),
    spin: (userId) => games.spin(d, userId),
    startDuel: (userId, examCode) => games.startDuel(d, userId, examCode),
    submitDuel: (userId, duelId, body) => games.submitDuel(d, userId, duelId, body),
  };
}
