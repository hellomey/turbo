import { randomInt } from "node:crypto";
import { Global, Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import { createQuestionBank, type ContentApi } from "@heymey/domain/modules/content";
import type { ExamsApi } from "@heymey/domain/modules/exams";
import { createMasteryModule } from "@heymey/domain/modules/mastery";
import type { SyllabusApi } from "@heymey/domain/modules/syllabus";
import type { Clock } from "@heymey/domain/shared";
import type { EconomyProgressionApi } from "@heymey/domain/modules/economy";
import { CLOCK, CONTENT_API, ECONOMY_API, EXAMS_API, MASTERY_API, PRISMA, SYLLABUS_API } from "../../platform/tokens.js";
import { economyEvents } from "../economy/economy.http-module.js";
import { MasteryController } from "./mastery.controller.js";

/**
 * HTTP adapter for the `mastery` module (BOLT-0009, blueprint §5.1, §5.2, §39). Owner: backend.
 * Composition: mastery depends on syllabus + content (module.json); the user's exams come from the exams module's
 * public API through LearnerPorts (no new module dependency, logical design "Composition"). CSPRNG = node:crypto.
 */
@Global()
@Module({
  controllers: [MasteryController],
  providers: [
    {
      provide: MASTERY_API,
      inject: [PRISMA, CLOCK, SYLLABUS_API, CONTENT_API, EXAMS_API, ECONOMY_API],
      useFactory: (prisma: PrismaClient, clock: Clock, syllabus: SyllabusApi, content: ContentApi, exams: ExamsApi, economy: EconomyProgressionApi) =>
        createMasteryModule({
          prisma,
          clock,
          syllabus,
          questions: createQuestionBank({ prisma, randomInt: (max) => randomInt(max) }),
          // Phase 2 stub (§11 "Relight: for topics you can open"): topics with published content; billing wires in Phase 3.
          openableTopics: (ids) => content.topicsWithPublishedLesson(ids),
          learner: {
            examCodes: async (userId) => {
              const mine = await exams.getMyExams(userId);
              return [...(mine.main ? [mine.main.code] : []), ...mine.others.map((e) => e.code)];
            },
            publishedExamCodes: () => exams.publishedCodes(),
          },
          events: economyEvents(economy), // BOLT-0113: lamp changes earn XP and trophies
        }),
    },
  ],
  exports: [MASTERY_API],
})
export class MasteryHttpModule {}
