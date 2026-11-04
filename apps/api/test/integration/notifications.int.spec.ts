/* eslint-disable @typescript-eslint/no-non-null-assertion -- tests assert presence right after creating the row */
// BOLT-0014: notifications + Exam Alerts end to end on REAL Postgres + Valkey (Testcontainers, blueprint §44).
// Blueprint §19.8 Q78, §6, §17.1 step 11, §19.1 Q7, §17.5, §20.2. INT-002-S16, S17. D-2026-10-22-31..33.
// Includes the webhook security tests: bad secret -> 401 and nothing stored; replay -> 409 and no duplicate.
import { createHmac, randomUUID } from "node:crypto";
import { afterAll, beforeAll, beforeEach, describe, expect, it } from "vitest";
import type { NestFastifyApplication } from "@nestjs/platform-fastify";
import { Queue } from "bullmq";
import { OFFICIAL_CONFIRM_LINE } from "@heymey/contracts";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { createExamAlertsModule } from "@heymey/domain/modules/exams";
import { createNotificationsModule } from "@heymey/domain/modules/notifications";
import { startPostgres, startValkey, type StartedDb } from "@heymey/testing";
import { seeder } from "../../../../packages/db/prisma/seed/catalog.js";
import { createApiApp } from "../../src/bootstrap.js";
import { setTestEnv, TEST_WEBHOOK_SECRET } from "../support/env.js";

let pg: StartedDb;
let valkey: StartedDb;
let app: NestFastifyApplication;
let prisma: PrismaClient;
let otpQueue: Queue;
let alertQueue: Queue;
let clientIp = "192.0.2.1";
let ipSeq = 1;

type Res = { statusCode: number; json: () => any }; // eslint-disable-line @typescript-eslint/no-explicit-any

