// exam-hall domain + use-case tests (BOLT-0011). Blueprint §9.9, §9.10, §11, §13, §18, §19.4, §39; U-exam-hall invariants 1-14.
import { beforeEach, describe, expect, it } from "vitest";
import { FakeClock } from "@heymey/testing";
import { createExamHallModule, EXAM_HALL_CONFIG, FREE_FOR_EVERYONE, type ExamHallApi } from "../../src/modules/exam-hall/index.js";
import { add, compare, frac, sub, times, toDisplay, ZERO } from "../../src/modules/exam-hall/domain/fraction.js";
import { rankAttempts } from "../../src/modules/exam-hall/domain/ranking.js";
import {
  checkWindow,
  classifySave,
  deadlineFor,
  istMonthKey,
  modeForPaper,
  nextStateMockSunday,
  remainingSeconds,
  usesAllowance,
} from "../../src/modules/exam-hall/domain/rules.js";
import { hasNegativeMarking, isCorrect, scoreAttempt } from "../../src/modules/exam-hall/domain/scoring.js";
import type { MockRecord, PaperView } from "../../src/modules/exam-hall/domain/types.js";
import { toPaperView } from "../../src/modules/exam-hall/infrastructure/exams-paper-source.js";
import { parseSections } from "../../src/modules/exam-hall/infrastructure/prisma-exam-hall-repository.js";
import { FakeExamHallRepo, FakePapers, FakeQuestions, section, uuid } from "./exam-hall.fakes.js";

const U1 = uuid(9001);
const U2 = uuid(9002);
const U3 = uuid(9003);
const TOPIC_A = uuid(8001);
const TOPIC_B = uuid(8002);
const PAPER = uuid(7001);
const MIN = 60_000;

// ------------------------------------------------------------------ pure rules

describe("fractions (exact marks, no floats)", () => {
  it("reduces, adds, subtracts, compares", () => {
    expect(frac(2, 4)).toEqual({ num: 1, den: 2 });
    expect(frac(1, -3)).toEqual({ num: -1, den: 3 });
    expect(frac(0, 5)).toEqual(ZERO);
    expect(add(frac(1, 3), frac(1, 6))).toEqual(frac(1, 2));
    expect(sub(frac(1), frac(4, 3))).toEqual(frac(-1, 3));
    expect(times(frac(1, 3), 3)).toEqual(frac(1));
    expect(compare(frac(1, 3), frac(1, 4))).toBe(1);
    expect(compare(frac(1, 4), frac(2, 8))).toBe(0);
    expect(() => frac(1, 0)).toThrow(RangeError);
    expect(() => frac(0.5)).toThrow(RangeError);
  });

  it("display rounds half away from zero with integer maths", () => {
    expect(toDisplay(frac(200, 3), 2)).toBe("66.67");
    expect(toDisplay(frac(-4, 3), 2)).toBe("-1.33");
    expect(toDisplay(frac(1, 8), 2)).toBe("0.13");
    expect(toDisplay(frac(50), 2)).toBe("50.00");
    expect(toDisplay(frac(-1, 1000), 2)).toBe("0.00");
    expect(toDisplay(frac(7, 2), 0)).toBe("4");
  });
});

