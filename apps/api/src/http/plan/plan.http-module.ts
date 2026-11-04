import { Global, Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import type { ExamsApi } from "@heymey/domain/modules/exams";
import type { MasteryApi } from "@heymey/domain/modules/mastery";
import { createPlanModule, planPortsFrom } from "@heymey/domain/modules/plan";
import type { SyllabusApi } from "@heymey/domain/modules/syllabus";
import type { Clock } from "@heymey/domain/shared";
import { CLOCK, EXAMS_API, MASTERY_API, PLAN_API, PRISMA, SYLLABUS_API } from "../../platform/tokens.js";
import { PlanController } from "./plan.controller.js";

/**
 * HTTP adapter for the `plan` module (BOLT-0012, blueprint §10.6, §17.3, §19.2). Owner: backend.
 * Composition: plan depends on syllabus, mastery and exams (module.json) through their public APIs only.
 * PLAN_API is exported (global) so the offline sync dispatcher can route `plan_item_status` to plan.
 */
@Global()
@Module({
  controllers: [PlanController],
  providers: [
    {
      provide: PLAN_API,
      inject: [PRISMA, CLOCK, EXAMS_API, SYLLABUS_API, MASTERY_API],
      useFactory: (prisma: PrismaClient, clock: Clock, exams: ExamsApi, syllabus: SyllabusApi, mastery: MasteryApi) =>
        createPlanModule({ prisma, clock, ports: planPortsFrom({ exams, syllabus, mastery }) }),
    },
  ],
  exports: [PLAN_API],
})
export class PlanHttpModule {}
