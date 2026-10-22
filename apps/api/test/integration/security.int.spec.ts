/* eslint-disable @typescript-eslint/no-non-null-assertion -- tests assert presence right after creating the row */
// Security review BOLT-0006 (security agent): tests that DEMONSTRATE open findings on REAL Postgres + Valkey.
// Every `it.fails` below asserts the SECURE behaviour and currently fails because of the finding named in its title
// (see aidlc/construction/bolts/BOLT-0006-reviews.md, "Security review"). When a finding is fixed, vitest reports the
// `it.fails` as failing: flip it to `it` so it becomes a permanent regression test. Never delete or weaken these.
// Blueprint 18 (OTP abuse), 23, 37 (rate limits per IP), 38 (5 tries per code, 10/IP/hour), 15 (Desk 2nd factor).
import { createHmac, randomUUID } from "node:crypto";
import { afterAll, beforeAll, beforeEach, describe, expect, it } from "vitest";
import type { NestFastifyApplication } from "@nestjs/platform-fastify";
import { Queue } from "bullmq";
import { Redis } from "ioredis";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { startPostgres, startValkey, type StartedDb } from "@heymey/testing";
import { createApiApp } from "../../src/bootstrap.js";
import { setTestEnv } from "../support/env.js";

let pg: StartedDb;
let valkey: StartedDb;
let app: NestFastifyApplication;
let prisma: PrismaClient;
let otpQueue: Queue;
let redis: Redis;
let ipSeq = 1;

type Res = { statusCode: number; json: () => any }; // eslint-disable-line @typescript-eslint/no-explicit-any

/** `xff` is the X-Forwarded-For header exactly as Caddy forwards it (client part + appended proxy hops). */
async function call(method: string, url: string, opts: { body?: unknown; xff?: string; key?: string } = {}): Promise<Res> {
  const headers: Record<string, string> = { "x-forwarded-for": opts.xff ?? `203.0.113.${(++ipSeq % 250) + 1}` };
  if (method !== "GET") headers["idempotency-key"] = opts.key ?? randomUUID();
  const res = await app.getHttpAdapter().getInstance().inject({
    method: method as "GET",
    url,
    headers,
    ...(opts.body !== undefined ? { payload: opts.body as object } : {}),
  });
  return { statusCode: res.statusCode, json: () => res.json() };
}

async function lastCode(to: string): Promise<string> {
  const jobs = (await otpQueue.getJobs(["waiting", "delayed", "prioritized", "active"])).filter((j) => j.data.to === to);
  jobs.sort((a, b) => b.timestamp - a.timestamp);
  if (!jobs[0]) throw new Error(`no email.otp job for ${to}`);
  return jobs[0].data.code as string;
}

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

/** A 6-digit code that is none of `avoid`. */
function wrongCode(seed: number, avoid: string[]): string {
  let n = seed;
  for (;;) {
    const c = String(n % 1_000_000).padStart(6, "0");
    if (!avoid.includes(c)) return c;
    n += 7919;
  }
}

async function deskChallenge(email: string): Promise<string> {
  expect((await call("POST", "/v1/auth/otp/request", { body: { email } })).statusCode).toBe(200);
  const res = await call("POST", "/v1/auth/otp/verify", {
    body: { email, code: await lastCode(email), deviceId: randomUUID(), platform: "web", client: "desk" },
  });
  expect(res.statusCode).toBe(200);
  return res.json().challengeToken as string;
}

async function opsUser(email: string): Promise<void> {
  const u = await prisma.user.create({ data: { email } });
  await prisma.roleAssignment.create({ data: { userId: u.id, role: "OPS", grantedBy: u.id } });
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
  redis = new Redis(valkey.url);
});

// Each finding is tested in isolation: fresh rate-limit counters, so one test's traffic can't 429 the next.
beforeEach(async () => {
  const keys = await redis.keys("rl:*");
  if (keys.length) await redis.del(...keys);
});

afterAll(async () => {
  redis?.disconnect();
  await otpQueue?.close();
  await app?.close();
  await prisma?.$disconnect();
  await Promise.all([pg?.stop(), valkey?.stop()]);
});

