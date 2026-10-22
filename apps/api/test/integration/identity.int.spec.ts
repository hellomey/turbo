/* eslint-disable @typescript-eslint/no-non-null-assertion -- tests assert presence right after creating the row */
// API end to end for the identity track (BOLT-0002) on REAL Postgres + Valkey (blueprint §44).
import { createHmac, randomUUID } from "node:crypto";
import { afterAll, beforeAll, beforeEach, describe, expect, it } from "vitest";
import type { NestFastifyApplication } from "@nestjs/platform-fastify";
import { Queue } from "bullmq";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { startPostgres, startValkey, type StartedDb } from "@heymey/testing";
import { createApiApp } from "../../src/bootstrap.js";
import { setTestEnv } from "../support/env.js";

let pg: StartedDb;
let valkey: StartedDb;
let app: NestFastifyApplication;
let prisma: PrismaClient;
let otpQueue: Queue;
let clientIp = "203.0.113.1";
let ipSeq = 1;

type Res = { statusCode: number; headers: Record<string, unknown>; json: () => any }; // eslint-disable-line @typescript-eslint/no-explicit-any

async function call(method: string, url: string, opts: { body?: unknown; token?: string; key?: string | null } = {}): Promise<Res> {
  const headers: Record<string, string> = { "x-forwarded-for": clientIp };
  if (opts.token) headers.authorization = `Bearer ${opts.token}`;
  if (opts.key !== null && method !== "GET") headers["idempotency-key"] = opts.key ?? randomUUID();
  const res = await app.getHttpAdapter().getInstance().inject({
    method: method as "GET",
    url,
    headers,
    ...(opts.body !== undefined ? { payload: opts.body as object } : {}),
  });
  return { statusCode: res.statusCode, headers: res.headers as Record<string, unknown>, json: () => res.json() };
}

/** The newest queued `email.otp` job for this address (read straight from BullMQ in Valkey). */
async function lastCode(to: string): Promise<{ code: string; purpose: string; count: number }> {
  const jobs = (await otpQueue.getJobs(["waiting", "delayed", "prioritized", "active"])).filter((j) => j.data.to === to);
  jobs.sort((a, b) => b.timestamp - a.timestamp);
  const job = jobs[0];
  if (!job) throw new Error(`no email.otp job for ${to}`);
  return { code: job.data.code as string, purpose: job.data.purpose as string, count: jobs.length };
}

/** RFC 6238 TOTP (SHA-1, 6 digits, 30 s) for the test's authenticator app. */
function totp(base32: string, at = Date.now()): string {
  const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
  let bits = "";
  for (const c of base32.replace(/=+$/, "").toUpperCase()) bits += alphabet.indexOf(c).toString(2).padStart(5, "0");
  const key = Buffer.from(bits.match(/.{8}/g)!.map((b) => parseInt(b, 2)));
  const counter = Buffer.alloc(8);
  counter.writeBigUInt64BE(BigInt(Math.floor(at / 1000 / 30)));
  const h = createHmac("sha1", key).update(counter).digest();
  const o = h[h.length - 1]! & 0xf;
  return String((h.readUInt32BE(o) & 0x7fffffff) % 1_000_000).padStart(6, "0");
}

async function signIn(email: string, deviceId = randomUUID()) {
  expect((await call("POST", "/v1/auth/otp/request", { body: { email } })).statusCode).toBe(200);
  const { code } = await lastCode(email);
  const res = await call("POST", "/v1/auth/otp/verify", { body: { email, code, deviceId, platform: "android" } });
  expect(res.statusCode).toBe(200);
  return { ...res.json(), deviceId } as { kind: string; isNewUser: boolean; tokens: { accessToken: string; refreshToken: string }; deviceId: string };
}

beforeAll(async () => {
  [pg, valkey] = await Promise.all([startPostgres(), startValkey()]);
  setTestEnv({ DATABASE_URL: pg.url, VALKEY_URL: valkey.url });
  app = await createApiApp({ logger: false });
  await app.init();
  await app.getHttpAdapter().getInstance().ready();
  prisma = createPrismaClient(pg.url);
  const url = new URL(valkey.url);
  otpQueue = new Queue("email.otp", { connection: { host: url.hostname, port: Number(url.port), maxRetriesPerRequest: null } });
});

afterAll(async () => {
  await otpQueue?.close();
  await app?.close();
  await prisma?.$disconnect();
  await Promise.all([pg?.stop(), valkey?.stop()]);
});

