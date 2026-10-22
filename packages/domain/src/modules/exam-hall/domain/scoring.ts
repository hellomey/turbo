import { add, sub, times, ZERO, type Fraction } from "./fraction.js";
import type { AnswerKey, AttemptScore, MockSectionRef, SavedAnswer, SchemeSection, SectionScore } from "./types.js";

/** Correct = exactly the key's options (order-free). Empty choice = unanswered. */
export function isCorrect(chosen: readonly string[], key: readonly string[]): boolean {
  if (chosen.length !== key.length) return false;
  const want = new Set(key);
  return new Set(chosen).size === chosen.length && chosen.every((c) => want.has(c));
}

/**
 * Score an attempt with ONE marking scheme version (§9.9, ADR-0013, invariants 6-8):
 * per section, correct x marksPerCorrect - wrong x penaltyPerWrong, exact fractions; unanswered = 0;
 * "answer any N" counts only the first N answered questions in paper order (the rest count as unanswered).
 * Sections of the scheme that the mock does not include are skipped (sectional mocks).
 */
export function scoreAttempt(
  scheme: readonly SchemeSection[],
  mockSections: readonly MockSectionRef[],
  answers: ReadonlyMap<string, Pick<SavedAnswer, "chosenOptionIds">>,
  keys: ReadonlyMap<string, AnswerKey>,
): AttemptScore {
  const sections: SectionScore[] = [];
  for (const s of [...scheme].sort((a, b) => a.order - b.order)) {
    const ref = mockSections.find((m) => m.sectionCode === s.code);
    if (!ref) continue;
    sections.push(scoreSection(s, ref.questionIds, answers, keys));
  }
  return {
    score: sections.reduce<Fraction>((acc, s) => add(acc, s.score), ZERO),
    maxScore: sections.reduce<Fraction>((acc, s) => add(acc, s.maxScore), ZERO),
    correct: sum(sections, "correct"),
    wrong: sum(sections, "wrong"),
    unanswered: sum(sections, "unanswered"),
    sections,
  };
}

function scoreSection(
  s: SchemeSection,
  questionIds: readonly string[],
  answers: ReadonlyMap<string, Pick<SavedAnswer, "chosenOptionIds">>,
  keys: ReadonlyMap<string, AnswerKey>,
): SectionScore {
  const limit = s.attemptLimit ?? Number.POSITIVE_INFINITY;
  let counted = 0;
  let correct = 0;
  let wrong = 0;
  for (const qid of questionIds) {
    const chosen = answers.get(qid)?.chosenOptionIds ?? [];
    if (chosen.length === 0 || counted >= limit) continue;
    counted += 1;
    const key = keys.get(qid);
    if (key && isCorrect(chosen, key.correctOptionIds)) correct += 1;
    else wrong += 1;
  }
  const scorable = Math.min(questionIds.length, limit);
  return {
    code: s.code,
    name: s.name,
    correct,
    wrong,
    unanswered: questionIds.length - correct - wrong,
    score: sub(times(s.marksPerCorrect, correct), times(s.penaltyPerWrong, wrong)),
    maxScore: times(s.marksPerCorrect, scorable),
  };
}

function sum(sections: SectionScore[], k: "correct" | "wrong" | "unanswered"): number {
  return sections.reduce((acc, s) => acc + s[k], 0);
}

/** True when the scheme takes marks off for wrong answers in any section. */
export function hasNegativeMarking(scheme: readonly SchemeSection[]): boolean {
  return scheme.some((s) => s.penaltyPerWrong.num > 0);
}

