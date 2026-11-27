import { randomInt } from "node:crypto";
import { Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import { createQuestionSetReader } from "@heymey/domain/modules/content";
import { createLampCheck } from "@heymey/domain/modules/mastery";
import { createExpoModule } from "@heymey/domain/modules/practice";
import type { Clock } from "@heymey/domain/shared";
import { CLOCK, EXPO_API, PRISMA } from "../../platform/tokens.js";
import { ExpoController } from "./expo.controller.js";

/**
 * HTTP adapter for the stall slice of `practice` (BOLT-0112). Composition: practice depends on content (question set)
 * and mastery (first lamp check), both read-only. CSPRNG for question picking and sticker codes = node:crypto.
 */
@Module({
  controllers: [ExpoController],
  providers: [
    {
      provide: EXPO_API,
      inject: [PRISMA, CLOCK],
      useFactory: (prisma: PrismaClient, clock: Clock) =>
        createExpoModule({
          prisma,
          clock,
          randomInt: (max) => randomInt(max),
          questions: createQuestionSetReader({ prisma }),
          lamps: createLampCheck({ prisma }),
        }),
    },
  ],
})
export class ExpoHttpModule {}
