import { z } from "../zod.js";

/** `economy`: XP, levels, Points, daily check-in, trophies, opt-in weekly leaderboard (BOLT-0113). */

export const TrophyCode = z
  .enum(["first_lamp", "first_gold", "subject_lit", "first_mock", "five_study_days", "expo_challenge"])
  .openapi("TrophyCode");

export const EarnedTrophy = z
  .object({ code: TrophyCode, title: z.string(), earnedAt: z.iso.datetime() })
  .openapi("EarnedTrophy");

export const MyProgress = z
  .object({
    xp: z.number().int().min(0),
    level: z.number().int().min(1),
    /** XP at which the current level started (for the progress bar). */
    levelStartXp: z.number().int().min(0),
    nextLevelXp: z.number().int().positive(),
    /** Points: never bought, never converted to Sparks or money. */
    points: z.number().int(),
    checkedInToday: z.boolean(),
    trophies: z.array(EarnedTrophy),
  })
  .openapi("MyProgress");

export const CheckInResult = z
  .object({
    awarded: z.object({ xp: z.number().int().min(0), points: z.number().int().min(0) }),
    alreadyCheckedIn: z.boolean(),
  })
  .openapi("CheckInResult");

export const LeaderboardEntry = z
  .object({ rank: z.number().int().min(1), displayName: z.string(), xp: z.number().int().min(0), isMe: z.boolean() })
  .openapi("LeaderboardEntry");

export const WeeklyLeaderboard = z
  .object({
    /** Monday 00:00 IST, as UTC. */
    weekStart: z.iso.datetime(),
    weekEnd: z.iso.datetime(),
    optedIn: z.boolean(),
    /** Only real users who opted in and have a nickname. Never padded. */
    entries: z.array(LeaderboardEntry),
  })
  .openapi("WeeklyLeaderboard");

export const LeaderboardOptInBody = z.object({ optIn: z.boolean() }).strict().openapi("LeaderboardOptInBody");

export const LeaderboardOptIn = z
  .object({
    optIn: z.boolean(),
    /** True when the board can actually show me: opted in, a nickname set, not hidden from leaderboards. */
    listed: z.boolean(),
  })
  .openapi("LeaderboardOptIn");