describe("scoring (invariants 6, 7)", () => {
  const q = ["q1", "q2", "q3", "q4"];
  const keys = new Map(q.map((id) => [id, { questionId: id, topicId: TOPIC_A, correctOptionIds: ["A"] }]));
  const ans = (m: Record<string, string[]>) => new Map(Object.entries(m).map(([k, v]) => [k, { chosenOptionIds: v }]));
  const mockSections = [{ sectionCode: "S", questionIds: q }];

  it.each([
    ["no negative marking", section("S"), { q1: ["A"], q2: ["B"] }, frac(1), 1, 1, 2],
    ["1/3 penalty", section("S", { penaltyPerWrong: frac(1, 3) }), { q1: ["A"], q2: ["B"], q3: ["B"] }, frac(1, 3), 1, 2, 1],
    ["1/4 penalty, 2 marks", section("S", { marksPerCorrect: frac(2), penaltyPerWrong: frac(1, 2) }), { q1: ["A"], q2: ["A"], q3: ["C"] }, frac(7, 2), 2, 1, 1],
    ["all wrong goes negative", section("S", { penaltyPerWrong: frac(1, 4) }), { q1: ["B"], q2: ["B"] }, frac(-1, 2), 0, 2, 2],
    ["answer any 2: only first 2 answered count", section("S", { attemptLimit: 2 }), { q1: ["B"], q3: ["A"], q4: ["A"] }, frac(1), 1, 1, 2],
    ["unanswered = 0", section("S"), {}, ZERO, 0, 0, 4],
  ])("%s", (_name, s, answers, score, correct, wrong, unanswered) => {
    const r = scoreAttempt([s], mockSections, ans(answers), keys);
    expect(r.score).toEqual(score);
    expect([r.correct, r.wrong, r.unanswered]).toEqual([correct, wrong, unanswered]);
  });

  it("max score uses the attempt limit; sections not in the mock are skipped; missing key = wrong", () => {
    const r = scoreAttempt(
      [section("S", { attemptLimit: 3, order: 2 }), section("X", { order: 1 })],
      [{ sectionCode: "S", questionIds: [...q, "q5"] }],
      ans({ q5: ["A"] }),
      keys,
    );
    expect(r.sections.map((s) => s.code)).toEqual(["S"]);
    expect(r.maxScore).toEqual(frac(3));
    expect(r.wrong).toBe(1);
  });

  it("TEST-FAMILY: the same answers score differently under two schemes, each by its own scheme only", () => {
    const answers = ans({ q1: ["A"], q2: ["B"], q3: ["B"] });
    const plain = scoreAttempt([section("S")], mockSections, answers, keys);
    const testFamily = scoreAttempt([section("S", { marksPerCorrect: frac(3), penaltyPerWrong: frac(1) })], mockSections, answers, keys);
    expect(plain.score).toEqual(frac(1));
    expect(testFamily.score).toEqual(frac(1));
    const testFamily2 = scoreAttempt([section("S", { marksPerCorrect: frac(4), penaltyPerWrong: frac(1, 2) })], mockSections, answers, keys);
    expect(testFamily2.score).toEqual(frac(3));
  });

  it("multi-choice must match exactly; negative marking detection", () => {
    expect(isCorrect(["B", "A"], ["A", "B"])).toBe(true);
    expect(isCorrect(["A", "A"], ["A", "B"])).toBe(false);
    expect(isCorrect(["A"], ["A", "B"])).toBe(false);
    expect(hasNegativeMarking([section("S")])).toBe(false);
    expect(hasNegativeMarking([section("S", { penaltyPerWrong: frac(1, 3) })])).toBe(true);
  });
});

