// BOLT-0010: practice domain rules + use cases with fakes (blueprint §10.6, §11, §13, §19.4, §19.6 Q60, §37, §39).
// U-practice invariants 1-13. Time is a FakeClock; IST day = Asia/Kolkata.
import { randomUUID } from "node:crypto";
import { describe, expect, it } from "vitest";
import { FakeClock } from "@heymey/testing";
import { DomainError } from "../../src/shared/index.js";
import {
  PRACTICE_CONFIG,
  addWrong,
  dailyLimitFor,
  decideCount,
  decodeCursor,
  drillDue,
  encodeCursor,
  isCountedMode,
  isWeak,
  judgedAnswerTime,
  lockQuestion,
  nextIstMidnight,
  unlockedYears,
  usageOf,
} from "../../src/modules/practice/index.js";
import { practiceContent, type PackRow, type PracticeContentStore } from "../../src/modules/content/index.js";
import { createEntitlementStub } from "../../src/modules/billing/index.js";
import { EXAM, TOPIC_A, TOPIC_B, buildPractice, makeQuestion } from "./practice.fakes.js";

const USER = "0199f5a0-0303-7000-8000-000000000001";
const OTHER = "0199f5a0-0303-7000-8000-000000000002";
// 2026-10-22 23:59 IST = 18:29 UTC
const IST_2359 = "2026-10-22T18:29:00.000Z";

async function codeOf(p: Promise<unknown>): Promise<string> {
  try {
    await p;
    return "none";
  } catch (e) {
    return e instanceof DomainError ? e.code : String(e);
  }
}

const body = (questionId: string, chosen = ["a"]) => ({ clientActionId: randomUUID(), questionId, questionVersion: 1, chosenOptionIds: chosen, timeMs: 1000 });

describe("limit rules (inv. 1-5)", () => {
  it("counts only practice and pyq; Pro is unlimited", () => {
    expect(isCountedMode("practice")).toBe(true);
    expect(isCountedMode("pyq")).toBe(true);
    expect(isCountedMode("mistakes")).toBe(false);
    expect(isCountedMode("drill")).toBe(false);
    expect(dailyLimitFor("free")).toBe(30);
    expect(dailyLimitFor("pro")).toBeNull();
    expect(decideCount("practice", 29, 30)).toBe("count");
    expect(decideCount("practice", 30, 30)).toBe("over_limit");
    expect(decideCount("pyq", 500, null)).toBe("count");
    expect(decideCount("mistakes", 30, 30)).toBe("uncounted");
  });

  it("resets at IST midnight", () => {
    expect(nextIstMidnight(new Date(IST_2359)).toISOString()).toBe("2026-10-22T18:30:00.000Z");
    expect(nextIstMidnight(new Date("2026-10-22T18:30:00.000Z")).toISOString()).toBe("2026-10-23T18:30:00.000Z");
    const u = usageOf(new Date(IST_2359), null, 30);
    expect(u).toEqual({ istDay: "2026-10-22", used: 0, limit: 30, resetsAt: "2026-10-22T18:30:00.000Z", limitSheetShownToday: false });
  });

  it("clamps offline clientAt to [now - 7 days, now]", () => {
    const now = new Date("2026-10-22T10:00:00.000Z");
    expect(judgedAnswerTime(now, null)).toEqual(now);
    expect(judgedAnswerTime(now, new Date("bad"))).toEqual(now);
    expect(judgedAnswerTime(now, new Date("2027-01-01T00:00:00.000Z"))).toEqual(now);
    expect(judgedAnswerTime(now, new Date("2026-10-01T00:00:00.000Z")).toISOString()).toBe("2026-10-15T10:00:00.000Z");
    expect(judgedAnswerTime(now, new Date("2026-10-20T00:00:00.000Z")).toISOString()).toBe("2026-10-20T00:00:00.000Z");
  });
});

