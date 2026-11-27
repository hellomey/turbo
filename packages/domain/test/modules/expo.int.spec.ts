// BOLT-0112 integration: expo Prisma adapter, question set reader and lamp check on REAL PostgreSQL (Testcontainers).
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { FakeClock, startPostgres, type StartedDb } from "@heymey/testing";
import { createQuestionSetReader } from "../../src/modules/content/index.js";
import { createLampCheck } from "../../src/modules/mastery/index.js";
import { createExpoModule, EXPO_CONFIG } from "../../src/modules/practice/index.js";

let db: StartedDb;
let prisma: PrismaClient;
const TOPIC = "0199f5a0-0101-7000-8000-000000000101";

beforeAll(async () => {
  db = await startPostgres();
  prisma = createPrismaClient(db.url);
  const expo = await prisma.source.create({ data: { citation: "SEED expo", kind: "original", setName: EXPO_CONFIG.setName } });
  const other = await prisma.source.create({ data: { citation: "SEED other", kind: "original", setName: "other-set" } });
  for (let i = 0; i < 12; i++) {
    const q = await prisma.question.create({ data: { topicId: TOPIC, status: i === 11 ? "draft" : "published" } });
    await prisma.questionVersion.create({
      data: {
        questionId: q.id,
        version: 1,
        stem: `SEED Q${i}`,
        options: [
          { id: "a", text: "A" },
          { id: "b", text: "B" },
        ],
        correctOptionIds: ["b"],
        explanationMarkdown: "Because.",
        sourceId: i === 10 ? other.id : expo.id,
        status: "published",
      },
    });
  }
});

afterAll(async () => {
  await prisma?.$disconnect();
  await db?.stop();
});

function module(randoms?: number[]) {
  const queue = randoms ? [...randoms] : [];
  return createExpoModule({
    prisma,
    clock: new FakeClock("2026-12-09T05:00:00.000Z"),
    randomInt: (max) => (queue.length ? (queue.shift() as number) % max : Math.floor(max / 2)),
    questions: createQuestionSetReader({ prisma }),
    lamps: createLampCheck({ prisma }),
  });
}

describe("expo on Postgres", () => {
  it("picks only published questions of the expo set", async () => {
    expect(await createQuestionSetReader({ prisma }).publishedIdsInSet(EXPO_CONFIG.setName)).toHaveLength(10);
    expect(await createQuestionSetReader({ prisma }).publishedIdsInSet("missing")).toEqual([]);
  });

  it("submits once, even when two submits race", async () => {
    const expo = module();
    const user = randomUUID();
    const c = await expo.startChallenge(user);
    const answers = c.questions.map((q) => ({ questionId: q.id, optionId: "b", ms: 1000 }));
    const both = await Promise.allSettled([expo.submit(user, c.challengeId, { answers }), expo.submit(user, c.challengeId, { answers })]);
    expect(both.filter((r) => r.status === "fulfilled")).toHaveLength(1);
    const ok = both.find((r) => r.status === "fulfilled");
    expect(ok?.status === "fulfilled" && ok.value.score).toBe(10);
  });

  it("draws again on a code collision, keeps one code per user, redeems once", async () => {
    const a = randomUUID();
    const b = randomUUID();
    const expo = module([5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6]);
    await prisma.userTopicState.createMany({ data: [a, b].map((userId) => ({ userId, topicId: TOPIC, goldAt: new Date() })) });
    const ca = (await expo.myStickerCode(a)).code;
    const cb = (await expo.myStickerCode(b)).code;
    expect(ca).toBe("HM-7777");
    expect(cb).toBe("HM-8888");
    expect((await expo.myStickerCode(a)).code).toBe(ca);

    const staff = randomUUID();
    const audited: string[] = [];
    await expo.redeem(staff, "HM-7777", async (tx) => void audited.push(typeof tx.stickerCode.findUnique));
    expect(audited).toEqual(["function"]);
    await expect(expo.redeem(staff, "HM-7777")).rejects.toMatchObject({ code: "STICKER_CODE_ALREADY_REDEEMED" });
    await expect(expo.redeem(staff, "HM-2345")).rejects.toMatchObject({ code: "STICKER_CODE_NOT_FOUND" });
  });

  it("rolls the redeem back when the audit hook fails", async () => {
    const user = randomUUID();
    await prisma.userTopicState.create({ data: { userId: user, topicId: TOPIC, litAt: new Date() } });
    const expo = module([9, 9, 9, 9]);
    const code = String((await expo.myStickerCode(user)).code);
    await expect(expo.redeem(randomUUID(), code, async () => Promise.reject(new Error("audit down")))).rejects.toThrow("audit down");
    expect((await expo.myStickerCode(user)).redeemed).toBe(false);
  });
});