describe("timer, windows, saves (invariants 1, 2, 5, 10)", () => {
  const stateMock = {
    kind: "state_mock_sunday" as const,
    opensAt: new Date("2026-11-01T04:30:00Z"),
    lateJoinUntil: new Date("2026-11-01T05:00:00Z"),
    closesAt: new Date("2026-11-01T18:29:00Z"),
  };

  it("window: not open, live, practice, closed", () => {
    expect(() => checkWindow(stateMock, new Date("2026-11-01T04:29:59Z"))).toThrow(expect.objectContaining({ code: "MOCK_NOT_OPEN" }));
    expect(checkWindow(stateMock, new Date("2026-11-01T04:45:00Z"))).toEqual({ live: true });
    expect(checkWindow(stateMock, new Date("2026-11-01T05:00:01Z"))).toEqual({ live: false });
    expect(() => checkWindow(stateMock, new Date("2026-11-01T18:29:00Z"))).toThrow(expect.objectContaining({ code: "MOCK_CLOSED" }));
    expect(checkWindow({ kind: "full", opensAt: null, lateJoinUntil: null, closesAt: null }, new Date())).toEqual({ live: false });
  });

  it("deadline = start + duration; live state mock capped at lateJoinUntil + duration", () => {
    const start = new Date("2026-11-01T04:40:00Z");
    expect(deadlineFor(start, 180, { lateJoinUntil: null }, false)).toEqual(new Date(start.getTime() + 180 * MIN));
    expect(deadlineFor(start, 180, stateMock, true)).toEqual(new Date(start.getTime() + 180 * MIN));
    const late = new Date("2026-11-01T05:10:00Z");
    expect(deadlineFor(late, 60, stateMock, true)).toEqual(new Date(stateMock.lateJoinUntil.getTime() + 60 * MIN));
    expect(deadlineFor(late, 60, stateMock, false)).toEqual(new Date(late.getTime() + 60 * MIN));
  });

  it("saves: on time, late (unranked), ignored after grace", () => {
    const d = new Date("2026-11-01T08:00:00Z");
    const grace = EXAM_HALL_CONFIG.answerGraceSeconds * 1000;
    expect(classifySave(new Date(d.getTime() - 1000), new Date(d.getTime() - 2000), d)).toBe("on_time");
    expect(classifySave(new Date(d.getTime() + 1000), d, d)).toBe("late");
    expect(classifySave(d, new Date(d.getTime() + 1000), d)).toBe("late");
    expect(classifySave(new Date(d.getTime() + grace + 1), d, d)).toBe("ignored");
    expect(remainingSeconds(new Date(d.getTime() - 61_500), d)).toBe(61);
    expect(remainingSeconds(new Date(d.getTime() + 5000), d)).toBe(0);
  });

  it("mode comes from the paper; descriptive refused (R4)", () => {
    expect(modeForPaper({ answerMode: "objective_omr" })).toBe("omr");
    expect(modeForPaper({ answerMode: "objective_cbt" })).toBe("cbt");
    expect(() => modeForPaper({ answerMode: "descriptive" })).toThrow(expect.objectContaining({ code: "PAPER_TYPE_NOT_SUPPORTED" }));
  });

  it("allowance only for non-free full mocks; IST month boundary", () => {
    expect(usesAllowance({ kind: "full", free: false })).toBe(true);
    expect(usesAllowance({ kind: "full", free: true })).toBe(false);
    expect(usesAllowance({ kind: "sectional", free: false })).toBe(false);
    expect(usesAllowance({ kind: "state_mock_sunday", free: false })).toBe(false);
    expect(istMonthKey(new Date("2026-10-31T18:29:59Z"))).toBe("2026-10");
    expect(istMonthKey(new Date("2026-10-31T18:30:00Z"))).toBe("2026-11");
  });

  it("next State Mock Sunday = 1st or 3rd Sunday in IST", () => {
    expect(nextStateMockSunday(new Date("2026-10-22T06:00:00Z"))).toBe("2026-11-01");
    expect(nextStateMockSunday(new Date("2026-11-01T10:00:00Z"))).toBe("2026-11-01");
    expect(nextStateMockSunday(new Date("2026-11-01T18:30:00Z"))).toBe("2026-11-15");
    expect(nextStateMockSunday(new Date("2026-11-16T00:00:00Z"))).toBe("2026-12-06");
  });
});

describe("ranking (invariant 12)", () => {
  it("ties share a rank; whole-number percentile; empty", () => {
    const rows = rankAttempts([
      { userId: "c", score: frac(10) },
      { userId: "a", score: frac(30, 2) },
      { userId: "b", score: frac(15) },
      { userId: "d", score: frac(-1, 3) },
    ]);
    expect(rows.map((r) => [r.userId, r.rank, r.percentile])).toEqual([
      ["a", 1, 100],
      ["b", 1, 100],
      ["c", 3, 50],
      ["d", 4, 25],
    ]);
    expect(rows.every((r) => r.candidates === 4)).toBe(true);
    expect(rankAttempts([])).toEqual([]);
  });
});

