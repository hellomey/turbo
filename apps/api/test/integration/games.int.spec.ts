// BOLT-0115: Daily Spin, Confidence Duel and Game Rules & Odds over HTTP with a REAL session on REAL Postgres
// (Testcontainers, §44). Uses the system clock: between 12 AM and 5 AM IST the play routes must answer GAMES_SLEEPING.
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, beforeEach, describe, expect, it } from "vitest";
import type { NestFastifyApplication } from "@nestjs/platform-fastify";
import { captureMailQueue } from "../support/mail.js";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { gamesAreSleeping } from "@heymey/domain/modules/games";
import { startPostgres, type StartedDb } from "@heymey/testing";
import { seeder } from "../../../../packages/db/prisma/seed/catalog.js";
import { createApiApp } from "../../src/bootstrap.js";
import { setTestEnv } from "../support/env.js";

let pg: StartedDb;
let app: NestFastifyApplication;
let prisma: PrismaClient;
let otpQueue: ReturnType<typeof captureMailQueue>;
let clientIp = "203.0.115.1";
let ipSeq = 1;
const EXAM = "tnpsc-group-4";
const PREAMBLE = "0199f5a0-0101-7000-8000-000000000101";

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

async function seedQuestions() {
  for (let i = 0; i < 8; i++) {
    const q = await prisma.question.create({ data: { topicId: PREAMBLE, status: "published", difficulty: 3 } });
    await prisma.questionVersion.create({
      data: {
        questionId: q.id, version: 1, stem: `SEED duel Q${i}`,
        options: [{ id: "a", text: "A" }, { id: "b", text: "B" }],
        correctOptionIds: ["a"], explanationMarkdown: "Because.", whyWrong: {}, status: "published",
      },
    });
  }
}

const pointsOf = async (token: string) => (await call("GET", "/v1/me/progress", { token })).json().points as number;

beforeAll(async () => {
  pg = await startPostgres();
  prisma = createPrismaClient(pg.url);
  await seeder.run(prisma);
  await seedQuestions();
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
  clientIp = `203.0.115.${++ipSeq}`;
});

describe("games over HTTP (BOLT-0115)", () => {
  it("Game Rules & Odds are public; play routes need a session", async () => {
    const rules = await call("GET", "/v1/games/rules");
    expect(rules.statusCode).toBe(200);
    expect(rules.json()).toMatchObject({ stake: "none", prizeCurrencies: ["POINTS"], dailySpin: { spinsPerDay: 1 }, confidenceDuel: { dailyPointsCap: 50 } });
    for (const [m, u] of [
      ["GET", "/v1/games/daily-spin"],
      ["POST", "/v1/games/daily-spin"],
      ["GET", `/v1/games/confidence-duel?examCode=${EXAM}`],
      ["POST", `/v1/games/confidence-duel/${randomUUID()}/submit`],
    ] as const) {
      expect((await call(m, u, { body: m === "POST" ? { answers: [] } : undefined })).statusCode, `${m} ${u}`).toBe(401);
    }
  });

  it("Daily Spin: odds shown before spinning match the result's odds; one spin a day; Points credited once", async () => {
    const token = await signIn(`spin-${randomUUID()}@example.org`);
    const state = (await call("GET", "/v1/games/daily-spin", { token })).json();
    expect(state).toMatchObject({ spunToday: false, todaysPrize: null, oddsVersion: 1 });
    expect(state.prizes.reduce((s: number, p: { percent: number }) => s + p.percent, 0)).toBe(100);
    if (gamesAreSleeping(new Date())) {
      const r = await call("POST", "/v1/games/daily-spin", { token });
      expect([r.statusCode, r.json().error.code]).toEqual([409, "GAMES_SLEEPING"]);
      return;
    }
    const key = randomUUID();
    const first = await call("POST", "/v1/games/daily-spin", { token, key });
    expect(first.statusCode).toBe(200);
    const prize = first.json().prize;
    expect(first.json()).toMatchObject({ alreadySpun: false, odds: state.prizes });
    // Same key: the stored response. New key, same day: the same prize, nothing credited again.
    expect((await call("POST", "/v1/games/daily-spin", { token, key })).json()).toEqual(first.json());
    expect((await call("POST", "/v1/games/daily-spin", { token })).json()).toMatchObject({ alreadySpun: true, prize });
    expect(await pointsOf(token)).toBe(prize.amount);
    expect(await prisma.dailySpin.count()).toBeGreaterThanOrEqual(1);
    expect((await call("GET", "/v1/games/daily-spin", { token })).json()).toMatchObject({ spunToday: true, todaysPrize: prize });
  });

  it("Confidence Duel: questions without answers; server grades; too-fast answers earn nothing; replays are refused", async () => {
    const token = await signIn(`duel-${randomUUID()}@example.org`);
    if (gamesAreSleeping(new Date())) {
      expect((await call("GET", `/v1/games/confidence-duel?examCode=${EXAM}`, { token })).json().error.code).toBe("GAMES_SLEEPING");
      return;
    }
    const start = await call("GET", `/v1/games/confidence-duel?examCode=${EXAM}`, { token });
    expect(start.statusCode).toBe(200);
    const duel = start.json();
    expect(duel.questions).toHaveLength(5);
    expect(JSON.stringify(duel.questions)).not.toMatch(/correctOptionIds|explanation/);

    const answers = duel.questions.map((q: { id: string }) => ({ questionId: q.id, optionId: "a", confidence: 3 }));
    // A stake smuggled into the body is a validation error, not ignored.
    expect((await call("POST", `/v1/games/confidence-duel/${duel.duelId}/submit`, { token, body: { answers, stake: 10 } })).statusCode).toBe(400);

    const key = randomUUID();
    const res = await call("POST", `/v1/games/confidence-duel/${duel.duelId}/submit`, { token, key, body: { answers } });
    expect(res.statusCode).toBe(200);
    // Submitted well under 10 s after start: graded, Points withheld.
    expect(res.json()).toMatchObject({ score: 25, pointsAwarded: 0, pointsWithheld: "too_fast" });
    expect(res.json().results[0]).toMatchObject({ correct: true, correctOptionIds: ["a"], explanationMarkdown: "Because." });
    expect(await pointsOf(token)).toBe(0);

    expect((await call("POST", `/v1/games/confidence-duel/${duel.duelId}/submit`, { token, key, body: { answers } })).json()).toEqual(res.json());
    const replay = await call("POST", `/v1/games/confidence-duel/${duel.duelId}/submit`, { token, body: { answers } });
    expect([replay.statusCode, replay.json().error.code]).toEqual([409, "DUEL_ALREADY_SUBMITTED"]);

    // A malformed duel id is a validation error, not a server error.
    expect((await call("POST", "/v1/games/confidence-duel/not-a-uuid/submit", { token, body: { answers } })).statusCode).toBe(400);

    // Someone else cannot submit my duel.
    const other = await signIn(`duel-other-${randomUUID()}@example.org`);
    const stolen = await call("POST", `/v1/games/confidence-duel/${duel.duelId}/submit`, { token: other, body: { answers } });
    expect([stolen.statusCode, stolen.json().error.code]).toEqual([404, "DUEL_NOT_FOUND"]);
  });

  it("Confidence Duel: an exam with no questions says so", async () => {
    const token = await signIn(`duel-empty-${randomUUID()}@example.org`);
    if (gamesAreSleeping(new Date())) return;
    const r = await call("GET", "/v1/games/confidence-duel?examCode=no-such-exam", { token });
    expect(r.statusCode).toBe(404);
  });
});
