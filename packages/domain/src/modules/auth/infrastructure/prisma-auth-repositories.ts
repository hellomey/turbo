import { Prisma, type PrismaClient } from "@heymey/db";
import type { Purpose } from "../domain/policy.js";
import type {
  AuthRepositories,
  DeviceRepository,
  OtpRecord,
  OtpRepository,
  RefreshTokenRepository,
  RevokeReason,
  SessionRecord,
  SessionRepository,
  TwoFactorRepository,
} from "../application/ports.js";

class PrismaOtpRepository implements OtpRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async create(input: { email: string; purpose: Purpose; codeHash: string; expiresAt: Date; requestIp: string | null; at: Date }) {
    const row = await this.prisma.otpCode.create({
      data: {
        email: input.email,
        purpose: input.purpose,
        codeHash: input.codeHash,
        expiresAt: input.expiresAt,
        requestIp: input.requestIp,
        createdAt: input.at,
      },
      select: { id: true },
    });
    return row;
  }

  async latest(email: string, purpose: Purpose): Promise<OtpRecord | null> {
    const row = await this.prisma.otpCode.findFirst({ where: { email, purpose }, orderBy: [{ createdAt: "desc" }, { id: "desc" }] });
    return row ? { ...row, purpose: row.purpose as Purpose } : null;
  }

  /**
   * SEC-M1: `UPDATE otp_codes SET attempts = attempts + 1 WHERE id = $1 AND attempts < $max AND usedAt IS NULL AND
   * lockedAt IS NULL AND expiresAt > $now RETURNING attempts`: one statement, so Postgres serialises concurrent
   * callers on the row lock (each re-checks the WHERE after the previous commit) and RETURNING gives this caller's
   * own attempt number. Timestamps are stored as UTC `timestamp(3)`; `now` is passed as ISO and converted to UTC.
   */
  async reserveAttempt(id: string, now: Date, max: number): Promise<number | null> {
    const rows = await this.prisma.$queryRaw<{ attempts: number }[]>`
      UPDATE "OtpCode" SET "attempts" = "attempts" + 1
      WHERE "id" = ${id}::uuid
        AND "attempts" < ${max}::int
        AND "usedAt" IS NULL
        AND "lockedAt" IS NULL
        AND "expiresAt" > (${now.toISOString()}::timestamptz AT TIME ZONE 'UTC')
      RETURNING "attempts"`;
    return rows[0] ? Number(rows[0].attempts) : null;
  }

  async lock(id: string, at: Date): Promise<void> {
    await this.prisma.otpCode.updateMany({ where: { id, lockedAt: null }, data: { lockedAt: at } });
  }

  async markUsed(id: string, at: Date): Promise<boolean> {
    const res = await this.prisma.otpCode.updateMany({ where: { id, usedAt: null, lockedAt: null }, data: { usedAt: at } });
    return res.count === 1;
  }

  async purgeByEmail(email: string): Promise<number> {
    return (await this.prisma.otpCode.deleteMany({ where: { email } })).count;
  }

  async purgeCreatedBefore(before: Date): Promise<number> {
    return (await this.prisma.otpCode.deleteMany({ where: { createdAt: { lt: before } } })).count;
  }
}

class PrismaDeviceRepository implements DeviceRepository {
  constructor(private readonly prisma: PrismaClient) {}

  find(id: string) {
    return this.prisma.device.findUnique({ where: { id }, select: { id: true, userId: true, platform: true } });
  }

  async upsert(input: { id: string; userId: string; platform: string; at: Date }): Promise<void> {
    await this.prisma.device.upsert({
      where: { id: input.id },
      create: { id: input.id, userId: input.userId, platform: input.platform, createdAt: input.at, lastSeenAt: input.at },
      update: { platform: input.platform, lastSeenAt: input.at },
    });
  }
}

const sessionSelect = {
  id: true,
  userId: true,
  deviceId: true,
  isDesk: true,
  expiresAt: true,
  revokedAt: true,
  revokedReason: true,
} as const;

class PrismaSessionRepository implements SessionRepository {
  constructor(private readonly prisma: PrismaClient) {}

  create(input: { userId: string; deviceId: string; isDesk: boolean; expiresAt: Date; at: Date }): Promise<SessionRecord> {
    return this.prisma.session.create({
      data: {
        userId: input.userId,
        deviceId: input.deviceId,
        isDesk: input.isDesk,
        expiresAt: input.expiresAt,
        createdAt: input.at,
        lastUsedAt: input.at,
      },
      select: sessionSelect,
    });
  }

  findById(id: string): Promise<SessionRecord | null> {
    return this.prisma.session.findUnique({ where: { id }, select: sessionSelect });
  }

  async touch(id: string, at: Date): Promise<void> {
    await this.prisma.session.update({ where: { id }, data: { lastUsedAt: at } });
  }

  async revoke(id: string, reason: RevokeReason, at: Date): Promise<boolean> {
    const res = await this.prisma.session.updateMany({ where: { id, revokedAt: null }, data: { revokedAt: at, revokedReason: reason } });
    return res.count === 1;
  }

