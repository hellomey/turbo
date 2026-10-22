import { DomainError } from "../../../shared/errors.js";
import { EXAM_HALL_CONFIG } from "../domain/config.js";
import { rankAttempts } from "../domain/ranking.js";
import type { ExamHallDeps, StatewideRankDto } from "./ports.js";
import { paperOf, settle, toMarks } from "./shared.js";

const EXPIRE_BATCH = 200;

/**
 * Worker `exam-hall.expire` (every 5 min): score every in-progress attempt past deadline + grace as `expired`
 * (invariant 9). Safe to run twice: finishing is conditional on `in_progress`.
 */
export async function expireOverdueAttempts(deps: ExamHallDeps): Promise<{ expired: number }> {
  const now = deps.clock.now();
  const cutoff = new Date(now.getTime() - EXAM_HALL_CONFIG.answerGraceSeconds * 1000);
  let expired = 0;
  for (;;) {
    const ids = await deps.repo.overdueAttemptIds(cutoff, EXPIRE_BATCH);
    let batch = 0;
    for (const id of ids) {
      const attempt = await deps.repo.findAttempt(id);
      if (attempt && (await settle(deps, attempt)).status === "expired") batch += 1;
    }
    expired += batch;
    if (ids.length < EXPIRE_BATCH || batch === 0) break;
  }
  return { expired };
}

/**
 * Worker `exam-hall.publish-ranks` (every 10 min, acts at `rankPublishAt`; invariant 12): for each due State Mock,
 * close any still-open attempt, rank the RANKED finished attempts by exact score, write rank rows ONCE.
 */
export async function publishDueRanks(deps: ExamHallDeps): Promise<{ mocks: number; rows: number }> {
  const now = deps.clock.now();
  let mocks = 0;
  let rows = 0;
  for (const mock of await deps.repo.mocksDueForRanks(now)) {
    for (const attempt of await deps.repo.openAttempts(mock.id)) await settle(deps, attempt);
    const ranked = rankAttempts(await deps.repo.rankedScores(mock.id));
    if (!ranked.length) continue;
    rows += await deps.repo.insertRanks(mock.id, ranked, now);
    mocks += 1;
    await deps.events?.publish({ type: "exam_hall.rank_published", occurredAt: now, payload: { mockId: mock.id, examCode: mock.examCode, candidates: ranked.length } });
  }
  return { mocks, rows };
}

/** GET /v1/mocks/{mockId}/statewide-rank (§18, §39): before publish -> RANK_NOT_READY; not ranked -> NOT_FOUND. */
export async function statewideRank(deps: ExamHallDeps, userId: string, mockId: string): Promise<StatewideRankDto> {
  const mock = await deps.repo.findMock(mockId);
  if (!mock || mock.status !== "published") throw new DomainError("MOCK_NOT_FOUND", { mockId });
  const now = deps.clock.now();
  if (!mock.rankPublishAt || now < mock.rankPublishAt || !(await deps.repo.ranksPublished(mockId))) {
    throw new DomainError("RANK_NOT_READY", { rankPublishAt: mock.rankPublishAt?.toISOString() ?? null });
  }
  const [rank, attempt, paper] = await Promise.all([
    deps.repo.findRank(mockId, userId),
    deps.repo.rankedAttempt(mockId, userId),
    paperOf(deps, mock),
  ]);
  if (!rank || !attempt?.result) throw new DomainError("NOT_FOUND", { mockId });
  return {
    mockId,
    scopeLabel: paper.rankScope,
    rank: rank.rank,
    rankedCandidates: rank.candidates,
    percentile: rank.percentile,
    score: toMarks(attempt.result.score),
    publishedAt: rank.publishedAt.toISOString(),
  };
}
