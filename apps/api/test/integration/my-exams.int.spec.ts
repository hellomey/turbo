// QA (BOLT-0006): HTTP happy path + platform guarantees for GET/PUT /v1/me/exams with a REAL session
// (email OTP sign-in) on REAL Postgres + Valkey (Testcontainers, blueprint §44).
// Blueprint: §17.1 step 4 (main exam + up to 2 more), §34.3 + §37 (Idempotency-Key, error envelope,
// X-Min-App-Version), §38 (sessions). Intent INT-001 S01, S02, S07.
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, beforeEach, describe, expect, it } from "vitest";
import type { NestFastifyApplication } from "@nestjs/platform-fastify";
import { Queue } from "bullmq";
import { ERROR_CODES } from "@heymey/contracts";
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
let clientIp = "198.51.100.1";
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

async function lastCode(to: string): Promise<string> {
  const jobs = (await otpQueue.getJobs(["waiting", "delayed", "prioritized", "active"])).filter((j) => j.data.to === to);
  jobs.sort((a, b) => b.timestamp - a.timestamp);
  if (!jobs[0]) throw new Error(`no email.otp job for ${to}`);
  return jobs[0].data.code as string;
}

async function signIn(email: string): Promise<{ token: string; userId: string }> {
  expect((await call("POST", "/v1/auth/otp/request", { body: { email } })).statusCode).toBe(200);
  const code = await lastCode(email);
  const res = await call("POST", "/v1/auth/otp/verify", { body: { email, code, deviceId: randomUUID(), platform: "android" } });
  expect(res.statusCode).toBe(200);
  const token = res.json().tokens.accessToken as string;
  const me = await call("GET", "/v1/me", { token });
  return { token, userId: me.json().id as string };
}

const codes = (r: { main: { code: string } | null; others: { code: string }[] }) => ({
  main: r.main?.code ?? null,
  others: r.others.map((o) => o.code),
});

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
  clientIp = `198.51.100.${++ipSeq}`;
});

describe("my exams over HTTP with a real session (§17.1 step 4)", () => {
  it("a new user starts with no exams; PUT saves main + others; GET returns the same", async () => {
    const { token } = await signIn("myexams-a@example.com");
    const empty = await call("GET", "/v1/me/exams", { token });
    expect(empty.statusCode).toBe(200);
    expect(empty.json()).toEqual({ main: null, others: [] });

    const put = await call("PUT", "/v1/me/exams", { token, body: { mainExamCode: "tnpsc-group-4", otherExamCodes: ["tnpsc-group-2", "ssc-mts"] } });
    expect(put.statusCode).toBe(200);
    // The contract does not define the order of `others` (the API returns them in its own order, not the request's).
    expect(codes(put.json()).main).toBe("tnpsc-group-4");
    expect([...codes(put.json()).others].sort()).toEqual(["ssc-mts", "tnpsc-group-2"]);
    expect(put.json().main).toMatchObject({ code: "tnpsc-group-4", conductingBody: "TNPSC", level: "state", fullPrep: true });

    const get = await call("GET", "/v1/me/exams", { token });
    expect(get.statusCode).toBe(200);
    expect(get.json()).toEqual(put.json());
  });

  it("PUT replaces the previous choice; otherExamCodes defaults to none", async () => {
    const { token, userId } = await signIn("myexams-b@example.com");
    await call("PUT", "/v1/me/exams", { token, body: { mainExamCode: "tnpsc-group-4", otherExamCodes: ["ssc-mts"] } });
    const put = await call("PUT", "/v1/me/exams", { token, body: { mainExamCode: "tnpsc-group-2" } });
    expect(put.statusCode).toBe(200);
    expect(codes(put.json())).toEqual({ main: "tnpsc-group-2", others: [] });
    const rows = await prisma.userExamChoice.findMany({ where: { userId } });
    expect(rows.map((r) => [r.examCode, r.isMain])).toEqual([["tnpsc-group-2", true]]);
  });

  it("choices are per user: another signed-in user does not see them", async () => {
    const a = await signIn("myexams-c1@example.com");
    const b = await signIn("myexams-c2@example.com");
    await call("PUT", "/v1/me/exams", { token: a.token, body: { mainExamCode: "ssc-chsl" } });
    expect((await call("GET", "/v1/me/exams", { token: b.token })).json()).toEqual({ main: null, others: [] });
  });

  it("unknown exam -> 404 EXAM_NOT_FOUND and the saved choice is unchanged", async () => {
    const { token } = await signIn("myexams-d@example.com");
    await call("PUT", "/v1/me/exams", { token, body: { mainExamCode: "tnpsc-group-4" } });
    const bad = await call("PUT", "/v1/me/exams", { token, body: { mainExamCode: "tnpsc-group-4", otherExamCodes: ["no-such-exam"] } });
    expect(bad.statusCode).toBe(404);
    expect(bad.json().error).toMatchObject({ code: "EXAM_NOT_FOUND", message: ERROR_CODES.EXAM_NOT_FOUND });
    expect(codes((await call("GET", "/v1/me/exams", { token })).json())).toEqual({ main: "tnpsc-group-4", others: [] });
  });

  it("more than 2 other exams, or the main repeated in others -> 400 VALIDATION_FAILED", async () => {
    const { token } = await signIn("myexams-e@example.com");
    const tooMany = await call("PUT", "/v1/me/exams", {
      token,
      body: { mainExamCode: "tnpsc-group-4", otherExamCodes: ["tnpsc-group-2", "tnpsc-group-2a", "ssc-mts"] },
    });
    expect(tooMany.statusCode).toBe(400);
    expect(tooMany.json().error.code).toBe("VALIDATION_FAILED");
    const dup = await call("PUT", "/v1/me/exams", { token, body: { mainExamCode: "tnpsc-group-4", otherExamCodes: ["tnpsc-group-4"] } });
    expect(dup.statusCode).toBe(400);
    expect(dup.json().error.code).toBe("VALIDATION_FAILED");
  });
});

