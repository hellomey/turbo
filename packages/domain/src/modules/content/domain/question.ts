import type { GradedAnswer, Question, QuestionSource, z } from "@heymey/contracts";

/**
 * Questions as served (blueprint §19.4 Q31-Q38, §22). Pure. The correct answer ("key") never leaves the server with a
 * question that is being answered: the contract `Question` has no answer field; the key is used only for grading.
 * (Added by BOLT-0011 for exam-hall; restored by BOLT-0009 after an accidental overwrite, same exported shapes.)
 */
export type QuestionDto = z.infer<typeof Question>;
export type QuestionSourceDto = z.infer<typeof QuestionSource>;

/** Server-only answer key of the latest published version. */
export interface QuestionKeyDto {
  questionId: string;
  topicId: string;
  correctOptionIds: string[];
  explanationMarkdown: string;
  whyWrong: Record<string, string>;
  source: QuestionSourceDto;
}

export interface QuestionWithKey {
  question: QuestionDto;
  key: QuestionKeyDto;
}

/** Port: read published questions with their keys. Unknown or unpublished ids are left out. */
export interface QuestionReader {
  withKeys(questionIds: readonly string[]): Promise<QuestionWithKey[]>;
}

/** Contract `QuestionSource` from a stored Source row and the question's PYQ facts. */
export function sourceOf(
  src: { citation: string; url: string | null } | null,
  pyq: { examCode: string | null; paperCode: string | null; year: number | null; number: number | null },
): QuestionSourceDto {
  return {
    citation: src?.citation ?? "HeyMey original question",
    url: src?.url ?? null,
    pyq: pyq.examCode && pyq.year ? { examCode: pyq.examCode, paperCode: pyq.paperCode, year: pyq.year, questionNumber: pyq.number } : null,
  };
}

// ---- BOLT-0009 (mastery checks): grading + CSPRNG shuffle. Additive.
export type GradedAnswerDto = z.infer<typeof GradedAnswer>;

/** Exact match of the chosen set with the correct set (order and duplicates ignored). Empty = skipped = wrong. */
export function isCorrect(correctOptionIds: readonly string[], chosen: readonly string[]): boolean {
  const a = new Set(correctOptionIds);
  const b = new Set(chosen);
  return b.size > 0 && a.size === b.size && [...a].every((id) => b.has(id));
}

/** Grade one answer against the server-only key (§34.1, §19.4 Q38 "why yours was wrong"). */
export function gradeWithKey(key: QuestionKeyDto, chosenOptionIds: readonly string[]): GradedAnswerDto {
  const chosen = [...new Set(chosenOptionIds)];
  const correct = isCorrect(key.correctOptionIds, chosen);
  const wrongChoice = correct ? undefined : chosen.find((id) => key.whyWrong[id]);
  return {
    questionId: key.questionId,
    correct,
    correctOptionIds: [...key.correctOptionIds],
    chosenOptionIds: chosen,
    explanationMarkdown: key.explanationMarkdown,
    whyChosenIsWrong: wrongChoice ? (key.whyWrong[wrongChoice] ?? null) : null,
    source: key.source,
    topicId: key.topicId,
  };
}

/** Fisher-Yates with an injected CSPRNG (`randomInt(maxExclusive)`), never Math.random (§40). */
export function shuffle<T>(items: readonly T[], randomInt: (maxExclusive: number) => number): T[] {
  const out = [...items];
  for (let i = out.length - 1; i > 0; i--) {
    const j = randomInt(i + 1);
    [out[i], out[j]] = [out[j] as T, out[i] as T];
  }
  return out;
}
