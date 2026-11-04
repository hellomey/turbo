// BOLT-0011: Exam Hall + exam structure over HTTP with a REAL session on REAL Postgres + Valkey (Testcontainers, §44).
// Blueprint §9.9, §9.10, §10.6, §19.4 Q36-Q38, §34.3 (Idempotency-Key), §37 (error envelope). INT-002 S10, S11.
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, beforeEach, describe, expect, it } from "vitest";
import type { NestFastifyApplication } from "@nestjs/platform-fastify";
import { Queue } from "bullmq";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { startPostgres, startValkey, type StartedDb } from "@heymey/testing";
import { seeder as catalog } from "../../../../packages/db/prisma/seed/catalog.js";
import { seeder as examHallSeed } from "../../../../packages/db/prisma/seed/exam-hall.js";
import { createApiApp } from "../../src/bootstrap.js";
import { setTestEnv } from "../support/env.js";

let pg: StartedDb;
let valkey: StartedDb;
let app: NestFastifyApplication;
let prisma: PrismaClient;
let otpQueue: Queue;
let clientIp = "198.51.101.1";
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
  [pg, valkey] = await Promise.all([startPostgres(), startValkey()]);
  prisma = createPrismaClient(pg.url);
  await catalog.run(prisma);
  await examHallSeed.run(prisma);
  setTestEnv({ DATABASE_URL: pg.url, VALKEY_URL: valkey.url });
  app = await createApiApp({ logger: false });
  await app.init();
  await app.getHttpAdapter().getInstance().ready();
  const url = new URL(valkey.url);
  otpQueue = new Queue("email.otp", { connection: { host: url.hostname, port: Number(url.port), maxRetriesPerRequest: null } });
});

afterAll(async () => {
  await otpQueue?.close();
  await app?.close();
  await prisma?.$disconnect();
  await Promise.all([pg?.stop(), valkey?.stop()]);
});

beforeEach(() => {
  clientIp = `198.51.101.${++ipSeq}`;
});

describe("exam structure over HTTP (public)", () => {
  it("200 with SEED (unverified) scheme; 404 EXAM_NOT_FOUND; 400 bad code", async () => {
    const ok = await call("GET", "/v1/exams/tnpsc-group-4/structure");
    expect(ok.statusCode).toBe(200);
    expect(ok.json()).toMatchObject({ examCode: "tnpsc-group-4", family: { code: "tnpsc" }, disclaimer: "Always confirm with the official notification." });
    expect(ok.json().stages[0].papers[0].scheme.verified).toBe(false);
    const missing = await call("GET", "/v1/exams/no-such-exam/structure");
    expect(missing.statusCode).toBe(404);
    expect(missing.json().error.code).toBe("EXAM_NOT_FOUND");
    expect((await call("GET", "/v1/exams/BAD_CODE/structure")).statusCode).toBe(400);
  });
});