describe("mistake loop + PYQ rules (inv. 9, 10)", () => {
  it("tallies wrong answers inside a 14-day window", () => {
    const t0 = new Date("2026-10-01T00:00:00.000Z");
    const a = addWrong(null, t0);
    const b = addWrong(a, new Date("2026-10-05T00:00:00.000Z"));
    const c = addWrong(b, new Date("2026-10-10T00:00:00.000Z"));
    expect(c.wrongCount).toBe(3);
    expect(drillDue(c, true, false)).toBe(true);
    expect(drillDue(c, false, false)).toBe(false);
    expect(drillDue(c, true, true)).toBe(false);
    expect(drillDue(b, true, false)).toBe(false);
    expect(isWeak(b, new Date("2026-10-06T00:00:00.000Z"))).toBe(true);
    expect(isWeak(a, new Date("2026-10-06T00:00:00.000Z"))).toBe(false);
    expect(isWeak(b, new Date("2026-11-30T00:00:00.000Z"))).toBe(false);
    expect(addWrong(c, new Date("2026-10-20T00:00:00.000Z")).wrongCount).toBe(1);
  });

  it("free users get the latest 2 years held; Pro all", () => {
    expect([...unlockedYears([2019, 2024, 2022, 2024], false)]).toEqual([2024, 2022]);
    expect([...unlockedYears([2019, 2024, 2022], true)]).toEqual([2024, 2022, 2019]);
    expect(unlockedYears([], false).size).toBe(0);
  });

  it("cursor round-trips and rejects garbage; locked items carry no text", () => {
    const c = { year: 2024, id: "0199f5a0-0202-7000-8000-000000000001" };
    expect(decodeCursor(encodeCursor(c))).toEqual(c);
    expect(decodeCursor(undefined)).toBeUndefined();
    expect(() => decodeCursor("nope")).toThrow(DomainError);
    const q = makeQuestion(1, TOPIC_A, 2019).question;
    expect(lockQuestion(q)).toMatchObject({ id: q.id, stem: "", options: [], affectedNote: null });
  });
});