describe("adapters", () => {
  it("parseSections drops malformed entries", () => {
    expect(parseSections([{ sectionCode: "S", questionIds: ["a", 1] }, { x: 1 }, null])).toEqual([{ sectionCode: "S", questionIds: ["a"] }]);
    expect(parseSections("nope")).toEqual([]);
  });

  it("toPaperView maps raw num/den into reduced fractions", () => {
    const v = toPaperView({
      examCode: "e",
      paperCode: "p",
      answerMode: "objective_cbt",
      qualifyingOnly: true,
      rankScope: "statewide",
      scheme: {
        version: 2, status: "published", durationMinutes: 60, totalQuestions: 1, sourceUrl: "https://x.test/", verifiedAt: null,
        sections: [{ code: "S", name: "S", order: 1, questionCount: 1, attemptLimit: null, correctMarksNum: 2, correctMarksDen: 4, wrongPenaltyNum: 1, wrongPenaltyDen: 3, sectionMinutes: 10 }],
      },
    });
    expect(v.scheme.sections[0]?.marksPerCorrect).toEqual(frac(1, 2));
    expect(v.scheme.sections[0]?.penaltyPerWrong).toEqual(frac(1, 3));
  });
});

// ------------------------------------------------------------------ use cases (fakes)

function paperView(over: Partial<PaperView> = {}, sections = [section("S", { penaltyPerWrong: frac(1, 3) })]): PaperView {
  return {
    examCode: "test-exam",
    paperCode: "paper-1",
    answerMode: "objective_omr",
    qualifyingOnly: false,
    rankScope: "statewide",
    scheme: { version: 1, status: "published", durationMinutes: 60, totalQuestions: 4, sections },
    ...over,
  };
}

