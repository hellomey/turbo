import type { ReadinessMeter, ReadinessTrend, z } from "@heymey/contracts";
import { istDayKey } from "../../../shared/clock.js";
import { DomainError } from "../../../shared/errors.js";
import { READINESS_CONFIG } from "../domain/config.js";
import { barValues, coverageDetail, labelFor, meterBars, readyForFullMocks, suggestionFor, type Evidence } from "../domain/meter.js";
import type { ReadinessDeps } from "./ports.js";

export type ReadinessMeterDto = z.infer<typeof ReadinessMeter>;
export type ReadinessTrendDto = z.infer<typeof ReadinessTrend>;

const DAY_MS = 24 * 60 * 60 * 1000;

/** Lamps of one exam from mastery's public API: counts from the summary, "Steady and not dim" from the lamp states. */
async function lampEvidence(d: ReadinessDeps, userId: string, examCode: string): Promise<Evidence["lamps"]> {
  const summary = await d.mastery.summary(userId);
  const mine = summary.byExam.find((e) => e.examCode === examCode);
  if (!mine) return null;
  let steadyNotDim = 0;
  let cursor: string | undefined;
  do {
    const page = await d.mastery.topicStates(userId, { examCode, cursor, limit: 500 });
    for (const s of page.items) if (s.ring.lit && s.ring.steadyLevel > 0 && s.ring.dim !== "dim") steadyNotDim++;
    cursor = page.nextCursor ?? undefined;
  } while (cursor);
  const c = mine.counts;
  return { total: c.totalLamps, lit: c.lit, steady: c.steady, gold: c.gold, steadyNotDim: Math.min(steadyNotDim, c.lit) };
}

/** Last N submitted mocks of this exam (invariant 2), from exam-hall's public history + report. */
async function mockEvidence(d: ReadinessDeps, userId: string, examCode: string): Promise<Evidence["mocks"]> {
  const out: Evidence["mocks"] = [];
  let cursor: string | null = null;
  let scanned = 0;
  do {
    const page = await d.examHall.history(userId, cursor, 20);
    for (const item of page.items) {
      scanned++;
      if (item.status !== "submitted") continue;
      const r = await d.examHall.report(userId, item.attemptId);
      if (r.examCode !== examCode) continue;
      out.push({ score: r.score.numerator / r.score.denominator, max: r.maxScore.numerator / r.maxScore.denominator });
      if (out.length >= READINESS_CONFIG.examPerformanceLastMocks) return out;
    }
    cursor = page.nextCursor;
  } while (cursor && scanned < READINESS_CONFIG.mockHistoryScan);
  return out;
}

export async function evidenceFor(d: ReadinessDeps, userId: string, examCode: string): Promise<{ evidence: Evidence; labelled: boolean }> {
  const [lamps, mocks, info, practiced] = await Promise.all([
    lampEvidence(d, userId, examCode),
    mockEvidence(d, userId, examCode),
    d.exams.examInfo(examCode),
    d.practice.speed(userId, examCode),
  ]);
  if (!info) throw new DomainError("EXAM_NOT_FOUND", { code: examCode });
  const paper = info.paperSecondsPerQuestion;
  const speed = practiced && paper ? { medianSeconds: practiced.medianSeconds, paperSeconds: paper } : null;
  const labelled = READINESS_CONFIG.labelledConductingBodies.includes(info.conductingBody);
  return { evidence: { lamps, mocks, speed }, labelled };
}

/**
 * GET /v1/me/readiness (§19.5 Q41-Q48). The label always uses all server evidence; free users see two bars
 * (invariant 5). Stores today's snapshot (one per user/exam/IST day, invariant 7) for the trend.
 */
export async function getMeter(d: ReadinessDeps, userId: string, examCode: string): Promise<ReadinessMeterDto> {
  const now = d.clock.now();
  const [{ evidence, labelled }, isPro] = await Promise.all([evidenceFor(d, userId, examCode), d.entitlements.isPro(userId)]);
  const v = barValues(evidence);
  const label = labelFor(v, labelled);
  const coverage = coverageDetail(evidence);
  if (evidence.lamps) {
    await d.repo.upsertSnapshot({
      userId,
      examCode,
      istDay: istDayKey(now),
      label,
      coverage: v.coverage,
      memory: v.memory,
      examPerformance: v.examPerformance,
      speed: v.speed,
      ...coverage,
      configVersion: READINESS_CONFIG.version,
      computedAt: now,
    });
  }
  return {
    examCode,
    label,
    bars: meterBars(evidence, v, isPro),
    coverage,
    readyForFullMocks: readyForFullMocks(v),
    suggestion: suggestionFor(evidence, v, labelled),
    computedAt: now.toISOString(),
  };
}

/** GET /v1/me/readiness/trend (§19.5 Q47): Pro only (invariant 6). Days with no snapshot are simply absent. */
export async function getTrend(d: ReadinessDeps, userId: string, examCode: string, days: number): Promise<ReadinessTrendDto> {
  if (!(await d.entitlements.isPro(userId))) throw new DomainError("PRO_REQUIRED", { feature: "readiness_trend" });
  const now = d.clock.now();
  const rows = await d.repo.snapshotsBetween(userId, examCode, istDayKey(new Date(now.getTime() - (days - 1) * DAY_MS)), istDayKey(now));
  return {
    examCode,
    days,
    points: rows.map((r) => ({
      day: r.istDay,
      label: r.label as ReadinessMeterDto["label"],
      coverage: r.coverage,
      memory: r.memory,
      examPerformance: r.examPerformance,
      speed: r.speed,
    })),
  };
}
