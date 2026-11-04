// BOLT-0010: practice + content routes over HTTP with a REAL session on REAL Postgres + Valkey (Testcontainers, §44).
// §10.6 practice, §11 free 30/day (IST), §13 limit sheet, §19.4 PYQ Vault + reports, §19.6 Q60 drills, §39 packs + sync.
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
let clientIp = "203.0.114.1";
let ipSeq = 1;
const EXAM = "tnpsc-group-4";
const PREAMBLE = "0199f5a0-0101-7000-8000-000000000101";
const qids: string[] = [];

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

async function seedQuestions() {
  for (let i = 0; i < 45; i++) {
    const pyqYear = i < 6 ? 2021 + (i % 3) : null; // 2021, 2022, 2023
    const q = await prisma.question.create({ data: { topicId: PREAMBLE, status: "published", difficulty: 3, pyqExamCode: pyqYear ? EXAM : null, pyqYear } });
    qids.push(q.id);
    await prisma.questionVersion.create({
      data: {
        questionId: q.id,
        version: 1,
        stem: `SEED Q${i}`,
        options: [
          { id: "a", text: "A" },
          { id: "b", text: "B" },
        ],
        correctOptionIds: ["a"],
        explanationMarkdown: "Because.",
        whyWrong: { b: "B is wrong" },
        status: "published",
      },
    });
  }
}

beforeAll(async () => {
  [pg, valkey] = await Promise.all([startPostgres(), startValkey()]);
  prisma = createPrismaClient(pg.url);
  await seeder.run(prisma);
  await seedQuestions();
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
  clientIp = `203.0.114.${++ipSeq}`;
});

const answerBody = (questionId: string, chosen = ["a"]) => ({ clientActionId: randomUUID(), questionId, questionVersion: 1, chosenOptionIds: chosen, timeMs: 1200 });

