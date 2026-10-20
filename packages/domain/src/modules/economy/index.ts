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
  remainingEarnedSparks,
} from "./domain/firewall.js";
export type { Currency, SparksSource, GameReward, GameEntryPayment } from "./domain/firewall.js";