describe("security review BOLT-0006 (open findings; it.fails = still vulnerable)", () => {
  // SEC-H1: Fastify trustProxy:true takes the LEFT-MOST X-Forwarded-For entry, which the client controls
  // (Cloudflare and Caddy both append to it, neither strips it). One real client = unlimited "IPs".
  it("SEC-H1: the 10 OTP requests / IP / hour limit holds when the client prepends a fake X-Forwarded-For", async () => {
    const realClient = "198.51.100.77";
    const cloudflareEdge = "162.158.1.1";
    const statuses: number[] = [];
    for (let i = 0; i < 12; i++) {
      const xff = `10.66.${i}.1, ${cloudflareEdge}, ${realClient}`; // client-spoofed entries, then the hop Caddy appends
      statuses.push((await call("POST", "/v1/auth/otp/request", { body: { email: `xff${i}@example.com` }, xff })).statusCode);
    }
    expect(statuses.slice(10)).toEqual([429, 429]);
  });

  // SEC-H2: Desk TOTP verify has no per-user / per-challenge failure counter; only 20/IP/hour (spoofable, SEC-H1).
  // Fixed in BOLT-0007: single-use challenge (jti), per-user lock after 5 wrong codes (TOTP_LOCKED, 429).
  it("SEC-H2: Desk TOTP verify locks after repeated wrong codes on one challenge", async () => {
    const email = "ops-bruteforce@heymey.app";
    await opsUser(email);
    const first = await deskChallenge(email);
    const { secret } = (await call("POST", "/v1/auth/desk/totp/enroll", { body: { challengeToken: first } })).json();
    expect((await call("POST", "/v1/auth/desk/totp/verify", { body: { challengeToken: first, code: totp(secret) } })).statusCode).toBe(200);

    // Attacker controls the mailbox (email OTP) but not the phone: one challenge, many guesses from many "IPs".
    const challengeToken = await deskChallenge(email);
    const now = Date.now();
    const valid = [-30_000, 0, 30_000, 60_000].map((d) => totp(secret, now + d));
    for (let i = 0; i < 40; i++) {
      const r = await call("POST", "/v1/auth/desk/totp/verify", { body: { challengeToken, code: wrongCode(i * 104_729, valid) } });
      expect(r.statusCode).not.toBe(200);
      // The first wrong code burns the challenge (BOLT-0007): every later guess on it is never even evaluated.
      expect(r.json().error.code).toBe(i === 0 ? "TOTP_INVALID" : "CHALLENGE_EXPIRED");
    }
    // The 41st guess is right (stands in for a successful brute force): it must NOT open a Desk session.
    const hit = await call("POST", "/v1/auth/desk/totp/verify", { body: { challengeToken, code: totp(secret, Date.now() + 30_000) } });
    expect(hit.statusCode).not.toBe(200);
  });

  it("SEC-H2: 5 wrong codes on fresh challenges lock the user's TOTP (429 TOTP_LOCKED), even for the right code", async () => {
    const email = "ops-lockout@heymey.app";
    await opsUser(email);
    const fresh = async () => {
      for (const k of await redis.keys("otp:email:*")) await redis.del(k); // the attacker owns the mailbox; skip the 3/10 min mail limit
      return deskChallenge(email);
    };
    const first = await fresh();
    const { secret } = (await call("POST", "/v1/auth/desk/totp/enroll", { body: { challengeToken: first } })).json();
    expect((await call("POST", "/v1/auth/desk/totp/verify", { body: { challengeToken: first, code: totp(secret) } })).statusCode).toBe(200);
    const valid = [-30_000, 0, 30_000, 60_000].map((d) => totp(secret, Date.now() + d));
    const codes: string[] = [];
    for (let i = 0; i < 5; i++) {
      const r = await call("POST", "/v1/auth/desk/totp/verify", { body: { challengeToken: await fresh(), code: wrongCode(7 + i * 13, valid) } });
      codes.push(r.json().error.code);
    }
    expect(codes).toEqual(["TOTP_INVALID", "TOTP_INVALID", "TOTP_INVALID", "TOTP_INVALID", "TOTP_LOCKED"]);
    const right = await call("POST", "/v1/auth/desk/totp/verify", { body: { challengeToken: await fresh(), code: totp(secret, Date.now() + 30_000) } });
    expect(right.statusCode).toBe(429);
    expect(right.json().error.code).toBe("TOTP_LOCKED");
  });

  // SEC-M1: the attempt counter is read BEFORE the slow argon2 compare and incremented after it, with no atomic
  // "reserve an attempt" step, so concurrent guesses on one code are all evaluated.
  // Fixed in BOLT-0007: atomic attempt reservation (UPDATE ... RETURNING) before the argon2 compare.
  it("SEC-M1: at most 5 guesses are evaluated per OTP code, even when sent concurrently", async () => {
    const email = "race@example.com";
    expect((await call("POST", "/v1/auth/otp/request", { body: { email } })).statusCode).toBe(200);
    const real = await lastCode(email);
    await Promise.all(
      Array.from({ length: 25 }, (_, i) =>
        call("POST", "/v1/auth/otp/verify", {
          body: { email, code: wrongCode(100_000 + i, [real]), deviceId: randomUUID(), platform: "android" },
        }),
      ),
    );
    const row = await prisma.otpCode.findFirst({ where: { email }, orderBy: { createdAt: "desc" } });
    expect(row!.attempts).toBeLessThanOrEqual(5);
  });

  // SEC-M2: the idempotency store keeps whole response bodies for 24 h in plaintext (Valkey, no auth), including
  // the Desk TOTP seed from /enroll and the refresh token from /otp/verify and /refresh.
  it("SEC-M2: no TOTP seed is stored in plaintext in the idempotency store", async () => {
    const email = "ops-idem@heymey.app";
    await opsUser(email);
    const challengeToken = await deskChallenge(email);
    const { secret } = (await call("POST", "/v1/auth/desk/totp/enroll", { body: { challengeToken } })).json();
    await new Promise((r) => setTimeout(r, 200)); // store.complete() is fire-and-forget
    const keys = await redis.keys("idem:*");
    const values = await Promise.all(keys.map((k) => redis.get(k)));
    expect(values.some((v) => v?.includes(secret as string))).toBe(false);
  });
});
