// BOLT-0014 · U-exams Phase 2 invariants 4-10 (Exam Alerts). Blueprint §19.1 Q7, §17.5, §20.2; D-2026-10-22-32.
import { describe, expect, it } from "vitest";
import { OFFICIAL_CONFIRM_LINE } from "@heymey/contracts";
import { FakeClock } from "@heymey/testing";
import type { DomainEvent } from "../../src/shared/ports.js";
import {
  applyStageDate,
  canReviewExamChanges,
  createExamAlertsModule,
  type ExamAlertRecord,
  type ExamAlertsRepository,
  type ExamChangeRecord,
} from "../../src/modules/exams/index.js";

const SECRET = "s".repeat(40);
const OPS = "0199f5a0-0000-7000-8000-0000000000aa";
const AT = new Date("2026-10-22T06:30:00.000Z");
const body = { watchUuid: "0199f5a0-0000-7000-8000-000000000001", watchUrl: "https://www.tnpsc.gov.in/", changeId: "2026-10-22T06:00:00Z" };
const approveBody = { examCode: "tnpsc-group-4", kind: "notification" as const, title: "Group 4 notified", summary: "Applications open now.", officialUrl: "https://www.tnpsc.gov.in/n.pdf" };

class MemRepo implements ExamAlertsRepository {
  changes: ExamChangeRecord[] = [];
  alerts: ExamAlertRecord[] = [];
  followers = new Map<string, string[]>([["tnpsc-group-4", ["u1", "u2"]]]);
  hasCycleStage = true;
  private seq = 0;
  async insertChange(i: { watchUuid: string; changeId: string; watchUrl: string; title: string | null; diffSummary: string | null; at: Date }) {
    if (this.changes.some((c) => c.watchUuid === i.watchUuid && c.changeId === i.changeId)) return "duplicate" as const;
    this.changes.push({ id: `c${++this.seq}`, watchUuid: i.watchUuid, changeId: i.changeId, watchUrl: i.watchUrl, title: i.title, diffSummary: i.diffSummary, receivedAt: i.at, status: "pending", reviewedAt: null, alertId: null, examCode: null });
    return "created" as const;
  }
  async listChanges(status: string, _c: string | undefined, limit: number) {
    return this.changes.filter((c) => c.status === status).slice(0, limit);
  }
  async findChange(id: string) {
    return this.changes.find((c) => c.id === id) ?? null;
  }
  async examIdByCode(code: string) {
    return code === "tnpsc-group-4" ? "exam-1" : null;
  }
  async approve(i: Parameters<ExamAlertsRepository["approve"]>[0]) {
    const c = this.changes.find((x) => x.id === i.changeId && x.status === "pending");
    if (!c) return null;
    const alert: ExamAlertRecord = { id: `a${++this.seq}`, examCode: i.alert.examCode, kind: i.alert.kind, title: i.alert.title, summary: i.alert.summary, officialUrl: i.alert.officialUrl, publishedAt: i.at };
    this.alerts.push(alert);
    Object.assign(c, { status: "approved", reviewedAt: i.at, alertId: alert.id, examCode: i.alert.examCode });
    return { change: c, alert, cycleId: i.stageDate && this.hasCycleStage ? "cycle-1" : null };
  }
  async reject(i: { changeId: string; at: Date }) {
    const c = this.changes.find((x) => x.id === i.changeId && x.status === "pending");
    if (!c) return null;
    Object.assign(c, { status: "rejected", reviewedAt: i.at });
    return c;
  }
  async alertsForUser(_u: string, _c: string | undefined, limit: number) {
    return this.alerts.slice(0, limit);
  }
  async followersOf(code: string) {
    return this.followers.get(code) ?? [];
  }
}

function setup() {
  const repo = new MemRepo();
  const events: DomainEvent[] = [];
  const api = createExamAlertsModule({ repository: repo, clock: new FakeClock(AT), events: { publish: async (e) => void events.push(e) }, webhookSecret: SECRET });
  return { repo, events, api };
}

describe("webhook intake (invariants 4-6)", () => {
  it("wrong or missing secret -> WEBHOOK_UNAUTHORIZED and nothing stored, body never parsed", async () => {
    const s = setup();
    let parsed = 0;
    const parse = () => (parsed++, body);
    for (const bad of [undefined, "", "x", SECRET + "x", SECRET.slice(1)]) {
      await expect(s.api.receiveSiteChange(bad, parse)).rejects.toMatchObject({ code: "WEBHOOK_UNAUTHORIZED" });
    }
    expect(parsed).toBe(0);
    expect(s.repo.changes).toHaveLength(0);
  });

  it("without a configured secret every call is refused", async () => {
    const api = createExamAlertsModule({ repository: new MemRepo(), clock: new FakeClock(AT), events: { publish: async () => {} } });
    await expect(api.receiveSiteChange(SECRET, () => body)).rejects.toMatchObject({ code: "WEBHOOK_UNAUTHORIZED" });
  });

  it("valid -> stored pending, nothing published; replay -> WEBHOOK_REPLAYED, one row", async () => {
    const s = setup();
    expect(await s.api.receiveSiteChange(SECRET, () => body)).toEqual({ received: true });
    await expect(s.api.receiveSiteChange(SECRET, () => body)).rejects.toMatchObject({ code: "WEBHOOK_REPLAYED" });
    expect(s.repo.changes).toHaveLength(1);
    expect(s.repo.changes[0]?.status).toBe("pending");
    expect(s.events).toEqual([]);
  });
});