describe("practice use cases", () => {
  it("free limit: 30 counted then PRACTICE_DAILY_LIMIT; nothing stored; sheet once; resets at IST midnight (inv. 1, 2, 12)", async () => {
    const clock = new FakeClock("2026-10-22T10:00:00.000Z");
    const { api, repo, content, events } = buildPractice(clock);
    const ids = content.bank.map((b) => b.question.id);
    let s = await api.startSession(USER, { mode: "practice", examCode: EXAM, size: 50 });
    expect(s.questions.length).toBe(20);
    expect(s.questions[0]).not.toHaveProperty("correctOptionIds");
    for (let i = 0; i < 30; i++) {
      if (i === 20) s = await api.startSession(USER, { mode: "practice", examCode: EXAM, size: 50 });
      const r = await api.answer(USER, s.sessionId, body(ids[i % 20] as string));
      expect(r.usage.used).toBe(i + 1);
    }
    const before = repo.answers.size;
    const over = api.answer(USER, s.sessionId, body(ids[11] as string));
    const err = await over.catch((e: DomainError) => e);
    expect(err).toBeInstanceOf(DomainError);
    expect((err as DomainError).code).toBe("PRACTICE_DAILY_LIMIT");
    expect((err as DomainError).details).toMatchObject({ showLimitSheet: true, showProPriceLine: false, usage: { used: 30, limit: 30, limitSheetShownToday: true } });
    expect(repo.answers.size).toBe(before);
    const again = await api.answer(USER, s.sessionId, body(ids[12] as string)).catch((e: DomainError) => e);
    expect((again as DomainError).details).toMatchObject({ showLimitSheet: false });
    expect(events.filter((e) => e.type === "practice.answered")).toHaveLength(30);

    // Uncounted modes still work over the limit (inv. 4).
    const m = await api.startSession(USER, { mode: "mistakes", examCode: EXAM, size: 10 });
    expect(m.usage.used).toBe(30);

    // 23:59 IST still today; 00:00 IST a new day.
    clock.set(IST_2359);
    expect((await api.usage(USER)).used).toBe(30);
    clock.advanceMinutes(1);
    const fresh = await api.usage(USER);
    expect(fresh).toMatchObject({ istDay: "2026-10-23", used: 0, limitSheetShownToday: false });
    const s2 = await api.startSession(USER, { mode: "practice", examCode: EXAM, size: 5 });
    expect((await api.answer(USER, s2.sessionId, body(s2.questions[0]?.id as string))).usage.used).toBe(1);
  });

  it("Pro is unlimited", async () => {
    const { api, content } = buildPractice(new FakeClock("2026-10-22T10:00:00.000Z"), { entitlement: "pro" });
    const ids = content.bank.map((b) => b.question.id);
    for (let i = 0; i < 31; i++) {
      const s = await api.startSession(USER, { mode: "practice", examCode: EXAM, size: 1 });
      const r = await api.answer(USER, s.sessionId, body(s.questions[0]?.id ?? (ids[0] as string)));
      expect(r.usage.limit).toBeNull();
    }
    expect((await api.usage(USER)).used).toBe(31);
  });

  it("grades on the server, replays by clientActionId, guards sessions (inv. 6, 7, 8)", async () => {
    const clock = new FakeClock("2026-10-22T10:00:00.000Z");
    const { api } = buildPractice(clock);
    const s = await api.startSession(USER, { mode: "practice", examCode: EXAM, topicId: TOPIC_A, size: 2 });
    const [q1, q2] = s.questions;
    const b1 = body(q1?.id as string, ["b"]);
    const r1 = await api.answer(USER, s.sessionId, b1);
    expect(r1.graded).toMatchObject({ correct: false, correctOptionIds: ["a"], chosenOptionIds: ["b"], whyChosenIsWrong: "B is wrong", topicId: TOPIC_A });
    const replay = await api.answer(USER, s.sessionId, b1);
    expect(replay.graded).toEqual(r1.graded);
    expect(replay.usage.used).toBe(1);
    expect(await codeOf(api.answer(OTHER, s.sessionId, body(q2?.id as string)))).toBe("NOT_FOUND");
    expect(await codeOf(api.answer(USER, randomUUID(), body(q2?.id as string)))).toBe("NOT_FOUND");
    expect(await codeOf(api.answer(USER, s.sessionId, body(randomUUID())))).toBe("QUESTION_NOT_FOUND");
    expect(await codeOf(api.answer(USER, s.sessionId, { ...body(q2?.id as string), questionVersion: 9 }))).toBe("QUESTION_NOT_FOUND");
    // second wrong on the lamp -> weak
    const r2 = await api.answer(USER, s.sessionId, body(q2?.id as string, ["b"]));
    expect(r2.weakTopicIds).toEqual([TOPIC_A]);
    // session full -> closed
    expect(await codeOf(api.answer(USER, s.sessionId, body(q1?.id as string)))).toBe("PRACTICE_SESSION_CLOSED");
    // replay works on a closed session; SEC-P2-L2: another user reusing the same clientActionId gets a fresh answer
    expect((await api.answer(USER, s.sessionId, b1)).graded.correct).toBe(false);
    const so = await api.startSession(OTHER, { mode: "practice", examCode: EXAM, size: 2 });
    const r3 = await api.answer(OTHER, so.sessionId, { ...body(so.questions[0]?.id as string), clientActionId: b1.clientActionId });
    expect(r3.usage.used).toBe(1);
  });

  it("a new session closes the previous one", async () => {
    const { api } = buildPractice(new FakeClock("2026-10-22T10:00:00.000Z"));
    const a = await api.startSession(USER, { mode: "practice", examCode: EXAM, size: 3 });
    await api.startSession(USER, { mode: "practice", examCode: EXAM, size: 3 });
    expect(await codeOf(api.answer(USER, a.sessionId, body(a.questions[0]?.id as string)))).toBe("PRACTICE_SESSION_CLOSED");
  });

  it("scope errors: unknown exam / topic / subject", async () => {
    const { api } = buildPractice(new FakeClock());
    expect(await codeOf(api.startSession(USER, { mode: "practice", examCode: "nope-exam", size: 5 }))).toBe("EXAM_NOT_FOUND");
    expect(await codeOf(api.startSession(USER, { mode: "practice", examCode: EXAM, topicId: randomUUID(), size: 5 }))).toBe("TOPIC_NOT_FOUND");
    expect(await codeOf(api.startSession(USER, { mode: "practice", examCode: EXAM, subjectCode: "history", size: 5 }))).toBe("TOPIC_NOT_FOUND");
  });

  it("offline answers: accepted once, clamped day, over the limit = study log only (inv. 5)", async () => {
    const clock = new FakeClock("2026-10-22T10:00:00.000Z");
    const { api, repo, content } = buildPractice(clock);
    const q = content.bank[0]?.question.id as string;
    const action = (clientAt: string, mode: "practice" | "drill" = "practice", questionId = q) => ({
      kind: "practice_answer" as const,
      clientActionId: randomUUID(),
      clientAt,
      questionId,
      questionVersion: 1,
      chosenOptionIds: ["a"],
      timeMs: 500,
      mode,
    });
    const a = action("2026-10-21T10:00:00.000Z");
    expect(await api.syncAnswer(USER, a)).toEqual({ clientActionId: a.clientActionId, status: "accepted", errorCode: null });
    expect(await api.syncAnswer(USER, a)).toMatchObject({ status: "duplicate" });
    // SEC-P2-L2: another user with the same clientActionId is accepted (dedupe is per user)
    expect(await api.syncAnswer(OTHER, a)).toMatchObject({ status: "accepted" });
    expect(repo.answers.get(`${USER}|${a.clientActionId}`)).toMatchObject({ istDay: "2026-10-21", source: "offline_sync", countsToLimit: true });
    // a month old -> clamped to now - 7 days
    const old = action("2026-09-01T00:00:00.000Z");
    await api.syncAnswer(USER, old);
    expect(repo.answers.get(`${USER}|${old.clientActionId}`)?.istDay).toBe("2026-10-15");
    // fill today, then offline over the limit -> study_log_only
    for (let i = 0; i < 30; i++) expect((await api.syncAnswer(USER, action("2026-10-22T09:00:00.000Z"))).status).toBe("accepted");
    const over = action("2026-10-22T09:30:00.000Z");
    expect(await api.syncAnswer(USER, over)).toMatchObject({ status: "study_log_only", errorCode: "PRACTICE_DAILY_LIMIT" });
    expect(repo.answers.get(`${USER}|${over.clientActionId}`)).toMatchObject({ studyLogOnly: true, countsToLimit: false });
    expect((await api.usage(USER)).used).toBe(30);
    expect(await api.syncAnswer(USER, action("2026-10-22T09:00:00.000Z", "drill"))).toMatchObject({ status: "rejected", errorCode: "PRO_REQUIRED" });
    expect(await api.syncAnswer(USER, action("2026-10-22T09:00:00.000Z", "practice", randomUUID()))).toMatchObject({ status: "rejected", errorCode: "QUESTION_NOT_FOUND" });
  });

  it("mistake review lists the latest wrong answers with cursor paging; correct later removes it", async () => {
    const clock = new FakeClock("2026-10-22T10:00:00.000Z");
    const { api } = buildPractice(clock);
    const s = await api.startSession(USER, { mode: "practice", examCode: EXAM, size: 5 });
    for (const q of s.questions.slice(0, 3)) {
      clock.advanceMinutes(1);
      await api.answer(USER, s.sessionId, body(q.id, ["b"]));
    }
    const p1 = await api.mistakes(USER, { limit: 2 });
    expect(p1.items).toHaveLength(2);
    expect(p1.items[0]).toMatchObject({ questionId: s.questions[2]?.id, wrongCount: 1, stem: expect.any(String), graded: { correct: false } });
    const p2 = await api.mistakes(USER, { limit: 2, cursor: p1.nextCursor as string });
    expect(p2.items.map((i) => i.questionId)).toEqual([s.questions[0]?.id]);
    expect(p2.nextCursor).toBeNull();
    expect(await codeOf(api.mistakes(USER, { limit: 2, cursor: "bad" }))).toBe("VALIDATION_FAILED");

    // mistakes session (uncounted), answer right -> leaves the list
    const m = await api.startSession(USER, { mode: "mistakes", examCode: EXAM, size: 10 });
    expect(m.questions).toHaveLength(3);
    const r = await api.answer(USER, m.sessionId, body(m.questions[0]?.id as string, ["a"]));
    expect(r.usage.used).toBe(3);
    expect((await api.mistakes(USER, { limit: 10 })).items).toHaveLength(2);
  });

  it("drills: Free never gets one and sees locked; Pro gets exactly one open drill after 3 wrong (inv. 9)", async () => {
    const clock = new FakeClock("2026-10-22T10:00:00.000Z");
    const free = buildPractice(clock);
    const s = await free.api.startSession(USER, { mode: "practice", examCode: EXAM, topicId: TOPIC_A, size: 5 });
    for (const q of s.questions.slice(0, 4)) await free.api.answer(USER, s.sessionId, body(q.id, ["b"]));
    expect(await free.api.drills(USER)).toEqual({ items: [], locked: true });
    expect(await codeOf(free.api.startSession(USER, { mode: "drill", examCode: EXAM, drillId: randomUUID(), size: 5 }))).toBe("PRO_REQUIRED");
    expect(await codeOf(free.api.startSession(USER, { mode: "drill", examCode: EXAM, size: 5 }))).toBe("VALIDATION_FAILED");

    const pro = buildPractice(clock, { entitlement: "pro" });
    const ps = await pro.api.startSession(USER, { mode: "practice", examCode: EXAM, topicId: TOPIC_B, size: 5 });
    for (const q of ps.questions.slice(0, 4)) await pro.api.answer(USER, ps.sessionId, body(q.id, ["b"]));
    const list = await pro.api.drills(USER);
    expect(list.locked).toBe(false);
    expect(list.items).toHaveLength(1);
    expect(list.items[0]).toMatchObject({ topicId: TOPIC_B, status: "open", reason: expect.stringContaining("3 questions") });
    const ds = await pro.api.startSession(USER, { mode: "drill", examCode: EXAM, drillId: list.items[0]?.id as string, size: 5 });
    expect(ds.questions.length).toBeGreaterThan(0);
    expect(await codeOf(pro.api.startSession(OTHER, { mode: "drill", examCode: EXAM, drillId: list.items[0]?.id as string, size: 5 }))).toBe("NOT_FOUND");
    const drill = [...pro.repo.drillMap.values()][0];
    if (drill) drill.status = "done";
    expect(await codeOf(pro.api.startSession(USER, { mode: "drill", examCode: EXAM, drillId: drill?.id as string, size: 5 }))).toBe("PRACTICE_SESSION_CLOSED");
  });

  it("PYQ Vault: filters, cursor pages, older years locked without text for Free (inv. 10)", async () => {
    const { api } = buildPractice(new FakeClock());
    const p1 = await api.searchPyqs(USER, { examCode: EXAM, limit: 3 });
    expect(p1.items.map((i) => i.question.source.pyq?.year)).toEqual([2024, 2024, 2023]);
    expect(p1.items.every((i) => !i.locked)).toBe(true);
    const all = [...p1.items];
    let cursor = p1.nextCursor;
    while (cursor) {
      const p = await api.searchPyqs(USER, { examCode: EXAM, limit: 3, cursor });
      all.push(...p.items);
      cursor = p.nextCursor;
    }
    expect(all).toHaveLength(8);
    const locked = all.filter((i) => i.locked);
    expect(locked.map((i) => i.question.source.pyq?.year).sort()).toEqual([2021, 2021, 2022, 2022]);
    expect(locked.every((i) => i.question.stem === "" && i.question.options.length === 0)).toBe(true);
    expect((await api.searchPyqs(USER, { examCode: EXAM, year: 2023, limit: 10 })).items).toHaveLength(2);
    expect((await api.searchPyqs(USER, { examCode: EXAM, topicId: TOPIC_B, limit: 10 })).items.every((i) => i.question.topicId === TOPIC_B)).toBe(true);
    expect((await api.searchPyqs(USER, { examCode: EXAM, subjectCode: "polity", difficulty: 3, limit: 10 })).items).toHaveLength(8);
    expect(await codeOf(api.searchPyqs(USER, { examCode: "nope-exam", limit: 10 }))).toBe("EXAM_NOT_FOUND");

    const f = await api.pyqFacets(USER, EXAM);
    expect(f.years).toEqual([
      { year: 2024, count: 2, locked: false },
      { year: 2023, count: 2, locked: false },
      { year: 2022, count: 2, locked: true },
      { year: 2021, count: 2, locked: true },
    ]);
    expect(f.subjects).toEqual([{ code: "polity", name: "Polity", count: 8 }]);

    // PYQ practice sessions only use unlocked years for Free
    const s = await api.startSession(USER, { mode: "pyq", examCode: EXAM, size: 50 });
    expect(s.questions.map((q) => q.source.pyq?.year).every((y) => y === 2024 || y === 2023)).toBe(true);
    const pro = buildPractice(new FakeClock(), { entitlement: "pro" });
    expect((await pro.api.pyqFacets(USER, EXAM)).years.every((y) => !y.locked)).toBe(true);
  });

  it("billing stub says everyone is Free in Phase 2; config is provisional", async () => {
    expect(await createEntitlementStub().entitlementOf(USER)).toBe("free");
    expect(PRACTICE_CONFIG.freeDailyLimit).toBe(30);
    expect(PRACTICE_CONFIG.showProPriceLine).toBe(false);
  });
});

