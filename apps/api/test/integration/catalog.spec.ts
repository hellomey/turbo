// API end-to-end for the catalog (BOLT-0003) against REAL Postgres + Valkey (Testcontainers, blueprint §44).
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import type { NestFastifyApplication } from "@nestjs/platform-fastify";
import { OFFICIAL_CONFIRM_LINE } from "@heymey/contracts";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { startPostgres, startValkey, type StartedDb } from "@heymey/testing";
import { seeder } from "../../../../packages/db/prisma/seed/catalog.js";
import { createApiApp } from "../../src/bootstrap.js";
import { setTestEnv } from "../support/env.js";

let pg: StartedDb;
let valkey: StartedDb;
let prisma: PrismaClient;
let app: NestFastifyApplication;

const PREAMBLE = "0199f5a0-0101-7000-8000-000000000101";
const RIVERS = "0199f5a0-0302-7000-8000-000000000302";

beforeAll(async () => {
  pg = await startPostgres();
  valkey = await startValkey();
  prisma = createPrismaClient(pg.url);
  await seeder.run(prisma);
  setTestEnv({ DATABASE_URL: pg.url, VALKEY_URL: valkey.url });
  app = await createApiApp({ logger: false });
  await app.init();
  await app.getHttpAdapter().getInstance().ready();
});

afterAll(async () => {
  await app?.close();
  await prisma?.$disconnect();
  await Promise.all([pg?.stop(), valkey?.stop()]);
});

const inject = (opts: { method: "GET" | "POST" | "PUT"; url: string; payload?: unknown; headers?: Record<string, string> }) =>
  app.getHttpAdapter().getInstance().inject(opts as never);

const adult = { dateOfBirth: "2000-01-15", qualification: "sslc", community: "BC", pstm: true, specialCategories: [] };

describe("exams", () => {
  it("GET /v1/exams lists published exams, launch exams first", async () => {
    const res = await inject({ method: "GET", url: "/v1/exams" });
    expect(res.statusCode).toBe(200);
    expect(res.json().items.map((e: { code: string }) => e.code)).toEqual([
      "tnpsc-group-2", "tnpsc-group-2a", "tnpsc-group-4", "ssc-chsl", "ssc-mts",
    ]);
  });

  it("GET /v1/exams/{code} returns the exam page with the official line", async () => {
    const res = await inject({ method: "GET", url: "/v1/exams/tnpsc-group-4" });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ code: "tnpsc-group-4", disclaimer: OFFICIAL_CONFIRM_LINE, officialUrl: "https://www.tnpsc.gov.in/" });
  });

  it("unknown exam -> 404 EXAM_NOT_FOUND", async () => {
    const res = await inject({ method: "GET", url: "/v1/exams/no-such-exam" });
    expect(res.statusCode).toBe(404);
    expect(res.json().error.code).toBe("EXAM_NOT_FOUND");
  });
});

describe("POST /v1/eligibility/check", () => {
  it("200 with eligible and not-eligible lists, ranked, with reasons", async () => {
    const res = await inject({ method: "POST", url: "/v1/eligibility/check", payload: adult });
    expect(res.statusCode).toBe(200);
    const body = res.json();
    expect(body.disclaimer).toContain(OFFICIAL_CONFIRM_LINE);
    expect(body.eligible.map((e: { examCode: string }) => e.examCode)).toEqual(["tnpsc-group-4", "ssc-mts"]);
    expect(body.eligible[0]).toMatchObject({ fitRank: 1, eligible: true, officialNotificationUrl: "https://www.tnpsc.gov.in/" });
    expect(body.eligibleCount).toBe(2);
    expect(body.notEligible).toHaveLength(3);
    expect(body.notEligible[0].reasons.map((r: { code: string }) => r.code)).toContain("QUALIFICATION_TOO_LOW");
  });

  it("under 18 today (IST) -> 422 UNDER_18", async () => {
    const dob = new Date();
    dob.setUTCFullYear(dob.getUTCFullYear() - 10);
    const res = await inject({ method: "POST", url: "/v1/eligibility/check", payload: { ...adult, dateOfBirth: dob.toISOString().slice(0, 10) } });
    expect(res.statusCode).toBe(422);
    expect(res.json().error).toMatchObject({ code: "UNDER_18", message: "HeyMey is for 18+. See you on your 18th birthday." });
  });

  it("bad answers -> 400 VALIDATION_FAILED", async () => {
    const res = await inject({ method: "POST", url: "/v1/eligibility/check", payload: { ...adult, community: "XYZ" } });
    expect(res.statusCode).toBe(400);
    expect(res.json().error.code).toBe("VALIDATION_FAILED");
  });
});

