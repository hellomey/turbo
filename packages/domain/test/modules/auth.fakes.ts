/* eslint-disable @typescript-eslint/no-non-null-assertion -- tests assert presence right after creating the row */
// In-memory adapters for the identity modules' ports (unit tests only).
import { generateKeyPairSync, randomBytes, randomUUID } from "node:crypto";
import type { Role } from "@heymey/contracts";
import { FakeClock } from "@heymey/testing";
import type { RateLimiter } from "../../src/shared/index.js";
import { createAuditModule, type AuditEntry } from "../../src/modules/audit/index.js";
import { createRolesModule, type RoleRepository } from "../../src/modules/roles/index.js";
import {
  createUsersModule,
  type ConsentRepository,
  type ConsentRow,
  type Profile,
  type UserRecord,
  type UserRepository,
} from "../../src/modules/users/index.js";
import {
  createAuthModule,
  type AuthRepositories,
  type DeviceRecord,
  type OneTimeTokenStore,
  type OtpRecord,
  type RefreshTokenRecord,
  type SessionRecord,
  type TwoFactorRecord,
} from "../../src/modules/auth/index.js";

export class MemUsers implements UserRepository {
  rows = new Map<string, UserRecord>();
  profiles = new Map<string, Profile>();
  constructor(private readonly clock: FakeClock) {}

  async findById(id: string) {
    return this.rows.get(id) ?? null;
  }
  async findByEmail(email: string) {
    return [...this.rows.values()].find((u) => u.email === email) ?? null;
  }
  async create(email: string) {
    const existing = await this.findByEmail(email);
    if (existing) return { user: existing, created: false };
    const user: UserRecord = {
      id: randomUUID(),
      email,
      nickname: null,
      district: null,
      calmMode: false,
      liteMode: null,
      hideFromLeaderboards: false,
      createdAt: this.clock.now(),
      deletionRequestedAt: null,
      deletedAt: null,
    };
    this.rows.set(user.id, user);
    return { user, created: true };
  }
  async update(id: string, patch: Partial<UserRecord>) {
    const u = { ...this.rows.get(id)!, ...patch };
    this.rows.set(id, u);
    return u;
  }
  async getProfile(userId: string) {
    return this.profiles.get(userId) ?? null;
  }
  async saveProfile(userId: string, profile: Profile) {
    this.profiles.set(userId, profile);
  }
  async setDeletionRequestedAt(id: string, at: Date | null) {
    await this.update(id, { deletionRequestedAt: at });
  }
  async dueForErasure(cutoff: Date, limit: number) {
    return [...this.rows.values()]
      .filter((u) => u.deletionRequestedAt && u.deletionRequestedAt <= cutoff && !u.deletedAt)
      .slice(0, limit)
      .map((u) => u.id);
  }
  consents?: MemConsents;
  async erase(id: string, erasedEmail: string, at: Date, cutoff: Date) {
    const u = this.rows.get(id);
    if (!u || u.deletedAt || !u.deletionRequestedAt || u.deletionRequestedAt > cutoff) return false;
    this.profiles.delete(id);
    this.consents?.rows.delete(id);
    await this.update(id, { email: erasedEmail, nickname: null, district: null, deletedAt: at });
    return true;
  }
}

export class MemConsents implements ConsentRepository {
  rows = new Map<string, ConsentRow[]>();
  async append(userId: string, rows: ConsentRow[]) {
    this.rows.set(userId, [...(this.rows.get(userId) ?? []), ...rows]);
  }
  async latest(userId: string) {
    const out = new Map<string, ConsentRow>();
    for (const r of this.rows.get(userId) ?? []) {
      const prev = out.get(r.purpose);
      if (!prev || r.at >= prev.at) out.set(r.purpose, r);
    }
    return [...out.values()];
  }
}

export class MemRoles implements RoleRepository {
  rows: { userId: string; role: Role; grantedBy: string }[] = [];
  async activeRoles(userId: string) {
    return this.rows.filter((r) => r.userId === userId).map((r) => r.role);
  }
  async grantIfAbsent(input: { userId: string; role: Role; grantedBy: string }) {
    if (this.rows.some((r) => r.userId === input.userId && r.role === input.role)) return false;
    this.rows.push(input);
    return true;
  }
}

