// BOLT-0112 stall: expo challenge + sticker codes through the module interface, with an in-memory repository.
import { describe, expect, it } from "vitest";
import { FakeClock } from "@heymey/testing";
import {
  canRedeemStickerCodes,
  createExpoModule,
  newStickerCode,
  normalizeStickerCode,
  type ExpoChallengeRecord,
  type ExpoRepository,
  type RedeemOutcome,
} from "../../src/modules/practice/index.js";
import type { QuestionWithKey } from "../../src/modules/content/index.js";

const U1 = "00000000-0000-4000-8000-0000000000a1";
const U2 = "00000000-0000-4000-8000-0000000000a2";
const STAFF = "00000000-0000-4000-8000-0000000000f1";
const qid = (i: number) => `5e000000-e001-4000-8000-${String(i).padStart(12, "0")}`;

function bank(n: number): QuestionWithKey[] {
  return Array.from({ length: n }, (_, i) => {
    const source = { citation: "HeyMey original", url: null, pyq: null };
    return {
      question: {
        id: qid(i),
        version: 1,
        topicId: qid(900),
        kind: "single_choice",
        language: "en",
        stem: `Q${i}`,
        options: [
          { id: "a", text: "A" },
          { id: "b", text: "B" },
        ],
        difficulty: 1,
        source,
        affectedNote: null,
      },
      key: { questionId: qid(i), topicId: qid(900), correctOptionIds: ["a"], explanationMarkdown: `Because ${i}.`, whyWrong: {}, source },
    } as QuestionWithKey;
  });
}

class MemRepo implements ExpoRepository {
  challenges = new Map<string, ExpoChallengeRecord>();
  codes = new Map<string, { code: string; reason: string; redeemedAt: Date | null; redeemedBy: string | null }>();
  private n = 0;
  async createChallenge(c: Omit<ExpoChallengeRecord, "id" | "submittedAt">) {
    const id = `00000000-0000-4000-8000-${String(++this.n).padStart(12, "0")}`;
    this.challenges.set(id, { ...c, id, submittedAt: null });
    return id;
  }
  async getChallenge(id: string) {
    return this.challenges.get(id) ?? null;
  }
  async markSubmitted(id: string, at: Date) {
    const c = this.challenges.get(id);
    if (!c || c.submittedAt) return false;
    c.submittedAt = at;
    return true;
  }
  async stickerCodeOf(userId: string) {
    const c = this.codes.get(userId);
    return c ? { code: c.code, redeemedAt: c.redeemedAt } : null;
  }
  async insertStickerCode(userId: string, code: string, reason: string) {
    if (this.codes.has(userId)) return "user_has_code" as const;
    if ([...this.codes.values()].some((c) => c.code === code)) return "code_taken" as const;
    this.codes.set(userId, { code, reason, redeemedAt: null, redeemedBy: null });
    return "ok" as const;
  }
  async redeem(code: string, by: string, at: Date, inTx?: (tx: never) => Promise<void>): Promise<RedeemOutcome> {
    const c = [...this.codes.values()].find((x) => x.code === code);
    if (!c) return { kind: "not_found" };
    if (c.redeemedAt) return { kind: "already" };
    c.redeemedAt = at;
    c.redeemedBy = by;
    if (inTx) await inTx(undefined as never);
    return { kind: "ok", redeemedAt: at };
  }
}

function setup(opts: { questions?: number; lit?: Set<string>; randoms?: number[] } = {}) {
  const repo = new MemRepo();
  const clock = new FakeClock("2026-12-09T05:00:00.000Z");
  const all = bank(opts.questions ?? 30);
  const randoms = opts.randoms ? [...opts.randoms] : null;
  let seq = 0;
  const expo = createExpoModule({
    repository: repo,
    clock,
    randomInt: (max) => (randoms?.length ? (randoms.shift() as number) : seq++ % max),
    questions: {
      publishedIdsInSet: async () => all.map((q) => q.question.id),
      withKeys: async (ids) => all.filter((q) => ids.includes(q.question.id)),
    },
    lamps: { hasLitLamp: async (userId) => opts.lit?.has(userId) ?? false },
  });
  return { expo, repo, clock };
}

