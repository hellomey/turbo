// BOLT-0012 integration: plan Prisma adapter + exams attempt cycles + syllabus on REAL PostgreSQL (Testcontainers, §44).
// Covers: put/rebuild in one transaction, rebalance idempotent per IST day, date change, item status race, offline
// clientActionId accepted once (unique StudyLog.clientActionId), nightly paging.
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { FakeClock, startPostgres, type StartedDb } from "@heymey/testing";
import { createExamsModule } from "../../src/modules/exams/index.js";
import { createPlanModule, planPortsFrom, WELCOME_BACK } from "../../src/modules/plan/index.js";
import { createSyllabusModule } from "../../src/modules/syllabus/index.js";
import { seeder } from "../../../db/prisma/seed/catalog.js";

let db: StartedDb;
let prisma: PrismaClient;
const MAIN = "tnpsc-group-4";
let cycleId = "";

beforeAll(async () => {
  db = await startPostgres();
  prisma = createPrismaClient(db.url);
  await seeder.run(prisma);
  const exam = await prisma.exam.findUniqueOrThrow({ where: { code: MAIN } });
  const c = await prisma.examAttemptCycle.create({
    data: { examId: exam.id, code: "it-2027", name: "Test sitting", status: "announced", stageDates: [{ stageCode: "written", date: "2027-06-01", dateStatus: "official" }], sourceUrl: "https://example.org" },
  });
  cycleId = c.id;
  // one critical lamp for the Final Stretch
  const tag = await prisma.topicExamTag.findFirstOrThrow({ where: { examCode: MAIN }, orderBy: { topicId: "desc" } });
  await prisma.topicExamTag.update({ where: { topicId_examCode: { topicId: tag.topicId, examCode: MAIN } }, data: { priority: 2 } });
});

afterAll(async () => {
  await prisma?.$disconnect();
  await db?.stop();
});

function build(clock: FakeClock, lit: Set<string> = new Set()) {
  const exams = createExamsModule({ prisma, clock });
  const syllabus = createSyllabusModule({ prisma });
  const events: string[] = [];
  const plan = createPlanModule({
    prisma,
    clock,
    events: { publish: async (e) => void events.push(e.type) },
    ports: planPortsFrom({
      exams,
      syllabus,
      mastery: {
        summary: async () => ({ rank: { step: 1 } }) as never,
        relightQueue: async () => ({ items: [], totalMinutes: 0 }),
        statesOf: async (_u, ids) => ids.filter((id) => lit.has(id)).map((id) => ({ topicId: id, litAt: "2026-11-01T00:00:00.000Z" }) as never),
      },
    }),
  });
  return { exams, plan, events };
}

