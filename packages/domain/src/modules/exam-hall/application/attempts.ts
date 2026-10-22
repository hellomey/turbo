import { DomainError } from "../../../shared/errors.js";
import { checkWindow, classifySave, deadlineFor, istMonthKey, modeForPaper, remainingSeconds, usesAllowance } from "../domain/rules.js";
import type { AttemptMode, AttemptRecord, MockRecord, SavedAnswer } from "../domain/types.js";
import type { ExamHallDeps, MockAnswersSavedDto, MockAttemptStateDto } from "./ports.js";
import { mockOf, ownedAttempt, paperOf, questionIdsOf, settle, toSummary } from "./shared.js";

/**
 * POST /v1/mocks/{mockId}/attempts (§9.9, §19.8 Q76; invariants 1-4, 10, 11). The SERVER sets start and deadline.
 * In-progress attempt -> returned as is (resume). Mode comes from the paper (R4); the body's mode must match it.
 */
export async function startAttempt(deps: ExamHallDeps, userId: string, mockId: string, requested: AttemptMode): Promise<MockAttemptStateDto> {
  const mock = await deps.repo.findMock(mockId);
  if (!mock || mock.status !== "published") throw new DomainError("MOCK_NOT_FOUND", { mockId });
  const paper = await paperOf(deps, mock);
  if (paper.scheme.status !== "published") throw new DomainError("MOCK_NOT_FOUND", { mockId });
  const mode = modeForPaper(paper);
  if (requested !== mode) throw new DomainError("VALIDATION_FAILED", { issues: [{ path: "mode", message: `This paper is ${mode}.` }] });

  const open = await deps.repo.findInProgress(userId, mockId);
  if (open) {
    const settled = await settle(deps, open);
    if (settled.status === "in_progress") return view(deps, settled, mock);
  }

  const now = deps.clock.now();
  const { live } = checkWindow(mock, now);
  const pro = usesAllowance(mock) ? await deps.entitlements.isPro(userId) : true;
  const { attempt } = await deps.repo.startAttempt({
    userId,
    mockId,
    mode,
    startedAt: now,
    deadlineAt: deadlineFor(now, paper.scheme.durationMinutes, mock, live),
    schemeVersion: mock.schemeVersion,
    istMonth: istMonthKey(now),
    rankedIfFirst: live,
    useAllowance: usesAllowance(mock) && !pro,
  });
  return view(deps, attempt, mock);
}

/** GET /v1/mock-attempts/{id}: resume exactly, with server time left (owner only). */
export async function getAttempt(deps: ExamHallDeps, userId: string, attemptId: string): Promise<MockAttemptStateDto> {
  const attempt = await settle(deps, await ownedAttempt(deps, userId, attemptId));
  return view(deps, attempt, await mockOf(deps, attempt));
}

async function view(deps: ExamHallDeps, attempt: AttemptRecord, mock: MockRecord): Promise<MockAttemptStateDto> {
  const paper = await paperOf(deps, mock);
  const [answers, items] = await Promise.all([deps.repo.answers(attempt.id), deps.questions.withKeys(questionIdsOf(mock))]);
  const byId = new Map(items.map((i) => [i.question.id, i.question]));
  const sectionNames = new Map(paper.scheme.sections.map((s) => [s.code, s]));
  return {
    attemptId: attempt.id,
    mock: toSummary(mock, paper, false, attempt.id),
    mode: attempt.mode,
    status: attempt.status,
    startedAt: attempt.startedAt.toISOString(),
    deadlineAt: attempt.deadlineAt.toISOString(),
    serverNow: deps.clock.now().toISOString(),
    sections: mock.sections.map((s) => ({
      code: s.sectionCode,
      name: sectionNames.get(s.sectionCode)?.name ?? s.sectionCode,
      questionIds: s.questionIds,
      minutes: sectionNames.get(s.sectionCode)?.minutes ?? null,
    })),
    questions: questionIdsOf(mock).flatMap((id) => {
      const q = byId.get(id);
      return q ? [q] : [];
    }),
    answers: answers.map((a) => ({ questionId: a.questionId, chosenOptionIds: a.chosenOptionIds, markedForReview: a.markedForReview })),
    ranked: attempt.ranked,
  };
}

export interface AnswerInput {
  questionId: string;
  chosenOptionIds: string[];
  markedForReview: boolean;
  clientAt: string;
}

/**
 * PUT /v1/mock-attempts/{id}/answers (invariant 5, Q25): last write per question wins (newer clientAt);
 * after deadline + grace answers are ignored; ANY answer after the deadline makes the attempt unranked.
 */
export async function saveAnswers(deps: ExamHallDeps, userId: string, attemptId: string, input: AnswerInput[]): Promise<MockAnswersSavedDto> {
  const attempt = await settle(deps, await ownedAttempt(deps, userId, attemptId));
  if (attempt.status === "submitted") throw new DomainError("MOCK_ALREADY_SUBMITTED");
  const now = deps.clock.now();
  const reply = (saved: number, ignored: number): MockAnswersSavedDto => ({
    saved,
    ignoredAfterDeadline: ignored,
    serverNow: now.toISOString(),
    remainingSeconds: remainingSeconds(now, attempt.deadlineAt),
  });
  if (attempt.status === "expired") return reply(0, input.length);

  const mock = await mockOf(deps, attempt);
  const allowed = new Set(questionIdsOf(mock));
  const unknown = input.find((a) => !allowed.has(a.questionId));
  if (unknown) throw new DomainError("VALIDATION_FAILED", { issues: [{ path: "answers.questionId", message: "Question is not in this mock." }] });

  // Last write in the batch wins per question (by clientAt, then array order).
  const latest = new Map<string, SavedAnswer>();
  let late = false;
  let ignored = 0;
  for (const a of input) {
    const clientAt = new Date(a.clientAt);
    const verdict = classifySave(now, clientAt, attempt.deadlineAt);
    if (verdict === "ignored") {
      ignored += 1;
      continue;
    }
    if (verdict === "late") late = true;
    const prev = latest.get(a.questionId);
    if (!prev || prev.clientAt <= clientAt) {
      latest.set(a.questionId, { questionId: a.questionId, chosenOptionIds: [...new Set(a.chosenOptionIds)], markedForReview: a.markedForReview, savedAt: now, clientAt });
    }
  }
  if (latest.size === 0) return reply(0, ignored);
  const saved = await deps.repo.saveAnswers(attempt.id, [...latest.values()], late);
  if (saved === null) throw new DomainError("MOCK_ALREADY_SUBMITTED");
  return reply(saved, ignored);
}
