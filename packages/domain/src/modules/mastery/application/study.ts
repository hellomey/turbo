import type { AnswerInput, CheckResult, TopicCheck, z } from "@heymey/contracts";
import { DomainError } from "../../../shared/errors.js";
import { checkSpec, deadlineFor, goldLimitReached, isExpired, isLate, scoreCheck } from "../domain/check.js";
import { MASTERY_CONFIG } from "../domain/config.js";
import { toTopicStateDto, type TopicStateDto } from "../domain/dto.js";
import { applyCheck, canStart, completeLesson as completeLessonRule, emptyLamp, istDayStartPlusDays, nextCheck, type CheckKind } from "../domain/lamp.js";
import type { MasteryDeps } from "./ports.js";
import { recomputeRank } from "./read.js";
import { writeLamp } from "./write-lamp.js";

export type TopicCheckDto = z.infer<typeof TopicCheck>;
export type CheckResultDto = z.infer<typeof CheckResult>;
export type AnswerInputDto = z.infer<typeof AnswerInput>;

async function requireTopic(deps: MasteryDeps, topicId: string): Promise<void> {
  if (!(await deps.syllabus.topic(topicId))) throw new DomainError("TOPIC_NOT_FOUND", { topicId });
}

/** POST /v1/topics/{topicId}/lesson-complete (S01): opens the Lit check. Idempotent by rule (a repeat changes nothing). */
export async function completeLesson(deps: MasteryDeps, userId: string, topicId: string): Promise<TopicStateDto> {
  await requireTopic(deps, topicId);
  const w = await writeLamp(deps, { userId, topicId, source: "online" }, completeLessonRule);
  return toTopicStateDto(w.state, w.now);
}

/**
 * POST /v1/topics/{topicId}/checks: the server picks the questions (CSPRNG in content) and sets Gold's deadline
 * (§5.1, §34.1). 409 CHECK_NOT_AVAILABLE before its step or with too few questions; GOLD_DAILY_LIMIT per IST day.
 */
export async function startCheck(deps: MasteryDeps, userId: string, topicId: string, kind: CheckKind): Promise<TopicCheckDto> {
  await requireTopic(deps, topicId);
  const now = deps.clock.now();
  const state = (await deps.repo.getState(userId, topicId)) ?? emptyLamp(userId, topicId, now);
  if (!canStart(kind, state, now)) throw new DomainError("CHECK_NOT_AVAILABLE", { kind, nextCheck: nextCheck(state, now) });
  if (kind === "gold") {
    const today = await deps.repo.countChecksSince(userId, topicId, "gold", istDayStartPlusDays(now, 0));
    if (goldLimitReached(today)) throw new DomainError("GOLD_DAILY_LIMIT", { topicId });
  }
  const spec = checkSpec(kind);
  const questions = await deps.questions.pick({ topicId, count: spec.questions, minDifficulty: spec.minDifficulty });
  if (questions.length < spec.questions) throw new DomainError("CHECK_NOT_AVAILABLE", { kind, reason: "not_enough_questions" });
  const check = await deps.repo.createCheck({
    userId,
    topicId,
    kind,
    questionIds: questions.map((q) => q.id),
    passMark: spec.passMark,
    issuedAt: now,
    deadlineAt: deadlineFor(kind, now),
    source: "online",
    configVersion: MASTERY_CONFIG.version,
  });
  return {
    checkId: check.id,
    topicId,
    kind,
    questions,
    passMark: check.passMark,
    issuedAt: check.issuedAt.toISOString(),
    deadlineAt: check.deadlineAt ? check.deadlineAt.toISOString() : null,
    serverNow: now.toISOString(),
  };
}

/** Last answer per issued question; answers to other questions are ignored. */
function answersFor(questionIds: readonly string[], answers: readonly AnswerInputDto[]): Map<string, string[]> {
  const issued = new Set(questionIds);
  const out = new Map<string, string[]>();
  for (const a of answers) if (issued.has(a.questionId)) out.set(a.questionId, a.chosenOptionIds);
  return out;
}

/**
 * POST /v1/checks/{checkId}/submit: grade on the server (inv. 15), move the rings in one transaction with the
 * single-submit guard (inv. 4), recompute rank (inv. 12). Late Gold answers count as wrong (inv. 11).
 */
export async function submitCheck(deps: MasteryDeps, userId: string, checkId: string, answers: readonly AnswerInputDto[]): Promise<CheckResultDto> {
  const check = await deps.repo.getCheck(checkId);
  if (!check || check.userId !== userId) throw new DomainError("NOT_FOUND", { checkId });
  if (check.submittedAt) throw new DomainError("CHECK_ALREADY_SUBMITTED", { checkId });
  const now = deps.clock.now();
  if (isExpired(check, now)) throw new DomainError("CHECK_EXPIRED", { checkId });

  const chosen = answersFor(check.questionIds, answers);
  const graded = await deps.questions.grade(check.questionIds.map((id) => ({ questionId: id, chosenOptionIds: chosen.get(id) ?? [] })));
  const answered = [...chosen.values()].filter((c) => c.length > 0).length;
  const score = scoreCheck({
    total: check.questionIds.length,
    passMark: check.passMark,
    correctIds: new Set(graded.filter((g) => g.correct).map((g) => g.questionId)),
    answered,
    late: isLate(check, now),
  });

  const w = await writeLamp(
    deps,
    { userId, topicId: check.topicId, source: "online", checkId, check: { id: checkId, correct: score.correct, passed: score.passed } },
    (s, at) => {
      const t = applyCheck(check.kind, score.passed, s, at);
      return { ...t, events: t.events.map((e) => ({ ...e, details: { ...e.details, correct: score.correct, total: check.questionIds.length } })) };
    },
  );
  if (w.outcome === "duplicate") throw new DomainError("CHECK_ALREADY_SUBMITTED", { checkId });
  const rankUp = w.changed ? (await recomputeRank(deps, userId)).rankUp : null;
  return {
    checkId,
    kind: check.kind,
    passed: score.passed,
    correct: score.correct,
    total: check.questionIds.length,
    lateAnswersIgnored: score.lateAnswersIgnored,
    graded,
    topicState: toTopicStateDto(w.state, w.now),
    rankUp,
  };
}