describe("identity API (integration)", () => {
  // Each test is its own client (trustProxy is on); per-IP limits are tested explicitly below.
  beforeEach(() => {
    clientIp = `203.0.113.${++ipSeq}`;
  });

  it("per-IP limit: 10 OTP requests per hour, then 429 with Retry-After", async () => {
    for (let i = 0; i < 10; i++) {
      expect((await call("POST", "/v1/auth/otp/request", { body: { email: `ip${i}@example.com` } })).statusCode).toBe(200);
    }
    const limited = await call("POST", "/v1/auth/otp/request", { body: { email: "ip10@example.com" } });
    expect(limited.statusCode).toBe(429);
    expect(limited.json().error.code).toBe("RATE_LIMITED");
    expect(Number(limited.headers["retry-after"])).toBeGreaterThan(0);
  });

  it("per-email limit: 3 codes per 10 minutes", async () => {
    for (let i = 0; i < 3; i++) {
      expect((await call("POST", "/v1/auth/otp/request", { body: { email: "busy@example.com" } })).statusCode).toBe(200);
    }
    const limited = await call("POST", "/v1/auth/otp/request", { body: { email: "BUSY@example.com" } });
    expect(limited.statusCode).toBe(429);
    expect(limited.json().error.details.retryAfterSeconds).toBeGreaterThan(0);
  });

  it("a write without Idempotency-Key is refused", async () => {
    const res = await call("POST", "/v1/auth/otp/request", { body: { email: "x@example.com" }, key: null });
    expect(res.statusCode).toBe(400);
    expect(res.json().error.code).toBe("IDEMPOTENCY_KEY_REQUIRED");
  });

  it("OTP request: 200, queued once, idempotent replay; disposable domain refused", async () => {
    const key = randomUUID();
    const first = await call("POST", "/v1/auth/otp/request", { body: { email: "Replay@Example.com" }, key });
    expect(first.statusCode).toBe(200);
    expect(first.json()).toEqual({ resendAfterSeconds: 60 });
    const again = await call("POST", "/v1/auth/otp/request", { body: { email: "Replay@Example.com" }, key });
    expect(again.statusCode).toBe(200);
    expect(again.headers["idempotent-replayed"]).toBe("true");
    expect(again.json()).toEqual({ resendAfterSeconds: 60 });
    const queued = await lastCode("replay@example.com");
    expect(queued.count).toBe(1);
    expect(queued.purpose).toBe("login");
    expect(queued.code).toMatch(/^\d{6}$/);

    const bad = await call("POST", "/v1/auth/otp/request", { body: { email: "a@yopmail.com" } });
    expect(bad.statusCode).toBe(400);
    expect(bad.json().error.code).toBe("EMAIL_NOT_ALLOWED");
  });

  it("verify -> session; GET /v1/me; no token -> 401", async () => {
    const s = await signIn("asha@example.com");
    expect(s.kind).toBe("session");
    expect(s.isNewUser).toBe(true);
    const me = await call("GET", "/v1/me", { token: s.tokens.accessToken });
    expect(me.statusCode).toBe(200);
    expect(me.headers["x-min-app-version"]).toBe("1.0.0");
    expect(me.json()).toMatchObject({ email: "asha@example.com", roles: ["ASPIRANT"], profile: null, deletionScheduledFor: null });
    const anon = await call("GET", "/v1/me");
    expect(anon.statusCode).toBe(401);
    expect(anon.json().error.code).toBe("UNAUTHENTICATED");
    const wrong = await call("POST", "/v1/auth/otp/verify", {
      body: { email: "asha@example.com", code: "12345", deviceId: randomUUID(), platform: "android" },
    });
    expect(wrong.json().error.code).toBe("VALIDATION_FAILED");
  });

  it("PATCH /v1/me, PUT profile (under-18 refused), consents", async () => {
    const s = await signIn("ravi@example.com");
    const t = s.tokens.accessToken;
    const patched = await call("PATCH", "/v1/me", { token: t, body: { nickname: "Ravi 01", district: "Salem", calmMode: true } });
    expect(patched.statusCode).toBe(200);
    expect(patched.json()).toMatchObject({ nickname: "Ravi 01", district: "Salem", calmMode: true });
    const badNick = await call("PATCH", "/v1/me", { token: t, body: { nickname: "call 98400 http://x" } });
    expect(badNick.statusCode).toBe(400);

    const young = new Date();
    young.setUTCFullYear(young.getUTCFullYear() - 17);
    const under = await call("PUT", "/v1/me/profile", {
      token: t,
      body: { dateOfBirth: young.toISOString().slice(0, 10), qualification: "hsc", community: "OC", pstm: false },
    });
    expect(under.statusCode).toBe(422);
    expect(under.json().error).toMatchObject({ code: "UNDER_18", message: "HeyMey is for 18+. See you on your 18th birthday." });
    expect(await prisma.userProfile.count()).toBe(0);
    const ok = await call("PUT", "/v1/me/profile", {
      token: t,
      body: { dateOfBirth: "1998-06-15", qualification: "degree", degreeSubject: "Tamil", community: "BC", pstm: true, specialCategories: [] },
    });
    expect(ok.statusCode).toBe(200);
    expect(ok.json().profile).toMatchObject({ dateOfBirth: "1998-06-15", degreeSubject: "Tamil" });

    const notice = await call("GET", "/v1/consents/notice");
    expect(notice.statusCode).toBe(200);
    expect(notice.json().version).toBe("2026-10-v2");
    const missing = await call("POST", "/v1/me/consents", {
      token: t,
      body: { noticeVersion: "2026-10-v2", choices: [{ purpose: "offers_email", granted: true }] },
    });
    expect(missing.statusCode).toBe(422);
    expect(missing.json().error.code).toBe("CONSENT_REQUIRED");
    const rec = await call("POST", "/v1/me/consents", {
      token: t,
      body: { noticeVersion: "2026-10-v2", choices: [{ purpose: "core_service", granted: true }, { purpose: "offers_email", granted: false }] },
    });
    expect(rec.statusCode).toBe(200);
    expect(rec.json().noticeVersion).toBe("2026-10-v2");
    const got = await call("GET", "/v1/me/consents", { token: t });
    expect(got.json().choices).toHaveLength(2);
  });

  it("refresh rotates; re-using the old token revokes the session (SESSION_REVOKED)", async () => {
    const s = await signIn("rotate@example.com");
    const r1 = await call("POST", "/v1/auth/refresh", { body: { refreshToken: s.tokens.refreshToken } });
    expect(r1.statusCode).toBe(200);
    const pair = r1.json();
    expect(pair.refreshToken).not.toBe(s.tokens.refreshToken);
    expect((await call("GET", "/v1/me", { token: pair.accessToken })).statusCode).toBe(200);

    const reuse = await call("POST", "/v1/auth/refresh", { body: { refreshToken: s.tokens.refreshToken } });
    expect(reuse.statusCode).toBe(401);
    expect(reuse.json().error.code).toBe("SESSION_REVOKED");
    const after = await call("POST", "/v1/auth/refresh", { body: { refreshToken: pair.refreshToken } });
    expect(after.json().error.code).toBe("SESSION_REVOKED");
    expect((await call("GET", "/v1/me", { token: pair.accessToken })).statusCode).toBe(401);
    expect(await prisma.auditLog.count({ where: { action: "auth.session_revoked" } })).toBeGreaterThan(0);
  });

  it("logout ends the session; logout-all ends every session", async () => {
    const a = await signIn("out@example.com");
    expect((await call("POST", "/v1/auth/logout", { token: a.tokens.accessToken })).json()).toEqual({ ok: true });
    expect((await call("GET", "/v1/me", { token: a.tokens.accessToken })).statusCode).toBe(401);
    const b = await signIn("out@example.com", a.deviceId);
    const c = await signIn("out@example.com", a.deviceId);
    expect((await call("POST", "/v1/auth/logout-all", { token: c.tokens.accessToken })).statusCode).toBe(200);
    expect((await call("GET", "/v1/me", { token: b.tokens.accessToken })).statusCode).toBe(401);
  });

  it("Desk: aspirant refused; OPS user enrolls TOTP and gets a Desk session", async () => {
    await signIn("aspirant-desk@example.com");
    await call("POST", "/v1/auth/otp/request", { body: { email: "aspirant-desk@example.com" } });
    const refused = await call("POST", "/v1/auth/otp/verify", {
      body: { email: "aspirant-desk@example.com", code: (await lastCode("aspirant-desk@example.com")).code, deviceId: randomUUID(), platform: "web", client: "desk" },
    });
    expect(refused.statusCode).toBe(403);
    expect(refused.json().error.code).toBe("DESK_NOT_ALLOWED");

    const ops = await prisma.user.create({ data: { email: "ops@heymey.app" } });
    await prisma.roleAssignment.create({ data: { userId: ops.id, role: "OPS", grantedBy: ops.id } });
    await call("POST", "/v1/auth/otp/request", { body: { email: "ops@heymey.app" } });
    const ch = await call("POST", "/v1/auth/otp/verify", {
      body: { email: "ops@heymey.app", code: (await lastCode("ops@heymey.app")).code, deviceId: randomUUID(), platform: "web", client: "desk" },
    });
    expect(ch.statusCode).toBe(200);
    expect(ch.json()).toMatchObject({ kind: "desk_2fa", totpEnrolled: false });
    const challengeToken = ch.json().challengeToken as string;

    const enroll = await call("POST", "/v1/auth/desk/totp/enroll", { body: { challengeToken } });
    expect(enroll.statusCode).toBe(200);
    const { secret, otpauthUri } = enroll.json();
    expect(otpauthUri).toContain("HeyMey%20Desk");

    const code = totp(secret);
    const wrongCode = code === "000000" ? "111111" : "000000";
    const bad = await call("POST", "/v1/auth/desk/totp/verify", { body: { challengeToken, code: wrongCode } });
    expect(bad.json().error.code).toBe("TOTP_INVALID");
    // SEC-H2: one guess per challenge. The burned challenge refuses even the right code; sign in again for a new one.
    const burned = await call("POST", "/v1/auth/desk/totp/verify", { body: { challengeToken, code } });
    expect(burned.json().error.code).toBe("CHALLENGE_EXPIRED");
    await call("POST", "/v1/auth/otp/request", { body: { email: "ops@heymey.app" } });
    const ch2 = await call("POST", "/v1/auth/otp/verify", {
      body: { email: "ops@heymey.app", code: (await lastCode("ops@heymey.app")).code, deviceId: randomUUID(), platform: "web", client: "desk" },
    });
    expect(ch2.json()).toMatchObject({ kind: "desk_2fa", totpEnrolled: false });
    const ok = await call("POST", "/v1/auth/desk/totp/verify", { body: { challengeToken: ch2.json().challengeToken, code } });
    expect(ok.statusCode).toBe(200);
    expect(ok.json()).toMatchObject({ kind: "session", isNewUser: false, deletionCancelled: false });
    const replay = await call("POST", "/v1/auth/desk/totp/verify", { body: { challengeToken: ch2.json().challengeToken, code } });
    expect(replay.statusCode).not.toBe(200);
    const me = await call("GET", "/v1/me", { token: ok.json().tokens.accessToken });
    expect(me.json().roles).toEqual(["OPS"]);
    expect((await call("POST", "/v1/auth/desk/totp/enroll", { body: { challengeToken } })).json().error.code).toBe("FORBIDDEN");
    expect((await call("POST", "/v1/auth/desk/totp/enroll", { body: { challengeToken: "garbage" } })).json().error.code).toBe("CHALLENGE_EXPIRED");
  });

  it("delete account: code for the caller's email -> deletion in 7 days; other emails forbidden", async () => {
    const s = await signIn("leave@example.com");
    const t = s.tokens.accessToken;
    const forbidden = await call("POST", "/v1/auth/otp/request", { token: t, body: { email: "asha@example.com", purpose: "delete_account" } });
    expect(forbidden.statusCode).toBe(403);
    expect((await call("POST", "/v1/auth/otp/request", { token: t, body: { email: "leave@example.com", purpose: "delete_account" } })).statusCode).toBe(200);
    const { code, purpose } = await lastCode("leave@example.com");
    expect(purpose).toBe("delete_account");
    const del = await call("POST", "/v1/auth/delete-account", { token: t, body: { code } });
    expect(del.statusCode).toBe(200);
    const at = new Date(del.json().deletionScheduledFor).getTime();
    expect(Math.abs(at - (Date.now() + 7 * 86_400_000))).toBeLessThan(60_000);
    // signed out everywhere; signing in again cancels
    expect((await call("GET", "/v1/me", { token: t })).statusCode).toBe(401);
    expect((await call("POST", "/v1/auth/otp/request", { body: { email: "leave@example.com" } })).statusCode).toBe(200);
    const back = await call("POST", "/v1/auth/otp/verify", {
      body: { email: "leave@example.com", code: (await lastCode("leave@example.com")).code, deviceId: s.deviceId, platform: "android" },
    });
    expect(back.json()).toMatchObject({ kind: "session", deletionCancelled: true });
  });
});
