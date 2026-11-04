// BOLT-0013: readiness routes over HTTP with a REAL session on REAL Postgres + Valkey (Testcontainers, blueprint §44).
// §19.5 Q41-Q50 four bars + label (never one overall percentage), §11 free vs Pro, §37 error envelope. INT-002 S14, S15.
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, beforeEach, describe, expect, it } from "vitest";
import type { NestFastifyApplication } from "@nestjs/platform-fastify";
import { Queue } from "bullmq";
import { ReadinessMeter, SundayReport, SundayReportPage } from "@heymey/contracts";
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
const PREAMBLE = "0199f5a0-0101-7000-8000-000000000101";

type Res = { statusCode: number; json: () => any }; // eslint-disable-line @typescript-eslint/no-explicit-any

async function call(method: string, url: string, opts: { body?: unknown; token?: string } = {}): Promise<Res> {
  const headers: Record<string, string> = { "x-forwarded-for": clientIp };
  if (opts.token) headers.authorization = `Bearer ${opts.token}`;
  if (method !== "GET") headers["idempotency-key"] = randomUUID();
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

const userIdOf = async (email: string) => (await prisma.user.findUniqueOrThrow({ where: { email } })).id;

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

describe("readiness over HTTP (BOLT-0013)", () => {
  it("every readiness route needs a session (401)", async () => {
    for (const u of ["/v1/me/readiness?examCode=tnpsc-group-4", "/v1/me/readiness/trend?examCode=tnpsc-group-4", "/v1/me/sunday-reports", `/v1/me/sunday-reports/${randomUUID()}`]) {
      expect((await call("GET", u)).statusCode, u).toBe(401);
    }
  });

  it("meter: free user sees Coverage + Memory, two locked bars, a label, never one overall percentage", async () => {
    const email = "readiness-a@example.com";
    const token = await signIn(email);
    expect((await call("PUT", "/v1/me/exams", { token, body: { mainExamCode: "tnpsc-group-4" } })).statusCode).toBe(200);
    const userId = await userIdOf(email);
    await prisma.userTopicState.create({ data: { userId, topicId: PREAMBLE, litAt: new Date(), steadyLevel: 1, nextDueAt: new Date(Date.now() + 86_400_000) } });

    const res = await call("GET", "/v1/me/readiness?examCode=tnpsc-group-4", { token });
    expect(res.statusCode).toBe(200);
    const m = ReadinessMeter.parse(res.json());
    expect(Object.keys(res.json()).sort()).toEqual(["bars", "computedAt", "coverage", "examCode", "label", "readyForFullMocks", "suggestion"]);
    expect(m.bars.map((b) => [b.key, b.locked])).toEqual([
      ["coverage", false],
      ["memory", false],
      ["exam_performance", true],
      ["speed", true],
    ]);
    expect(m.bars[0]?.value).toBeGreaterThan(0);
    expect(m.bars[1]?.value).toBe(100);
    expect(m.bars[2]?.value).toBeNull();
    expect(["not_yet", "building"]).toContain(m.label);
    expect(await prisma.readinessSnapshot.count({ where: { userId } })).toBe(1);

    // Trend is Pro (billing not built: everyone is free) -> 403 PRO_REQUIRED.
    const trend = await call("GET", "/v1/me/readiness/trend?examCode=tnpsc-group-4&days=7", { token });
    expect([trend.statusCode, trend.json().error.code]).toEqual([403, "PRO_REQUIRED"]);
    expect((await call("GET", "/v1/me/readiness/trend?examCode=tnpsc-group-4&days=8", { token })).statusCode).toBe(400);

    // Validation and unknown exam.
    expect((await call("GET", "/v1/me/readiness", { token })).statusCode).toBe(400);
    const unknown = await call("GET", "/v1/me/readiness?examCode=no-such-exam", { token });
    expect([unknown.statusCode, unknown.json().error.code]).toEqual([404, "EXAM_NOT_FOUND"]);
  });

  it("Sunday reports: owner lists and reads; another user gets 404; bad id 400", async () => {
    const email = "readiness-b@example.com";
    const token = await signIn(email);
    const userId = await userIdOf(email);
    expect((await call("GET", "/v1/me/sunday-reports", { token })).json()).toEqual({ items: [], nextCursor: null });
    const body = {
      lampsLit: 2, steadyEarned: 1, goldEarned: 0, relit: 0, dimmedNow: 0, questionsAnswered: 0, accuracyPct: null, mocksTaken: 0, studyMinutes: 0,
      lines: ["This week you lit 2 lamps and earned 1 Steady step.", "This report shows your study. It does not predict your result."],
      nextWeek: null,
    };
    const row = await prisma.sundayReport.create({ data: { userId, weekStart: "2026-11-02", tier: "short", body } });

    const list = await call("GET", "/v1/me/sunday-reports?limit=10", { token });
    expect(list.statusCode).toBe(200);
    expect(SundayReportPage.parse(list.json()).items.map((i) => i.id)).toEqual([row.id]);
    const one = await call("GET", `/v1/me/sunday-reports/${row.id}`, { token });
    expect(one.statusCode).toBe(200);
    expect(SundayReport.parse(one.json())).toMatchObject({ weekStart: "2026-11-02", tier: "short", lampsLit: 2 });

    const other = await signIn("readiness-c@example.com");
    const denied = await call("GET", `/v1/me/sunday-reports/${row.id}`, { token: other });
    expect([denied.statusCode, denied.json().error.code]).toEqual([404, "REPORT_NOT_FOUND"]);
    expect((await call("GET", "/v1/me/sunday-reports/not-a-uuid", { token })).statusCode).toBe(400);
    expect((await call("GET", "/v1/me/sunday-reports?cursor=bad", { token })).statusCode).toBe(400);
  });
});