describe("platform guarantees on PUT /v1/me/exams (§34.3, §37; INT-001 S07)", () => {
  it("no Idempotency-Key -> 400 IDEMPOTENCY_KEY_REQUIRED and nothing is written", async () => {
    const { token, userId } = await signIn("idem-a@example.com");
    const res = await call("PUT", "/v1/me/exams", { token, key: null, body: { mainExamCode: "tnpsc-group-4" } });
    expect(res.statusCode).toBe(400);
    expect(res.json().error.code).toBe("IDEMPOTENCY_KEY_REQUIRED");
    expect(await prisma.userExamChoice.count({ where: { userId } })).toBe(0);
  });

  it("same Idempotency-Key + same body twice -> one effect, the second is a replay", async () => {
    const { token, userId } = await signIn("idem-b@example.com");
    const key = randomUUID();
    const body = { mainExamCode: "tnpsc-group-4", otherExamCodes: ["ssc-mts"] };
    const first = await call("PUT", "/v1/me/exams", { token, key, body });
    expect(first.statusCode).toBe(200);
    expect(first.headers["idempotent-replayed"]).toBeUndefined();
    const createdAt = (await prisma.userExamChoice.findMany({ where: { userId }, orderBy: { examCode: "asc" } })).map((r) => r.createdAt.getTime());

    const second = await call("PUT", "/v1/me/exams", { token, key, body });
    expect(second.statusCode).toBe(200);
    expect(second.headers["idempotent-replayed"]).toBe("true");
    expect(second.json()).toEqual(first.json());
    // The handler did not run again: the rows were not deleted and re-created.
    const after = (await prisma.userExamChoice.findMany({ where: { userId }, orderBy: { examCode: "asc" } })).map((r) => r.createdAt.getTime());
    expect(after).toEqual(createdAt);
  });

  it("same Idempotency-Key + a different body -> 422 IDEMPOTENCY_KEY_REUSED, first choice kept", async () => {
    const { token } = await signIn("idem-c@example.com");
    const key = randomUUID();
    expect((await call("PUT", "/v1/me/exams", { token, key, body: { mainExamCode: "tnpsc-group-4" } })).statusCode).toBe(200);
    const reused = await call("PUT", "/v1/me/exams", { token, key, body: { mainExamCode: "ssc-mts" } });
    expect(reused.statusCode).toBe(422);
    expect(reused.json().error.code).toBe("IDEMPOTENCY_KEY_REUSED");
    expect(codes((await call("GET", "/v1/me/exams", { token })).json()).main).toBe("tnpsc-group-4");
  });

  it("Idempotency-Keys are scoped per user: two users using the same key both get their own effect", async () => {
    const a = await signIn("idem-d1@example.com");
    const b = await signIn("idem-d2@example.com");
    const key = randomUUID();
    const ra = await call("PUT", "/v1/me/exams", { token: a.token, key, body: { mainExamCode: "tnpsc-group-4" } });
    const rb = await call("PUT", "/v1/me/exams", { token: b.token, key, body: { mainExamCode: "tnpsc-group-4" } });
    expect(ra.statusCode).toBe(200);
    expect(rb.statusCode).toBe(200);
    expect(rb.headers["idempotent-replayed"]).toBeUndefined();
    expect(await prisma.userExamChoice.count({ where: { userId: b.userId } })).toBe(1);
  });

  it("success and handler/interceptor errors carry X-Min-App-Version; errors use the envelope with the contract message", async () => {
    const { token } = await signIn("envelope@example.com");
    const ok = await call("GET", "/v1/me/exams", { token });
    const unauth = await call("GET", "/v1/me/exams");
    const noKey = await call("PUT", "/v1/me/exams", { token, key: null, body: { mainExamCode: "tnpsc-group-4" } });
    const notFound = await call("GET", "/v1/exams/no-such-exam");
    for (const [name, r] of Object.entries({ ok, noKey, notFound })) expect(r.headers["x-min-app-version"], name).toBe("1.0.0");
    expect(unauth.statusCode).toBe(401);
    for (const r of [unauth, noKey, notFound]) {
      const { error } = r.json();
      expect(Object.keys(r.json())).toEqual(["error"]);
      expect(error.message).toBe(ERROR_CODES[error.code as keyof typeof ERROR_CODES]);
    }
  });

  it("per-user rate limits live in Valkey and follow the user across IPs (delete-account: 5 per user per hour)", async () => {
    const a = await signIn("peruser-a@example.com");
    const b = await signIn("peruser-b@example.com");
    for (let i = 0; i < 5; i++) {
      clientIp = `192.0.2.${10 + i}`; // a new IP every time: the per-IP default limit cannot be what stops us
      const r = await call("POST", "/v1/auth/delete-account", { token: a.token, body: { code: "000000" } });
      expect(r.statusCode, `attempt ${i + 1}`).not.toBe(429);
    }
    clientIp = "192.0.2.99";
    const limited = await call("POST", "/v1/auth/delete-account", { token: a.token, body: { code: "000000" } });
    expect(limited.statusCode).toBe(429);
    expect(limited.json().error.code).toBe("RATE_LIMITED");
    expect(Number(limited.headers["retry-after"])).toBeGreaterThan(0);
    // Another user on the same IP is not affected.
    const other = await call("POST", "/v1/auth/delete-account", { token: b.token, body: { code: "000000" } });
    expect(other.statusCode).not.toBe(429);
  });

  // FINDING Q-2 (BOLT-0006 QA, owner: backend platform / U-platform-api): responses rejected by PlatformGuard
  // (401 UNAUTHENTICATED, 429 RATE_LIMITED, 403 DESK_*) carry neither X-Min-App-Version nor X-Request-Id, because
  // AppVersionInterceptor runs after guards. §37 + INT-001 S07 say "every response". `it.fails` = still broken;
  // when fixed this test fails and must be turned into a plain `it`.
  it("guard-rejected responses (401, 429) also carry X-Min-App-Version and X-Request-Id", async () => {
    const unauth = await call("GET", "/v1/me/exams");
    expect(unauth.statusCode).toBe(401);
    expect(unauth.headers["x-min-app-version"]).toBe("1.0.0");
    expect(unauth.headers["x-request-id"]).toBeDefined();
  });
});

describe("eligibility before sign-up stores nothing (INT-001 S01, §17.1 steps 1-3)", () => {
  it("an under-18 check and an adult check write no rows on the server", async () => {
    const tables = async () => ({
      users: await prisma.user.count(),
      profiles: await prisma.userProfile.count(),
      choices: await prisma.userExamChoice.count(),
      consents: await prisma.consent.count(),
      idempotency: await prisma.idempotencyRecord.count(),
    });
    const before = await tables();
    const base = { qualification: "sslc", community: "BC", pstm: false, specialCategories: [] };
    const minor = await call("POST", "/v1/eligibility/check", { body: { ...base, dateOfBirth: "2015-06-01" } });
    expect(minor.statusCode).toBe(422);
    expect(minor.json().error.message).toBe("HeyMey is for 18+. See you on your 18th birthday.");
    const adult = await call("POST", "/v1/eligibility/check", { body: { ...base, dateOfBirth: "2000-01-15" } });
    expect(adult.statusCode).toBe(200);
    expect(await tables()).toEqual(before);
  });
});
