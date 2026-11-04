// mastery unit tests (U-mastery invariants 1-17, blueprint §5.1, §5.2, §39). FakeClock everywhere.
import { describe, expect, it } from "vitest";
import { FakeClock } from "@heymey/testing";
import {
  MASTERY_CONFIG,
  applyCheck,
  canStart,
  checkSpec,
  completeLessonRule,
  computeRank,
  countRings,
  deadlineFor,
  dimStep,
  emptyLamp,
  gapAfterLevel,
  goldLimitReached,
  isExpired,
  isLate,
  isTooOld,
  istDayStartPlusDays,
  nextCheck,
  rankTitle,
  scoreCheck,
  xpOf,
  type LampState,
} from "../../src/modules/mastery/index.js";
import { DomainError } from "../../src/shared/index.js";
import { U1, U2, answersFor, makeMastery, topicId } from "./mastery.fakes.js";

const T1 = topicId(1);
const at = (s: string) => new Date(s);
// 10:00 IST on 2026-11-02 = 04:30Z
const START = "2026-11-02T04:30:00.000Z";

function lit(now = at(START)): LampState {
  const s = { ...emptyLamp(U1, T1, now), lessonCompletedAt: now };
  return applyCheck("lit", true, s, now).next as LampState;
}

async function codeOf(p: Promise<unknown>): Promise<string> {
  try {
    await p;
  } catch (e) {
    if (e instanceof DomainError) return e.code;
    throw e;
  }
  return "no error";
}

describe("IST day math (§37)", () => {
  it("due = IST midnight of the next IST day, also just before IST midnight", () => {
    expect(istDayStartPlusDays(at("2026-11-02T04:30:00Z"), 1).toISOString()).toBe("2026-11-02T18:30:00.000Z");
    // 23:59 IST on 2 Nov -> still 2 Nov
    expect(istDayStartPlusDays(at("2026-11-02T18:29:00Z"), 1).toISOString()).toBe("2026-11-02T18:30:00.000Z");
    // 00:01 IST on 3 Nov -> next is 4 Nov
    expect(istDayStartPlusDays(at("2026-11-02T18:31:00Z"), 1).toISOString()).toBe("2026-11-03T18:30:00.000Z");
    expect(istDayStartPlusDays(at("2026-11-02T18:31:00Z"), 0).toISOString()).toBe("2026-11-02T18:30:00.000Z");
  });
});