async function call(method: string, url: string, opts: { body?: unknown; token?: string; key?: string | null; headers?: Record<string, string> } = {}): Promise<Res> {
  const headers: Record<string, string> = { "x-forwarded-for": clientIp, ...opts.headers };
  if (opts.token) headers.authorization = `Bearer ${opts.token}`;
  if (opts.key !== null && method !== "GET") headers["idempotency-key"] = opts.key ?? randomUUID();
  const res = await app.getHttpAdapter().getInstance().inject({ method: method as "GET", url, headers, ...(opts.body !== undefined ? { payload: opts.body as object } : {}) });
  return { statusCode: res.statusCode, json: () => res.json() };
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

async function signIn(email: string): Promise<{ token: string; userId: string }> {
  expect((await call("POST", "/v1/auth/otp/request", { body: { email } })).statusCode).toBe(200);
  const res = await call("POST", "/v1/auth/otp/verify", { body: { email, code: await lastCode(email), deviceId: randomUUID(), platform: "android" } });
  expect(res.statusCode).toBe(200);
  const token = res.json().tokens.accessToken as string;
  return { token, userId: (await call("GET", "/v1/me", { token })).json().id as string };
}

/** A Desk session for a user holding `role` (email OTP -> TOTP enrol -> TOTP verify). */
async function deskSignIn(email: string, role: "OPS" | "ADMIN" | "REVIEWER"): Promise<{ token: string; userId: string }> {
  const user = await prisma.user.create({ data: { email } });
  await prisma.roleAssignment.create({ data: { userId: user.id, role, grantedBy: user.id } });
  await call("POST", "/v1/auth/otp/request", { body: { email } });
  const ch = await call("POST", "/v1/auth/otp/verify", { body: { email, code: await lastCode(email), deviceId: randomUUID(), platform: "web", client: "desk" } });
  const challengeToken = ch.json().challengeToken as string;
  const { secret } = (await call("POST", "/v1/auth/desk/totp/enroll", { body: { challengeToken } })).json();
  const ok = await call("POST", "/v1/auth/desk/totp/verify", { body: { challengeToken, code: totp(secret) } });
  expect(ok.statusCode).toBe(200);
  return { token: ok.json().tokens.accessToken as string, userId: user.id };
}

const webhook = (body: unknown, secret: string | null = TEST_WEBHOOK_SECRET) =>
  call("POST", "/v1/webhooks/changedetection", { body, key: null, headers: secret === null ? {} : { "x-heymey-webhook-secret": secret } });

const siteChange = (changeId: string) => ({ watchUuid: "0199f5a0-0000-7000-8000-0000000000c1", watchUrl: "https://www.tnpsc.gov.in/notifications", title: "TNPSC notifications", changeId, diffSummary: "+ Group 4 2027 notification" });
const approveBody = { examCode: "tnpsc-group-4", kind: "notification", title: "Group 4 notification is out", summary: "Applications are open on the TNPSC site.", officialUrl: "https://www.tnpsc.gov.in/n/group4.pdf" };

beforeAll(async () => {
  [pg, valkey] = await Promise.all([startPostgres(), startValkey()]);
  prisma = createPrismaClient(pg.url);
  await seeder.run(prisma);
  setTestEnv({ DATABASE_URL: pg.url, VALKEY_URL: valkey.url });
  app = await createApiApp({ logger: false });
  await app.init();
  await app.getHttpAdapter().getInstance().ready();
  const url = new URL(valkey.url);
  const connection = { host: url.hostname, port: Number(url.port), maxRetriesPerRequest: null };
  otpQueue = new Queue("email.otp", { connection });
  alertQueue = new Queue("notifications.exam-alert", { connection });
});

afterAll(async () => {
  await Promise.allSettled([otpQueue?.close(), alertQueue?.close()]);
  await app?.close();
  await prisma?.$disconnect();
  await Promise.all([pg?.stop(), valkey?.stop()]);
});

beforeEach(() => {
  clientIp = `192.0.2.${++ipSeq}`;
});

describe("push tokens + alert settings (S16)", () => {
  it("register, re-register (upsert), delete; Idempotency-Key required", async () => {
    const { token, userId } = await signIn("push-a@example.com");
    const body = { deviceId: "device-aaaa-0001", platform: "android", token: "fcm-token-".padEnd(40, "x") };
    expect((await call("POST", "/v1/me/push-tokens", { token, body, key: null })).statusCode).toBe(400);
    const r = await call("POST", "/v1/me/push-tokens", { token, body });
    expect(r.statusCode).toBe(200);
    expect(r.json()).toMatchObject({ deviceId: "device-aaaa-0001" });
    await call("POST", "/v1/me/push-tokens", { token, body: { ...body, token: "fcm-token-2".padEnd(40, "y") } });
    expect(await prisma.pushToken.count({ where: { userId } })).toBe(1);
    const del = await call("DELETE", "/v1/me/push-tokens/device-aaaa-0001", { token });
    expect(del.statusCode).toBe(200);
    expect(del.json()).toEqual({ ok: true });
    expect(await prisma.pushToken.count({ where: { userId } })).toBe(0);
    expect((await call("POST", "/v1/me/push-tokens", { body })).statusCode).toBe(401);
  });

  it("settings: defaults, save, offers without consent -> CONSENT_REQUIRED, dailyLimit > 3 -> 400", async () => {
    const { token } = await signIn("push-b@example.com");
    const get = await call("GET", "/v1/me/alert-settings", { token });
    expect(get.statusCode).toBe(200);
    expect(get.json()).toEqual({ studyReminders: true, examAlerts: true, offers: false, quietHours: { enabled: true, startMinute: 1320, endMinute: 420 }, morningAlertMinute: 450, dailyLimit: 3 });
    const next = { ...get.json(), studyReminders: false, dailyLimit: 2, quietHours: { enabled: true, startMinute: 1380, endMinute: 360 } };
    const put = await call("PUT", "/v1/me/alert-settings", { token, body: next });
    expect(put.statusCode).toBe(200);
    expect((await call("GET", "/v1/me/alert-settings", { token })).json()).toEqual(next);
    const offers = await call("PUT", "/v1/me/alert-settings", { token, body: { ...next, offers: true } });
    expect(offers.json().error.code).toBe("CONSENT_REQUIRED");
    expect((await call("PUT", "/v1/me/alert-settings", { token, body: { ...next, dailyLimit: 4 } })).statusCode).toBe(400);
  });
});

describe("changedetection webhook security (S17, U-exams invariants 4-6)", () => {
  it("bad or missing secret -> 401 WEBHOOK_UNAUTHORIZED and nothing stored", async () => {
    for (const secret of [null, "wrong", TEST_WEBHOOK_SECRET.slice(0, -1) + "Z", TEST_WEBHOOK_SECRET + "x"]) {
      const r = await webhook(siteChange("2026-10-22T01:00:00Z"), secret);
      expect(r.statusCode).toBe(401);
      expect(r.json().error.code).toBe("WEBHOOK_UNAUTHORIZED");
    }
    // secret is checked before the body: garbage with a bad secret is still 401, not 400
    expect((await webhook({ nope: 1 }, "wrong")).statusCode).toBe(401);
    expect(await prisma.examWatchChange.count({ where: { changeId: "2026-10-22T01:00:00Z" } })).toBe(0);
  });

  it("valid -> 202 pending; replay -> 409 WEBHOOK_REPLAYED and still one row; bad body -> 400", async () => {
    const ok = await webhook(siteChange("2026-10-22T02:00:00Z"));
    expect(ok.statusCode).toBe(202);
    expect(ok.json()).toEqual({ received: true });
    const replay = await webhook(siteChange("2026-10-22T02:00:00Z"));
    expect(replay.statusCode).toBe(409);
    expect(replay.json().error.code).toBe("WEBHOOK_REPLAYED");
    expect(await prisma.examWatchChange.count({ where: { changeId: "2026-10-22T02:00:00Z" } })).toBe(1);
    expect((await prisma.examWatchChange.findFirst({ where: { changeId: "2026-10-22T02:00:00Z" } }))!.status).toBe("pending");
    expect(await alertQueue.count()).toBe(0); // a webhook never sends anything
    expect((await webhook({ watchUuid: "not-a-uuid" })).statusCode).toBe(400);
  });

  it("is rate-limited per IP (60/min)", async () => {
    clientIp = "192.0.2.250";
    let last = 0;
    for (let i = 0; i < 61; i++) last = (await webhook({ bad: true }, "wrong")).statusCode;
    expect(last).toBe(429);
  });
});

describe("Desk review + Exam Alerts (S17, invariants 7-10, D-2026-10-22-32)", () => {
  it("aspirant -> DESK error; REVIEWER -> 403; OPS lists, approves once (alert + event + audit), 2nd approve -> 409", async () => {
    const follower = await signIn("follower@example.com");
    await call("PUT", "/v1/me/exams", { token: follower.token, body: { mainExamCode: "tnpsc-group-4" } });
    const other = await signIn("other@example.com");
    await call("PUT", "/v1/me/exams", { token: other.token, body: { mainExamCode: "ssc-mts" } });

    await webhook(siteChange("2026-10-22T03:00:00Z"));
    const change = await prisma.examWatchChange.findFirst({ where: { changeId: "2026-10-22T03:00:00Z" } });

    expect((await call("GET", "/v1/desk/exam-changes", { token: follower.token })).statusCode).toBeGreaterThanOrEqual(401);
    const reviewer = await deskSignIn("reviewer@heymey.app", "REVIEWER");
    const refused = await call("POST", `/v1/desk/exam-changes/${change!.id}/approve`, { token: reviewer.token, body: approveBody });
    expect(refused.statusCode).toBe(403);
    expect((await call("GET", "/v1/desk/exam-changes", { token: reviewer.token })).statusCode).toBe(403);

    const ops = await deskSignIn("ops-alerts@heymey.app", "OPS");
    const list = await call("GET", "/v1/desk/exam-changes", { token: ops.token });
    expect(list.statusCode).toBe(200);
    expect(list.json().items.map((c: { id: string }) => c.id)).toContain(change!.id);
    expect(list.json().items[0]).toMatchObject({ status: "pending", examCode: null });

    expect((await call("POST", `/v1/desk/exam-changes/${change!.id}/approve`, { token: ops.token, body: approveBody, key: null })).statusCode).toBe(400);
    const ok = await call("POST", `/v1/desk/exam-changes/${change!.id}/approve`, { token: ops.token, body: approveBody });
    expect(ok.statusCode).toBe(200);
    expect(ok.json()).toMatchObject({ id: change!.id, status: "approved", examCode: "tnpsc-group-4" });
    const alertId = ok.json().alertId as string;
    expect(await prisma.examAlert.count({ where: { changeId: change!.id } })).toBe(1);
    expect(await prisma.auditLog.count({ where: { action: "exam_change.approve" } })).toBe(1);
    const job = await alertQueue.getJob(`exam-alert-${alertId}`);
    expect(job?.data).toEqual({ alertId, examCode: "tnpsc-group-4" });

    const again = await call("POST", `/v1/desk/exam-changes/${change!.id}/approve`, { token: ops.token, body: approveBody });
    expect(again.statusCode).toBe(409);
    expect(again.json().error.code).toBe("EXAM_CHANGE_ALREADY_REVIEWED");
    expect(await prisma.examAlert.count({ where: { changeId: change!.id } })).toBe(1);

    // followers see it (with the confirm line); others don't
    const mine = await call("GET", "/v1/me/exam-alerts", { token: follower.token });
    expect(mine.statusCode).toBe(200);
    expect(mine.json().items).toEqual([expect.objectContaining({ id: alertId, examCode: "tnpsc-group-4", officialUrl: approveBody.officialUrl, confirmLine: OFFICIAL_CONFIRM_LINE })]);
    expect((await call("GET", "/v1/me/exam-alerts", { token: other.token })).json().items).toEqual([]);
    expect((await call("GET", "/v1/me/exam-alerts?cursor=bad", { token: follower.token })).statusCode).toBe(400);

    // worker composition: fan-out to followers through notifications (no module dependency), deduped per user
    const sent: string[] = [];
    const notifications = createNotificationsModule({ prisma, clock: { now: () => new Date("2026-10-22T06:30:00.000Z") }, consent: { offersGranted: async () => false }, dispatcher: { dispatch: async (id) => void sent.push(id) } });
    const exams = createExamAlertsModule({ prisma, clock: { now: () => new Date() }, events: { publish: async () => {} } });
    const followers = await exams.followersOf("tnpsc-group-4");
    expect(followers).toEqual([follower.userId]);
    expect(await notifications.enqueueExamAlert(alertId, followers)).toEqual({ queued: 1 });
    expect(await notifications.enqueueExamAlert(alertId, followers)).toEqual({ queued: 1 }); // same row, not re-dispatched
    expect(sent).toHaveLength(1);
    expect(await prisma.sendLog.count({ where: { userId: follower.userId, category: "exam" } })).toBe(1);
  });

  it("reject: 200, never publishes, audited; unknown id -> 404; ADMIN may review", async () => {
    await webhook(siteChange("2026-10-22T04:00:00Z"));
    const change = await prisma.examWatchChange.findFirst({ where: { changeId: "2026-10-22T04:00:00Z" } });
    const admin = await deskSignIn("admin-alerts@heymey.app", "ADMIN");
    const before = await alertQueue.count();
    const r = await call("POST", `/v1/desk/exam-changes/${change!.id}/reject`, { token: admin.token, body: { reason: "Only a page layout change." } });
    expect(r.statusCode).toBe(200);
    expect(r.json()).toMatchObject({ status: "rejected", alertId: null });
    expect(await alertQueue.count()).toBe(before);
    expect(await prisma.auditLog.count({ where: { action: "exam_change.reject" } })).toBe(1);
    expect((await call("POST", `/v1/desk/exam-changes/${randomUUID()}/reject`, { token: admin.token, body: { reason: "nope" } })).statusCode).toBe(404);
    const rejected = await call("GET", "/v1/desk/exam-changes?status=rejected", { token: admin.token });
    expect(rejected.json().items.map((c: { id: string }) => c.id)).toEqual([change!.id]);
  });

  it("SEC-P2-M1: audit write fails -> nothing approved/rejected, no alert, no job queued", async () => {
    await webhook(siteChange("2026-10-22T05:00:00Z"));
    const change = await prisma.examWatchChange.findFirst({ where: { changeId: "2026-10-22T05:00:00Z" } });
    const ops = await deskSignIn("ops-auditfail@heymey.app", "OPS");
    const jobsBefore = await alertQueue.count();
    const auditsBefore = await prisma.auditLog.count();
    await prisma.$executeRawUnsafe(`CREATE OR REPLACE FUNCTION hm_test_fail_audit() RETURNS trigger AS $$ BEGIN RAISE EXCEPTION 'audit down'; END $$ LANGUAGE plpgsql`);
    await prisma.$executeRawUnsafe(`CREATE TRIGGER hm_test_fail_audit BEFORE INSERT ON "AuditLog" FOR EACH ROW EXECUTE FUNCTION hm_test_fail_audit()`);
    try {
      const a = await call("POST", `/v1/desk/exam-changes/${change!.id}/approve`, { token: ops.token, body: approveBody });
      expect(a.statusCode).toBe(500);
      const r = await call("POST", `/v1/desk/exam-changes/${change!.id}/reject`, { token: ops.token, body: { reason: "Layout only." } });
      expect(r.statusCode).toBe(500);
    } finally {
      await prisma.$executeRawUnsafe(`DROP TRIGGER IF EXISTS hm_test_fail_audit ON "AuditLog"`);
    }
    expect((await prisma.examWatchChange.findUnique({ where: { id: change!.id } }))?.status).toBe("pending");
    expect(await prisma.examAlert.count({ where: { changeId: change!.id } })).toBe(0);
    expect(await prisma.auditLog.count()).toBe(auditsBefore);
    expect(await alertQueue.count()).toBe(jobsBefore);
  });
});

describe("send budget on real Postgres (invariant 1, concurrency)", () => {
  it("10 concurrent study alerts for one user -> exactly 3 queued", async () => {
    const { userId } = await signIn("budget@example.com");
    const n = createNotificationsModule({ prisma, clock: { now: () => new Date("2026-10-22T06:30:00.000Z") }, consent: { offersGranted: async () => false } });
    const res = await Promise.all(Array.from({ length: 10 }, (_, i) => n.enqueue({ userId, category: "study", templateKey: "study", dedupeKey: `budget-${i}` })));
    expect(res.filter((r) => r.status === "queued")).toHaveLength(3);
    expect(res.filter((r) => r.status === "dropped_budget")).toHaveLength(7);
  });
});