export function memAuthRepos() {
  const otps = new Map<string, OtpRecord & { seq?: number }>();
  const devices = new Map<string, DeviceRecord>();
  const sessions = new Map<string, SessionRecord>();
  const tokens = new Map<string, RefreshTokenRecord & { tokenHash: string }>();
  const twoFactors = new Map<string, TwoFactorRecord>();
  let seq = 0;
  const repos: AuthRepositories = {
    otps: {
      async create(i) {
        const id = randomUUID();
        otps.set(id, { id, email: i.email, purpose: i.purpose, codeHash: i.codeHash, attempts: 0, expiresAt: i.expiresAt, usedAt: null, lockedAt: null, createdAt: i.at, seq: seq++ });
        return { id };
      },
      async latest(email, purpose) {
        return [...otps.values()].filter((o) => o.email === email && o.purpose === purpose).sort((a, b) => +b.createdAt - +a.createdAt || (b.seq ?? 0) - (a.seq ?? 0))[0] ?? null;
      },
      async reserveAttempt(id, now, max) {
        const o = otps.get(id);
        if (!o || o.attempts >= max || o.usedAt || o.lockedAt || o.expiresAt <= now) return null;
        o.attempts += 1;
        return o.attempts;
      },
      async purgeByEmail(email) {
        const ids = [...otps.values()].filter((o) => o.email === email).map((o) => o.id);
        for (const id of ids) otps.delete(id);
        return ids.length;
      },
      async purgeCreatedBefore(before) {
        const ids = [...otps.values()].filter((o) => o.createdAt < before).map((o) => o.id);
        for (const id of ids) otps.delete(id);
        return ids.length;
      },
      async lock(id, at) {
        const o = otps.get(id)!;
        o.lockedAt ??= at;
      },
      async markUsed(id, at) {
        const o = otps.get(id)!;
        if (o.usedAt || o.lockedAt) return false;
        o.usedAt = at;
        return true;
      },
    },
    devices: {
      async find(id) {
        return devices.get(id) ?? null;
      },
      async upsert(i) {
        const prev = devices.get(i.id);
        devices.set(i.id, { id: i.id, userId: prev?.userId ?? i.userId, platform: i.platform });
      },
    },
    sessions: {
      async create(i) {
        const s: SessionRecord = { id: randomUUID(), userId: i.userId, deviceId: i.deviceId, isDesk: i.isDesk, expiresAt: i.expiresAt, revokedAt: null, revokedReason: null };
        sessions.set(s.id, s);
        return { ...s };
      },
      async findById(id) {
        const s = sessions.get(id);
        return s ? { ...s } : null;
      },
      async touch() {},
      async revoke(id, reason, at) {
        const s = sessions.get(id);
        if (!s || s.revokedAt) return false;
        s.revokedAt = at;
        s.revokedReason = reason;
        return true;
      },
      async revokeAllForUser(userId, reason, at) {
        let n = 0;
        for (const s of sessions.values()) {
          if (s.userId === userId && !s.revokedAt) {
            s.revokedAt = at;
            s.revokedReason = reason;
            n++;
          }
        }
        return n;
      },
    },
    refreshTokens: {
      async create(i) {
        tokens.set(i.tokenHash, { id: randomUUID(), sessionId: i.sessionId, expiresAt: i.expiresAt, usedAt: null, tokenHash: i.tokenHash });
      },
      async findByHash(h) {
        const t = tokens.get(h);
        return t ? { ...t } : null;
      },
      async markUsed(id, at) {
        const t = [...tokens.values()].find((x) => x.id === id)!;
        if (t.usedAt) return false;
        t.usedAt = at;
        return true;
      },
    },
    twoFactors: {
      async find(userId) {
        const t = twoFactors.get(userId);
        return t ? { ...t } : null;
      },
      async savePending(userId, secretEnc, at, replaceIfCreatedBefore) {
        const t = twoFactors.get(userId);
        if (t && (t.confirmedAt || t.createdAt > replaceIfCreatedBefore)) return false;
        twoFactors.set(userId, { userId, secretEnc, confirmedAt: null, lastUsedStep: null, failedAttempts: t?.failedAttempts ?? 0, lockedUntil: t?.lockedUntil ?? null, createdAt: at });
        return true;
      },
      async acceptStep(userId, step, at, confirm) {
        const t = twoFactors.get(userId);
        if (!t || (t.lastUsedStep !== null && t.lastUsedStep >= step) || (confirm && t.confirmedAt)) return false;
        if (t.lockedUntil && t.lockedUntil > at) return false;
        t.lastUsedStep = step;
        t.failedAttempts = 0;
        t.lockedUntil = null;
        if (confirm) t.confirmedAt = at;
        return true;
      },
      async recordFailure(userId, max, lockUntil) {
        const t = twoFactors.get(userId);
        if (!t) return { failedAttempts: 0, locked: false };
        t.failedAttempts += 1;
        if (t.failedAttempts < max) return { failedAttempts: t.failedAttempts, locked: false };
        t.failedAttempts = 0;
        t.lockedUntil = lockUntil;
        return { failedAttempts: max, locked: true };
      },
      async reseal(userId, expectedEnc, secretEnc) {
        const t = twoFactors.get(userId);
        if (t && t.secretEnc === expectedEnc) t.secretEnc = secretEnc;
      },
    },
  };
  return { repos, otps, devices, sessions, tokens, twoFactors };
}

