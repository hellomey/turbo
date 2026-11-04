// §43 Phase 2 done-when / INT-002-S03 acceptance: a 7-day simulated week with a fake clock. A scripted user studies,
// skips 3 days, and returns; light -> dim -> relight states must match the golden timeline below.
import { describe, expect, it } from "vitest";
import { FakeClock } from "@heymey/testing";
import { U1, answersFor, makeMastery, topicId } from "./mastery.fakes.js";

const A = topicId(1);
const B = topicId(2);

describe("§43 7-day fake-clock acceptance (INT-002-S03)", () => {
  it("study, skip 3 days, return: light -> dim -> relight timeline matches the golden", async () => {
    // Day 1 = Monday 2 Nov 2026, 19:00 IST (13:30Z).
    const clock = new FakeClock("2026-11-02T13:30:00.000Z");
    const { api } = makeMastery(clock);
    const timeline: string[] = [];

    const snap = async (day: number) => {
      const states = await api.statesOf(U1, [A, B]);
      for (const s of states) {
        const name = s.topicId === A ? "A" : "B";
        timeline.push(`d${day} ${name} lit=${s.ring.lit} steady=${s.ring.steadyLevel} ${s.ring.dim} next=${s.nextCheck} due=${s.nextDueAt?.slice(0, 16) ?? "-"}`);
      }
    };
    /** The scheduler runs every 15 minutes; run it across the elapsed hours of the day. */
    const liveDay = async (hours: number) => {
      for (let i = 0; i < hours * 4; i++) {
        clock.advanceMinutes(15);
        await api.runDimming();
      }
    };
    const pass = async (topic: string, kind: "lit" | "recall" | "relight") => {
      const c = await api.startCheck(U1, topic, kind);
      return api.submitCheck(U1, c.checkId, answersFor(c.questions.map((q) => q.id), c.questions.length));
    };

    // Day 1: study two lamps.
    for (const t of [A, B]) {
      await api.completeLesson(U1, t);
      await pass(t, "lit");
    }
    await snap(1);
    await liveDay(24);
    // Day 2 19:00 IST: both recalls due (since 00:00 IST); pass them.
    await pass(A, "recall");
    await pass(B, "recall");
    await snap(2);
    // Skip days 3, 4, 5 (no app open). The scheduler keeps running.
    await liveDay(24 * 3);
    await snap(5);
    // Day 6 19:00 IST: return, relight A only.
    await liveDay(24);
    const queue = await api.relightQueue(U1);
    timeline.push(`d6 queue=${queue.items.map((i) => (i.topicId === A ? "A" : "B")).join(",")} minutes=${queue.totalMinutes}`);
    await pass(A, "relight");
    await snap(6);
    // Day 7.
    await liveDay(24);
    await snap(7);

    expect(timeline).toEqual([
      "d1 A lit=true steady=0 bright next=gold due=2026-11-02T18:30",
      "d1 B lit=true steady=0 bright next=gold due=2026-11-02T18:30",
      "d2 A lit=true steady=1 bright next=gold due=2026-11-05T18:30",
      "d2 B lit=true steady=1 bright next=gold due=2026-11-05T18:30",
      "d5 A lit=true steady=1 dimming next=relight due=2026-11-05T18:30",
      "d5 B lit=true steady=1 dimming next=relight due=2026-11-05T18:30",
      "d6 queue=A,B minutes=6",
      "d6 A lit=true steady=2 bright next=gold due=2026-11-13T18:30",
      "d6 B lit=true steady=1 dimming next=relight due=2026-11-05T18:30",
      "d7 A lit=true steady=2 bright next=gold due=2026-11-13T18:30",
      "d7 B lit=true steady=1 dimming next=relight due=2026-11-05T18:30",
    ]);
  });
});