describe("review (invariants 7-10)", () => {
  it("only OPS or ADMIN may review", () => {
    expect(canReviewExamChanges(["OPS"])).toBe(true);
    expect(canReviewExamChanges(["ADMIN", "CREATOR"])).toBe(true);
    expect(canReviewExamChanges(["REVIEWER", "PUBLISHER"])).toBe(false);
  });

  it("approve: one alert + exams.notification_published; second approve -> 409 code", async () => {
    const s = setup();
    await s.api.receiveSiteChange(SECRET, () => body);
    const res = await s.api.approve(OPS, "c1", approveBody);
    expect(res).toMatchObject({ status: "approved", examCode: "tnpsc-group-4", alertId: "a2" });
    expect(s.events.map((e) => [e.type, e.payload])).toEqual([["exams.notification_published", { alertId: "a2", examCode: "tnpsc-group-4" }]]);
    await expect(s.api.approve(OPS, "c1", approveBody)).rejects.toMatchObject({ code: "EXAM_CHANGE_ALREADY_REVIEWED" });
    await expect(s.api.reject(OPS, "c1", "too late")).rejects.toMatchObject({ code: "EXAM_CHANGE_ALREADY_REVIEWED" });
    expect(s.repo.alerts).toHaveLength(1);
  });

  it("approve with newStageDate also publishes exams.date_changed (only when a cycle took it)", async () => {
    const s = setup();
    await s.api.receiveSiteChange(SECRET, () => body);
    await s.api.approve(OPS, "c1", { ...approveBody, newStageDate: { stageCode: "prelims", date: "2027-06-01" } });
    expect(s.events.map((e) => e.type)).toEqual(["exams.notification_published", "exams.date_changed"]);
    expect(s.events[1]?.payload).toEqual({ examCode: "tnpsc-group-4", cycleId: "cycle-1", stageCode: "prelims", date: "2027-06-01" });
    s.repo.hasCycleStage = false;
    await s.api.receiveSiteChange(SECRET, () => ({ ...body, changeId: "2026-10-23T00:00:00Z" }));
    await s.api.approve(OPS, "c3", { ...approveBody, newStageDate: { stageCode: "nope", date: "2027-06-01" } });
    expect(s.events.map((e) => e.type)).toEqual(["exams.notification_published", "exams.date_changed", "exams.notification_published"]);
  });

  it("approve: unknown change -> NOT_FOUND, unknown exam -> EXAM_NOT_FOUND", async () => {
    const s = setup();
    await expect(s.api.approve(OPS, "nope", approveBody)).rejects.toMatchObject({ code: "NOT_FOUND" });
    await s.api.receiveSiteChange(SECRET, () => body);
    await expect(s.api.approve(OPS, "c1", { ...approveBody, examCode: "ssc-zzz" })).rejects.toMatchObject({ code: "EXAM_NOT_FOUND" });
  });

  it("reject never publishes; reject unknown -> NOT_FOUND", async () => {
    const s = setup();
    await s.api.receiveSiteChange(SECRET, () => body);
    expect((await s.api.reject(OPS, "c1", "not an exam page")).status).toBe("rejected");
    expect(s.events).toEqual([]);
    await expect(s.api.reject(OPS, "x", "why")).rejects.toMatchObject({ code: "NOT_FOUND" });
  });

  it("invariant 9: every alert carries the official URL and the confirm line; pages have a cursor", async () => {
    const s = setup();
    for (const id of ["1", "2", "3"]) {
      await s.api.receiveSiteChange(SECRET, () => ({ ...body, changeId: id }));
    }
    for (const c of ["c1", "c2", "c3"]) await s.api.approve(OPS, c, approveBody);
    const page = await s.api.myAlerts("u1", { limit: 2 });
    expect(page.items).toHaveLength(2);
    expect(page.nextCursor).toBe(page.items[1]?.id);
    expect(page.items[0]).toMatchObject({ officialUrl: approveBody.officialUrl, confirmLine: OFFICIAL_CONFIRM_LINE });
    expect((await s.api.myAlerts("u1", { limit: 5 })).nextCursor).toBeNull();
    expect((await s.api.listChanges({ status: "approved", limit: 20 })).items).toHaveLength(3);
    expect(await s.api.followersOf("tnpsc-group-4")).toEqual(["u1", "u2"]);
  });

  it("applyStageDate marks the stage announced and reports whether anything changed", () => {
    const r = applyStageDate([{ stageCode: "prelims", date: null, dateStatus: "expected" }, { stageCode: "mains", date: null }], "prelims", "2027-06-01");
    expect(r.changed).toBe(true);
    expect(r.entries[0]).toEqual({ stageCode: "prelims", date: "2027-06-01", dateStatus: "announced" });
    expect(applyStageDate([], "prelims", "2027-06-01").changed).toBe(false);
  });
});
