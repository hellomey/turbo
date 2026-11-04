import { Logger, Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import { createExamHallModule } from "@heymey/domain/modules/exam-hall";
import { createExamCatalogueModule } from "@heymey/domain/modules/exams";
import type { Clock, DomainEvent } from "@heymey/domain/shared";
import { CLOCK, EXAM_CATALOGUE_API, EXAM_HALL_API, PRISMA } from "../../platform/tokens.js";
import { ExamStructureController } from "../exams/exam-structure.controller.js";
import { ExamHallController } from "./exam-hall.controller.js";

const log = new Logger("exam-hall");

/**
 * HTTP adapter for the `exam-hall` module (BOLT-0011). Provides EXAM_HALL_API.
 * Billing is not built yet: everyone is free (allowance + locked full report). No event bus yet: events are logged by id.
 */
@Module({
  controllers: [ExamHallController, ExamStructureController],
  providers: [
    { provide: EXAM_CATALOGUE_API, inject: [PRISMA], useFactory: (prisma: PrismaClient) => createExamCatalogueModule({ prisma }) },
    {
      provide: EXAM_HALL_API,
      inject: [PRISMA, CLOCK],
      useFactory: (prisma: PrismaClient, clock: Clock) =>
        createExamHallModule({
          prisma,
          clock,
          events: {
            publish: async (e: DomainEvent) => {
              const p = e.payload as { attemptId?: string; mockId?: string };
              log.log({ event: e.type, attemptId: p.attemptId, mockId: p.mockId });
            },
          },
        }),
    },
  ],
  exports: [EXAM_HALL_API, EXAM_CATALOGUE_API],
})
export class ExamHallHttpModule {}