/** `SET NX EX` semantics on the fake clock (SEC-H2 single-use challenges). */
export class MemOneTimeTokens implements OneTimeTokenStore {
  readonly used = new Map<string, number>();
  constructor(private readonly clock: FakeClock) {}
  async consume(jti: string, ttlSeconds: number) {
    const now = this.clock.now().getTime();
    const until = this.used.get(jti);
    if (until !== undefined && until > now) return false;
    this.used.set(jti, now + ttlSeconds * 1000);
    return true;
  }
}

/** Fixed-window limiter on the fake clock. */
export class MemRateLimiter implements RateLimiter {
  private windows = new Map<string, { count: number; resetAt: number }>();
  constructor(private readonly clock: FakeClock) {}
  async hit(key: string, limit: number, windowSeconds: number) {
    const now = this.clock.now().getTime();
    let w = this.windows.get(key);
    if (!w || now >= w.resetAt) this.windows.set(key, (w = { count: 0, resetAt: now + windowSeconds * 1000 }));
    w.count++;
    return { allowed: w.count <= limit, retryAfterSeconds: Math.ceil((w.resetAt - now) / 1000) };
  }
}

export const testKeys = () => {
  const { privateKey, publicKey } = generateKeyPairSync("ed25519");
  return {
    jwtPrivateKeyPem: privateKey.export({ type: "pkcs8", format: "pem" }).toString(),
    jwtPublicKeyPem: publicKey.export({ type: "spki", format: "pem" }).toString(),
    jwtIssuer: "http://localhost:4567",
    otpPepper: randomBytes(32).toString("hex"),
    totpEncKey: randomBytes(32).toString("base64"),
  };
};

/** Everything wired with in-memory adapters, a fake clock, and a mailbox that captures codes. */
export function identityHarness(start = "2026-10-20T06:00:00.000Z") {
  const clock = new FakeClock(start);
  const auditRows: AuditEntry[] = [];
  const audit = createAuditModule({ repository: { append: async (e) => void auditRows.push(e) } });
  const roleRepo = new MemRoles();
  const roles = createRolesModule({ repository: roleRepo, audit });
  const userRepo = new MemUsers(clock);
  const consentRepo = new MemConsents();
  userRepo.consents = consentRepo;
  const users = createUsersModule({ repositories: { users: userRepo, consents: consentRepo }, audit, clock, roles });
  const mem = memAuthRepos();
  const mailbox: { otpId: string; to: string; code: string; purpose: string }[] = [];
  const config = testKeys();
  const oneTimeTokens = new MemOneTimeTokens(clock);
  const auth = createAuthModule({
    repositories: mem.repos,
    users,
    roles,
    audit,
    clock,
    rateLimiter: new MemRateLimiter(clock),
    mailer: { send: async (m) => void mailbox.push(m) },
    oneTimeTokens,
    config,
  });
  const lastCode = (to?: string) => [...mailbox].reverse().find((m) => !to || m.to === to)!.code;
  return { clock, audit, auditRows, roles, roleRepo, users, userRepo, consentRepo, auth, mem, mailbox, lastCode, config, oneTimeTokens };
}

export const ACTOR = { userId: null, role: "VISITOR", ip: "127.0.0.1", requestId: "req-test" };
