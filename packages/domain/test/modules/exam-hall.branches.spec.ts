// exam-hall branch-gap tests (BOLT-0020 QA). Blueprint §9.9, §18, §19.4, §39; U-exam-hall invariants 5, 9, 12, 13.
// Covers race/edge branches the main spec does not reach: lost finish race, expire batching, rank lookups,
// report mistakes with missing keys / no "why wrong" text, and the Prisma wiring branch of the module factory.
import { beforeEach, describe, expect, it } from "vitest";
import type { PrismaClient } from "@heymey/db";
import { FakeClock } from "@heymey/testing";
import { createExamHallModule, type ExamHallApi } from "../../src/modules/exam-hall/index.js";
import { frac } from "../../src/modules/exam-hall/domain/fraction.js";
import type { FinishInput } from "../../src/modules/exam-hall/application/ports.js";
import type { MockRecord, PaperView } from "../../src/modules/exam-hall/domain/types.js";
import { FakeExamHallRepo, FakePapers, FakeQuestions, section, uuid } from "./exam-hall.fakes.js";

const U1 = uuid(19001);
const U2 = uuid(19002);
const TOPIC = uuid(18001);
const PAPER = uuid(17001);
const QIDS = [uuid(16001), uuid(16002), uuid(16003)];

/** Simulates another worker closing the attempt first: finish reports "not changed" and leaves the row open. */
class LosingRaceRepo extends FakeExamHallRepo {
  lose = false;
  override async finishAttempt(attemptId: string, input: FinishInput) {
    if (!this.lose) return super.finishAttempt(attemptId, input);
    const a = this.attempts.get(attemptId);
    if (!a) throw new Error("missing");
    return { attempt: { ...a }, changed: false };
  }
}

function paperView(over: Partial<PaperView> = {}): PaperView {
  return {
    examCode: "test-exam",
    paperCode: "paper-1",
    answerMode: "objective_omr",
    qualifyingOnly: false,
    rankScope: "statewide",
    scheme: { version: 1, status: "published", durationMinutes: 60, totalQuestions: 3, sections: [section("S", { penaltyPerWrong: frac(1, 3) })] },
    ...over,
  };
}

describe("exam hall branch gaps (BOLT-0020 QA)", () => {
  let clock: FakeClock;
  let repo: LosingRaceRepo;
  let questions: FakeQuestions;
  let events: string[];
  let hall: ExamHallApi;

  const addMock = (over: Partial<MockRecord> = {}): MockRecord => {
    const m: MockRecord = {
      id: uuid(), code: `b-${repo.mocks.size}`, examCode: "test-exam", paperId: PAPER, schemeVersion: 1, title: "Mock", kind: "sectional",
      sections: [{ sectionCode: "S", questionIds: QIDS }], opensAt: null, lateJoinUntil: null, closesAt: null, rankPublishAt: null,
      free: false, status: "published", ...over,
    };
    repo.mocks.set(m.id, m);
    return m;
  };
  const answer = (questionId: string, chosen: string[], clientAt = clock.now().toISOString()) => ({ questionId, chosenOptionIds: chosen, markedForReview: false, clientAt });

  beforeEach(() => {
    clock = new FakeClock("2026-10-22T06:00:00.000Z");
    repo = new LosingRaceRepo();
    const papers = new FakePapers();
    papers.add(PAPER, 1, paperView());
    questions = new FakeQuestions();
    // q1 has a "why wrong" text for B; q2 has none; q3 has no key at all (withKeys omits it).
    questions.add(QIDS[0] as string, TOPIC, ["A"], { B: "B is a trap." });
    questions.add(QIDS[1] as string, TOPIC, ["A"]);
    events = [];
    hall = createExamHallModule({ repository: repo, papers, questions, clock, events: { publish: async (e) => void events.push(e.type) } });
  });

  it("report: mistakes skip questions without a key; no why-wrong text gives null; mistakes keep paper order (invariant 13)", async () => {
    const a = await hall.start(U1, addMock().id, "omr");
    const [q1, q2, q3] = QIDS as [string, string, string];
    await hall.saveAnswers(U1, a.attemptId, [answer(q3, ["B"]), answer(q2, ["C"]), answer(q1, ["B"])]);
    const r = await hall.submit(U1, a.attemptId);
    expect(r.mistakes.map((m) => [m.questionId, m.whyChosenIsWrong])).toEqual([
      [q1, "B is a trap."],
      [q2, null],
    ]);
  });

  it("lost finish race: no duplicate submitted event; saves while the server still sees it open past grace are ignored (invariants 5, 9)", async () => {
    const a = await hall.start(U1, addMock().id, "omr");
    repo.lose = true;
    clock.advanceMinutes(70); // past deadline + grace, but another closer "won" and the row still reads open
    const r = await hall.saveAnswers(U1, a.attemptId, [answer(QIDS[0] as string, ["A"])]);
    expect(r).toMatchObject({ saved: 0, ignoredAfterDeadline: 1, remainingSeconds: 0 });
    expect(events).not.toContain("exam_hall.mock_submitted");
  });

  it("expire job: works in batches of 200 until fewer remain; stops if a batch closes nothing (invariant 9)", async () => {
    const m = addMock();
    for (let i = 0; i < 201; i += 1) await hall.start(uuid(), m.id, "omr");
    clock.advanceMinutes(63);
    expect(await hall.expireOverdue()).toEqual({ expired: 201 });

    await hall.start(U2, addMock().id, "omr");
    clock.advanceMinutes(63);
    repo.lose = true; // every close is lost to another worker -> loop must not spin
    expect(await hall.expireOverdue()).toEqual({ expired: 0 });
  });

  it("statewide rank: no publish time / before publish -> RANK_NOT_READY; published but user not ranked -> NOT_FOUND (§18, invariant 12)", async () => {
    const noTime = addMock({ kind: "state_mock_sunday", rankPublishAt: null });
    await expect(hall.statewideRank(U1, noTime.id)).rejects.toMatchObject({ code: "RANK_NOT_READY", details: { rankPublishAt: null } });
    await expect(hall.statewideRank(U1, uuid())).rejects.toMatchObject({ code: "MOCK_NOT_FOUND" });

    const opens = new Date("2026-11-01T04:30:00.000Z");
    const m = addMock({
      kind: "state_mock_sunday", opensAt: opens, lateJoinUntil: new Date(opens.getTime() + 15 * 60_000),
      closesAt: new Date(opens.getTime() + 24 * 3600_000), rankPublishAt: new Date(opens.getTime() + 26 * 3600_000),
    });
    clock.set(opens.toISOString());
    const a = await hall.start(U2, m.id, "omr");
    await hall.saveAnswers(U2, a.attemptId, [answer(QIDS[0] as string, ["A"])]);
    await hall.submit(U2, a.attemptId);
    await expect(hall.statewideRank(U2, m.id)).rejects.toMatchObject({ code: "RANK_NOT_READY" });
    clock.set(new Date(opens.getTime() + 27 * 3600_000).toISOString());
    expect((await hall.publishRanks()).mocks).toBe(1);
    expect((await hall.statewideRank(U2, m.id)).rank).toBe(1);
    await expect(hall.statewideRank(U1, m.id)).rejects.toMatchObject({ code: "NOT_FOUND" });
  });

  it("factory: the Prisma wiring branch builds a module without touching the database", () => {
    const api = createExamHallModule({ prisma: {} as unknown as PrismaClient, clock });
    expect(typeof api.start).toBe("function");
  });
});