describe("plan on Postgres (integration)", () => {
  it("PUT /v1/me/exams attemptCycles is stored and drives the plan date (R2)", async () => {
    const user = randomUUID();
    const clock = new FakeClock("2026-11-02T04:30:00.000Z");
    const { exams, plan } = build(clock);
    await expect(exams.setMyExams(user, { mainExamCode: MAIN, attemptCycles: { [MAIN]: randomUUID() } })).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
    await exams.setMyExams(user, { mainExamCode: MAIN, otherExamCodes: ["tnpsc-group-2"], attemptCycles: { [MAIN]: cycleId } });
    const row = await prisma.userExamChoice.findUniqueOrThrow({ where: { userId_examCode: { userId: user, examCode: MAIN } } });
    expect(row.attemptCycleId).toBe(cycleId);
    const p = await plan.put(user, { weekdayMinutes: 60, weekendMinutes: 120 });
    expect(p.exams[0]).toMatchObject({ examCode: MAIN, attemptCycleId: cycleId, examDate: "2027-06-01", priority: 1, daysLeft: 211 });
    expect(p.exams[1]?.examCode).toBe("tnpsc-group-2");
    const days = await plan.days(user, "2026-11-02", "2026-11-15");
    expect(days.days.every((d) => d.items.length > 0)).toBe(true);
    expect(await prisma.planItem.count({ where: { planId: p.id } })).toBeGreaterThan(14);
  });

  it("item status: owner only, conditional update, study log; offline action accepted once", async () => {
    const user = randomUUID();
    const clock = new FakeClock("2026-11-02T04:30:00.000Z");
    const { exams, plan } = build(clock);
    await exams.setMyExams(user, { mainExamCode: MAIN });
    await plan.put(user, { weekdayMinutes: 60, weekendMinutes: 60 });
    const card = (await plan.today(user)).todayCard;
    if (!card) throw new Error("no card");
    await expect(plan.updateItem(randomUUID(), card.id, "done")).rejects.toMatchObject({ code: "NOT_FOUND" });
    const [a, b] = await Promise.all([plan.updateItem(user, card.id, "done"), plan.updateItem(user, card.id, "skipped")]);
    const final = await prisma.planItem.findUniqueOrThrow({ where: { id: card.id } });
    expect([a.status, b.status]).toContain(final.status);
    expect(await prisma.studyLog.count({ where: { userId: user } })).toBe(final.status === "done" ? 1 : 0);

    const next = (await plan.today(user)).todayCard;
    if (!next) throw new Error("no next");
    const action = { clientActionId: randomUUID(), clientAt: clock.now().toISOString(), kind: "plan_item_status" as const, itemId: next.id, status: "done" as const };
    const r = await Promise.all([plan.syncAction(user, action), plan.syncAction(user, action)]);
    expect(r.map((x) => x.status).sort()).toEqual(["accepted", "duplicate"]);
    expect(await prisma.studyLog.count({ where: { clientActionId: action.clientActionId } })).toBe(1);
    expect((await prisma.plan.findUniqueOrThrow({ where: { userId: user } })).lastActiveIstDay).toBe("2026-11-02");
  });

  it("rebalance after 2 missed days is idempotent per IST day; nightly job pages users", async () => {
    const users = [randomUUID(), randomUUID()];
    const clock = new FakeClock("2026-11-02T04:30:00.000Z");
    const { exams, plan, events } = build(clock);
    for (const u of users) {
      await exams.setMyExams(u, { mainExamCode: MAIN });
      await plan.put(u, { weekdayMinutes: 60, weekendMinutes: 60 });
    }
    clock.advanceDays(2);
    const first = await plan.rebalanceDue();
    expect(first.rebalanced).toBeGreaterThanOrEqual(2);
    const moved = await prisma.planItem.count({ where: { plan: { userId: users[0] }, status: "moved" } });
    expect(moved).toBeGreaterThan(0);
    const again = await plan.rebalanceDue();
    expect(again.rebalanced).toBe(0);
    expect(await prisma.planItem.count({ where: { plan: { userId: users[0] }, status: "moved" } })).toBe(moved);
    const t = await plan.today(users[0] as string);
    expect(t.welcomeBack).toBe(WELCOME_BACK);
    expect(events.filter((e) => e === "plan.rebalanced").length).toBeGreaterThanOrEqual(2);
  });

  it("exams.date_changed refreshes the cached date and rebuilds (Final Stretch d30)", async () => {
    const user = randomUUID();
    const clock = new FakeClock("2026-11-02T04:30:00.000Z");
    const { exams, plan } = build(clock);
    await exams.setMyExams(user, { mainExamCode: MAIN, attemptCycles: { [MAIN]: cycleId } });
    await plan.put(user, { weekdayMinutes: 60, weekendMinutes: 60 });
    await prisma.examAttemptCycle.update({ where: { id: cycleId }, data: { stageDates: [{ stageCode: "written", date: "2026-11-25", dateStatus: "official" }] } });
    try {
      const r = await plan.onDateChanged({ examCode: MAIN, cycleId });
      expect(r.plans).toBeGreaterThanOrEqual(1);
      const p = await plan.get(user);
      expect(p.exams[0]?.examDate).toBe("2026-11-25");
      expect(p.stretch).toBe("d30");
      // after the starter path, d30 plans only critical lamps
      const d = await plan.days(user, "2026-11-09", "2026-11-15");
      const lessons = d.days.flatMap((x) => x.items.filter((i) => i.kind === "lesson"));
      const crit = await prisma.topicExamTag.findMany({ where: { examCode: MAIN, priority: { gte: 2 } } });
      for (const l of lessons) expect(crit.map((c) => c.topicId)).toContain(l.topicId);
    } finally {
      await prisma.examAttemptCycle.update({ where: { id: cycleId }, data: { stageDates: [{ stageCode: "written", date: "2027-06-01", dateStatus: "official" }] } });
    }
  });

  it("syllabus topics carry TopicExamTag.priority", async () => {
    const syllabus = createSyllabusModule({ prisma });
    const t = await syllabus.topicsForExam(MAIN);
    expect(t.some((x) => x.priorities?.[MAIN] === 2)).toBe(true);
  });
});
