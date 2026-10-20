import { Global, Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import { createExamsModule } from "@heymey/domain/modules/exams";
import type { Clock } from "@heymey/domain/shared";
import { CLOCK, EXAMS_API, PRISMA } from "../../platform/tokens.js";
import { ExamsController } from "./exams.controller.js";

/**
 * HTTP adapter for the `exams` module. Owner: backend (catalog track).
 * Scope: exams: list, detail, eligibility check, my exams. Provides EXAMS_API.
 */
@Global()
@Module({
  controllers: [ExamsController],
  providers: [
    {
      provide: EXAMS_API,
      inject: [PRISMA, CLOCK],
      useFactory: (prisma: PrismaClient, clock: Clock) => createExamsModule({ prisma, clock }),
    },
  ],
  exports: [EXAMS_API],
})
export class ExamsHttpModule {}