describe("lamp rules", () => {
  it("lesson -> lit check -> lit (inv. 2, 5); lit time is server time (inv. 1)", () => {
    const now = at(START);
    const e = emptyLamp(U1, T1, now);
    expect(nextCheck(e, now)).toBe("lesson");
    expect(canStart("lit", e, now)).toBe(false);
    const l = completeLessonRule(e, now);
    expect(l.next?.lessonCompletedAt).toEqual(now);
    expect(completeLessonRule(l.next as LampState, now).next).toBeNull();
    expect(nextCheck(l.next as LampState, now)).toBe("lit");
    const s = lit(now);
    expect(s.litAt).toEqual(now);
    expect(s.nextDueAt?.toISOString()).toBe("2026-11-02T18:30:00.000Z");
    expect(nextCheck(s, now)).toBe("gold");
  });

  it("failed Lit check keeps the lamp unlit and logs lit_fail (inv. 3); lit before lesson is log only", () => {
    const now = at(START);
    const s = { ...emptyLamp(U1, T1, now), lessonCompletedAt: now };
    const t = applyCheck("lit", false, s, now);
    expect(t.next?.litAt).toBeNull();
    expect(t.events[0]?.kind).toBe("lit_fail");
    expect(applyCheck("lit", true, emptyLamp(U1, T1, now), now).events[0]?.kind).toBe("study_log_only");
    expect(applyCheck("lit", true, lit(now), now).next).toBeNull();
  });

  it("ladder: +1, +3, +7, +21, then +30 maintenance; max level 4 (inv. 5)", () => {
    expect([0, 1, 2, 3, 4].map((l) => (l === 0 ? MASTERY_CONFIG.recall.ladderDays[0] : gapAfterLevel(l)))).toEqual([1, 3, 7, 21, 30]);
    let s = lit();
    const gaps: number[] = [];
    for (let i = 0; i < 5; i++) {
      const now = s.nextDueAt as Date;
      const t = applyCheck("recall", true, s, now);
      s = t.next as LampState;
      gaps.push(Math.round(((s.nextDueAt as Date).getTime() - now.getTime()) / 86_400_000));
    }
    expect(gaps).toEqual([3, 7, 21, 30, 30]);
    expect(s.steadyLevel).toBe(4);
    expect(s.steadyEarnedAt).not.toBeNull();
  });

  it("recall before due never advances (inv. 6); failed recall steps back, due next day, never unlit (inv. 7)", () => {
    const s = lit();
    expect(applyCheck("recall", true, s, at(START)).next).toBeNull();
    expect(canStart("recall", s, at(START))).toBe(false);
    const due = s.nextDueAt as Date;
    const up = applyCheck("recall", true, s, due).next as LampState;
    const failAt = up.nextDueAt as Date;
    const down = applyCheck("recall", false, up, failAt);
    expect(down.next?.steadyLevel).toBe(0);
    expect(down.next?.litAt).not.toBeNull();
    expect(down.next?.nextDueAt).toEqual(istDayStartPlusDays(failAt, 1));
    expect(applyCheck("recall", false, down.next as LampState, down.next?.nextDueAt as Date).next?.steadyLevel).toBe(0);
    expect(applyCheck("recall", true, emptyLamp(U1, T1, due), due).events[0]?.details?.reason).toBe("not_lit");
  });

  it("dimming: due -> dimming; +7 days -> dim, Steady lost, Gold kept; twice changes nothing (inv. 8, 9)", () => {
    let s = applyCheck("recall", true, lit(), lit().nextDueAt as Date).next as LampState;
    s = { ...s, goldAt: at(START) };
    const due = s.nextDueAt as Date;
    expect(dimStep(s, new Date(due.getTime() - 1)).next).toBeNull();
    const d1 = dimStep(s, due);
    expect(d1.next?.dimState).toBe("dimming");
    expect(d1.next?.dimSince).toEqual(due);
    expect(dimStep(d1.next as LampState, due).next).toBeNull();
    const later = new Date(due.getTime() + 7 * 86_400_000);
    const d2 = dimStep(d1.next as LampState, later);
    expect(d2.next?.dimState).toBe("dim");
    expect(d2.next?.steadyLevel).toBe(0);
    expect(d2.next?.goldAt).not.toBeNull();
    expect(d2.events.map((e) => e.kind)).toEqual(["dim", "steady_lost"]);
    expect(dimStep(d2.next as LampState, later).next).toBeNull();
    // bright straight to dim in one run
    expect(dimStep(s, later).events.map((e) => e.kind)).toEqual(["dimming", "dim", "steady_lost"]);
    // shield pauses dimming; unlit never dims
    expect(dimStep({ ...s, shieldUntil: new Date(due.getTime() + 1000) }, due).next).toBeNull();
    expect(dimStep(emptyLamp(U1, T1, due), due).next).toBeNull();
  });

  it("relight: pass -> bright + counts as a passed recall; fail -> unchanged (inv. 10)", () => {
    const s = lit();
    const dimming = dimStep(s, s.nextDueAt as Date).next as LampState;
    expect(nextCheck(dimming, s.nextDueAt as Date)).toBe("relight");
    expect(canStart("relight", dimming, s.nextDueAt as Date)).toBe(true);
    expect(canStart("recall", dimming, s.nextDueAt as Date)).toBe(true);
    expect(applyCheck("recall", true, dimming, s.nextDueAt as Date).next?.dimState).toBe("bright");
    const now = new Date((s.nextDueAt as Date).getTime() + 3 * 86_400_000);
    const ok = applyCheck("relight", true, dimming, now);
    expect(ok.next?.dimState).toBe("bright");
    expect(ok.next?.steadyLevel).toBe(1);
    expect(ok.next?.nextDueAt).toEqual(istDayStartPlusDays(now, 3));
    const fail = applyCheck("relight", false, dimming, now);
    expect(fail.next?.dimState).toBe("dimming");
    expect(fail.events[0]?.kind).toBe("relight_fail");
    expect(applyCheck("relight", true, s, now).next).toBeNull();
    const dim = dimStep(dimming, new Date(now.getTime() + 8 * 86_400_000)).next as LampState;
    expect(canStart("recall", dim, now)).toBe(false);
    expect(applyCheck("recall", true, dim, now).events[0]?.details?.reason).toBe("needs_relight");
  });

  it("gold needs Lit, is never removed, and pass/fail are logged (inv. 11)", () => {
    const now = at(START);
    expect(canStart("gold", emptyLamp(U1, T1, now), now)).toBe(false);
    expect(applyCheck("gold", true, emptyLamp(U1, T1, now), now).next).toBeNull();
    const g = applyCheck("gold", true, lit(), now).next as LampState;
    expect(g.goldAt).toEqual(now);
    expect(nextCheck(g, now)).toBe("none");
    expect(applyCheck("gold", true, g, now).next).toBeNull();
    expect(applyCheck("gold", false, lit(), now).events[0]?.kind).toBe("gold_fail");
  });

  it("check specs, deadlines, expiry, lateness, scoring, offline age", () => {
    expect(checkSpec("lit")).toMatchObject({ questions: 3, passMark: 2 });
    expect(checkSpec("relight")).toMatchObject({ questions: 5, passMark: 4 });
    expect(checkSpec("gold")).toMatchObject({ questions: 15, passMark: 12, minDifficulty: 3, timed: true });
    const issued = at(START);
    const dl = deadlineFor("gold", issued) as Date;
    expect(dl.getTime() - issued.getTime()).toBe(15 * 60 * 1000);
    expect(deadlineFor("lit", issued)).toBeNull();
    expect(isLate({ deadlineAt: dl }, new Date(dl.getTime() + 5000))).toBe(false);
    expect(isLate({ deadlineAt: dl }, new Date(dl.getTime() + 5001))).toBe(true);
    expect(isLate({ deadlineAt: null }, new Date(dl.getTime() + 1e9))).toBe(false);
    expect(isExpired({ deadlineAt: null, issuedAt: issued }, new Date(issued.getTime() + 24 * 3_600_000 + 1))).toBe(true);
    expect(isExpired({ deadlineAt: dl, issuedAt: issued }, new Date(issued.getTime() + 1e10))).toBe(false);
    // 79% vs 80% (S04)
    expect(scoreCheck({ total: 15, passMark: 12, correctIds: new Set(Array.from({ length: 11 }, (_, i) => `${i}`)), answered: 15, late: false }).passed).toBe(false);
    expect(scoreCheck({ total: 15, passMark: 12, correctIds: new Set(Array.from({ length: 12 }, (_, i) => `${i}`)), answered: 15, late: false }).passed).toBe(true);
    expect(scoreCheck({ total: 15, passMark: 12, correctIds: new Set(["a"]), answered: 9, late: true })).toEqual({ correct: 0, passed: false, lateAnswersIgnored: 9 });
    expect(goldLimitReached(1)).toBe(false);
    expect(goldLimitReached(2)).toBe(true);
    expect(isTooOld(at("2026-11-01T00:00:00Z"), at("2026-11-08T00:00:00Z"))).toBe(false);
    expect(isTooOld(at("2026-11-01T00:00:00Z"), at("2026-11-08T00:00:01Z"))).toBe(true);
  });
});

