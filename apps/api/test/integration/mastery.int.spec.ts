// BOLT-0009: mastery routes over HTTP with a REAL session on REAL Postgres + Valkey (Testcontainers, blueprint §44).
// §5.1 rings, §5.2 Career Ladder, §34.3 Idempotency-Key, §37 error envelope, §39 offline sync. INT-002 S01-S05, S18.
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
const PREAMBLE = "0199f5a0-0101-7000-8000-000000000101";

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

async function signIn(email: string): Promise<string> {
  expect((await call("POST", "/v1/auth/otp/request", { body: { email } })).statusCode).toBe(200);
  const jobs = (await otpQueue.getJobs(["waiting", "delayed", "prioritized", "active"])).filter((j) => j.data.to === email);
  jobs.sort((a, b) => b.timestamp - a.timestamp);
  const code = jobs[0]?.data.code as string;
  const res = await call("POST", "/v1/auth/otp/verify", { body: { email, code, deviceId: randomUUID(), platform: "android" } });
  expect(res.statusCode).toBe(200);
  return res.json().tokens.accessToken as string;
}

async function seedQuestions(topicId: string, n: number) {
  for (let i = 0; i < n; i++) {
    const q = await prisma.question.create({ data: { topicId, status: "published", difficulty: 3 } });
    await prisma.questionVersion.create({
      data: {
        questionId: q.id,
        version: 1,
        stem: `Q${i}`,
        options: [
          { id: "a", text: "A" },
          { id: "b", text: "B" },
        ],
        correctOptionIds: ["a"],
        explanationMarkdown: "Because.",
        status: "published",
      },
    });
  }
}

