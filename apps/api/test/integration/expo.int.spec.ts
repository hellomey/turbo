/* eslint-disable @typescript-eslint/no-non-null-assertion -- tests assert presence right after creating the row */
// BOLT-0112 stall: expo challenge, my sticker code and Desk redeem end to end on REAL Postgres (Testcontainers).
// Uses the real expo-challenge-1 set from content/questions via the aptitude-content seeder.
import { createHmac, randomUUID } from "node:crypto";
import { afterAll, beforeAll, beforeEach, describe, expect, it } from "vitest";
import type { NestFastifyApplication } from "@nestjs/platform-fastify";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { startPostgres, type StartedDb } from "@heymey/testing";
import { seeder as catalog } from "../../../../packages/db/prisma/seed/catalog.js";
import { seeder as content } from "../../../../packages/db/prisma/seed/aptitude-content.js";
import { createApiApp } from "../../src/bootstrap.js";
import { setTestEnv } from "../support/env.js";
import { captureMailQueue } from "../support/mail.js";

let pg: StartedDb;
let app: NestFastifyApplication;
let prisma: PrismaClient;
let otpQueue: ReturnType<typeof captureMailQueue>;
let clientIp = "198.51.100.1";
let ipSeq = 1;

type Res = { statusCode: number; json: () => any }; // eslint-disable-line @typescript-eslint/no-explicit-any

async function call(method: string, url: string, opts: { body?: unknown; token?: string; key?: string | null } = {}): Promise<Res> {
  const headers: Record<string, string> = { "x-forwarded-for": clientIp };
  if (opts.token) headers.authorization = `Bearer ${opts.token}`;
  if (opts.key !== null && method !== "GET") headers["idempotency-key"] = opts.key ?? randomUUID();
  const res = await app.getHttpAdapter().getInstance().inject({ method: method as "GET", url, headers, ...(opts.body !== undefined ? { payload: opts.body as object } : {}) });
  return { statusCode: res.statusCode, json: () => res.json() };
}

async function guest(): Promise<string> {
  const res = await call("POST", "/v1/auth/guest", { body: { deviceId: randomUUID(), platform: "web", ageConfirmed18: true } });
  expect(res.statusCode).toBe(200);
  return res.json().accessToken as string;
}