describe("expo challenge", () => {
  it("serves 10 distinct questions with 20 seconds each and no answers", async () => {
    const { expo } = setup();
    const c = await expo.startChallenge(U1);
    expect(c.questions).toHaveLength(10);
    expect(new Set(c.questions.map((q) => q.id)).size).toBe(10);
    expect(c.secondsPerQuestion).toBe(20);
    expect(Object.keys(c.questions[0] ?? {}).sort()).toEqual(["id", "options", "stem"]);
    expect(JSON.stringify(c)).not.toContain("Because");
  });

  it("serves what there is when the set has fewer than 10, and refuses an empty set", async () => {
    expect((await setup({ questions: 4 }).expo.startChallenge(U1)).questions).toHaveLength(4);
    await expect(setup({ questions: 0 }).expo.startChallenge(U1)).rejects.toMatchObject({ code: "EXPO_CHALLENGE_UNAVAILABLE" });
  });

  it("grades on the server, counts unanswered as wrong and awards a sticker code for finishing", async () => {
    const { expo } = setup();
    const c = await expo.startChallenge(U1);
    const [q0, q1] = c.questions.map((q) => q.id) as [string, string];
    const r = await expo.submit(U1, c.challengeId, {
      answers: [
        { questionId: q0, optionId: "a", ms: 3000 },
        { questionId: q1, optionId: "b", ms: 4000 },
      ],
    });
    expect(r.score).toBe(1);
    expect(r.total).toBe(10);
    expect(r.results).toHaveLength(10);
    expect(r.results[0]).toEqual({ questionId: q0, correct: true, correctOptionId: "a", explanation: expect.stringMatching(/^Because/) });
    expect(r.results[1]?.correct).toBe(false);
    expect(r.results[2]?.correct).toBe(false);
    expect(r.stickerCode).toMatch(/^HM-[2-9A-HJ-NP-Z]{4}$/);
    expect(await expo.myStickerCode(U1)).toEqual({ code: r.stickerCode, redeemed: false });
  });

  it("ignores answers to questions that were not in the challenge", async () => {
    const { expo } = setup();
    const c = await expo.startChallenge(U1);
    const r = await expo.submit(U1, c.challengeId, { answers: [{ questionId: qid(777), optionId: "a", ms: 1 }] });
    expect(r.score).toBe(0);
    expect(r.results.map((x) => x.questionId)).toEqual(c.questions.map((q) => q.id));
  });

  it("accepts one submit only, refuses other users and refuses after 15 minutes", async () => {
    const { expo, clock } = setup();
    const c = await expo.startChallenge(U1);
    await expect(expo.submit(U2, c.challengeId, { answers: [] })).rejects.toMatchObject({ code: "EXPO_CHALLENGE_NOT_FOUND" });
    await expo.submit(U1, c.challengeId, { answers: [] });
    await expect(expo.submit(U1, c.challengeId, { answers: [] })).rejects.toMatchObject({ code: "EXPO_CHALLENGE_ALREADY_SUBMITTED" });

    const late = await expo.startChallenge(U2);
    clock.set("2026-12-09T05:15:00.001Z");
    await expect(expo.submit(U2, late.challengeId, { answers: [] })).rejects.toMatchObject({ code: "EXPO_CHALLENGE_EXPIRED" });
  });

  it("keeps the first code when the same user finishes again", async () => {
    const { expo } = setup();
    const a = await expo.submit(U1, (await expo.startChallenge(U1)).challengeId, { answers: [] });
    const b = await expo.submit(U1, (await expo.startChallenge(U1)).challengeId, { answers: [] });
    expect(b.stickerCode).toBe(a.stickerCode);
  });
});

describe("sticker codes", () => {
  it("has no code before finishing the challenge or lighting a lamp", async () => {
    expect(await setup().expo.myStickerCode(U1)).toEqual({ code: null, redeemed: false });
  });

  it("earns a code once a first lamp is lit", async () => {
    const { expo, repo } = setup({ lit: new Set([U1]) });
    const mine = await expo.myStickerCode(U1);
    expect(mine.code).toMatch(/^HM-[2-9A-HJ-NP-Z]{4}$/);
    expect(repo.codes.get(U1)?.reason).toBe("first_lamp");
    expect((await expo.myStickerCode(U1)).code).toBe(mine.code);
  });

  it("retries when a generated code is already taken", async () => {
    // User 1 draws index 0 four times = HM-2222; user 2 first draws the same, then index 1 four times = HM-3333.
    const { expo } = setup({ lit: new Set([U1, U2]), randoms: [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1] });
    expect((await expo.myStickerCode(U1)).code).toBe("HM-2222");
    expect((await expo.myStickerCode(U2)).code).toBe("HM-3333");
  });

  it("redeems a code once, forgiving case and spaces, with an audit hook", async () => {
    const { expo, clock } = setup({ lit: new Set([U1]) });
    const code = String((await expo.myStickerCode(U1)).code);
    const audited: string[] = [];
    const r = await expo.redeem(STAFF, `  ${code.toLowerCase()} `, async () => void audited.push(code));
    expect(r).toEqual({ redeemed: true, redeemedAt: clock.now().toISOString() });
    expect(audited).toEqual([code]);
    expect(await expo.myStickerCode(U1)).toEqual({ code, redeemed: true });
    await expect(expo.redeem(STAFF, code)).rejects.toMatchObject({ code: "STICKER_CODE_ALREADY_REDEEMED" });
  });

  it("refuses unknown or malformed codes", async () => {
    const { expo } = setup();
    await expect(expo.redeem(STAFF, "HM-2345")).rejects.toMatchObject({ code: "STICKER_CODE_NOT_FOUND" });
    await expect(expo.redeem(STAFF, "HM-0OI1")).rejects.toMatchObject({ code: "STICKER_CODE_NOT_FOUND" });
  });
});

describe("sticker code rules", () => {
  it("builds HM- plus 4 characters without 0, O, 1 or I", () => {
    expect(newStickerCode(() => 0)).toBe("HM-2222");
    expect(newStickerCode((max) => max - 1)).toBe("HM-ZZZZ");
  });

  it("normalizes input and rejects ambiguous characters", () => {
    expect(normalizeStickerCode(" hm-7kqx ")).toBe("HM-7KQX");
    expect(normalizeStickerCode("HM-7KQO")).toBeNull();
    expect(normalizeStickerCode("7KQX")).toBeNull();
  });

  it("lets only Ops, Admin and Support agents redeem", () => {
    expect(canRedeemStickerCodes(["OPS"])).toBe(true);
    expect(canRedeemStickerCodes(["SUPPORT_AGENT"])).toBe(true);
    expect(canRedeemStickerCodes(["ADMIN"])).toBe(true);
    expect(canRedeemStickerCodes(["REVIEWER", "ASPIRANT"])).toBe(false);
  });
});
