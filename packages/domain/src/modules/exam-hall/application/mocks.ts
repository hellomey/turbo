import { EXAM_HALL_CONFIG } from "../domain/config.js";
import { istMonthKey, nextStateMockSunday, usesAllowance } from "../domain/rules.js";
import type { ExamHallDeps, MockListDto, StateMockInfoDto } from "./ports.js";
import { toSummary } from "./shared.js";

/**
 * GET /v1/mocks?examCode (§9.9, §11, §13): published mocks whose scheme version is PUBLISHED (unverified schemes in
 * production stay draft and are not listed). Free users see `locked` on full mocks once this IST month's mock is used.
 * Descriptive papers are listed nowhere in Phase 2 (R4).
 */
export async function listMocks(deps: ExamHallDeps, userId: string, examCode: string): Promise<MockListDto> {
  const now = deps.clock.now();
  const istMonth = istMonthKey(now);
  const [mocks, pro, used] = await Promise.all([
    deps.repo.listPublishedMocks(examCode),
    deps.entitlements.isPro(userId),
    deps.repo.allowanceUsed(userId, istMonth),
  ]);
  const last = await deps.repo.lastAttemptIds(userId, mocks.map((m) => m.id));
  const items: MockListDto["items"] = [];
  for (const mock of mocks) {
    const paper = await deps.papers.paperForMock(mock.paperId, mock.schemeVersion);
    if (!paper || paper.scheme.status !== "published" || paper.answerMode === "descriptive") continue;
    if (mock.closesAt && now >= mock.closesAt) continue;
    items.push(toSummary(mock, paper, !pro && used && usesAllowance(mock), last.get(mock.id) ?? null));
  }
  return {
    items,
    allowance: {
      istMonth,
      freeFullMocksUsed: used ? 1 : 0,
      freeFullMocksLimit: pro ? null : EXAM_HALL_CONFIG.freeFullMocksPerIstMonth,
    },
  };
}

/** GET /v1/state-mock-sunday?examCode (Q13): the scheduled mock if Ops created one, and the next 1st/3rd Sunday (IST). */
export async function stateMockInfo(deps: ExamHallDeps, examCode: string): Promise<StateMockInfoDto> {
  const now = deps.clock.now();
  const mock = await deps.repo.nextStateMock(examCode, now);
  const paper = mock ? await deps.papers.paperForMock(mock.paperId, mock.schemeVersion) : null;
  const usable = mock && paper && paper.scheme.status === "published" && paper.answerMode !== "descriptive" ? { mock, paper } : null;
  return {
    mock: usable ? toSummary(usable.mock, usable.paper, false, null) : null,
    nextSunday: nextStateMockSunday(now),
    rankPublishAt: usable?.mock.rankPublishAt?.toISOString() ?? null,
  };
}
