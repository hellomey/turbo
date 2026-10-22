import { z } from "./zod.js";

/**
 * Stable error codes (blueprint §37). The app switches on `code` and may show `message` directly,
 * so messages are simple English (blueprint §10.2). Codes are NEVER renamed or reused: add new ones.
 */
export const ERROR_CODES = {
  VALIDATION_FAILED: "Some details are not right. Please check and try again.",
  UNAUTHENTICATED: "Please sign in again.",
  FORBIDDEN: "You don't have access to this.",
  NOT_FOUND: "We couldn't find that.",
  RATE_LIMITED: "Too many tries. Please wait a little and try again.",
  IDEMPOTENCY_KEY_REQUIRED: "Something went wrong. Please try again.",
  IDEMPOTENCY_KEY_REUSED: "Something went wrong. Please try again.",
  IDEMPOTENT_RESPONSE_UNAVAILABLE: "This was already done. Please start again.",
  IDEMPOTENCY_IN_PROGRESS: "This is still being processed. Please wait a moment.",
  APP_UPDATE_REQUIRED: "Please update HeyMey to continue.",
  FEATURE_PAUSED: "This is paused for a short time. Please try later.",
  INTERNAL_ERROR: "Something went wrong. Please try again.",

  OTP_INVALID: "That code is not right. Please check your email and try again.",
  OTP_EXPIRED: "That code has expired. Please ask for a new one.",
  OTP_LOCKED: "Too many wrong tries. Please ask for a new code.",
  EMAIL_NOT_ALLOWED: "Please use a different email address.",
  UNDER_18: "HeyMey is for 18+. See you on your 18th birthday.",
  DESK_2FA_REQUIRED: "Enter the code from your authenticator app.",
  TOTP_INVALID: "That authenticator code is not right. Please try again.",
  TOTP_LOCKED: "Too many wrong authenticator codes. Please wait 15 minutes and sign in again.",
  CHALLENGE_EXPIRED: "Your sign-in took too long. Please start again.",
  DESK_NOT_ALLOWED: "HeyMey Desk is only for partners and staff. Please use the HeyMey app.",
  SESSION_REVOKED: "You were signed out. Please sign in again.",
  CONSENT_REQUIRED: "Please tick 'Run my HeyMey account' to continue. The other choices are optional.",
  EXAM_NOT_FOUND: "We couldn't find that exam.",
  LESSON_NOT_FOUND: "This lesson is not ready yet.",

  PRACTICE_DAILY_LIMIT: "You've used today's free questions. More open tomorrow at 12 AM.",
  AI_LIMIT_REACHED: "You've used your AI help for now.",
  AI_BUSY: "AI help is busy. Here is the written explanation.",
  GAMES_SLEEPING: "Games are sleeping now. They wake up at 5 AM. Study is open.",
  RANKED_DAILY_CAP: "You've played today's 10 ranked duels. Practice duels are open.",

  // Phase 2: core study (INT-002, BOLT-0008). Added, never renamed.
  TOPIC_NOT_FOUND: "We couldn't find that topic.",
  QUESTION_NOT_FOUND: "We couldn't find that question.",
  CHECK_NOT_AVAILABLE: "This check is not open yet. Finish the step before it first.",
  CHECK_EXPIRED: "Time is up for this check. Please start a new one.",
  CHECK_ALREADY_SUBMITTED: "This check is already done.",
  GOLD_DAILY_LIMIT: "You've tried Gold for this lamp enough today. Try again tomorrow.",
  PRO_REQUIRED: "This is part of HeyMey Pro.",
  PRACTICE_SESSION_CLOSED: "This practice session has ended. Please start a new one.",
  MOCK_NOT_FOUND: "We couldn't find that mock.",
  MOCK_NOT_OPEN: "This mock opens at the scheduled time.",
  MOCK_CLOSED: "This mock is closed.",
  MOCK_MONTHLY_LIMIT: "You've used this month's free full mock. State Mock Sunday is free for everyone.",
  MOCK_DEADLINE_PASSED: "Time is up. Answers saved before the end time are kept.",
  MOCK_ALREADY_SUBMITTED: "This mock is already submitted.",
  PAPER_TYPE_NOT_SUPPORTED: "This type of paper is coming later.",
  RANK_NOT_READY: "The statewide rank is not ready yet. Please check later today.",
  PLAN_NOT_FOUND: "Set up your plan first.",
  REPORT_NOT_FOUND: "We couldn't find that report.",
  WEBHOOK_UNAUTHORIZED: "Not allowed.",
  WEBHOOK_REPLAYED: "Already received.",
  EXAM_CHANGE_ALREADY_REVIEWED: "This change was already reviewed.",
  SYNC_ACTION_TOO_OLD: "Saved as study history. Rings only change for the last 7 days.",

  FIREWALL_VIOLATION: "This action is not allowed.",
  PURCHASE_NOT_VERIFIED: "We couldn't confirm this payment yet. If money was taken, we will add your purchase or refund you.",
  SPENDING_LIMIT_REACHED: "This is over the spending limit you set.",
} as const;

export type ErrorCode = keyof typeof ERROR_CODES;

const codes = Object.keys(ERROR_CODES) as [ErrorCode, ...ErrorCode[]];

export const ErrorEnvelope = z
  .object({
    error: z.object({
      code: z.enum(codes),
      message: z.string(),
      details: z.record(z.string(), z.unknown()).optional(),
    }),
  })
  .openapi("ErrorEnvelope");
export type ErrorEnvelope = z.infer<typeof ErrorEnvelope>;
