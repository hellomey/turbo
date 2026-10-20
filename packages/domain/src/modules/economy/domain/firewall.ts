import { DomainError } from "../../../shared/errors.js";

/**
 * THE MONEY / GAME FIREWALL (blueprint §5.3, §18, §30).
 *
 * This file is the legal line between "online social game" (allowed) and "online money game"
 * (banned by the Promotion and Regulation of Online Gaming Act, 2025). Every rule here is covered
 * by a permanent test in packages/domain/test/firewall (IDs in MANIFEST.json). Changing this file
 * needs founder approval (CODEOWNERS) and must never weaken a rule.
 */

export const CURRENCIES = ["XP", "POINTS", "TROPHIES", "MATCH_CHIPS", "SPARKS"] as const;
export type Currency = (typeof CURRENCIES)[number];

/** Currencies that can be bought with money. Only Sparks. Keep it that way. */
export const MONEY_BACKED: ReadonlySet<Currency> = new Set<Currency>(["SPARKS"]);

/** The only currencies a game may award. Match chips / board cash live and die inside one match. */
export const GAME_REWARD_CURRENCIES: ReadonlySet<Currency> = new Set<Currency>(["XP", "POINTS", "TROPHIES"]);

/** Ways Sparks may enter or leave the ledger. A game is deliberately not one of them. */
export const SPARKS_SOURCES = ["purchase", "milestone", "spend", "reversal"] as const;
export type SparksSource = (typeof SPARKS_SOURCES)[number];

/** Earned Sparks cap from study milestones (blueprint §5.3). */
export const EARNED_SPARKS_MONTHLY_CAP = 50;

/** Anything with value outside a game. A game may never pay any of these out. */
export const MONEY_VALUE_ITEMS = ["SPARKS", "PRO", "EXAM_PASS", "SEASON_PASS", "BOOK", "CREATOR_ITEM", "GIFT"] as const;

export type GameReward =
  | { kind: "currency"; currency: Currency; amount: number }
  | { kind: "cosmetic"; cosmeticId: string; soldForMoney: boolean }
  | { kind: "boost"; boost: "REVISION_SHIELD" | "XP_2X_HOUR" }
  | { kind: "item"; item: (typeof MONEY_VALUE_ITEMS)[number] };

/** What a player offers to enter or act in a game. Games are free: only `null` passes. */
export type GameEntryPayment = { currency: Currency; amount: number } | { purchasedItemId: string } | null;

function violation(rule: string, details: Record<string, unknown>): never {
  throw new DomainError("FIREWALL_VIOLATION", { rule, ...details });
}

/** Rule 1: no conversion between Sparks and any other currency, in either direction. */
export function assertConversionAllowed(from: Currency, to: Currency): void {
  if (MONEY_BACKED.has(from) || MONEY_BACKED.has(to)) violation("NO_SPARKS_CONVERSION", { from, to });
}

/** Rule 2: nothing bought with money (or anything at all) can be used to enter or play a game. */
export function assertGameEntry(payment: GameEntryPayment): void {
  if (payment !== null) violation("GAMES_ARE_FREE", { payment });
}

/** Rule 3: no game pays out Sparks, subscriptions, books, or anything worth money. */
export function assertGameReward(reward: GameReward): void {
  switch (reward.kind) {
    case "currency":
      if (!GAME_REWARD_CURRENCIES.has(reward.currency)) violation("NO_MONEY_REWARDS", { currency: reward.currency });
      if (!Number.isInteger(reward.amount) || reward.amount < 0) violation("INVALID_REWARD_AMOUNT", { amount: reward.amount });
      return;
    case "cosmetic":
      if (reward.soldForMoney) violation("NO_SOLD_COSMETIC_REWARDS", { cosmeticId: reward.cosmeticId });
      return;
    case "boost":
      return;
    case "item":
      violation("NO_MONEY_REWARDS", { item: reward.item });
  }
}

/** Sparks ledger entries may only come from these sources. */
export function assertSparksSource(source: string): asserts source is SparksSource {
  if (!(SPARKS_SOURCES as readonly string[]).includes(source)) violation("SPARKS_SOURCE_NOT_ALLOWED", { source });
}

/** How many milestone Sparks may still be credited this month (never negative). */
export function remainingEarnedSparks(earnedThisMonth: number): number {
  return Math.max(0, EARNED_SPARKS_MONTHLY_CAP - earnedThisMonth);
}
