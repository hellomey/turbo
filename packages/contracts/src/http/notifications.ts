import { z } from "../zod.js";

/** `notifications` (blueprint §19.8 Q78, §17.1 step 11, §6, §36): tokens, alert settings, budget, quiet hours. */

export const RegisterPushTokenBody = z
  .object({
    deviceId: z.string().min(8).max(128),
    platform: z.enum(["android", "ios"]),
    token: z.string().min(16).max(4096),
  })
  .openapi("RegisterPushTokenBody");

export const PushTokenAck = z.object({ deviceId: z.string(), registeredAt: z.iso.datetime() }).openapi("PushTokenAck");

/** Minutes after midnight, Asia/Kolkata. */
const MinuteOfDay = z.number().int().min(0).max(1439);

export const AlertSettings = z
  .object({
    studyReminders: z.boolean(),
    examAlerts: z.boolean(),
    /** Offers are opt-in only and also need the `offers` consent (§17.1 step 8, §19.8 Q78). */
    offers: z.boolean(),
    quietHours: z.object({ enabled: z.boolean(), startMinute: MinuteOfDay, endMinute: MinuteOfDay }),
    morningAlertMinute: MinuteOfDay,
    /** Non-exam alerts per IST day (max 3, §19.8 Q78). */
    dailyLimit: z.number().int().min(0).max(3),
  })
  .openapi("AlertSettings");

export const PutAlertSettingsBody = AlertSettings.openapi("PutAlertSettingsBody");
