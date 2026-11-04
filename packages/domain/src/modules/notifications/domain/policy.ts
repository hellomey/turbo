import { NOTIFICATIONS_CONFIG } from "./config.js";

/** Pure send rules for alerts (blueprint §19.8 Q78, §6, §9.10, §17.1 step 11; D-2026-10-22-31). No I/O. */

export type AlertCategory = "study" | "exam" | "offer" | "system";

/**
 * SEC-P2-L1: may a push token registered to (owner.userId, owner.deviceId) be registered by the caller?
 * Same user: yes (moved between that user's own devices). Another user: only when the caller proves the device:
 * the body's deviceId is the owner's deviceId AND the caller's session is bound to that same device (a new sign-in
 * on the same install). Otherwise refuse; never silently redirect another user's pushes.
 */
export function pushTokenMoveAllowed(
  owner: { userId: string; deviceId: string },
  caller: { userId: string; deviceId: string; sessionDeviceId: string | undefined },
): boolean {
  if (owner.userId === caller.userId) return true;
  return owner.deviceId === caller.deviceId && caller.sessionDeviceId === caller.deviceId;
}

/**
 * Every outcome is written to SendLog. `dropped_quiet` (non-exam alert inside quiet hours) and `dropped_opted_out`
 * (category switched off) extend the status list in notifications.prisma (free-text column, BOLT-0014).
 */
export type SendStatus =
  | "queued"
  | "sent"
  | "held_quiet"
  | "dropped_budget"
  | "dropped_quiet"
  | "dropped_opted_out"
  | "dropped_exam_hall"
  | "dropped_no_consent"
  | "failed";

/** Statuses that use up one of the day's non-exam alerts. */
export const COUNTED_STATUSES: readonly SendStatus[] = ["queued", "sent"];

export interface AlertPrefs {
  studyReminders: boolean;
  examAlerts: boolean;
  offers: boolean;
  quietEnabled: boolean;
  quietStartMinute: number;
  quietEndMinute: number;
  morningAlertMinute: number;
  dailyLimit: number;
}

export function defaultPrefs(): AlertPrefs {
  const q = NOTIFICATIONS_CONFIG.quietHoursDefault;
  return {
    studyReminders: true,
    examAlerts: true,
    offers: false,
    quietEnabled: q.enabled,
    quietStartMinute: q.startMinute,
    quietEndMinute: q.endMinute,
    morningAlertMinute: NOTIFICATIONS_CONFIG.morningAlertMinute,
    dailyLimit: NOTIFICATIONS_CONFIG.maxNonExamPerIstDay,
  };
}

const IST_OFFSET_MINUTES = 5 * 60 + 30;

/** Minutes after midnight in Asia/Kolkata (0..1439). */
export function istMinuteOfDay(at: Date): number {
  const total = Math.floor(at.getTime() / 60_000) + IST_OFFSET_MINUTES;
  return ((total % 1440) + 1440) % 1440;
}

/** Window is [start, end); crosses midnight when start > end (22:00-07:00). start == end means no window. */
export function inQuietHours(minute: number, prefs: Pick<AlertPrefs, "quietEnabled" | "quietStartMinute" | "quietEndMinute">): boolean {
  if (!prefs.quietEnabled) return false;
  const { quietStartMinute: s, quietEndMinute: e } = prefs;
  if (s === e) return false;
  return s < e ? minute >= s && minute < e : minute >= s || minute < e;
}

/** Server clamp (invariant 8): never more than the config maximum, never negative. */
export function clampDailyLimit(n: number): number {
  return Math.max(0, Math.min(NOTIFICATIONS_CONFIG.maxNonExamPerIstDay, Math.trunc(n)));
}

export interface SendInput {
  category: AlertCategory;
  at: Date;
  prefs: AlertPrefs;
  /** Non-exam alerts already counted today (IST), see COUNTED_STATUSES. */
  nonExamCountedToday: number;
  hasActiveExamHallAttempt: boolean;
  offersConsent: boolean;
}

/** The single send decision. Order: Exam Hall → opt-out/consent → quiet hours → budget. */
export function decideSend(i: SendInput): SendStatus {
  if (i.hasActiveExamHallAttempt) return "dropped_exam_hall";
  if (i.category === "study" && !i.prefs.studyReminders) return "dropped_opted_out";
  if (i.category === "exam" && !i.prefs.examAlerts) return "dropped_opted_out";
  if (i.category === "offer" && (!i.prefs.offers || !i.offersConsent)) return "dropped_no_consent";
  if (inQuietHours(istMinuteOfDay(i.at), i.prefs)) {
    if (i.category === "exam") return NOTIFICATIONS_CONFIG.examAlertsDuringQuietHours === "hold" ? "held_quiet" : "queued";
    return "dropped_quiet";
  }
  if (i.category === "exam") return "queued";
  return i.nonExamCountedToday >= clampDailyLimit(i.prefs.dailyLimit) ? "dropped_budget" : "queued";
}
