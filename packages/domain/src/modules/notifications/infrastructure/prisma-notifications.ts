import type { PrismaClient } from "@heymey/db";
import { COUNTED_STATUSES, type AlertCategory, type AlertPrefs, type SendStatus } from "../domain/policy.js";
import type {
  AlertPreferenceRepository,
  PushSender,
  PushTokenRepository,
  PushTokenRow,
  SendLogRepository,
  SendLogRow,
} from "../application/ports.js";

export class PrismaPushTokenRepository implements PushTokenRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async upsert(
    i: { userId: string; deviceId: string; platform: "android" | "ios"; token: string; at: Date },
    canTakeFrom: (owner: { userId: string; deviceId: string }) => boolean,
  ): Promise<"ok" | "refused"> {
    return this.prisma.$transaction(async (tx) => {
      // SEC-P2-L1: a token held by another (user, device) moves only when the caller proves the device.
      const owner = await tx.pushToken.findUnique({ where: { token: i.token }, select: { userId: true, deviceId: true } });
      if (owner && !(owner.userId === i.userId && owner.deviceId === i.deviceId) && !canTakeFrom(owner)) return "refused" as const;
      await tx.pushToken.deleteMany({ where: { token: i.token, NOT: { userId: i.userId, deviceId: i.deviceId } } });
      await tx.pushToken.upsert({
        where: { userId_deviceId: { userId: i.userId, deviceId: i.deviceId } },
        create: { userId: i.userId, deviceId: i.deviceId, platform: i.platform, token: i.token, lastSeenAt: i.at },
        update: { platform: i.platform, token: i.token, lastSeenAt: i.at, revokedAt: null },
      });
      return "ok" as const;
    });
  }

  async remove(userId: string, deviceId: string): Promise<boolean> {
    return (await this.prisma.pushToken.deleteMany({ where: { userId, deviceId } })).count > 0;
  }

  async removeAllForUser(userId: string): Promise<number> {
    return (await this.prisma.pushToken.deleteMany({ where: { userId } })).count;
  }

  async activeForUser(userId: string): Promise<PushTokenRow[]> {
    const rows = await this.prisma.pushToken.findMany({ where: { userId, revokedAt: null }, orderBy: { lastSeenAt: "desc" } });
    return rows.map((r) => ({ deviceId: r.deviceId, platform: r.platform === "ios" ? "ios" : "android", token: r.token }));
  }

  async revokeToken(token: string, at: Date): Promise<void> {
    await this.prisma.pushToken.updateMany({ where: { token, revokedAt: null }, data: { revokedAt: at } });
  }
}

export class PrismaAlertPreferenceRepository implements AlertPreferenceRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async get(userId: string): Promise<AlertPrefs | null> {
    const r = await this.prisma.alertPreference.findUnique({ where: { userId } });
    if (!r) return null;
    return {
      studyReminders: r.studyReminders,
      examAlerts: r.examAlerts,
      offers: r.offers,
      quietEnabled: r.quietEnabled,
      quietStartMinute: r.quietStartMinute,
      quietEndMinute: r.quietEndMinute,
      morningAlertMinute: r.morningAlertMinute,
      dailyLimit: r.dailyLimit,
    };
  }

  async put(userId: string, prefs: AlertPrefs): Promise<void> {
    await this.prisma.alertPreference.upsert({ where: { userId }, create: { userId, ...prefs }, update: prefs });
  }
}

type LogRecord = { id: string; userId: string; category: string; templateKey: string; dedupeKey: string; istDay: string; status: string };
const toRow = (r: LogRecord): SendLogRow => ({ ...r, category: r.category as AlertCategory, status: r.status as SendStatus });

export class PrismaSendLogRepository implements SendLogRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async record(
    input: { userId: string; category: AlertCategory; templateKey: string; dedupeKey: string; istDay: string },
    decide: (nonExamCountedToday: number) => SendStatus,
  ): Promise<{ row: SendLogRow; created: boolean }> {
    return this.prisma.$transaction(async (tx) => {
      // Serialise decisions per user (released at commit) so two workers can't both take the 3rd slot.
      await tx.$executeRaw`SELECT pg_advisory_xact_lock(hashtext(${input.userId}))`;
      const existing = await tx.sendLog.findUnique({ where: { dedupeKey: input.dedupeKey } });
      if (existing) return { row: toRow(existing), created: false };
      const counted = await tx.sendLog.count({
        where: { userId: input.userId, istDay: input.istDay, category: { not: "exam" }, status: { in: [...COUNTED_STATUSES] } },
      });
      const created = await tx.sendLog.create({ data: { ...input, status: decide(counted) } });
      return { row: toRow(created), created: true };
    });
  }

  async get(id: string): Promise<SendLogRow | null> {
    const r = await this.prisma.sendLog.findUnique({ where: { id } });
    return r ? toRow(r) : null;
  }

  async transition(id: string, from: SendStatus, to: SendStatus, sentAt?: Date): Promise<boolean> {
    const res = await this.prisma.sendLog.updateMany({ where: { id, status: from }, data: { status: to, ...(sentAt ? { sentAt } : {}) } });
    return res.count === 1;
  }

  async listHeld(limit: number): Promise<SendLogRow[]> {
    const rows = await this.prisma.sendLog.findMany({ where: { status: "held_quiet" }, orderBy: { createdAt: "asc" }, take: limit });
    return rows.map(toRow);
  }
}

/**
 * D-2026-10-22-33: no Firebase/APNs accounts yet, so "sending" logs ids only (never the token or any text).
 * Swap for an FCM/APNs adapter when NOTIFICATIONS_CONFIG.senderMode becomes "live".
 */
export class LogOnlyPushSender implements PushSender {
  constructor(private readonly log: (line: string) => void) {}

  async send(msg: { sendLogId: string; deviceId: string; platform: "android" | "ios"; templateKey: string }): Promise<"sent"> {
    this.log(`push log_only sendLog=${msg.sendLogId} platform=${msg.platform} template=${msg.templateKey.split(":")[0] ?? ""}`);
    return "sent";
  }
}
