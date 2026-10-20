import { istHour } from "../../../shared/clock.js";

/**
 * Game limits are the SAME FOR EVERYONE (firewall rule 4: Pro and the Season Pass give no game
 * advantage). That is why nothing in this module may know about entitlements, plans or billing.
 * A permanent test scans this module's source for that (FW-008).
 */
export const GAME_LIMITS = Object.freeze({
  rankedDuelsPerDay: 10,
  freeSpinsPerDay: 1,
  earnedSpinsPerDay: 1,
  freeSlotPullsPerDay: 1,
  earnedSlotPullsPerDay: 1,
  clueStartingChips: 1000,
  districtQuestStartingBoardCash: 1500,
  reconnectWindowSeconds: 60,
  playtimeReminderAfterMinutes: 60,
  playtimeReminderEveryMinutes: 30,
} as const);

/** Games sleep 12 AM - 5 AM Asia/Kolkata. Study stays open (blueprint §9.10). */
export function gamesAreSleeping(at: Date): boolean {
  return istHour(at) < 5;
}
