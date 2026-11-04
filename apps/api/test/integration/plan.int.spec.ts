// BOLT-0012: plan + Today routes over HTTP with a REAL session on REAL Postgres + Valkey (Testcontainers, blueprint §44).
// §10.6 Today, §17.1 step 9, §17.3, §19.2, §34.3 Idempotency-Key, §37 error envelope, §39 offline sync. INT-002 S12, S13, R2.
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, beforeEach, describe, expect, it } from "vitest";
import type { NestFastifyApplication } from "@nestjs/platform-fastify";
import { Queue } from "bullmq";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { startPostgres, startValkey, type StartedDb } from "@heymey/testing";
import { seeder } from "../../../../packages/db/prisma/seed/catalog.js";
import { createApiApp } from "../../src/bootstrap.js";
import { setTestEnv } from "../support/env.js";

let pg: StartedDb;
let valkey: StartedDb;
let app: NestFastifyApplication;
let prisma: PrismaClient;
let otpQueue: Queue;
let clientIp = "203.0.113.1";
let ipSeq = 1;
const MAIN = "tnpsc-group-4";

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
  await seeder.run(prisma);
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
  clientIp = `203.0.113.${++ipSeq}`;
});

describe("plan over HTTP (BOLT-0012)", () => {
  it("every plan route needs a session (401)", async () => {
    for (const [m, u] of [
      ["GET", "/v1/me/today"],
      ["GET", "/v1/me/plan"],
      ["PUT", "/v1/me/plan"],
      ["GET", "/v1/me/plan/days?from=2026-11-02&to=2026-11-03"],
      ["POST", `/v1/me/plan/items/${randomUUID()}/status`],
      ["POST", "/v1/me/plan/rebalance"],
    ] as const) {
      const r = await call(m, u, { body: m === "GET" ? undefined : {} });
      expect(r.statusCode, `${m} ${u}`).toBe(401);
    }
  });

  it("no plan: Today hasPlan=false; plan routes 404 PLAN_NOT_FOUND; PUT without an exam is 400", async () => {
    const token = await signIn("plan-a@example.com");
    const t = await call("GET", "/v1/me/today", { token });
    expect(t.statusCode).toBe(200);
    expect(t.json()).toMatchObject({ hasPlan: false, todayCard: null, stretch: "normal", welcomeBack: null, pocketSessions: [5, 10, 15] });
    for (const u of ["/v1/me/plan", "/v1/me/plan/days?from=2026-11-02&to=2026-11-03"]) {
      const r = await call("GET", u, { token });
      expect(r.statusCode, u).toBe(404);
      expect(r.json().error.code).toBe("PLAN_NOT_FOUND");
    }
    expect((await call("POST", "/v1/me/plan/rebalance", { token })).statusCode).toBe(404);
    const put = await call("PUT", "/v1/me/plan", { token, body: { weekdayMinutes: 60, weekendMinutes: 120 } });
    expect(put.statusCode).toBe(400);
    expect(put.json().error.code).toBe("VALIDATION_FAILED");
  });

  it("PUT /v1/me/exams attemptCycles -> PUT plan -> days -> Today card -> done (idempotent) -> rebalance", async () => {
    const token = await signIn("plan-b@example.com");
    const exam = await prisma.exam.findUniqueOrThrow({ where: { code: MAIN } });
    const cycle = await prisma.examAttemptCycle.create({
      data: { examId: exam.id, code: "http-2027", name: "Test sitting", status: "announced", stageDates: [{ stageCode: "written", date: "2099-06-01", dateStatus: "official" }], sourceUrl: "https://example.org" },
    });
    const bad = await call("PUT", "/v1/me/exams", { token, body: { mainExamCode: MAIN, attemptCycles: { [MAIN]: randomUUID() } } });
    expect(bad.statusCode).toBe(400);
    const ok = await call("PUT", "/v1/me/exams", { token, body: { mainExamCode: MAIN, attemptCycles: { [MAIN]: cycle.id } } });
    expect(ok.statusCode).toBe(200);

    // contract validation
    expect((await call("PUT", "/v1/me/plan", { token, body: { weekdayMinutes: 5, weekendMinutes: 60 } })).statusCode).toBe(400);
    expect((await call("PUT", "/v1/me/plan", { token, body: { weekdayMinutes: 60, weekendMinutes: 60 }, key: null })).statusCode).toBe(400);

    const key = randomUUID();
    const put = await call("PUT", "/v1/me/plan", { token, key, body: { weekdayMinutes: 60, weekendMinutes: 120, balance: 1 } });
    expect(put.statusCode).toBe(200);
    const plan = put.json();
    expect(plan.exams[0]).toMatchObject({ examCode: MAIN, attemptCycleId: cycle.id, examDate: "2099-06-01", priority: 1 });
    expect(plan.balance).toBe(1);
    const replay = await call("PUT", "/v1/me/plan", { token, key, body: { weekdayMinutes: 60, weekendMinutes: 120, balance: 1 } });
    expect(replay.json()).toEqual(plan);
    expect((await call("GET", "/v1/me/plan", { token })).json()).toEqual(plan);

    const today = await call("GET", "/v1/me/today", { token });
    expect(today.statusCode).toBe(200);
    const t = today.json();
    expect(t.hasPlan).toBe(true);
    expect(t.todayCard).not.toBeNull();
    expect(t.rank).toBeDefined();
    const from = t.day as string;

    const days = await call("GET", `/v1/me/plan/days?from=${from}&to=${from}`, { token });
    expect(days.statusCode).toBe(200);
    expect(days.json().days[0].items[0].id).toBe(t.todayCard.id);
    expect((await call("GET", `/v1/me/plan/days?from=${from}`, { token })).statusCode).toBe(400);

    const k2 = randomUUID();
    const done = await call("POST", `/v1/me/plan/items/${t.todayCard.id}/status`, { token, key: k2, body: { status: "done" } });
    expect(done.statusCode).toBe(200);
    expect(done.json().status).toBe("done");
    const again = await call("POST", `/v1/me/plan/items/${t.todayCard.id}/status`, { token, key: k2, body: { status: "done" } });
    expect(again.json()).toEqual(done.json());
    expect(await prisma.studyLog.count({ where: { details: { path: ["planItemId"], equals: t.todayCard.id } } })).toBe(1);
    expect((await call("POST", `/v1/me/plan/items/${t.todayCard.id}/status`, { token, body: { status: "maybe" } })).statusCode).toBe(400);
    expect((await call("POST", `/v1/me/plan/items/not-a-uuid/status`, { token, body: { status: "done" } })).statusCode).toBe(400);

    // another user cannot touch my item
    const other = await signIn("plan-c@example.com");
    const nope = await call("POST", `/v1/me/plan/items/${t.todayCard.id}/status`, { token: other, body: { status: "skipped" } });
    expect(nope.statusCode).toBe(404);

    const reb = await call("POST", "/v1/me/plan/rebalance", { token });
    expect(reb.statusCode).toBe(200);
    expect(reb.json().lastRebalancedAt).not.toBeNull();
    expect((await prisma.planItem.findUniqueOrThrow({ where: { id: t.todayCard.id } })).status).toBe("done");
  });

  it("offline plan_item_status is applied once through /v1/sync/study-actions (no longer FEATURE_PAUSED)", async () => {
    const token = await signIn("plan-d@example.com");
    expect((await call("PUT", "/v1/me/exams", { token, body: { mainExamCode: MAIN } })).statusCode).toBe(200);
    expect((await call("PUT", "/v1/me/plan", { token, body: { weekdayMinutes: 60, weekendMinutes: 60 } })).statusCode).toBe(200);
    const card = (await call("GET", "/v1/me/today", { token })).json().todayCard;
    const action = { clientActionId: randomUUID(), clientAt: new Date().toISOString(), kind: "plan_item_status", itemId: card.id, status: "done" };
    const r = await call("POST", "/v1/sync/study-actions", { token, body: { deviceId: "device-123456", actions: [action] } });
    expect(r.statusCode).toBe(200);
    expect(r.json().results).toEqual([{ clientActionId: action.clientActionId, status: "accepted", errorCode: null }]);
    const dup = await call("POST", "/v1/sync/study-actions", { token, body: { deviceId: "device-123456", actions: [action] } });
    expect(dup.json().results[0].status).toBe("duplicate");
    expect((await prisma.planItem.findUniqueOrThrow({ where: { id: card.id } })).status).toBe("done");
  });
});