describe("Career Ladder (inv. 12, 13)", () => {
  it("level from % of max lamp points; titles; xp boundaries", () => {
    expect(computeRank({ totalLamps: 0, lit: 0, steadySteps: 0, gold: 0 })).toEqual({ level: 1, xp: 0, xpForThisLevel: 0, xpForNextLevel: null });
    // 10 lamps -> max 500 xp. 10 xp = 2% -> level 2
    expect(computeRank({ totalLamps: 10, lit: 1, steadySteps: 0, gold: 0 })).toMatchObject({ level: 2, xp: 10, xpForThisLevel: 10, xpForNextLevel: 25 });
    expect(computeRank({ totalLamps: 10, lit: 10, steadySteps: 40, gold: 10 })).toMatchObject({ level: 11, xp: 500, xpForNextLevel: null });
    expect(xpOf({ lit: 2, steadySteps: 3, gold: 1 })).toBe(55);
    expect(rankTitle(1)).toBe("Aspirant");
    expect(rankTitle(11)).toBe("Chief Secretary");
    expect(rankTitle(11, ["x"])).toBe("Chief Secretary");
  });

  it("counts only lamps in scope, shared lamp once", () => {
    const s = lit();
    const other = { ...lit(), topicId: topicId(9) };
    const c = countRings([s, other, { ...s, topicId: topicId(2), dimState: "dim" }], new Set([T1, topicId(2)]));
    expect(c).toMatchObject({ totalLamps: 2, lit: 2, dim: 1, dimming: 0 });
  });
});