describe("Exam Hall over HTTP", () => {
  it("full flow: list, start (idempotent), resume, save, submit, report, history; owner only", async () => {
    expect((await call("GET", "/v1/mocks?examCode=tnpsc-group-4")).statusCode).toBe(401);
    const token = await signIn("hall-a@example.com");
    const list = await call("GET", "/v1/mocks?examCode=tnpsc-group-4", { token });
    expect(list.statusCode).toBe(200);
    expect(list.json().allowance).toMatchObject({ freeFullMocksUsed: 0, freeFullMocksLimit: 1 });
    const mockId = list.json().items[0].id as string;

    expect((await call("POST", `/v1/mocks/${mockId}/attempts`, { token, body: { mode: "omr" }, key: null })).statusCode).toBe(400);
    const key = randomUUID();
    const start = await call("POST", `/v1/mocks/${mockId}/attempts`, { token, body: { mode: "omr" }, key });
    expect(start.statusCode).toBe(201);
    const attempt = start.json();
    expect(attempt.questions).toHaveLength(10);
    expect(JSON.stringify(attempt)).not.toContain("correctOptionIds");
    const replay = await call("POST", `/v1/mocks/${mockId}/attempts`, { token, body: { mode: "omr" }, key });
    expect(replay.json().attemptId).toBe(attempt.attemptId);
    const resume = await call("POST", `/v1/mocks/${mockId}/attempts`, { token, body: { mode: "omr" } });
    expect(resume.json().attemptId).toBe(attempt.attemptId);
    expect((await call("POST", `/v1/mocks/${randomUUID()}/attempts`, { token, body: { mode: "omr" } })).json().error.code).toBe("MOCK_NOT_FOUND");

    const get = await call("GET", `/v1/mock-attempts/${attempt.attemptId}`, { token });
    expect(get.statusCode).toBe(200);
    expect(get.json().status).toBe("in_progress");

    const q = attempt.questions.map((x: { id: string }) => x.id) as string[];
    const save = await call("PUT", `/v1/mock-attempts/${attempt.attemptId}/answers`, {
      token,
      body: { answers: [{ questionId: q[0], chosenOptionIds: ["A"], markedForReview: false, clientAt: new Date().toISOString() }, { questionId: q[1], chosenOptionIds: ["B"], markedForReview: true, clientAt: new Date().toISOString() }] },
    });
    expect(save.statusCode).toBe(200);
    expect(save.json()).toMatchObject({ saved: 2, ignoredAfterDeadline: 0 });
    expect((await call("PUT", `/v1/mock-attempts/${attempt.attemptId}/answers`, { token, body: { answers: [] } })).statusCode).toBe(400);

    const notYet = await call("GET", `/v1/mock-attempts/${attempt.attemptId}/report`, { token });
    expect(notYet.statusCode).toBe(404);

    const other = await signIn("hall-b@example.com");
    expect((await call("GET", `/v1/mock-attempts/${attempt.attemptId}`, { token: other })).statusCode).toBe(404);
    expect((await call("POST", `/v1/mock-attempts/${attempt.attemptId}/submit`, { token: other })).statusCode).toBe(404);
    expect((await call("GET", `/v1/mock-attempts/${randomUUID()}`, { token })).statusCode).toBe(404);

    const submit = await call("POST", `/v1/mock-attempts/${attempt.attemptId}/submit`, { token });
    expect(submit.statusCode).toBe(200);
    expect(submit.json()).toMatchObject({ correct: 1, wrong: 1, unanswered: 8, scoreDisplay: "1.00", fullReportLocked: true, ranked: false });
    const again = await call("POST", `/v1/mock-attempts/${attempt.attemptId}/submit`, { token });
    expect(again.json()).toEqual(submit.json());
    expect((await call("GET", `/v1/mock-attempts/${attempt.attemptId}/report`, { token })).json()).toEqual(submit.json());
    const late = await call("PUT", `/v1/mock-attempts/${attempt.attemptId}/answers`, {
      token,
      body: { answers: [{ questionId: q[2], chosenOptionIds: ["A"], markedForReview: false, clientAt: new Date().toISOString() }] },
    });
    expect(late.statusCode).toBe(409);
    expect(late.json().error.code).toBe("MOCK_ALREADY_SUBMITTED");

    const hist = await call("GET", "/v1/me/mock-attempts?limit=5", { token });
    expect(hist.statusCode).toBe(200);
    expect(hist.json()).toMatchObject({ items: [{ attemptId: attempt.attemptId, status: "submitted", scoreDisplay: "1.00" }], nextCursor: null });

    // The free full mock for this IST month is used: another full mock is refused with 409.
    const g2 = (await call("GET", "/v1/mocks?examCode=tnpsc-group-2", { token })).json().items[0].id as string;
    const limit = await call("POST", `/v1/mocks/${g2}/attempts`, { token, body: { mode: "omr" } });
    expect(limit.statusCode).toBe(409);
    expect(limit.json().error.code).toBe("MOCK_MONTHLY_LIMIT");
  });

  it("State Mock Sunday info is public; statewide rank 409 before publish", async () => {
    const info = await call("GET", "/v1/state-mock-sunday?examCode=tnpsc-group-4");
    expect(info.statusCode).toBe(200);
    expect(info.json()).toMatchObject({ mock: null, rankPublishAt: null });
    expect(info.json().nextSunday).toMatch(/^\d{4}-\d{2}-\d{2}$/);
    expect((await call("GET", "/v1/state-mock-sunday")).statusCode).toBe(400);

    const token = await signIn("hall-c@example.com");
    const mockId = (await call("GET", "/v1/mocks?examCode=tnpsc-group-4", { token })).json().items[0].id as string;
    const rank = await call("GET", `/v1/mocks/${mockId}/statewide-rank`, { token });
    expect(rank.statusCode).toBe(409);
    expect(rank.json().error.code).toBe("RANK_NOT_READY");
  });
});