async function lastCode(to: string): Promise<string> {
  const jobs = (await otpQueue.getJobs(["waiting", "delayed", "prioritized", "active"])).filter((j) => j.data.to === to);
  jobs.sort((a, b) => b.timestamp - a.timestamp);
  if (!jobs[0]) throw new Error("no otp job");
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

async function deskSignIn(email: string, role: "OPS" | "SUPPORT_AGENT" | "REVIEWER"): Promise<string> {
  const user = await prisma.user.create({ data: { email } });
  await prisma.roleAssignment.create({ data: { userId: user.id, role, grantedBy: user.id } });
  await call("POST", "/v1/auth/otp/request", { body: { email } });
  const ch = await call("POST", "/v1/auth/otp/verify", { body: { email, code: await lastCode(email), deviceId: randomUUID(), platform: "web", client: "desk" } });
  const challengeToken = ch.json().challengeToken as string;
  const { secret } = (await call("POST", "/v1/auth/desk/totp/enroll", { body: { challengeToken } })).json();
  const ok = await call("POST", "/v1/auth/desk/totp/verify", { body: { challengeToken, code: totp(secret) } });
  expect(ok.statusCode).toBe(200);
  return ok.json().tokens.accessToken as string;
}

beforeAll(async () => {
  pg = await startPostgres();
  prisma = createPrismaClient(pg.url);
  await catalog.run(prisma);
  await content.run(prisma);
  setTestEnv({ DATABASE_URL: pg.url });
  app = await createApiApp({ logger: false });
  await app.init();
  await app.getHttpAdapter().getInstance().ready();
  otpQueue = captureMailQueue();
});

afterAll(async () => {
  await otpQueue?.close();
  await app?.close();
  await prisma?.$disconnect();
  await pg?.stop();
});

beforeEach(() => {
  clientIp = `198.51.100.${++ipSeq}`;
});

describe("expo challenge", () => {
  it("guest plays 10 questions without answers, submits once and gets a sticker code", async () => {
    const token = await guest();
    expect((await call("GET", "/v1/me/sticker-code", { token })).json()).toEqual({ code: null, redeemed: false });

    const c = await call("GET", "/v1/expo/challenge", { token });
    expect(c.statusCode).toBe(200);
    const body = c.json();
    expect(body.questions).toHaveLength(10);
    expect(body.secondsPerQuestion).toBe(20);
    expect(JSON.stringify(body)).not.toMatch(/correct|explanation/i);

    const answers = body.questions.map((q: { id: string; options: { id: string }[] }) => ({ questionId: q.id, optionId: q.options[0]!.id, ms: 5000 }));
    const url = `/v1/expo/challenge/${body.challengeId}/submit`;
    expect((await call("POST", url, { token, body: { answers }, key: null })).statusCode).toBe(400);
    const key = randomUUID();
    const r = await call("POST", url, { token, body: { answers }, key });
    expect(r.statusCode).toBe(200);
    expect(r.json().total).toBe(10);
    expect(r.json().results).toHaveLength(10);
    expect(r.json().stickerCode).toMatch(/^HM-[2-9A-HJ-NP-Z]{4}$/);
    // Replay with the same key returns the stored response; a new key is a second submit.
    expect((await call("POST", url, { token, body: { answers }, key })).json()).toEqual(r.json());
    expect((await call("POST", url, { token, body: { answers } })).json().error.code).toBe("EXPO_CHALLENGE_ALREADY_SUBMITTED");
    expect((await call("GET", "/v1/me/sticker-code", { token })).json()).toEqual({ code: r.json().stickerCode, redeemed: false });
    const meId = (await call("GET", "/v1/me", { token })).json().id as string;
    expect(await prisma.userTrophy.count({ where: { userId: meId, code: "expo_challenge" } })).toBe(1);

    const other = await guest();
    expect((await call("POST", url, { token: other, body: { answers } })).statusCode).toBe(404);
    expect((await call("GET", "/v1/expo/challenge")).statusCode).toBe(401);
  });

  it("a lit lamp earns a code without the challenge", async () => {
    const token = await guest();
    const me = (await call("GET", "/v1/me", { token })).json();
    await prisma.userTopicState.create({ data: { userId: me.id, topicId: "0199f5a0-0101-7000-8000-000000000101", litAt: new Date() } });
    expect((await call("GET", "/v1/me/sticker-code", { token })).json().code).toMatch(/^HM-[2-9A-HJ-NP-Z]{4}$/);
  });
});

describe("Desk redeem", () => {
  it("staff redeem once with an audit row; wrong role, unknown and reused codes are refused", async () => {
    const token = await guest();
    const c = (await call("GET", "/v1/expo/challenge", { token })).json();
    const code = (await call("POST", `/v1/expo/challenge/${c.challengeId}/submit`, { token, body: { answers: [] } })).json().stickerCode as string;

    const reviewer = await deskSignIn("reviewer-sticker@heymey.app", "REVIEWER");
    expect((await call("POST", "/v1/desk/sticker-codes/redeem", { token: reviewer, body: { code } })).statusCode).toBe(403);
    expect((await call("POST", "/v1/desk/sticker-codes/redeem", { token, body: { code } })).statusCode).toBe(401); // not a Desk session

    const staff = await deskSignIn("support-sticker@heymey.app", "SUPPORT_AGENT");
    const ok = await call("POST", "/v1/desk/sticker-codes/redeem", { token: staff, body: { code: ` ${code.toLowerCase()} ` } });
    expect(ok.statusCode).toBe(200);
    expect(ok.json()).toEqual({ redeemed: true, redeemedAt: expect.any(String) });
    expect(await prisma.auditLog.count({ where: { action: "sticker_code.redeem", target: `sticker_code:${code}` } })).toBe(1);
    expect((await call("GET", "/v1/me/sticker-code", { token })).json()).toEqual({ code, redeemed: true });

    const again = await call("POST", "/v1/desk/sticker-codes/redeem", { token: staff, body: { code } });
    expect(again.statusCode).toBe(409);
    expect(again.json().error.code).toBe("STICKER_CODE_ALREADY_REDEEMED");
    const unknown = await call("POST", "/v1/desk/sticker-codes/redeem", { token: staff, body: { code: "HM-ZZZZ" === code ? "HM-YYYY" : "HM-ZZZZ" } });
    expect(unknown.statusCode).toBe(404);
    expect(unknown.json().error.code).toBe("STICKER_CODE_NOT_FOUND");
  });
});
