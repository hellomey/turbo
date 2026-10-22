import type { AlertSettings, RegisterPushTokenBody, z } from "@heymey/contracts";
import { DomainError } from "../../../shared/errors.js";
import { istDayKey, type Clock } from "../../../shared/clock.js";
import {
  clampDailyLimit,
  decideSend,
  defaultPrefs,
  inQuietHours,
  istMinuteOfDay,
  type AlertCategory,
  type AlertPrefs,
  type SendStatus,
} from "../domain/policy.js";
import type {
  AlertPreferenceRepository,
  OffersConsentReader,
  PushSender,
  PushTokenRepository,
  SendDispatcher,
  SendLogRepository,
} from "./ports.js";

export type AlertSettingsDto = z.infer<typeof AlertSettings>;

export interface NotificationsDeps {
  tokens: PushTokenRepository;
  prefs: AlertPreferenceRepository;
  sendLog: SendLogRepository;
  consent: OffersConsentReader;
  clock: Clock;
  sender?: PushSender;
  dispatcher?: SendDispatcher;
}

// ------------------------------------------------------------------ tokens (S16, invariant 7)

export async function registerToken(d: NotificationsDeps, userId: string, body: z.infer<typeof RegisterPushTokenBody>) {
  const at = d.clock.now();
  await d.tokens.upsert({ userId, deviceId: body.deviceId, platform: body.platform, token: body.token, at });
  return { deviceId: body.deviceId, registeredAt: at.toISOString() };
}

export async function deleteToken(d: NotificationsDeps, userId: string, deviceId: string) {
  await d.tokens.remove(userId, deviceId); // idempotent: removing twice is ok
  return { ok: true as const };
}

// ------------------------------------------------------------------ settings (§17.1 step 11, §19.8 Q78)

function toDto(p: AlertPrefs): AlertSettingsDto {
  return {
    studyReminders: p.studyReminders,
    examAlerts: p.examAlerts,
    offers: p.offers,
    quietHours: { enabled: p.quietEnabled, startMinute: p.quietStartMinute, endMinute: p.quietEndMinute },
    morningAlertMinute: p.morningAlertMinute,
    dailyLimit: clampDailyLimit(p.dailyLimit),
  };
}

export async function getSettings(d: NotificationsDeps, userId: string): Promise<AlertSettingsDto> {
  return toDto((await d.prefs.get(userId)) ?? defaultPrefs());
}

export async function putSettings(d: NotificationsDeps, userId: string, body: AlertSettingsDto): Promise<AlertSettingsDto> {
  // Invariant 8: offers on only with the offers consent.
  if (body.offers && !(await d.consent.offersGranted(userId))) throw new DomainError("CONSENT_REQUIRED", { purpose: "offers_email" });
  const prefs: AlertPrefs = {
    studyReminders: body.studyReminders,
    examAlerts: body.examAlerts,
    offers: body.offers,
    quietEnabled: body.quietHours.enabled,
    quietStartMinute: body.quietHours.startMinute,
    quietEndMinute: body.quietHours.endMinute,
    morningAlertMinute: body.morningAlertMinute,
    dailyLimit: clampDailyLimit(body.dailyLimit),
  };
  await d.prefs.put(userId, prefs);
  return toDto(prefs);
}

// ------------------------------------------------------------------ sending (worker)

export interface EnqueueInput {
  userId: string;
  category: AlertCategory;
  templateKey: string;
  /** Same logical alert -> same key -> decided once (invariant 6). */
  dedupeKey: string;
  hasActiveExamHallAttempt?: boolean;
}

export async function enqueue(d: NotificationsDeps, input: EnqueueInput): Promise<{ id: string; status: SendStatus; created: boolean }> {
  const at = d.clock.now();
  const prefs = (await d.prefs.get(input.userId)) ?? defaultPrefs();
  const offersConsent = input.category === "offer" ? await d.consent.offersGranted(input.userId) : false;
  const { row, created } = await d.sendLog.record(
    { userId: input.userId, category: input.category, templateKey: input.templateKey, dedupeKey: input.dedupeKey, istDay: istDayKey(at) },
    (nonExamCountedToday) =>
      decideSend({ category: input.category, at, prefs, nonExamCountedToday, hasActiveExamHallAttempt: input.hasActiveExamHallAttempt ?? false, offersConsent }),
  );
  if (created && row.status === "queued") await d.dispatcher?.dispatch(row.id);
  return { id: row.id, status: row.status, created };
}

/** `push.send` job: deliver a queued row to every active device. Safe to retry. */
export async function send(d: NotificationsDeps, sendLogId: string): Promise<SendStatus | "skipped"> {
  if (!d.sender) throw new Error("notifications.send needs a PushSender");
  const row = await d.sendLog.get(sendLogId);
  if (!row || row.status !== "queued") return "skipped";
  const devices = await d.tokens.activeForUser(row.userId);
  let delivered = 0;
  for (const dev of devices) {
    const r = await d.sender.send({ sendLogId: row.id, deviceId: dev.deviceId, platform: dev.platform, token: dev.token, templateKey: row.templateKey });
    if (r === "sent") delivered++;
    else await d.tokens.revokeToken(dev.token, d.clock.now()); // FCM 404: token is dead
  }
  const to: SendStatus = delivered > 0 ? "sent" : "failed";
  await d.sendLog.transition(row.id, "queued", to, to === "sent" ? d.clock.now() : undefined);
  return to;
}

/** `notifications.release-held` (every 15 min): Exam Alerts held in quiet hours go out once quiet hours end. */
export async function releaseHeld(d: NotificationsDeps, limit = 500): Promise<number> {
  const minute = istMinuteOfDay(d.clock.now());
  let released = 0;
  for (const row of await d.sendLog.listHeld(limit)) {
    const prefs = (await d.prefs.get(row.userId)) ?? defaultPrefs();
    if (inQuietHours(minute, prefs)) continue;
    if (await d.sendLog.transition(row.id, "held_quiet", "queued")) {
      await d.dispatcher?.dispatch(row.id);
      released++;
    }
  }
  return released;
}

/** Account erasure: no token survives (invariant 7). */
export async function forgetUser(d: NotificationsDeps, userId: string): Promise<number> {
  return d.tokens.removeAllForUser(userId);
}
