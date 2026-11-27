import type { EconomyRepository, PeoplePort } from "../../src/modules/economy/index.js";

const istDay = (d: Date) => new Date(d.getTime() + 330 * 60_000).toISOString().slice(0, 10);

/** In-memory EconomyRepository with the same uniqueness rules as the Prisma adapter. */
export class FakeEconomyRepo implements EconomyRepository {
  xp: { userId: string; amount: number; reason: string; sourceKey: string; at: Date }[] = [];
  points: { userId: string; delta: number; reason: string; key: string }[] = [];
  trophies: { userId: string; code: string; earnedAt: Date }[] = [];
  optIns = new Map<string, boolean>();

  async awardXp(a: { userId: string; amount: number; reason: string; sourceKey: string; at: Date }) {
    if (this.xp.some((x) => x.userId === a.userId && x.sourceKey === a.sourceKey)) return false;
    this.xp.push(a);
    return true;
  }
  async checkIn(a: { userId: string; day: string; xp: number; points: number; at: Date }) {
    const key = `check_in:${a.userId}:${a.day}`;
    if (this.points.some((p) => p.key === key)) return false;
    this.points.push({ userId: a.userId, delta: a.points, reason: "check_in", key });
    this.xp.push({ userId: a.userId, amount: a.xp, reason: "check_in", sourceKey: `check_in:${a.day}`, at: a.at });
    return true;
  }
  async hasCheckedIn(userId: string, day: string) {
    return this.points.some((p) => p.key === `check_in:${userId}:${day}`);
  }
  async xpTotal(userId: string) {
    return this.xp.filter((x) => x.userId === userId).reduce((s, x) => s + x.amount, 0);
  }
  async pointsBalance(userId: string) {
    return this.points.filter((p) => p.userId === userId).reduce((s, p) => s + p.delta, 0);
  }
  async trophiesOf(userId: string) {
    return this.trophies.filter((t) => t.userId === userId).map(({ code, earnedAt }) => ({ code, earnedAt }));
  }
  async awardTrophy(userId: string, code: string, at: Date) {
    if (this.trophies.some((t) => t.userId === userId && t.code === code)) return false;
    this.trophies.push({ userId, code, earnedAt: at });
    return true;
  }
  async studyDays(userId: string) {
    return new Set(this.xp.filter((x) => x.userId === userId && x.reason !== "check_in").map((x) => istDay(x.at))).size;
  }
  async setOptIn(userId: string, optIn: boolean) {
    this.optIns.set(userId, optIn);
  }
  async isOptedIn(userId: string) {
    return this.optIns.get(userId) ?? false;
  }
  async weeklyXp(from: Date, to: Date, limit: number) {
    const sums = new Map<string, number>();
    for (const x of this.xp) if (this.optIns.get(x.userId) && x.at >= from && x.at < to) sums.set(x.userId, (sums.get(x.userId) ?? 0) + x.amount);
    return [...sums].map(([userId, xp]) => ({ userId, xp })).sort((a, b) => b.xp - a.xp || a.userId.localeCompare(b.userId)).slice(0, limit);
  }
}

export function fakePeople(rows: Record<string, { nickname?: string | null; isGuest?: boolean; hidden?: boolean; deleted?: boolean }>): PeoplePort {
  return {
    async profile(userId) {
      const r = rows[userId];
      if (!r) return null;
      return { nickname: r.nickname ?? null, isGuest: r.isGuest ?? false, hideFromLeaderboards: r.hidden ?? false, deleted: r.deleted ?? false };
    },
  };
}
