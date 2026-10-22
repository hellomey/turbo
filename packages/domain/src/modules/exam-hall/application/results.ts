import { DomainError } from "../../../shared/errors.js";
import { isCorrect } from "../domain/scoring.js";
import type { AttemptRecord } from "../domain/types.js";
import type { ExamHallDeps, MockAttemptListItemDto, MockReportDto } from "./ports.js";
import { display, finalize, mockOf, ownedAttempt, questionIdsOf, settle, toMarks } from "./shared.js";

const WEAK_TOPICS = 5;

/** POST /v1/mock-attempts/{id}/submit (invariant 9): scores once on the server; submitting again returns the same report. */
export async function submitAttempt(deps: ExamHallDeps, userId: string, attemptId: string): Promise<MockReportDto> {
  const attempt = await settle(deps, await ownedAttempt(deps, userId, attemptId));
  const done = attempt.status === "in_progress" ? await finalize(deps, attempt, "submitted") : attempt;
  return report(deps, done);
}

/** GET /v1/mock-attempts/{id}/report. An attempt still in progress has no report yet: REPORT_NOT_FOUND (no dedicated code in the contract; raised in BOLT-0011). */
export async function getReport(deps: ExamHallDeps, userId: string, attemptId: string): Promise<MockReportDto> {
  const attempt = await settle(deps, await ownedAttempt(deps, userId, attemptId));
  if (attempt.status === "in_progress") throw new DomainError("REPORT_NOT_FOUND", { attemptId });
  return report(deps, attempt);
}

/**
 * The report (§9.9, §13, §19.4 Q38; invariants 13-14): score, sections and mistakes are always shown; free users get
 * `fullReportLocked` (blurred Pro detail). Mistakes link to lamps (topicId). Nothing here changes rings.
 */
async function report(deps: ExamHallDeps, attempt: AttemptRecord): Promise<MockReportDto> {
  const result = attempt.result;
  /* c8 ignore next */ // finished attempts always carry a result.
  if (!result || !attempt.submittedAt) throw new DomainError("INTERNAL_ERROR");
  const mock = await mockOf(deps, attempt);
  const [answers, items, pro] = await Promise.all([
    deps.repo.answers(attempt.id),
    deps.questions.withKeys(questionIdsOf(mock)),
    deps.entitlements.isPro(attempt.userId),
  ]);
  const keys = new Map(items.map((i) => [i.key.questionId, i.key]));
  const order = new Map(questionIdsOf(mock).map((id, i) => [id, i]));
  const mistakes = answers
    .filter((a) => a.chosenOptionIds.length > 0)
    .flatMap((a) => {
      const key = keys.get(a.questionId);
      if (!key || isCorrect(a.chosenOptionIds, key.correctOptionIds)) return [];
      const why = a.chosenOptionIds.map((id) => key.whyWrong[id]).find((w) => typeof w === "string") ?? null;
      return [
        {
          questionId: a.questionId,
          correct: false,
          correctOptionIds: key.correctOptionIds,
          chosenOptionIds: a.chosenOptionIds,
          explanationMarkdown: key.explanationMarkdown,
          whyChosenIsWrong: why,
          source: key.source,
          topicId: key.topicId,
        },
      ];
    })
    .sort((x, y) => (order.get(x.questionId) ?? 0) - (order.get(y.questionId) ?? 0));
  const topicCounts = new Map<string, number>();
  for (const m of mistakes) topicCounts.set(m.topicId, (topicCounts.get(m.topicId) ?? 0) + 1);
  const weakTopicIds = [...topicCounts.entries()]
    .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))
    .slice(0, WEAK_TOPICS)
    .map(([id]) => id);
  return {
    attemptId: attempt.id,
    mockId: mock.id,
    examCode: mock.examCode,
    submittedAt: attempt.submittedAt.toISOString(),
    score: toMarks(result.score),
    maxScore: toMarks(result.maxScore),
    scoreDisplay: display(result.score),
    markingSchemeVersion: attempt.schemeVersion,
    correct: result.correct,
    wrong: result.wrong,
    unanswered: result.unanswered,
    sections: result.sections.map((s) => ({
      code: s.code,
      name: s.name,
      correct: s.correct,
      wrong: s.wrong,
      unanswered: s.unanswered,
      score: toMarks(s.score),
      maxScore: toMarks(s.maxScore),
    })),
    mistakes,
    weakTopicIds,
    ranked: attempt.ranked,
    fullReportLocked: !pro,
  };
}

/** GET /v1/me/mock-attempts: newest first, cursor paged. */
export async function history(
  deps: ExamHallDeps,
  userId: string,
  cursor: string | null,
  limit: number,
): Promise<{ items: MockAttemptListItemDto[]; nextCursor: string | null }> {
  const page = await deps.repo.history(userId, cursor, limit);
  return {
    items: page.rows.map(({ attempt, title, kind }) => ({
      attemptId: attempt.id,
      mockId: attempt.mockId,
      title,
      kind,
      status: attempt.status,
      startedAt: attempt.startedAt.toISOString(),
      scoreDisplay: attempt.result ? display(attempt.result.score) : null,
    })),
    nextCursor: page.nextCursor,
  };
}
