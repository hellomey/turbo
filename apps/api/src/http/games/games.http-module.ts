import { randomInt } from "node:crypto";
import { Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import type { PracticeContentApi } from "@heymey/domain/modules/content";
import type { EconomyProgressionApi } from "@heymey/domain/modules/economy";
import { createGames, type DuelQuestionsPort } from "@heymey/domain/modules/games";
import type { Clock } from "@heymey/domain/shared";
import { CLOCK, ECONOMY_API, GAMES_API, PRACTICE_CONTENT_API, PRISMA } from "../../platform/tokens.js";
import { GamesController } from "./games.controller.js";

/**
 * Duel questions from content: published, single-choice (one option is chosen with a confidence), random (CSPRNG).
 * Asks for twice as many so multi-choice ones can be dropped.
 */
export function duelQuestions(content: PracticeContentApi): DuelQuestionsPort {
  return {
    async pick(examCode, count) {
      const topicIds = await content.scope({ examCode });
      const qs = await content.pick({ topicIds, count: count * 2 });
      return qs.filter((q) => q.kind === "single_choice").slice(0, count);
    },
    keys: (refs) => content.atVersion(refs),
  };
}

/**
 * HTTP adapter for games (BOLT-0115). Composition: Points go through the economy firewall API (Points only), questions
 * come from content, randomness is node:crypto. games never sees billing or entitlements (FW-008).
 */
@Module({
  controllers: [GamesController],
  providers: [
    {
      provide: GAMES_API,
      inject: [PRISMA, CLOCK, ECONOMY_API, PRACTICE_CONTENT_API],
      useFactory: (prisma: PrismaClient, clock: Clock, economy: EconomyProgressionApi, content: PracticeContentApi) =>
        createGames({
          prisma,
          clock,
          rewards: { awardPoints: (a) => economy.awardGamePoints(a) },
          questions: duelQuestions(content),
          randomInt: (max) => randomInt(max),
        }),
    },
  ],
})
export class GamesHttpModule {}
