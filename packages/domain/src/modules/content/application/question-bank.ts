import { gradeWithKey, shuffle, type GradedAnswerDto, type QuestionDto, type QuestionReader } from "../domain/question.js";

/**
 * Server-picked question sets and server grading for mastery checks (blueprint §5.1, §34.1; BOLT-0009).
 * The server picks with a CSPRNG and grades from the stored key; client grading is never trusted (§39).
 */
/** Port: ids of published, answerable (objective) questions of a topic. */
export interface QuestionCandidates {
  candidateIds(topicId: string, minDifficulty: number): Promise<string[]>;
}

export interface QuestionBank {
  /** `count` random published questions of the topic, or [] when the topic has fewer than `count`. */
  pick(spec: { topicId: string; count: number; minDifficulty: number }): Promise<QuestionDto[]>;
  /** Grade answers on the server. Answers to unknown or unpublished questions are left out. */
  grade(answers: readonly { questionId: string; chosenOptionIds: readonly string[] }[]): Promise<GradedAnswerDto[]>;
}

export function questionBank(reader: QuestionReader, candidates: QuestionCandidates, randomInt: (maxExclusive: number) => number): QuestionBank {
  return {
    async pick({ topicId, count, minDifficulty }) {
      const ids = await candidates.candidateIds(topicId, minDifficulty);
      if (ids.length < count) return [];
      const chosen = shuffle(ids, randomInt).slice(0, count);
      const rows = await reader.withKeys(chosen);
      const byId = new Map(rows.map((r) => [r.question.id, r.question]));
      const out = chosen.map((id) => byId.get(id)).filter((q): q is QuestionDto => q !== undefined);
      return out.length === count ? out : [];
    },
    async grade(answers) {
      const ids = [...new Set(answers.map((a) => a.questionId))];
      const keys = new Map((await reader.withKeys(ids)).map((r) => [r.key.questionId, r.key]));
      const seen = new Set<string>();
      const out: GradedAnswerDto[] = [];
      for (const a of answers) {
        const key = keys.get(a.questionId);
        if (!key || seen.has(a.questionId)) continue;
        seen.add(a.questionId);
        out.push(gradeWithKey(key, a.chosenOptionIds));
      }
      return out;
    },
  };
}