  async revokeAllForUser(userId: string, reason: RevokeReason, at: Date): Promise<number> {
    const res = await this.prisma.session.updateMany({ where: { userId, revokedAt: null }, data: { revokedAt: at, revokedReason: reason } });
    return res.count;
  }
}

class PrismaRefreshTokenRepository implements RefreshTokenRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async create(input: { sessionId: string; tokenHash: string; expiresAt: Date; at: Date }): Promise<void> {
    await this.prisma.refreshToken.create({
      data: { sessionId: input.sessionId, tokenHash: input.tokenHash, expiresAt: input.expiresAt, createdAt: input.at },
    });
  }

  findByHash(tokenHash: string) {
    return this.prisma.refreshToken.findUnique({
      where: { tokenHash },
      select: { id: true, sessionId: true, expiresAt: true, usedAt: true },
    });
  }

  async markUsed(id: string, at: Date): Promise<boolean> {
    const res = await this.prisma.refreshToken.updateMany({ where: { id, usedAt: null }, data: { usedAt: at } });
    return res.count === 1;
  }
}

class PrismaTwoFactorRepository implements TwoFactorRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async find(userId: string) {
    const row = await this.prisma.twoFactor.findUnique({ where: { userId } });
    if (!row) return null;
    return {
      userId: row.userId,
      secretEnc: row.secretEnc,
      confirmedAt: row.confirmedAt,
      lastUsedStep: row.lastUsedStep === null ? null : Number(row.lastUsedStep),
      failedAttempts: row.failedAttempts,
      lockedUntil: row.lockedUntil,
      createdAt: row.createdAt,
    };
  }

  async savePending(userId: string, secretEnc: string, at: Date, replaceIfCreatedBefore: Date): Promise<boolean> {
    // Replace only an unconfirmed secret that is old enough (SEC-M4); one conditional statement, race-safe.
    // The failure counter and lock are kept: re-enrolling must not reset a TOTP lock.
    const res = await this.prisma.twoFactor.updateMany({
      where: { userId, confirmedAt: null, createdAt: { lte: replaceIfCreatedBefore } },
      data: { secretEnc, lastUsedStep: null, createdAt: at },
    });
    if (res.count === 1) return true;
    try {
      await this.prisma.twoFactor.create({ data: { userId, secretEnc, createdAt: at } });
      return true;
    } catch (e) {
      if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === "P2002") return false; // a row exists
      throw e;
    }
  }

  async acceptStep(userId: string, step: number, at: Date, confirm: boolean): Promise<boolean> {
    const res = await this.prisma.twoFactor.updateMany({
      where: {
        userId,
        AND: [
          { OR: [{ lastUsedStep: null }, { lastUsedStep: { lt: BigInt(step) } }] },
          { OR: [{ lockedUntil: null }, { lockedUntil: { lte: at } }] },
        ],
        ...(confirm ? { confirmedAt: null } : {}),
      },
      data: { lastUsedStep: BigInt(step), failedAttempts: 0, lockedUntil: null, ...(confirm ? { confirmedAt: at } : {}) },
    });
    return res.count === 1;
  }

  async recordFailure(userId: string, max: number, lockUntil: Date): Promise<{ failedAttempts: number; locked: boolean }> {
    // One statement (row lock serialises concurrent failures). Reaching `max` sets the lock and restarts the count at
    // 0, so a returned 0 means "this call locked" (otherwise the count is always >= 1).
    const rows = await this.prisma.$queryRaw<{ failedAttempts: number }[]>`
      UPDATE "TwoFactor" SET
        "lockedUntil" = CASE WHEN "failedAttempts" + 1 >= ${max}::int
                             THEN (${lockUntil.toISOString()}::timestamptz AT TIME ZONE 'UTC') ELSE "lockedUntil" END,
        "failedAttempts" = CASE WHEN "failedAttempts" + 1 >= ${max}::int THEN 0 ELSE "failedAttempts" + 1 END
      WHERE "userId" = ${userId}::uuid
      RETURNING "failedAttempts"`;
    if (!rows[0]) return { failedAttempts: 0, locked: false }; // no enrolment row: nothing to count
    const n = Number(rows[0].failedAttempts);
    return n === 0 ? { failedAttempts: max, locked: true } : { failedAttempts: n, locked: false };
  }

  async reseal(userId: string, expectedEnc: string, secretEnc: string): Promise<void> {
    await this.prisma.twoFactor.updateMany({ where: { userId, secretEnc: expectedEnc }, data: { secretEnc } });
  }
}

export function createPrismaAuthRepositories(prisma: PrismaClient): AuthRepositories {
  return {
    otps: new PrismaOtpRepository(prisma),
    devices: new PrismaDeviceRepository(prisma),
    sessions: new PrismaSessionRepository(prisma),
    refreshTokens: new PrismaRefreshTokenRepository(prisma),
    twoFactors: new PrismaTwoFactorRepository(prisma),
  };
}
