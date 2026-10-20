/**
 * Public API of the `games` module. Spin, Slot, Duel, Clue Poker, District Quest, Memory Pits,
 * Tiger Trap; odds; leagues. Export use cases and types only. Never export repositories or Prisma models.
 */
export const GamesModule = { name: "games" } as const;

export { GAME_LIMITS, gamesAreSleeping } from "./domain/limits.js";
