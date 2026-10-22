import type { MasterySummary, Rank, RankChange, RelightQueue, TopicStatePage, z } from "@heymey/contracts";
import { DomainError } from "../../../shared/errors.js";
import type { TopicRow } from "../../syllabus/index.js";
import { MASTERY_CONFIG } from "../domain/config.js";
import { toTopicStateDto } from "../domain/dto.js";
import { computeRank, countRings, rankTitle, type CountsDto } from "../domain/rank.js";
import type { MasteryDeps } from "./ports.js";

export type MasterySummaryDto = z.infer<typeof MasterySummary>;
export type TopicStatePageDto = z.infer<typeof TopicStatePage>;
export type RelightQueueDto = z.infer<typeof RelightQueue>;
export type RankDto = z.infer<typeof Rank>;
export type RankChangeDto = z.infer<typeof RankChange>;

/** The user's syllabus: published exams they follow, the lamps of each, and the union (shared lamps once, inv. 13). */
export async function learnerScope(deps: MasteryDeps, userId: string) {
  const [codes, published] = await Promise.all([deps.learner.examCodes(userId), deps.learner.publishedExamCodes()]);
  const examCodes = [...new Set(codes)].filter((c) => published.has(c));
  const perExam = await Promise.all(examCodes.map(async (code) => ({ code, topics: await deps.syllabus.topicsForExam(code) })));
  const union = new Map<string, TopicRow>();
  for (const e of perExam) for (const t of e.topics) union.set(t.id, t);
  return { perExam, union };
}

function rankDto(r: ReturnType<typeof computeRank>): RankDto {
  return {
    level: r.level,
    title: rankTitle(r.level),
    familyCode: null,
    xp: r.xp,
    xpForThisLevel: r.xpForThisLevel,
    xpForNextLevel: r.xpForNextLevel,
    note: MASTERY_CONFIG.rankNote,
  };
}

/**
 * Recompute the Career Ladder from ring counts only (§5.2, §5.3 rule 4, inv. 12) and cache it. A level above the cached
 * one is a rank-up (the app shows the rank-up screen with the "Game title" note).
 */
export async function recomputeRank(deps: MasteryDeps, userId: string): Promise<{ rank: RankDto; rankUp: RankChangeDto | null }> {
  const { union } = await learnerScope(deps, userId);
  const ids = new Set(union.keys());
  const c = countRings(await deps.repo.statesFor(userId, [...ids]), ids);
  const r = computeRank({ totalLamps: c.totalLamps, lit: c.lit, steadySteps: c.steadySteps, gold: c.gold });
  const previous = (await deps.repo.getRankLevel(userId)) ?? 1;
  await deps.repo.saveRank(userId, { level: r.level, xp: r.xp, familyCode: null, configVersion: MASTERY_CONFIG.version });
  const rankUp = r.level > previous ? { from: previous, to: r.level, title: rankTitle(r.level), note: MASTERY_CONFIG.rankNote } : null;
  if (rankUp) await deps.events.publish({ type: "mastery.rank_up", occurredAt: deps.clock.now(), payload: { userId, from: rankUp.from, to: rankUp.to } });
  return { rank: rankDto(r), rankUp };
}

const counts = (c: CountsDto): CountsDto => ({ totalLamps: c.totalLamps, lit: c.lit, steady: c.steady, gold: c.gold, dimming: c.dimming, dim: c.dim });

/** GET /v1/me/mastery: rank (lamps only), counts over the union, and per exam. One state query. */
export async function getSummary(deps: MasteryDeps, userId: string): Promise<MasterySummaryDto> {
  const now = deps.clock.now();
  const { perExam, union } = await learnerScope(deps, userId);
  const ids = new Set(union.keys());
  const states = await deps.repo.statesFor(userId, [...ids]);
  const all = countRings(states, ids);
  const r = computeRank({ totalLamps: all.totalLamps, lit: all.lit, steadySteps: all.steadySteps, gold: all.gold });
  return {
    rank: rankDto(r),
    counts: counts(all),
    byExam: perExam.map((e) => ({ examCode: e.code, counts: counts(countRings(states, new Set(e.topics.map((t) => t.id)))) })),
    serverNow: now.toISOString(),
  };
}

const encodeCursor = (updatedAt: Date, topicId: string) => Buffer.from(`${updatedAt.toISOString()}|${topicId}`).toString("base64url");

function decodeCursor(cursor: string): { updatedAt: Date; topicId: string } {
  const [at, topicId] = Buffer.from(cursor, "base64url").toString("utf8").split("|");
  const updatedAt = new Date(at ?? "");
  if (!topicId || Number.isNaN(updatedAt.getTime())) throw new DomainError("VALIDATION_FAILED", { issues: [{ path: "cursor", message: "Invalid cursor" }] });
  return { updatedAt, topicId };
}

/**
 * GET /v1/me/topic-states: stored lamp states of one published exam's map, ordered by (updatedAt, topicId); `since`
 * for incremental Drift sync. Lamps with no stored row are unlit (the app's default).
 */
export async function listStates(
  deps: MasteryDeps,
  userId: string,
  q: { examCode: string; since?: string | undefined; cursor?: string | undefined; limit: number },
): Promise<TopicStatePageDto> {
  const now = deps.clock.now();
  if (!(await deps.learner.publishedExamCodes()).has(q.examCode)) throw new DomainError("EXAM_NOT_FOUND", { code: q.examCode });
  const topicIds = (await deps.syllabus.topicsForExam(q.examCode)).map((t) => t.id);
  const rows = await deps.repo.pageStates({
    userId,
    topicIds,
    since: q.since ? new Date(q.since) : null,
    after: q.cursor ? decodeCursor(q.cursor) : null,
    limit: q.limit + 1,
  });
  const page = rows.slice(0, q.limit);
  const last = page.at(-1);
  return {
    items: page.map((s) => toTopicStateDto(s, now)),
    nextCursor: rows.length > q.limit && last ? encodeCursor(last.updatedAt, last.topicId) : null,
    serverNow: now.toISOString(),
  };
}

/** GET /v1/me/relight-queue: dimming/dim lamps the user can open (inv. 17), oldest first, with minutes. */
export async function relightQueue(deps: MasteryDeps, userId: string): Promise<RelightQueueDto> {
  const { union } = await learnerScope(deps, userId);
  const states = (await deps.repo.statesFor(userId, [...union.keys()])).filter((s) => s.litAt && s.dimState !== "bright");
  const openable = states.length ? await deps.openableTopics(states.map((s) => s.topicId)) : new Set<string>();
  const minutes = MASTERY_CONFIG.relight.minutesEstimate;
  const items = states
    .filter((s) => openable.has(s.topicId))
    .sort((a, b) => (a.dimSince?.getTime() ?? 0) - (b.dimSince?.getTime() ?? 0) || a.topicId.localeCompare(b.topicId))
    .map((s) => {
      const topic = union.get(s.topicId) as TopicRow;
      return {
        topicId: s.topicId,
        topicName: topic.name,
        subjectCode: topic.subject.code,
        dim: s.dimState as "dimming" | "dim",
        overdueSince: (s.dimSince ?? s.nextDueAt ?? s.updatedAt).toISOString(),
        minutes,
      };
    });
  return { items, totalMinutes: items.length * minutes };
}
