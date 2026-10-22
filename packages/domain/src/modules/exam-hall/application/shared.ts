import { DomainError } from "../../../shared/errors.js";
import { EXAM_HALL_CONFIG } from "../domain/config.js";
import { toDisplay, type Fraction } from "../domain/fraction.js";
import { graceEnd } from "../domain/rules.js";
import { scoreAttempt, hasNegativeMarking } from "../domain/scoring.js";
import type { AnswerKey, AttemptRecord, MockRecord, PaperView } from "../domain/types.js";
import type { ExamHallDeps, MockSummaryDto } from "./ports.js";

/** Contract `Marks` has a non-negative numerator; a negative total is shown as 0 there and exactly in `scoreDisplay`. */
export function toMarks(f: Fraction): { numerator: number; denominator: number } {
  return f.num < 0 ? { numerator: 0, denominator: 1 } : { numerator: f.num, denominator: f.den };
}

export function display(f: Fraction): string {
  return toDisplay(f, EXAM_HALL_CONFIG.scoreDisplayDecimals);
}

export function questionIdsOf(mock: MockRecord): string[] {
  return mock.sections.flatMap((s) => s.questionIds);
}

/** The paper + scheme version the mock is built for; a mock without one is treated as missing. */
export async function paperOf(deps: ExamHallDeps, mock: MockRecord): Promise<PaperView> {
  const paper = await deps.papers.paperForMock(mock.paperId, mock.schemeVersion);
  if (!paper) throw new DomainError("MOCK_NOT_FOUND", { mockId: mock.id });
  return paper;
}

export function toSummary(mock: MockRecord, paper: PaperView, locked: boolean, myLastAttemptId: string | null): MockSummaryDto {
  return {
    id: mock.id,
    code: mock.code,
    examCode: mock.examCode,
    paperCode: paper.paperCode,
    title: mock.title,
    kind: mock.kind,
    questionCount: Math.max(1, questionIdsOf(mock).length),
    durationMinutes: paper.scheme.durationMinutes,
    negativeMarking: hasNegativeMarking(paper.scheme.sections),
    opensAt: mock.opensAt?.toISOString() ?? null,
    lateJoinUntil: mock.lateJoinUntil?.toISOString() ?? null,
    closesAt: mock.closesAt?.toISOString() ?? null,
    free: mock.free,
    locked,
    myLastAttemptId,
  };
}

/** Load an attempt the caller owns. Unknown -> NOT_FOUND; someone else's -> FORBIDDEN (owner only, design API tests). */
export async function ownedAttempt(deps: ExamHallDeps, userId: string, attemptId: string): Promise<AttemptRecord> {
  const attempt = await deps.repo.findAttempt(attemptId);
  if (!attempt) throw new DomainError("NOT_FOUND", { attemptId });
  if (attempt.userId !== userId) throw new DomainError("FORBIDDEN");
  return attempt;
}

export async function mockOf(deps: ExamHallDeps, attempt: AttemptRecord): Promise<MockRecord> {
  const mock = await deps.repo.findMock(attempt.mockId);
  /* c8 ignore next */ // FK guarantees the row; kept for type narrowing.
  if (!mock) throw new DomainError("MOCK_NOT_FOUND", { mockId: attempt.mockId });
  return mock;
}

/**
 * Score and close an attempt once (invariants 6-9, 11). Uses the attempt's OWN scheme version.
 * `expired` when the server closes it after deadline + grace; ranking is kept only if every answer was on time.
 */
export async function finalize(
  deps: ExamHallDeps,
  attempt: AttemptRecord,
  status: "submitted" | "expired",
): Promise<AttemptRecord> {
  if (attempt.status !== "in_progress") return attempt;
  const mock = await mockOf(deps, attempt);
  const paper = await deps.papers.paperForMock(mock.paperId, attempt.schemeVersion);
  /* c8 ignore next */ // a scheme version is never deleted (immutable once published).
  if (!paper) throw new DomainError("MOCK_NOT_FOUND", { mockId: mock.id });
  const [answers, items] = await Promise.all([deps.repo.answers(attempt.id), deps.questions.withKeys(questionIdsOf(mock))]);
  const keys = new Map<string, AnswerKey>(items.map((i) => [i.key.questionId, i.key]));
  const result = scoreAttempt(paper.scheme.sections, mock.sections, new Map(answers.map((a) => [a.questionId, a])), keys);
  const now = deps.clock.now();
  const submittedAt = status === "expired" ? attempt.deadlineAt : now;
  const { attempt: done, changed } = await deps.repo.finishAttempt(attempt.id, { status, submittedAt, result });
  if (changed) {
    await deps.events?.publish({
      type: "exam_hall.mock_submitted",
      occurredAt: now,
      payload: {
        attemptId: done.id,
        userId: done.userId,
        mockId: mock.id,
        examCode: mock.examCode,
        status,
        ranked: done.ranked,
        correct: result.correct,
        wrong: result.wrong,
        unanswered: result.unanswered,
        mistakeTopicIds: [
          ...new Set(
            answers.flatMap((a) => {
              const key = keys.get(a.questionId);
              return key && a.chosenOptionIds.length && !sameSet(a.chosenOptionIds, key.correctOptionIds) ? [key.topicId] : [];
            }),
          ),
        ],
      },
    });
  }
  return done;
}

function sameSet(a: string[], b: string[]): boolean {
  return a.length === b.length && a.every((x) => b.includes(x));
}

/** Read-time expiry: an open attempt past deadline + grace is scored as expired before anything else happens. */
export async function settle(deps: ExamHallDeps, attempt: AttemptRecord): Promise<AttemptRecord> {
  if (attempt.status === "in_progress" && deps.clock.now() > graceEnd(attempt.deadlineAt)) return finalize(deps, attempt, "expired");
  return attempt;
}
