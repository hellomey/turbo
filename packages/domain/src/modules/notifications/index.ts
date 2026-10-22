/**
 * Public API of the `notifications` module. Push tokens, alert preferences, daily alert budget, quiet hours.
 * Export use cases and types only. Never export repositories or Prisma models.
 * Design: aidlc/construction/units/U-notifications/. Blueprint §6, §9.10, §17.1 step 11, §19.8 Q78, §36.
 */
import type { PrismaClient } from "@heymey/db";
import type { RegisterPushTokenBody, z } from "@heymey/contracts";
import type { Clock } from "../../shared/clock.js";
import * as svc from "./application/notifications-service.js";
import type {
  AlertPreferenceRepository,
  OffersConsentReader,
  PushSender,
  PushTokenRepository,
  SendDispatcher,
  SendLogRepository,
} from "./application/ports.js";
import type { SendStatus } from "./domain/policy.js";
import {
  LogOnlyPushSender,
  PrismaAlertPreferenceRepository,
  PrismaPushTokenRepository,
  PrismaSendLogRepository,
} from "./infrastructure/prisma-notifications.js";

export const NotificationsModule = { name: "notifications" } as const;

export { NOTIFICATIONS_CONFIG } from "./domain/config.js";
export {
  clampDailyLimit,
  decideSend,
  defaultPrefs,
  inQuietHours,
  istMinuteOfDay,
  type AlertCategory,
  type AlertPrefs,
  type SendInput,
  type SendStatus,
} from "./domain/policy.js";
export type {
  AlertPreferenceRepository,
  OffersConsentReader,
  PushSender,
  PushTokenRepository,
  PushTokenRow,
  SendDispatcher,
  SendLogRepository,
  SendLogRow,
} from "./application/ports.js";
export type { AlertSettingsDto, EnqueueInput } from "./application/notifications-service.js";

export interface NotificationsApi {
  registerToken(userId: string, body: z.infer<typeof RegisterPushTokenBody>): Promise<{ deviceId: string; registeredAt: string }>;
  deleteToken(userId: string, deviceId: string): Promise<{ ok: true }>;
  getSettings(userId: string): Promise<svc.AlertSettingsDto>;
  putSettings(userId: string, body: svc.AlertSettingsDto): Promise<svc.AlertSettingsDto>;
  enqueue(input: svc.EnqueueInput): Promise<{ id: string; status: SendStatus; created: boolean }>;
  /** Exam Alert fan-out (from `exams.notification_published`, followers passed in by the worker). */
  enqueueExamAlert(alertId: string, followerIds: readonly string[], hasActiveExamHallAttempt?: (userId: string) => Promise<boolean>): Promise<Record<string, number>>;
  send(sendLogId: string): Promise<SendStatus | "skipped">;
  releaseHeld(limit?: number): Promise<number>;
  forgetUser(userId: string): Promise<number>;
}

export type NotificationsModuleDeps = (
  | { prisma: PrismaClient }
  | { repositories: { tokens: PushTokenRepository; prefs: AlertPreferenceRepository; sendLog: SendLogRepository } }
) & {
  clock: Clock;
  consent: OffersConsentReader;
  sender?: PushSender;
  dispatcher?: SendDispatcher;
};

export function createLogOnlyPushSender(log: (line: string) => void): PushSender {
  return new LogOnlyPushSender(log);
}

export function createNotificationsModule(deps: NotificationsModuleDeps): NotificationsApi {
  const repos =
    "repositories" in deps
      ? deps.repositories
      : {
          tokens: new PrismaPushTokenRepository(deps.prisma),
          prefs: new PrismaAlertPreferenceRepository(deps.prisma),
          sendLog: new PrismaSendLogRepository(deps.prisma),
        };
  const d: svc.NotificationsDeps = {
    ...repos,
    clock: deps.clock,
    consent: deps.consent,
    ...(deps.sender ? { sender: deps.sender } : {}),
    ...(deps.dispatcher ? { dispatcher: deps.dispatcher } : {}),
  };
  return {
    registerToken: (u, b) => svc.registerToken(d, u, b),
    deleteToken: (u, dev) => svc.deleteToken(d, u, dev),
    getSettings: (u) => svc.getSettings(d, u),
    putSettings: (u, b) => svc.putSettings(d, u, b),
    enqueue: (i) => svc.enqueue(d, i),
    async enqueueExamAlert(alertId, followerIds, active) {
      const counts: Record<string, number> = {};
      for (const userId of followerIds) {
        const r = await svc.enqueue(d, {
          userId,
          category: "exam",
          templateKey: `exam_alert:${alertId}`,
          dedupeKey: `exam_alert:${alertId}:${userId}`,
          hasActiveExamHallAttempt: active ? await active(userId) : false,
        });
        counts[r.status] = (counts[r.status] ?? 0) + 1;
      }
      return counts;
    },
    send: (id) => svc.send(d, id),
    releaseHeld: (limit) => svc.releaseHeld(d, limit),
    forgetUser: (u) => svc.forgetUser(d, u),
  };
}
