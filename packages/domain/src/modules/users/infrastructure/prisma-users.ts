import type { District } from "@heymey/contracts";
import { Prisma, type PrismaClient } from "@heymey/db";
import type {
  ConsentRepository,
  ConsentRow,
  Profile,
  Purpose,
  SettingsPatch,
  UserRecord,
  UserRepository,
} from "../application/ports.js";

type UserRow = {
  id: string;
  email: string;
  nickname: string | null;
  district: string | null;
  calmMode: boolean;
  liteMode: boolean | null;
  hideFromLeaderboards: boolean;
  createdAt: Date;
  deletionRequestedAt: Date | null;
  deletedAt: Date | null;
};

const toRecord = (u: UserRow): UserRecord => ({
  id: u.id,
  email: u.email,
  nickname: u.nickname,
  district: u.district as District | null,
  calmMode: u.calmMode,
  liteMode: u.liteMode,
  hideFromLeaderboards: u.hideFromLeaderboards,
  createdAt: u.createdAt,
  deletionRequestedAt: u.deletionRequestedAt,
  deletedAt: u.deletedAt,
});

/** "YYYY-MM-DD" <-> @db.Date (stored at UTC midnight). */
const toDate = (day: string) => new Date(`${day}T00:00:00.000Z`);
const toDay = (d: Date) => d.toISOString().slice(0, 10);

export class PrismaUserRepository implements UserRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async findById(id: string): Promise<UserRecord | null> {
    const u = await this.prisma.user.findUnique({ where: { id } });
    return u ? toRecord(u) : null;
  }

  async findByEmail(email: string): Promise<UserRecord | null> {
    const u = await this.prisma.user.findUnique({ where: { email } });
    return u ? toRecord(u) : null;
  }

  async create(email: string): Promise<{ user: UserRecord; created: boolean }> {
    try {
      return { user: toRecord(await this.prisma.user.create({ data: { email } })), created: true };
    } catch (e) {
      if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === "P2002") {
        const existing = await this.findByEmail(email);
        if (existing) return { user: existing, created: false };
      }
      throw e;
    }
  }

  async update(id: string, patch: SettingsPatch): Promise<UserRecord> {
    return toRecord(await this.prisma.user.update({ where: { id }, data: patch }));
  }

  async getProfile(userId: string): Promise<Profile | null> {
    const p = await this.prisma.userProfile.findUnique({ where: { userId } });
    if (!p) return null;
    return {
      dateOfBirth: toDay(p.dateOfBirth),
      qualification: p.qualification as Profile["qualification"],
      ...(p.degreeSubject ? { degreeSubject: p.degreeSubject } : {}),
      community: p.community as Profile["community"],
      pstm: p.pstm,
      specialCategories: p.specialCategories as Profile["specialCategories"],
    };
  }

  async saveProfile(userId: string, profile: Profile): Promise<void> {
    const data = {
      dateOfBirth: toDate(profile.dateOfBirth),
      qualification: profile.qualification,
      degreeSubject: profile.degreeSubject ?? null,
      community: profile.community,
      pstm: profile.pstm,
      specialCategories: [...profile.specialCategories],
    };
    await this.prisma.userProfile.upsert({ where: { userId }, create: { userId, ...data }, update: data });
  }

  async setDeletionRequestedAt(id: string, at: Date | null): Promise<void> {
    await this.prisma.user.update({ where: { id }, data: { deletionRequestedAt: at } });
  }

  async dueForErasure(cutoff: Date, limit: number): Promise<string[]> {
    const rows = await this.prisma.user.findMany({
      where: { deletionRequestedAt: { lte: cutoff }, deletedAt: null },
      select: { id: true },
      orderBy: { deletionRequestedAt: "asc" },
      take: limit,
    });
    return rows.map((r) => r.id);
  }

  /**
   * SEC-M3(b): the user row is updated FIRST, conditionally on the deletion still being due, inside one interactive
   * transaction. If the user cancelled (signed in) after `dueForErasure`, nothing matches and nothing is deleted.
   */
  async erase(id: string, erasedEmail: string, at: Date, cutoff: Date): Promise<boolean> {
    return this.prisma.$transaction(async (tx) => {
      const res = await tx.user.updateMany({
        where: { id, deletedAt: null, deletionRequestedAt: { lte: cutoff } },
        data: { email: erasedEmail, nickname: null, district: null, deletedAt: at },
      });
      if (res.count !== 1) return false;
      await tx.userProfile.deleteMany({ where: { userId: id } });
      await tx.consent.deleteMany({ where: { userId: id } });
      return true;
    });
  }
}

export class PrismaConsentRepository implements ConsentRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async append(userId: string, rows: ConsentRow[]): Promise<void> {
    await this.prisma.consent.createMany({
      data: rows.map((r) => ({ userId, purpose: r.purpose, granted: r.granted, noticeVersion: r.noticeVersion, createdAt: r.at })),
    });
  }

  async latest(userId: string): Promise<ConsentRow[]> {
    const rows = await this.prisma.consent.findMany({
      where: { userId },
      orderBy: [{ createdAt: "desc" }, { id: "desc" }],
      distinct: ["purpose"],
    });
    return rows.map((r) => ({ purpose: r.purpose as Purpose, granted: r.granted, noticeVersion: r.noticeVersion, at: r.createdAt }));
  }
}