describe("exam hall use cases", () => {
  let clock: FakeClock;
  let repo: FakeExamHallRepo;
  let papers: FakePapers;
  let questions: FakeQuestions;
  let events: { type: string; payload: unknown }[];
  let pro: Set<string>;
  let hall: ExamHallApi;
  const QIDS = [uuid(6001), uuid(6002), uuid(6003), uuid(6004)];

  function addMock(over: Partial<MockRecord> = {}): MockRecord {
    const m: MockRecord = {
      id: uuid(),
      code: `m-${repo.mocks.size}`,
      examCode: "test-exam",
      paperId: PAPER,
      schemeVersion: 1,
      title: "Mock",
      kind: "full",
      sections: [{ sectionCode: "S", questionIds: QIDS }],
      opensAt: null,
      lateJoinUntil: null,
      closesAt: null,
      rankPublishAt: null,
      free: false,
      status: "published",
      ...over,
    };
    repo.mocks.set(m.id, m);
    return m;
  }

  const at = (iso: string) => clock.set(iso);
  const answer = (questionId: string, chosen: string[], clientAt = clock.now().toISOString()) => ({ questionId, chosenOptionIds: chosen, markedForReview: false, clientAt });

  beforeEach(() => {
    clock = new FakeClock("2026-10-22T06:00:00.000Z");
    repo = new FakeExamHallRepo();
    papers = new FakePapers();
    questions = new FakeQuestions();
    events = [];
    pro = new Set();
    papers.add(PAPER, 1, paperView());
    QIDS.forEach((id, i) => questions.add(id, i < 2 ? TOPIC_A : TOPIC_B, ["A"], { B: "B is a trap." }));
    hall = createExamHallModule({
      repository: repo,
      papers,
      questions,
      clock,
      entitlements: { isPro: async (u) => pro.has(u) },
      events: { publish: async (e) => void events.push({ type: e.type, payload: e.payload }) },
    });
  });

  it("start sets server times, hides keys; resume returns the same attempt (invariants 1, 3)", async () => {
    const m = addMock();
    const a = await hall.start(U1, m.id, "omr");
    expect(a.startedAt).toBe("2026-10-22T06:00:00.000Z");
    expect(a.deadlineAt).toBe("2026-10-22T07:00:00.000Z");
    expect(a.questions).toHaveLength(4);
    expect(JSON.stringify(a)).not.toContain("correctOptionIds");
    expect(a.mock).toMatchObject({ negativeMarking: true, durationMinutes: 60, paperCode: "paper-1", myLastAttemptId: a.attemptId });
    expect(a.sections[0]).toMatchObject({ code: "S", name: "Section S", minutes: null });
    clock.advanceMinutes(10);
    const again = await hall.start(U1, m.id, "omr");
    expect(again.attemptId).toBe(a.attemptId);
    expect(again.deadlineAt).toBe(a.deadlineAt);
    const resumed = await hall.get(U1, a.attemptId);
    expect(resumed.serverNow).toBe("2026-10-22T06:10:00.000Z");
  });

  it("refuses unknown/draft mocks, unpublished schemes, descriptive papers and the wrong mode", async () => {
    await expect(hall.start(U1, uuid(), "omr")).rejects.toMatchObject({ code: "MOCK_NOT_FOUND" });
    const draft = addMock({ status: "draft" });
    await expect(hall.start(U1, draft.id, "omr")).rejects.toMatchObject({ code: "MOCK_NOT_FOUND" });
    const noPaper = addMock({ paperId: uuid() });
    await expect(hall.start(U1, noPaper.id, "omr")).rejects.toMatchObject({ code: "MOCK_NOT_FOUND" });
    papers.add(PAPER, 2, paperView({ scheme: { ...paperView().scheme, version: 2, status: "draft" } }));
    const draftScheme = addMock({ schemeVersion: 2 });
    await expect(hall.start(U1, draftScheme.id, "omr")).rejects.toMatchObject({ code: "MOCK_NOT_FOUND" });
    const DESC = uuid();
    papers.add(DESC, 1, paperView({ answerMode: "descriptive" }));
    const desc = addMock({ paperId: DESC });
    await expect(hall.start(U1, desc.id, "omr")).rejects.toMatchObject({ code: "PAPER_TYPE_NOT_SUPPORTED" });
    await expect(hall.start(U1, addMock().id, "cbt")).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
  });

  it("free user: 1 full mock per IST month; sectional, free and State mocks do not count; Pro unlimited (invariant 4)", async () => {
    const m1 = addMock();
    const m2 = addMock();
    await hall.start(U1, m1.id, "omr");
    await expect(hall.start(U1, m2.id, "omr")).rejects.toMatchObject({ code: "MOCK_MONTHLY_LIMIT" });
    await hall.start(U1, addMock({ kind: "sectional" }).id, "omr");
    await hall.start(U1, addMock({ free: true }).id, "omr");
    const list = await hall.listMocks(U1, "test-exam");
    expect(list.allowance).toEqual({ istMonth: "2026-10", freeFullMocksUsed: 1, freeFullMocksLimit: 1 });
    expect(list.items.find((i) => i.id === m2.id)?.locked).toBe(true);
    expect(list.items.find((i) => i.kind === "sectional")?.locked).toBe(false);
    at("2026-10-31T18:30:00.000Z"); // next IST month
    await hall.start(U1, m2.id, "omr");
    pro.add(U2);
    await hall.start(U2, m1.id, "omr");
    await hall.start(U2, m2.id, "omr");
    expect((await hall.listMocks(U2, "test-exam")).allowance.freeFullMocksLimit).toBeNull();
  });

  it("list hides closed, draft-scheme and descriptive mocks", async () => {
    addMock({ closesAt: new Date("2026-10-22T05:00:00Z") });
    addMock({ paperId: uuid() });
    const ok = addMock();
    expect((await hall.listMocks(U1, "test-exam")).items.map((i) => i.id)).toEqual([ok.id]);
    expect((await hall.listMocks(U1, "other")).items).toEqual([]);
  });

  it("answers: last write wins, late saves unrank, saves after grace ignored (invariant 5)", async () => {
    const m = addMock();
    const a = await hall.start(U1, m.id, "omr");
    const [q1, q2] = QIDS as [string, string];
    const t0 = clock.now().toISOString();
    clock.advanceMinutes(1);
    const r = await hall.saveAnswers(U1, a.attemptId, [answer(q1, ["B"]), answer(q1, ["A"]), answer(q2, ["A"], t0)]);
    expect(r).toMatchObject({ saved: 2, ignoredAfterDeadline: 0, remainingSeconds: 59 * 60 });
    // An older offline write never overwrites a newer one.
    await hall.saveAnswers(U1, a.attemptId, [answer(q1, ["C"], t0)]);
    expect((await hall.get(U1, a.attemptId)).answers.find((x) => x.questionId === q1)?.chosenOptionIds).toEqual(["A"]);
    await expect(hall.saveAnswers(U1, a.attemptId, [answer(uuid(), ["A"])])).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
    clock.advanceMinutes(60); // 1 minute after the deadline, inside grace
    const late = await hall.saveAnswers(U1, a.attemptId, [answer(q2, ["B"])]);
    expect(late.saved).toBe(1);
    expect((await hall.get(U1, a.attemptId)).ranked).toBe(false);
    clock.advanceMinutes(5); // past grace
    const ignored = await hall.saveAnswers(U1, a.attemptId, [answer(q2, ["A"])]);
    expect(ignored).toMatchObject({ saved: 0, ignoredAfterDeadline: 1 });
    expect((await hall.get(U1, a.attemptId)).status).toBe("expired");
  });

  it("owner only: another user's attempt is NOT_FOUND, same as unknown (SEC-P2-L3)", async () => {
    const a = await hall.start(U1, addMock().id, "omr");
    await expect(hall.get(U2, a.attemptId)).rejects.toMatchObject({ code: "NOT_FOUND" });
    await expect(hall.submit(U2, a.attemptId)).rejects.toMatchObject({ code: "NOT_FOUND" });
    await expect(hall.get(U1, uuid())).rejects.toMatchObject({ code: "NOT_FOUND" });
  });

  it("submit scores with the scheme, twice = same report; report locked for free users (invariants 6, 9, 13, 14)", async () => {
    const m = addMock();
    const a = await hall.start(U1, m.id, "omr");
    const [q1, q2, q3] = QIDS as [string, string, string];
    await hall.saveAnswers(U1, a.attemptId, [answer(q1, ["A"]), answer(q2, ["B"]), answer(q3, ["B"])]);
    await expect(hall.report(U1, a.attemptId)).rejects.toMatchObject({ code: "REPORT_NOT_FOUND" });
    clock.advanceMinutes(20);
    const r1 = await hall.submit(U1, a.attemptId);
    expect(r1).toMatchObject({
      score: { numerator: 1, denominator: 3 },
      maxScore: { numerator: 4, denominator: 1 },
      scoreDisplay: "0.33",
      correct: 1,
      wrong: 2,
      unanswered: 1,
      markingSchemeVersion: 1,
      ranked: false,
      fullReportLocked: true,
      submittedAt: "2026-10-22T06:20:00.000Z",
    });
    expect(r1.mistakes.map((x) => [x.questionId, x.topicId, x.whyChosenIsWrong])).toEqual([
      [q2, TOPIC_A, "B is a trap."],
      [q3, TOPIC_B, "B is a trap."],
    ]);
    expect(r1.weakTopicIds).toEqual([TOPIC_A, TOPIC_B].sort());
    clock.advanceMinutes(1);
    expect(await hall.submit(U1, a.attemptId)).toEqual(r1);
    expect(await hall.report(U1, a.attemptId)).toEqual(r1);
    expect(events.filter((e) => e.type === "exam_hall.mock_submitted")).toHaveLength(1);
    expect(events[0]?.payload).toMatchObject({ attemptId: a.attemptId, mistakeTopicIds: [TOPIC_A, TOPIC_B] });
    await expect(hall.saveAnswers(U1, a.attemptId, [answer(q1, ["B"])])).rejects.toMatchObject({ code: "MOCK_ALREADY_SUBMITTED" });
    pro.add(U1);
    expect((await hall.report(U1, a.attemptId)).fullReportLocked).toBe(false);
  });

  it("negative totals: Marks shows 0, scoreDisplay shows the exact negative value", async () => {
    const a = await hall.start(U1, addMock().id, "omr");
    await hall.saveAnswers(U1, a.attemptId, [answer(QIDS[0] as string, ["B"])]);
    const r = await hall.submit(U1, a.attemptId);
    expect(r.score).toEqual({ numerator: 0, denominator: 1 });
    expect(r.scoreDisplay).toBe("-0.33");
    expect(r.sections[0]?.score).toEqual({ numerator: 0, denominator: 1 });
  });

  it("a new scheme version never rescoring old attempts (invariant 8)", async () => {
    const m = addMock();
    const a = await hall.start(U1, m.id, "omr");
    await hall.saveAnswers(U1, a.attemptId, [answer(QIDS[0] as string, ["A"])]);
    const before = await hall.submit(U1, a.attemptId);
    papers.add(PAPER, 1, paperView({}, [section("S", { marksPerCorrect: frac(5) })])); // even if v1 data changed
    m.schemeVersion = 2;
    papers.add(PAPER, 2, paperView({ scheme: { ...paperView().scheme, version: 2 } }, [section("S", { marksPerCorrect: frac(2) })]));
    expect((await hall.report(U1, a.attemptId)).score).toEqual(before.score);
    expect((await hall.report(U1, a.attemptId)).markingSchemeVersion).toBe(1);
  });

  it("expire job auto-scores overdue attempts once (invariant 9)", async () => {
    const a = await hall.start(U1, addMock().id, "omr");
    await hall.saveAnswers(U1, a.attemptId, [answer(QIDS[0] as string, ["A"])]);
    expect(await hall.expireOverdue()).toEqual({ expired: 0 });
    clock.advanceMinutes(63);
    expect(await hall.expireOverdue()).toEqual({ expired: 1 });
    expect(await hall.expireOverdue()).toEqual({ expired: 0 });
    const r = await hall.report(U1, a.attemptId);
    expect(r).toMatchObject({ submittedAt: "2026-10-22T07:00:00.000Z", correct: 1 });
    expect((await hall.submit(U1, a.attemptId)).submittedAt).toBe(r.submittedAt);
    expect((await hall.history(U1, null, 10)).items[0]).toMatchObject({ status: "expired", scoreDisplay: "1.00" });
  });

  it("an expired open attempt is closed and a fresh one starts", async () => {
    const m = addMock({ kind: "sectional" });
    const a = await hall.start(U1, m.id, "omr");
    clock.advanceMinutes(90);
    const b = await hall.start(U1, m.id, "omr");
    expect(b.attemptId).not.toBe(a.attemptId);
    expect((await hall.get(U1, a.attemptId)).status).toBe("expired");
  });

  it("history pages newest first", async () => {
    for (let i = 0; i < 3; i += 1) {
      await hall.start(U1, addMock({ kind: "sectional", title: `T${i}` }).id, "omr");
      clock.advanceMinutes(1);
    }
    const p1 = await hall.history(U1, null, 2);
    expect(p1.items.map((x) => x.title)).toEqual(["T2", "T1"]);
    expect(p1.items[0]?.scoreDisplay).toBeNull();
    const p2 = await hall.history(U1, p1.nextCursor, 2);
    expect(p2).toMatchObject({ items: [{ title: "T0" }], nextCursor: null });
  });

  describe("State Mock Sunday (invariants 10-12)", () => {
    const opensAt = new Date("2026-11-01T04:30:00Z"); // 10:00 IST
    const lateJoinUntil = new Date("2026-11-01T05:00:00Z");
    const closesAt = new Date("2026-11-01T18:29:00Z");
    const rankPublishAt = new Date("2026-11-01T14:30:00Z"); // 20:00 IST
    const sunday = () => addMock({ kind: "state_mock_sunday", opensAt, lateJoinUntil, closesAt, rankPublishAt, title: "State Mock" });

    it("info: scheduled mock + next 1st/3rd Sunday; none scheduled", async () => {
      expect(await hall.stateMockSunday("test-exam")).toEqual({ mock: null, nextSunday: "2026-11-01", rankPublishAt: null });
      const m = sunday();
      const info = await hall.stateMockSunday("test-exam");
      expect(info.mock?.id).toBe(m.id);
      expect(info.rankPublishAt).toBe(rankPublishAt.toISOString());
    });

    it("full flow: not open, ranked live takers, unranked late joiner, ties, rank once", async () => {
      const m = sunday();
      at("2026-11-01T04:00:00Z");
      await expect(hall.start(U1, m.id, "omr")).rejects.toMatchObject({ code: "MOCK_NOT_OPEN" });
      await expect(hall.statewideRank(U1, m.id)).rejects.toMatchObject({ code: "RANK_NOT_READY" });

      at("2026-11-01T04:31:00Z");
      const a1 = await hall.start(U1, m.id, "omr");
      const a2 = await hall.start(U2, m.id, "omr");
      expect(a1.ranked && a2.ranked).toBe(true);
      await hall.saveAnswers(U1, a1.attemptId, [answer(QIDS[0] as string, ["A"])]);
      await hall.saveAnswers(U2, a2.attemptId, [answer(QIDS[1] as string, ["A"])]);
      await hall.submit(U1, a1.attemptId);
      // U2 never submits: auto-submitted at the deadline and still ranked.

      at("2026-11-01T06:00:00Z"); // after late join: practice only
      const a3 = await hall.start(U3, m.id, "omr");
      expect(a3.ranked).toBe(false);
      await hall.saveAnswers(U3, a3.attemptId, [answer(QIDS[0] as string, ["A"]), answer(QIDS[1] as string, ["A"])]);
      await hall.submit(U3, a3.attemptId);

      at("2026-11-01T14:00:00Z");
      expect(await hall.publishRanks()).toEqual({ mocks: 0, rows: 0 });
      at("2026-11-01T14:30:00Z");
      expect(await hall.publishRanks()).toEqual({ mocks: 1, rows: 2 });
      expect(await hall.publishRanks()).toEqual({ mocks: 0, rows: 0 });
      expect(events.some((e) => e.type === "exam_hall.rank_published")).toBe(true);

      const r1 = await hall.statewideRank(U1, m.id);
      const r2 = await hall.statewideRank(U2, m.id);
      expect(r1).toMatchObject({ rank: 1, rankedCandidates: 2, percentile: 100, scopeLabel: "statewide", score: { numerator: 1, denominator: 1 } });
      expect(r2.rank).toBe(1);
      await expect(hall.statewideRank(U3, m.id)).rejects.toMatchObject({ code: "NOT_FOUND" });
      await expect(hall.statewideRank(U1, uuid())).rejects.toMatchObject({ code: "MOCK_NOT_FOUND" });

      at("2026-11-01T18:29:00Z");
      await expect(hall.start(uuid(), m.id, "omr")).rejects.toMatchObject({ code: "MOCK_CLOSED" });
      expect((await hall.stateMockSunday("test-exam")).mock).toBeNull();
    });

    it("a second attempt of the same State Mock is never ranked; no ranked takers = nothing published", async () => {
      const m = sunday();
      at("2026-11-01T04:31:00Z");
      const a = await hall.start(U1, m.id, "omr");
      await hall.submit(U1, a.attemptId);
      const b = await hall.start(U1, m.id, "omr");
      expect(b.ranked).toBe(false);
      const m2 = sunday();
      at("2026-11-01T15:00:00Z");
      const res = await hall.publishRanks();
      expect(res.mocks).toBe(1);
      expect(await repo.ranksPublished(m2.id)).toBe(false);
    });
  });

  it("FREE_FOR_EVERYONE is the default entitlement until billing lands", async () => {
    expect(await FREE_FOR_EVERYONE.isPro(U1)).toBe(false);
    const free = createExamHallModule({ repository: repo, papers, questions, clock });
    const a = await free.start(U1, addMock().id, "omr");
    expect((await free.submit(U1, a.attemptId)).fullReportLocked).toBe(true);
  });
});
