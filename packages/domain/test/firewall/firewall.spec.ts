// PERMANENT. These tests may be added to but never deleted, skipped or weakened (blueprint §26.2 rule 3).
// tools/check-firewall.mjs verifies every ID in MANIFEST.json is present here.
import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import {
  CURRENCIES,
  EARNED_SPARKS_MONTHLY_CAP,
  MONEY_VALUE_ITEMS,
  assertConversionAllowed,
  assertGameEntry,
  assertGameReward,
  assertSparksSource,
  remainingEarnedSparks,
} from "../../src/modules/economy/index.js";
import { GAME_LIMITS } from "../../src/modules/games/index.js";

const firewallError = expect.objectContaining({ code: "FIREWALL_VIOLATION" });

describe("money / game firewall", () => {
  it("FW-001 Sparks never convert to or from any other currency", () => {
    for (const other of CURRENCIES.filter((c) => c !== "SPARKS")) {
      expect(() => assertConversionAllowed("SPARKS", other)).toThrow(firewallError);
      expect(() => assertConversionAllowed(other, "SPARKS")).toThrow(firewallError);
    }
  });

  it("FW-002 games accept no entry payment of any kind", () => {
    for (const currency of CURRENCIES) {
      expect(() => assertGameEntry({ currency, amount: 1 })).toThrow(firewallError);
    }
    expect(() => assertGameEntry({ purchasedItemId: "anything" })).toThrow(firewallError);
    expect(() => assertGameEntry(null)).not.toThrow();
  });

  it("FW-003 no game reward is Sparks", () => {
    expect(() => assertGameReward({ kind: "currency", currency: "SPARKS", amount: 1 })).toThrow(firewallError);
  });

  it("FW-004 no game reward is anything worth money", () => {
    for (const item of MONEY_VALUE_ITEMS) {
      expect(() => assertGameReward({ kind: "item", item })).toThrow(firewallError);
    }
    expect(() => assertGameReward({ kind: "currency", currency: "MATCH_CHIPS", amount: 10 })).toThrow(firewallError);
    for (const currency of ["XP", "POINTS", "TROPHIES"] as const) {
      expect(() => assertGameReward({ kind: "currency", currency, amount: 10 })).not.toThrow();
    }
  });

  it("FW-005 a cosmetic sold for money is never a game reward", () => {
    expect(() => assertGameReward({ kind: "cosmetic", cosmeticId: "madurai-map", soldForMoney: true })).toThrow(firewallError);
    expect(() => assertGameReward({ kind: "cosmetic", cosmeticId: "board-banner", soldForMoney: false })).not.toThrow();
  });

  it("FW-006 the Sparks ledger only accepts purchase, milestone, spend and reversal", () => {
    for (const ok of ["purchase", "milestone", "spend", "reversal"]) expect(() => assertSparksSource(ok)).not.toThrow();
    for (const bad of ["game", "spin", "slot", "duel", "squad_battle", "referral", "transfer", "points_exchange"]) {
      expect(() => assertSparksSource(bad)).toThrow(firewallError);
    }
  });

  it("FW-007 earned Sparks are capped at 50 a month", () => {
    expect(EARNED_SPARKS_MONTHLY_CAP).toBe(50);
    expect(remainingEarnedSparks(0)).toBe(50);
    expect(remainingEarnedSparks(50)).toBe(0);
    expect(remainingEarnedSparks(80)).toBe(0);
  });

  it("FW-008 the games module never references entitlements, billing, Pro or passes", () => {
    const gamesDir = join(import.meta.dirname, "../../src/modules/games");
    const forbidden = /(entitlement|billing|\bisPro\b|\bpro\b|season[_-]?pass|exam[_-]?pass|subscription)/i;
    const offenders: string[] = [];
    const walk = (dir: string) => {
      for (const name of readdirSync(dir)) {
        const path = join(dir, name);
        if (statSync(path).isDirectory()) walk(path);
        else if (path.endsWith(".ts")) {
          const code = readFileSync(path, "utf8").replace(/\/\*[\s\S]*?\*\/|\/\/.*$/gm, ""); // ignore comments
          if (forbidden.test(code)) offenders.push(path);
        }
      }
    };
    walk(gamesDir);
    expect(offenders).toEqual([]);
  });

  it("FW-009 ranked duel cap is 10 a day for every player", () => {
    expect(GAME_LIMITS.rankedDuelsPerDay).toBe(10);
    // Frozen at runtime: no code path (e.g. an entitlement check) can raise it for some players.
    expect(Object.isFrozen(GAME_LIMITS)).toBe(true);
  });
});