describe("content practice API (BOLT-0010 additions)", () => {
  const topic = (id: string, subject: string) => ({ id, code: id.slice(-4), name: id, order: 1, subject: { code: subject, name: subject.toUpperCase(), order: subject === "polity" ? 1 : 2 }, examCodes: [EXAM] });
  const pack = (code: string, version: number, tier: "free" | "pro"): PackRow => ({
    id: randomUUID(),
    code,
    examCode: EXAM,
    subjectCode: null,
    version,
    url: `https://cdn.heymey.app/packs/${code}-${version}.zip`,
    sha256: "a".repeat(64),
    sizeBytes: 100,
    tier,
    publishedAt: new Date("2026-10-01T00:00:00.000Z"),
  });
  function build(found: "ok" | "no_question" | "no_version" = "ok") {
    const reports: unknown[] = [];
    const bank = [makeQuestion(1, TOPIC_A), makeQuestion(2, TOPIC_B)];
    const store: PracticeContentStore = {
      candidateIds: async () => bank.map((b) => b.question.id),
      latest: async (ids) => bank.filter((b) => ids.includes(b.question.id)),
      atVersion: async () => bank,
      pyqYears: async () => [{ year: 2024, count: 1 }],
      pyqPage: async () => [],
      pyqTopicCounts: async () => [
        { topicId: TOPIC_B, count: 2 },
        { topicId: TOPIC_A, count: 3 },
        { topicId: randomUUID(), count: 9 },
      ],
      questionVersionExists: async () => found,
      insertReport: async (r) => {
        reports.push(r);
        return "0199f5a0-0404-7000-8000-000000000001";
      },
      publishedPacks: async () => [pack("b.polity", 1, "pro"), pack("a.history", 1, "free"), pack("a.history", 2, "free")],
    };
    const api = practiceContent({
      store,
      syllabus: { topicsForExam: async (e) => (e === EXAM ? [topic(TOPIC_A, "polity"), topic(TOPIC_B, "history")] : []), topic: async () => null },
      randomInt: () => 0,
    });
    return { api, reports };
  }

  it("scope, pick, questions, subjects", async () => {
    const { api } = build();
    expect(await api.scope({ examCode: EXAM })).toEqual([TOPIC_A, TOPIC_B]);
    expect(await api.scope({ examCode: EXAM, subjectCode: "history" })).toEqual([TOPIC_B]);
    expect(await codeOf(api.scope({ examCode: "x" }))).toBe("EXAM_NOT_FOUND");
    expect(await api.pick({ topicIds: [], count: 3 })).toEqual([]);
    expect((await api.pick({ topicIds: [TOPIC_A], count: 1 })).length).toBe(1);
    const ids = [makeQuestion(2, TOPIC_B).question.id, randomUUID(), makeQuestion(1, TOPIC_A).question.id];
    expect((await api.questions(ids)).map((q) => q.id)).toEqual([ids[0], ids[2]]);
    expect(await api.pyqSubjects(EXAM)).toEqual([
      { code: "polity", name: "POLITY", count: 3 },
      { code: "history", name: "HISTORY", count: 2 },
    ]);
    expect((await api.atVersion([])).length).toBe(2);
    expect(await api.pyqYears(EXAM)).toEqual([{ year: 2024, count: 1 }]);
    expect(await api.pyqPage({ examCode: EXAM, take: 1 })).toEqual([]);
  });

  it("reports: stored with note, unknown question / version refused", async () => {
    const ok = build();
    const qid = makeQuestion(1, TOPIC_A).question.id;
    expect(await ok.api.report(USER, qid, { questionVersion: 1, reason: "typo", note: "Spelling" })).toEqual({ reportId: "0199f5a0-0404-7000-8000-000000000001", status: "received" });
    expect(ok.reports[0]).toMatchObject({ userId: USER, reason: "typo", note: "Spelling" });
    await ok.api.report(USER, qid, { questionVersion: 1, reason: "other" });
    expect(ok.reports[1]).toMatchObject({ note: null });
    expect(await codeOf(build("no_question").api.report(USER, qid, { questionVersion: 1, reason: "typo" }))).toBe("QUESTION_NOT_FOUND");
    expect(await codeOf(build("no_version").api.report(USER, qid, { questionVersion: 3, reason: "typo" }))).toBe("VALIDATION_FAILED");
  });

  it("packs: latest version per code; pro packs locked for Free", async () => {
    const { api } = build();
    const free = await api.packs(EXAM, false);
    expect(free.items.map((p) => [p.code, p.version, p.locked])).toEqual([
      ["a.history", 2, false],
      ["b.polity", 1, true],
    ]);
    expect((await api.packs(EXAM, true)).items.every((p) => !p.locked)).toBe(true);
  });
});