describe("my exams", () => {
  // Signed-in happy path, idempotency and envelope for these routes: test/integration/my-exams.int.spec.ts (BOLT-0006 QA).
  // The use case (validation, published check, atomic replace) is covered in packages/domain/test/modules/exams.int.spec.ts.
  it("GET and PUT /v1/me/exams need a signed-in user", async () => {
    const get = await inject({ method: "GET", url: "/v1/me/exams" });
    expect(get.statusCode).toBe(401);
    expect(get.json().error.code).toBe("UNAUTHENTICATED");
    const put = await inject({
      method: "PUT",
      url: "/v1/me/exams",
      payload: { mainExamCode: "tnpsc-group-4" },
      headers: { "idempotency-key": randomUUID(), authorization: "Bearer not-a-token" },
    });
    expect(put.statusCode).toBe(401);
  });
});

describe("study map", () => {
  it("groups subjects and topics; shared lamps carry every exam; rings unlit", async () => {
    const res = await inject({ method: "GET", url: "/v1/exams/tnpsc-group-4/study-map" });
    expect(res.statusCode).toBe(200);
    const map = res.json();
    expect(map.subjects.map((s: { code: string }) => s.code)).toEqual(["polity", "history", "geography", "economy", "science", "aptitude"]);
    expect(map.totalTopics).toBe(25);
    const preamble = map.subjects[0].topics[0];
    expect(preamble).toMatchObject({
      id: PREAMBLE,
      hasLesson: true,
      examCodes: ["ssc-chsl", "tnpsc-group-2", "tnpsc-group-2a", "tnpsc-group-4"],
      ring: { lit: false, steadyLevel: 0, gold: false, dim: "bright" },
    });
  });

  it("a central exam sees only the lamps it shares", async () => {
    const res = await inject({ method: "GET", url: "/v1/exams/ssc-mts/study-map" });
    expect(res.statusCode).toBe(200);
    const ids = res.json().subjects.flatMap((s: { topics: { id: string }[] }) => s.topics.map((t) => t.id));
    expect(ids).not.toContain(PREAMBLE);
    expect(ids.length).toBeGreaterThan(0);
  });

  it("unknown exam -> 404 EXAM_NOT_FOUND", async () => {
    const res = await inject({ method: "GET", url: "/v1/exams/no-such-exam/study-map" });
    expect(res.statusCode).toBe(404);
    expect(res.json().error.code).toBe("EXAM_NOT_FOUND");
  });
});

describe("lessons", () => {
  it("GET /v1/topics/{id}/lesson returns the published lesson with refs and source", async () => {
    const res = await inject({ method: "GET", url: `/v1/topics/${PREAMBLE}/lesson` });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toMatchObject({ topicId: PREAMBLE, title: "The Preamble", version: 1 });
    expect(res.json().textbookRefs.length).toBeGreaterThan(0);
    expect(res.json().source.citation).toMatch(/Constitution of India/);
  });

  it("no lesson -> 404 LESSON_NOT_FOUND; bad id -> 400", async () => {
    const none = await inject({ method: "GET", url: `/v1/topics/${RIVERS}/lesson` });
    expect(none.statusCode).toBe(404);
    expect(none.json().error.code).toBe("LESSON_NOT_FOUND");
    expect((await inject({ method: "GET", url: "/v1/topics/not-a-uuid/lesson" })).statusCode).toBe(400);
  });
});

describe("glossary", () => {
  it("searches case-insensitively", async () => {
    const res = await inject({ method: "GET", url: "/v1/glossary?q=hall" });
    expect(res.statusCode).toBe(200);
    expect(res.json().items).toEqual([{ term: "Hall ticket", meaning: expect.any(String) }]);
  });

  it("without q lists terms A-Z", async () => {
    const res = await inject({ method: "GET", url: "/v1/glossary" });
    expect(res.statusCode).toBe(200);
    expect(res.json().items).toHaveLength(16);
  });
});
