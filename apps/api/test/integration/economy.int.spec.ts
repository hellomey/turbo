// BOLT-0113: progress, check-in, leaderboard opt-in over HTTP with a REAL session on REAL Postgres (Testcontainers, §44).
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, beforeEach, describe, expect, it } from "vitest";
import type { NestFastifyApplication } from "@nestjs/platform-fastify";
import { captureMailQueue } from "../support/mail.js";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { startPostgres, type StartedDb } from "@heymey/testing";
import { seeder } from "../../../../packages/db/prisma/seed/catalog.js";
import { createApiApp } from "../../src/bootstrap.js";
import { setTestEnv } from "../support/env.js";

let pg: StartedDb;
let app: NestFastifyApplication;
let prisma: PrismaClient;
let otpQueue: ReturnType<typeof captureMailQueue>;
let clientIp = "203.0.113.1";
let ipSeq = 1;

type Res = { statusCode: number; json: () => any }; // eslint-disable-line @typescript-eslint/no-explicit-any

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
  return { statusCode: res.statusCode, json: () => res.json() };
}

async function signIn(email: string): Promise<string> {
  expect((await call("POST", "/v1/auth/otp/request", { body: { email } })).statusCode).toBe(200);
  const jobs = (await otpQueue.getJobs(["waiting", "delayed", "prioritized", "active"])).filter((j) => j.data.to === email);
  jobs.sort((a, b) => b.timestamp - a.timestamp);
  const code = jobs[0]?.data.code as string;
  const res = await call("POST", "/v1/auth/otp/verify", { body: { email, code, deviceId: randomUUID(), platform: "android" } });
  expect(res.statusCode).toBe(200);
  return res.json().tokens.accessToken as string;
}

beforeAll(async () => {
  pg = await startPostgres();
  prisma = createPrismaClient(pg.url);
  await seeder.run(prisma);
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
  clientIp = `203.0.113.${++ipSeq}`;
});

describe("economy over HTTP (BOLT-0113)", () => {
  it("every economy route needs a session (401)", async () => {
    for (const [m, u] of [
      ["GET", "/v1/me/progress"],
      ["POST", "/v1/me/check-in"],
      ["GET", "/v1/leaderboard/weekly"],
      ["PUT", "/v1/me/leaderboard-opt-in"],
    ] as const) {
      expect((await call(m, u, { body: m === "PUT" ? { optIn: true } : undefined })).statusCode, `${m} ${u}`).toBe(401);
    }
  });

  it("check-in once per day; a replayed Idempotency-Key returns the same answer; Points never double", async () => {
    const token = await signIn(`econ-${randomUUID()}@example.org`);
    const key = randomUUID();
    const first = await call("POST", "/v1/me/check-in", { token, key });
    expect(first.statusCode).toBe(200);
    expect(first.json()).toEqual({ awarded: { xp: 5, points: 10 }, alreadyCheckedIn: false });
    expect((await call("POST", "/v1/me/check-in", { token, key })).json()).toEqual(first.json());
    expect((await call("POST", "/v1/me/check-in", { token })).json()).toEqual({ awarded: { xp: 0, points: 0 }, alreadyCheckedIn: true });
    expect((await call("POST", "/v1/me/check-in", { token, key: null })).statusCode).toBe(400);
    const p = (await call("GET", "/v1/me/progress", { token })).json();
    expect(p).toMatchObject({ xp: 5, level: 1, nextLevelXp: 100, points: 10, checkedInToday: true, trophies: [] });
  });

  it("finishing a lesson online earns XP through the mastery event", async () => {
    const token = await signIn(`econ-${randomUUID()}@example.org`);
    const tag = await prisma.topicExamTag.findFirstOrThrow({ where: { examCode: "tnpsc-group-4" } });
    expect((await call("POST", `/v1/topics/${tag.topicId}/lesson-complete`, { token, body: { via: "lesson" } })).statusCode).toBe(200);
    expect((await call("POST", `/v1/topics/${tag.topicId}/lesson-complete`, { token, body: { via: "lesson" } })).statusCode).toBe(200);
    expect((await call("GET", "/v1/me/progress", { token })).json().xp).toBe(10);
  });

  it("leaderboard is opt-in; named opted-in users appear; guests cannot join", async () => {
    const token = await signIn(`econ-${randomUUID()}@example.org`);
    expect((await call("PATCH", "/v1/me", { token, body: { nickname: "Kavi" } })).statusCode).toBe(200);
    await call("POST", "/v1/me/check-in", { token });
    expect((await call("GET", "/v1/leaderboard/weekly", { token })).json()).toMatchObject({ optedIn: false });
    const opt = await call("PUT", "/v1/me/leaderboard-opt-in", { token, body: { optIn: true } });
    expect(opt.json()).toEqual({ optIn: true, listed: true });
    const board = (await call("GET", "/v1/leaderboard/weekly", { token })).json();
    expect(board.optedIn).toBe(true);
    expect(board.entries).toContainEqual({ rank: expect.any(Number), displayName: "Kavi", xp: 5, isMe: true });
    expect((await call("PUT", "/v1/me/leaderboard-opt-in", { token, body: { optIn: true, extra: 1 } })).statusCode).toBe(400);

    const guest = await call("POST", "/v1/auth/guest", { body: { deviceId: randomUUID(), platform: "web", ageConfirmed18: true } });
    const gt = guest.json().accessToken as string;
    const denied = await call("PUT", "/v1/me/leaderboard-opt-in", { token: gt, body: { optIn: true } });
    expect(denied.statusCode).toBe(403);
    expect(denied.json().error.code).toBe("GUEST_NOT_ALLOWED");
  });
});