beforeAll(async () => {
  [pg, valkey] = await Promise.all([startPostgres(), startValkey()]);
  prisma = createPrismaClient(pg.url);
  await seeder.run(prisma);
  await seedQuestions(PREAMBLE, 20);
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

const allRight = (questions: { id: string }[]) => questions.map((q) => ({ questionId: q.id, chosenOptionIds: ["a"] }));

describe("mastery over HTTP (BOLT-0009)", () => {
  it("every mastery route needs a session (401)", async () => {
    for (const [m, u] of [
      ["GET", "/v1/me/mastery"],
      ["GET", "/v1/me/topic-states?examCode=tnpsc-group-4"],
      ["GET", "/v1/me/relight-queue"],
      ["POST", `/v1/topics/${PREAMBLE}/lesson-complete`],
      ["POST", `/v1/topics/${PREAMBLE}/checks`],
      ["POST", `/v1/checks/${randomUUID()}/submit`],
      ["POST", "/v1/sync/study-actions"],
    ] as const) {
      const r = await call(m, u, { body: m === "POST" ? {} : undefined });
      expect(r.statusCode, `${m} ${u}`).toBe(401);
    }
  });

  it("lesson -> lit check -> submit; idempotent replay; double submit 409; rank from lamps", async () => {
    const token = await signIn("mastery-a@example.com");
    expect((await call("PUT", "/v1/me/exams", { token, body: { mainExamCode: "tnpsc-group-4" } })).statusCode).toBe(200);

    expect((await call("POST", `/v1/topics/${PREAMBLE}/checks`, { token, body: { kind: "lit" } })).json().error.code).toBe("CHECK_NOT_AVAILABLE");
    const unknown = await call("POST", `/v1/topics/${randomUUID()}/lesson-complete`, { token, body: { via: "lesson" } });
    expect([unknown.statusCode, unknown.json().error.code]).toEqual([404, "TOPIC_NOT_FOUND"]);
    expect((await call("POST", `/v1/topics/${PREAMBLE}/lesson-complete`, { token, body: { via: "lesson" }, key: null })).json().error.code).toBe(
      "IDEMPOTENCY_KEY_REQUIRED",
    );
    expect((await call("POST", `/v1/topics/not-a-uuid/lesson-complete`, { token, body: { via: "lesson" } })).statusCode).toBe(400);

    const lesson = await call("POST", `/v1/topics/${PREAMBLE}/lesson-complete`, { token, body: { via: "lesson" } });
    expect(lesson.statusCode).toBe(200);
    expect(lesson.json()).toMatchObject({ topicId: PREAMBLE, nextCheck: "lit", ring: { lit: false } });

    const start = await call("POST", `/v1/topics/${PREAMBLE}/checks`, { token, body: { kind: "lit" } });
    expect(start.statusCode).toBe(201);
    const check = start.json();
    expect(check.questions).toHaveLength(3);
    expect(JSON.stringify(check)).not.toContain("correctOptionIds");

    const key = randomUUID();
    const body = { answers: allRight(check.questions) };
    const sub = await call("POST", `/v1/checks/${check.checkId}/submit`, { token, body, key });
    expect(sub.statusCode).toBe(200);
    expect(sub.json()).toMatchObject({ passed: true, correct: 3, total: 3, topicState: { ring: { lit: true } } });
    // One lamp of a large syllabus is under 2% of max lamp points: no rank-up yet (§5.2).
    expect(sub.json().rankUp).toBeNull();
    const replay = await call("POST", `/v1/checks/${check.checkId}/submit`, { token, body, key });
    expect(replay.statusCode).toBe(200);
    expect(replay.headers["idempotent-replayed"]).toBe("true");
    expect(replay.json()).toEqual(sub.json());
    const again = await call("POST", `/v1/checks/${check.checkId}/submit`, { token, body });
    expect([again.statusCode, again.json().error.code]).toEqual([409, "CHECK_ALREADY_SUBMITTED"]);
    expect((await call("POST", `/v1/checks/${randomUUID()}/submit`, { token, body })).statusCode).toBe(404);
    expect((await call("POST", `/v1/checks/${check.checkId}/submit`, { token, body: { answers: [] } })).statusCode).toBe(400);

    const summary = await call("GET", "/v1/me/mastery", { token });
    expect(summary.statusCode).toBe(200);
    expect(summary.json()).toMatchObject({ counts: { lit: 1 }, byExam: [{ examCode: "tnpsc-group-4", counts: { lit: 1 } }] });
    expect(summary.json().rank).toMatchObject({ level: 1, title: "Aspirant", xp: 10, note: "Game title. Not an official designation." });

    const states = await call("GET", "/v1/me/topic-states?examCode=tnpsc-group-4&limit=10", { token });
    expect(states.json().items.map((s: { topicId: string }) => s.topicId)).toEqual([PREAMBLE]);
    expect((await call("GET", "/v1/me/topic-states?examCode=nope-exam", { token })).statusCode).toBe(404);
    expect((await call("GET", "/v1/me/topic-states", { token })).statusCode).toBe(400);
    expect((await call("GET", "/v1/me/relight-queue", { token })).json()).toEqual({ items: [], totalMinutes: 0 });

    // Gold: 15 questions, timed.
    const gold = await call("POST", `/v1/topics/${PREAMBLE}/checks`, { token, body: { kind: "gold" } });
    expect(gold.statusCode).toBe(201);
    expect(gold.json().deadlineAt).not.toBeNull();
    await call("POST", `/v1/topics/${PREAMBLE}/checks`, { token, body: { kind: "gold" } });
    const limit = await call("POST", `/v1/topics/${PREAMBLE}/checks`, { token, body: { kind: "gold" } });
    expect([limit.statusCode, limit.json().error.code]).toEqual([429, "GOLD_DAILY_LIMIT"]);
  });

  it("offline sync: accepted once, duplicates, unbuilt kinds paused, authoritative states returned", async () => {
    const token = await signIn("mastery-b@example.com");
    const id = randomUUID();
    const now = new Date().toISOString();
    const body = {
      deviceId: "device-123456",
      actions: [
        { clientActionId: id, clientAt: now, kind: "lesson_complete", topicId: PREAMBLE, via: "textbook" },
        { clientActionId: randomUUID(), clientAt: now, kind: "plan_item_status", itemId: randomUUID(), status: "done" },
        { clientActionId: randomUUID(), clientAt: new Date(Date.now() - 9 * 86_400_000).toISOString(), kind: "lesson_complete", topicId: PREAMBLE, via: "lesson" },
      ],
    };
    const r = await call("POST", "/v1/sync/study-actions", { token, body });
    expect(r.statusCode).toBe(200);
    expect(r.json().results.map((x: { status: string; errorCode: string | null }) => [x.status, x.errorCode])).toEqual([
      ["accepted", null],
      ["rejected", "NOT_FOUND"], // BOLT-0012: plan_item_status is built; an unknown item is rejected
      ["study_log_only", "SYNC_ACTION_TOO_OLD"],
    ]);
    expect(r.json().topicStates).toEqual([expect.objectContaining({ topicId: PREAMBLE, nextCheck: "lit" })]);
    const again = await call("POST", "/v1/sync/study-actions", { token, body: { deviceId: "device-123456", actions: [body.actions[0]] } });
    expect(again.json().results[0].status).toBe("duplicate");
    const gold = await call("POST", "/v1/sync/study-actions", {
      token,
      body: { deviceId: "device-123456", actions: [{ clientActionId: randomUUID(), clientAt: now, kind: "topic_check", topicId: PREAMBLE, checkKind: "gold", answers: [] }] },
    });
    expect(gold.statusCode).toBe(400);
  });
});