describe("practice over HTTP (BOLT-0010)", () => {
  it("every route needs a session (401)", async () => {
    for (const [m, u] of [
      ["POST", "/v1/practice/sessions"],
      ["POST", `/v1/practice/sessions/${randomUUID()}/answers`],
      ["GET", "/v1/me/practice/usage"],
      ["GET", "/v1/me/mistakes"],
      ["GET", "/v1/me/drills"],
      ["GET", `/v1/pyq?examCode=${EXAM}`],
      ["GET", `/v1/pyq/facets?examCode=${EXAM}`],
      ["POST", `/v1/questions/${randomUUID()}/reports`],
      ["GET", `/v1/content/packs?examCode=${EXAM}`],
    ] as const) {
      expect((await call(m, u, { body: m === "POST" ? {} : undefined })).statusCode, `${m} ${u}`).toBe(401);
    }
  });

  it("40 parallel answers -> exactly 30 counted (200), 10 x 429 PRACTICE_DAILY_LIMIT; usage + limit sheet once", async () => {
    const token = await signIn("practice-a@example.com");
    const start = await call("POST", "/v1/practice/sessions", { token, body: { mode: "practice", examCode: EXAM, size: 40 } });
    expect(start.statusCode).toBe(201);
    const s = start.json();
    expect(s.questions).toHaveLength(40);
    expect(JSON.stringify(s.questions)).not.toContain("correctOptionIds");
    expect(s.usage).toMatchObject({ used: 0, limit: 30, limitSheetShownToday: false });

    const res = await Promise.all(
      (s.questions as { id: string }[]).map((q) => call("POST", `/v1/practice/sessions/${s.sessionId}/answers`, { token, body: answerBody(q.id) })),
    );
    const codes = res.map((r) => r.statusCode);
    expect(codes.filter((c) => c === 200)).toHaveLength(30);
    expect(codes.filter((c) => c === 429)).toHaveLength(10);
    const refused = res.filter((r) => r.statusCode === 429).map((r) => r.json().error);
    expect(refused.every((e) => e.code === "PRACTICE_DAILY_LIMIT" && e.message === "You've used today's free questions. More open tomorrow at 12 AM.")).toBe(true);
    expect(refused.filter((e) => e.details.showLimitSheet === true)).toHaveLength(1);

    const usage = await call("GET", "/v1/me/practice/usage", { token });
    expect(usage.json()).toMatchObject({ used: 30, limit: 30, limitSheetShownToday: true });
    const userId = (await prisma.practiceAnswer.findFirstOrThrow({ where: { sessionId: s.sessionId } })).userId;
    expect(await prisma.practiceAnswer.count({ where: { userId } })).toBe(30);
  });

  it("grading, replay with the same Idempotency-Key and clientActionId, 400/404/409 codes", async () => {
    const token = await signIn("practice-b@example.com");
    const s = (await call("POST", "/v1/practice/sessions", { token, body: { mode: "practice", examCode: EXAM, topicId: PREAMBLE, size: 2 } })).json();
    const b = answerBody(s.questions[0].id, ["b"]);
    const key = randomUUID();
    const r1 = await call("POST", `/v1/practice/sessions/${s.sessionId}/answers`, { token, body: b, key });
    expect(r1.statusCode).toBe(200);
    expect(r1.json().graded).toMatchObject({ correct: false, correctOptionIds: ["a"], whyChosenIsWrong: "B is wrong", topicId: PREAMBLE });
    const r2 = await call("POST", `/v1/practice/sessions/${s.sessionId}/answers`, { token, body: b, key });
    expect(r2.json()).toEqual(r1.json());
    const r3 = await call("POST", `/v1/practice/sessions/${s.sessionId}/answers`, { token, body: b });
    expect(r3.json().usage.used).toBe(1);

    expect((await call("POST", `/v1/practice/sessions/${s.sessionId}/answers`, { token, body: answerBody(s.questions[1].id), key: null })).statusCode).toBe(400);
    expect((await call("POST", `/v1/practice/sessions/${s.sessionId}/answers`, { token, body: { questionId: "x" } })).statusCode).toBe(400);
    expect((await call("POST", `/v1/practice/sessions/${randomUUID()}/answers`, { token, body: answerBody(s.questions[1].id) })).statusCode).toBe(404);
    const nq = await call("POST", `/v1/practice/sessions/${s.sessionId}/answers`, { token, body: answerBody(randomUUID()) });
    expect([nq.statusCode, nq.json().error.code]).toEqual([404, "QUESTION_NOT_FOUND"]);
    expect((await call("POST", `/v1/practice/sessions/${s.sessionId}/answers`, { token, body: answerBody(s.questions[1].id) })).statusCode).toBe(200);
    const closed = await call("POST", `/v1/practice/sessions/${s.sessionId}/answers`, { token, body: answerBody(s.questions[0].id) });
    expect([closed.statusCode, closed.json().error.code]).toEqual([409, "PRACTICE_SESSION_CLOSED"]);

    expect((await call("POST", "/v1/practice/sessions", { token, body: { mode: "practice", examCode: "nope-exam", size: 5 } })).statusCode).toBe(404);
    expect((await call("POST", "/v1/practice/sessions", { token, body: { mode: "practice", examCode: EXAM, topicId: randomUUID() } })).statusCode).toBe(404);
    const drill = await call("POST", "/v1/practice/sessions", { token, body: { mode: "drill", examCode: EXAM, drillId: randomUUID() } });
    expect([drill.statusCode, drill.json().error.code]).toEqual([403, "PRO_REQUIRED"]);

    // mistakes + drills (Free: locked)
    const m = await call("GET", "/v1/me/mistakes?limit=10", { token });
    expect(m.statusCode).toBe(200);
    expect(m.json().items).toEqual([expect.objectContaining({ questionId: s.questions[0].id, wrongCount: 1, stem: expect.any(String) })]);
    expect((await call("GET", "/v1/me/mistakes?cursor=bad", { token })).statusCode).toBe(400);
    expect((await call("GET", "/v1/me/drills", { token })).json()).toEqual({ items: [], locked: true });
  });

  it("PYQ Vault: latest 2 years free, older locked; facets; filters; 404 unknown exam", async () => {
    const token = await signIn("practice-c@example.com");
    const page = await call("GET", `/v1/pyq?examCode=${EXAM}&limit=4`, { token });
    expect(page.statusCode).toBe(200);
    const p1 = page.json();
    expect(p1.items.map((i: { question: { source: { pyq: { year: number } } } }) => i.question.source.pyq.year)).toEqual([2023, 2023, 2022, 2022]);
    const p2 = (await call("GET", `/v1/pyq?examCode=${EXAM}&limit=4&cursor=${p1.nextCursor}`, { token })).json();
    expect(p2.items.map((i: { locked: boolean; question: { stem: string } }) => [i.locked, i.question.stem])).toEqual([
      [true, ""],
      [true, ""],
    ]);
    expect(p2.nextCursor).toBeNull();
    expect((await call("GET", `/v1/pyq?examCode=${EXAM}&year=2022&topicId=${PREAMBLE}`, { token })).json().items).toHaveLength(2);
    expect((await call("GET", `/v1/pyq?examCode=nope-exam`, { token })).statusCode).toBe(404);
    expect((await call("GET", `/v1/pyq`, { token })).statusCode).toBe(400);
    const f = await call("GET", `/v1/pyq/facets?examCode=${EXAM}`, { token });
    expect(f.json().years).toEqual([
      { year: 2023, count: 2, locked: false },
      { year: 2022, count: 2, locked: false },
      { year: 2021, count: 2, locked: true },
    ]);
    expect(f.json().subjects).toEqual([expect.objectContaining({ count: 6 })]);
  });

  it("reports (201, 404) and packs (free unlocked, pro locked)", async () => {
    const token = await signIn("practice-d@example.com");
    const r = await call("POST", `/v1/questions/${qids[0]}/reports`, { token, body: { questionVersion: 1, reason: "wrong_answer", note: "Check option A" } });
    expect(r.statusCode).toBe(201);
    expect(r.json()).toMatchObject({ status: "received" });
    expect((await call("POST", `/v1/questions/${randomUUID()}/reports`, { token, body: { questionVersion: 1, reason: "typo" } })).statusCode).toBe(404);
    expect((await call("POST", `/v1/questions/${qids[0]}/reports`, { token, body: { questionVersion: 1, reason: "nope" } })).statusCode).toBe(400);

    const base = { examCode: EXAM, url: "https://cdn.heymey.app/packs/x.zip", sha256: "c".repeat(64), sizeBytes: 2048, status: "published", publishedAt: new Date("2026-10-01T00:00:00.000Z") };
    await prisma.contentPack.createMany({
      data: [
        { ...base, code: "tnpsc-group-4.polity", version: 1, tier: "free" },
        { ...base, code: "tnpsc-group-4.history", version: 1, tier: "pro" },
      ],
    });
    const packs = await call("GET", `/v1/content/packs?examCode=${EXAM}`, { token });
    expect(packs.statusCode).toBe(200);
    expect(packs.json().items.map((p: { code: string; locked: boolean }) => [p.code, p.locked])).toEqual([
      ["tnpsc-group-4.history", true],
      ["tnpsc-group-4.polity", false],
    ]);
  });

  it("offline sync: practice_answer is accepted once (no longer FEATURE_PAUSED)", async () => {
    const token = await signIn("practice-e@example.com");
    const action = { clientActionId: randomUUID(), clientAt: new Date().toISOString(), kind: "practice_answer", questionId: qids[10], questionVersion: 1, chosenOptionIds: ["b"], timeMs: 800, mode: "practice" };
    const r = await call("POST", "/v1/sync/study-actions", { token, body: { deviceId: "device-123456", actions: [action] } });
    expect(r.statusCode).toBe(200);
    expect(r.json().results).toEqual([{ clientActionId: action.clientActionId, status: "accepted", errorCode: null }]);
    const again = await call("POST", "/v1/sync/study-actions", { token, body: { deviceId: "device-123456", actions: [action] } });
    expect(again.json().results[0].status).toBe("duplicate");
    expect((await call("GET", "/v1/me/practice/usage", { token })).json().used).toBe(1);
    expect((await call("GET", "/v1/me/mistakes", { token })).json().items).toHaveLength(1);
  });
});
