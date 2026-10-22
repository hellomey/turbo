import type { PrismaClient } from "@heymey/db";

import type { QuestionCandidates } from "../application/question-bank.js";

/** Read-only over tables owned by content. */
export class PrismaQuestionCandidates implements QuestionCandidates {
  constructor(private readonly prisma: PrismaClient) {}

  async candidateIds(topicId: string, minDifficulty: number): Promise<string[]> {
    const rows = await this.prisma.question.findMany({
      where: {
        topicId,
        status: "published",
        difficulty: { gte: minDifficulty },
        kind: { in: ["single_choice", "multi_choice"] },
        versions: { some: { status: "published" } },
      },
      select: { id: true },
      orderBy: { id: "asc" },
    });
    return rows.map((r) => r.id);
  }
}