describe("mastery use cases (fakes)", () => {
  it("lesson-complete: unknown topic -> TOPIC_NOT_FOUND; repeat changes nothing", async () => {
    const clock = new FakeClock(START);
    const { api, repo, published } = makeMastery(clock);
    expect(await codeOf(api.completeLesson(U1, topicId(99)))).toBe("TOPIC_NOT_FOUND");
    const a = await api.completeLesson(U1, T1);
    expect(a.nextCheck).toBe("lit");
    clock.advanceMinutes(5);
    const b = await api.completeLesson(U1, T1);
    expect(b.lessonCompletedAt).toBe(a.lessonCompletedAt);
    expect(repo.events.map((e) => e.kind)).toEqual(["lesson_done", "lesson_done"]);
    expect(published.filter((e) => e.type === "mastery.lamp_changed")).toHaveLength(1);
  });

  it("lit check: not before the lesson; pass lights the lamp; second submit -> CHECK_ALREADY_SUBMITTED (inv. 4)", async () => {
    const clock = new FakeClock(START);
    const { api, repo } = makeMastery(clock);
    expect(await codeOf(api.startCheck(U1, T1, "lit"))).toBe("CHECK_NOT_AVAILABLE");
    await api.completeLesson(U1, T1);
    const check = await api.startCheck(U1, T1, "lit");
    expect(check.questions).toHaveLength(3);
    expect(check.deadlineAt).toBeNull();
    const ids = check.questions.map((q) => q.id);
    const res = await api.submitCheck(U1, check.checkId, answersFor(ids, 2));
    expect(res).toMatchObject({ passed: true, correct: 2, total: 3, lateAnswersIgnored: 0 });
    expect(res.topicState.ring.lit).toBe(true);
    expect(res.topicState.litAt).toBe(START);
    expect(res.rankUp).toMatchObject({ from: 1, to: 2, note: "Game title. Not an official designation." });
    expect(await codeOf(api.submitCheck(U1, check.checkId, answersFor(ids, 3)))).toBe("CHECK_ALREADY_SUBMITTED");
    expect(repo.events.filter((e) => e.kind === "lit")).toHaveLength(1);
    expect(await codeOf(api.submitCheck(U2, check.checkId, answersFor(ids, 3)))).toBe("NOT_FOUND");
    expect(await codeOf(api.startCheck(U1, T1, "lit"))).toBe("CHECK_NOT_AVAILABLE");
  });

  it("failed lit check leaves the lamp unlit; answers to other questions are ignored; expired check", async () => {
    const clock = new FakeClock(START);
    const { api } = makeMastery(clock);
    await api.completeLesson(U1, T1);
    const c = await api.startCheck(U1, T1, "lit");
    const res = await api.submitCheck(U1, c.checkId, [
      { questionId: c.questions[0]!.id, chosenOptionIds: ["a"] }, // eslint-disable-line @typescript-eslint/no-non-null-assertion
      { questionId: topicId(77), chosenOptionIds: ["a"] },
    ]);
    expect(res.passed).toBe(false);
    expect(res.topicState.ring.lit).toBe(false);
    expect(res.rankUp).toBeNull();
    const c2 = await api.startCheck(U1, T1, "lit");
    clock.advanceDays(2);
    expect(await codeOf(api.submitCheck(U1, c2.checkId, answersFor(c2.questions.map((q) => q.id), 3)))).toBe("CHECK_EXPIRED");
  });

  it("topic without enough questions -> CHECK_NOT_AVAILABLE", async () => {
    const clock = new FakeClock(START);
    const { api } = makeMastery(clock);
    await api.completeLesson(U1, topicId(6));
    expect(await codeOf(api.startCheck(U1, topicId(6), "lit"))).toBe("CHECK_NOT_AVAILABLE");
  });

  it("gold: timed, late answers count wrong, 2 attempts per IST day", async () => {
    const clock = new FakeClock(START);
    const { api } = makeMastery(clock);
    expect(await codeOf(api.startCheck(U1, T1, "gold"))).toBe("CHECK_NOT_AVAILABLE");
    await api.completeLesson(U1, T1);
    const lc = await api.startCheck(U1, T1, "lit");
    await api.submitCheck(U1, lc.checkId, answersFor(lc.questions.map((q) => q.id), 3));
    const g1 = await api.startCheck(U1, T1, "gold");
    expect(g1.questions).toHaveLength(15);
    expect(g1.questions.every((q) => q.difficulty >= 3)).toBe(true);
    expect(g1.deadlineAt).toBe(new Date(new Date(START).getTime() + 15 * 60_000).toISOString());
    clock.advanceMinutes(16);
    const late = await api.submitCheck(U1, g1.checkId, answersFor(g1.questions.map((q) => q.id), 15));
    expect(late).toMatchObject({ passed: false, correct: 0, lateAnswersIgnored: 15 });
    const g2 = await api.startCheck(U1, T1, "gold");
    expect(await codeOf(api.startCheck(U1, T1, "gold"))).toBe("GOLD_DAILY_LIMIT");
    const ok = await api.submitCheck(U1, g2.checkId, answersFor(g2.questions.map((q) => q.id), 12));
    expect(ok.passed).toBe(true);
    expect(ok.topicState.ring.gold).toBe(true);
    clock.advanceDays(1);
    expect(await codeOf(api.startCheck(U1, T1, "gold"))).toBe("CHECK_NOT_AVAILABLE"); // already gold
  });

  it("write retries on a rowVersion race with the dimming job", async () => {
    const clock = new FakeClock(START);
    const { api, repo } = makeMastery(clock);
    await api.completeLesson(U1, T1);
    repo.beforeCommit = () => {
      const k = `${U1}|${T1}`;
      const s = repo.states.get(k);
      if (s) repo.states.set(k, { ...s, rowVersion: s.rowVersion + 1 });
    };
    const c = await api.startCheck(U1, T1, "lit");
    const r = await api.submitCheck(U1, c.checkId, answersFor(c.questions.map((q) => q.id), 3));
    expect(r.topicState.ring.lit).toBe(true);
  });

  it("gives up after repeated conflicts", async () => {
    const clock = new FakeClock(START);
    const { api, repo } = makeMastery(clock);
    await api.completeLesson(U1, T1);
    const orig = repo.commit.bind(repo);
    repo.commit = async () => "conflict";
    await expect(api.completeLesson(U1, topicId(2))).rejects.toThrow("conflicting");
    repo.commit = orig;
  });

  it("summary: union counts once, per-exam counts, rank from lamps", async () => {
    const clock = new FakeClock(START);
    const { api } = makeMastery(clock);
    for (const n of [1, 3]) {
      await api.completeLesson(U1, topicId(n));
      const c = await api.startCheck(U1, topicId(n), "lit");
      await api.submitCheck(U1, c.checkId, answersFor(c.questions.map((q) => q.id), 3));
    }
    const s = await api.summary(U1);
    expect(s.counts).toMatchObject({ totalLamps: 6, lit: 2 });
    expect(s.byExam).toEqual([
      { examCode: "exam-a", counts: expect.objectContaining({ totalLamps: 4, lit: 2 }) },
      { examCode: "exam-b", counts: expect.objectContaining({ totalLamps: 4, lit: 1 }) },
    ]);
    expect(s.rank).toMatchObject({ xp: 20, title: expect.any(String), note: MASTERY_CONFIG.rankNote, familyCode: null });
    expect((await api.summary(U2)).counts.lit).toBe(0);
    expect((await api.summary("0199f5a0-aaaa-7000-8000-00000000ffff")).counts.totalLamps).toBe(0);
  });

  it("topic states: exam must exist; since + cursor paging", async () => {
    const clock = new FakeClock(START);
    const { api } = makeMastery(clock);
    expect(await codeOf(api.topicStates(U1, { examCode: "nope", limit: 10 }))).toBe("EXAM_NOT_FOUND");
    for (const n of [1, 2, 3, 5]) {
      await api.completeLesson(U1, topicId(n));
      clock.advanceMinutes(1);
    }
    const p1 = await api.topicStates(U1, { examCode: "exam-a", limit: 2 });
    expect(p1.items.map((i) => i.topicId)).toEqual([topicId(1), topicId(2)]);
    expect(p1.nextCursor).not.toBeNull();
    const p2 = await api.topicStates(U1, { examCode: "exam-a", limit: 2, cursor: p1.nextCursor as string });
    expect(p2.items.map((i) => i.topicId)).toEqual([topicId(3)]);
    expect(p2.nextCursor).toBeNull();
    const since = await api.topicStates(U1, { examCode: "exam-a", limit: 10, since: p1.items[1]!.updatedAt }); // eslint-disable-line @typescript-eslint/no-non-null-assertion
    expect(since.items.map((i) => i.topicId)).toEqual([topicId(3)]);
    expect(await codeOf(api.topicStates(U1, { examCode: "exam-a", limit: 2, cursor: "bad" }))).toBe("VALIDATION_FAILED");
  });

  it("dimming run + relight queue + relight (inv. 8, 9, 10, 17)", async () => {
    const clock = new FakeClock(START);
    const { api, repo } = makeMastery(clock, { openable: (ids) => new Set(ids.filter((i) => i !== topicId(2))) });
    for (const n of [1, 2]) {
      await api.completeLesson(U1, topicId(n));
      const c = await api.startCheck(U1, topicId(n), "lit");
      await api.submitCheck(U1, c.checkId, answersFor(c.questions.map((q) => q.id), 3));
    }
    expect((await api.runDimming()).dimming).toBe(0);
    clock.advanceDays(1);
    const r1 = await api.runDimming();
    expect(r1).toMatchObject({ examined: 2, dimming: 2, dim: 0 });
    expect((await api.runDimming()).examined).toBe(0);
    const q = await api.relightQueue(U1);
    expect(q.items.map((i) => i.topicId)).toEqual([T1]);
    expect(q).toMatchObject({ totalMinutes: 3, items: [{ dim: "dimming", subjectCode: "polity", topicName: "Topic 1", minutes: 3 }] });
    const rc = await api.startCheck(U1, T1, "relight");
    expect(rc.questions).toHaveLength(5);
    const res = await api.submitCheck(U1, rc.checkId, answersFor(rc.questions.map((x) => x.id), 4));
    expect(res.topicState.ring).toMatchObject({ dim: "bright", steadyLevel: 1 });
    clock.advanceDays(7);
    const r2 = await api.runDimming();
    expect(r2.dim).toBe(1);
    expect(repo.states.get(`${U1}|${topicId(2)}`)?.dimState).toBe("dim");
    expect((await api.relightQueue(U2)).items).toEqual([]);
  });

  it("dimming pages through more than one batch and skips lost races", async () => {
    const clock = new FakeClock(START);
    const { api, repo } = makeMastery(clock);
    const due = at("2026-11-01T00:00:00Z");
    for (let i = 0; i < MASTERY_CONFIG.dimmingBatch + 5; i++) {
      const s = { ...emptyLamp(U1, `0199f5a0-0000-7000-8000-${String(i + 1000).padStart(12, "0")}`, due), litAt: due, nextDueAt: due };
      repo.states.set(`${s.userId}|${s.topicId}`, s);
    }
    repo.beforeCommit = () => undefined;
    const orig = repo.commit.bind(repo);
    let n = 0;
    repo.commit = async (c) => (n++ === 0 ? "conflict" : orig(c));
    const r = await api.runDimming();
    expect(r.examined).toBe(MASTERY_CONFIG.dimmingBatch + 5);
    expect(r.conflicts).toBe(1);
    expect(r.dimming).toBe(MASTERY_CONFIG.dimmingBatch + 4);
  });

  it("offline sync: accept once, too old -> study log, re-graded, rejected cases (inv. 14-16, FW-022)", async () => {
    const clock = new FakeClock(START);
    const { api, repo, published } = makeMastery(clock);
    const id1 = "0199f5a0-bbbb-7000-8000-000000000001";
    const lesson = { clientActionId: id1, clientAt: START, kind: "lesson_complete" as const, topicId: T1, via: "lesson" as const };
    expect(await api.syncAction(U1, lesson)).toEqual({ clientActionId: id1, status: "accepted", errorCode: null });
    expect((await api.syncAction(U1, lesson)).status).toBe("duplicate");
    const qs = Array.from({ length: 3 }, (_, i) => `0199f5a0-0001-7000-9000-${String(i).padStart(12, "0")}`);
    const check = (id: string, right: number, extra: Partial<{ clientAt: string; topicId: string }> = {}) => ({
      clientActionId: id,
      clientAt: START,
      kind: "topic_check" as const,
      topicId: T1,
      checkKind: "lit" as const,
      answers: answersFor(qs, right),
      ...extra,
    });
    // fewer graded answers than the check size -> rejected
    expect(await api.syncAction(U1, { ...check("0199f5a0-bbbb-7000-8000-000000000002", 3), answers: answersFor(qs.slice(0, 2), 2) })).toMatchObject({
      status: "rejected",
      errorCode: "VALIDATION_FAILED",
    });
    expect((await api.syncAction(U1, check("0199f5a0-bbbb-7000-8000-000000000003", 3, { topicId: topicId(99) }))).errorCode).toBe("TOPIC_NOT_FOUND");
    const ranksBefore = published.filter((e) => e.type === "mastery.rank_up").length;
    expect((await api.syncAction(U1, check("0199f5a0-bbbb-7000-8000-000000000004", 2))).status).toBe("accepted");
    expect(published.filter((e) => e.type === "mastery.rank_up").length).toBe(ranksBefore);
    clock.advanceDays(8);
    const old = await api.syncAction(U1, check("0199f5a0-bbbb-7000-8000-000000000005", 3, { clientAt: START }));
    expect(old).toMatchObject({ status: "study_log_only", errorCode: "SYNC_ACTION_TOO_OLD" });
    const states = await api.statesOf(U1, [T1, T1]);
    expect(states).toHaveLength(1);
    expect(states[0]?.ring.lit).toBe(true);
    expect(await api.statesOf(U1, [])).toEqual([]);
    expect(repo.events.filter((e) => e.source === "offline_sync").map((e) => e.kind)).toEqual(["lesson_done", "lit", "study_log_only"]);
  });

  it("sync duplicates found only at commit time are reported as duplicate", async () => {
    const clock = new FakeClock(START);
    const { api, repo } = makeMastery(clock);
    repo.hasClientAction = async () => false;
    const a = { clientActionId: "0199f5a0-bbbb-7000-8000-00000000000a", clientAt: START, kind: "lesson_complete" as const, topicId: T1, via: "lesson" as const };
    await api.syncAction(U1, a);
    expect((await api.syncAction(U1, a)).status).toBe("duplicate");
    clock.advanceDays(9);
    const b = { ...a, clientActionId: "0199f5a0-bbbb-7000-8000-00000000000b" };
    await api.syncAction(U1, b);
    expect((await api.syncAction(U1, b)).status).toBe("duplicate");
  });
});
