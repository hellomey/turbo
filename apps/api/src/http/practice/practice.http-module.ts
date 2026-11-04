import { randomInt } from "node:crypto";
import { Global, Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import { createEntitlementStub, type EntitlementReader } from "@heymey/domain/modules/billing";
import { createPracticeContent, type PracticeContentApi } from "@heymey/domain/modules/content";
import { createPracticeModule } from "@heymey/domain/modules/practice";
import type { SyllabusApi } from "@heymey/domain/modules/syllabus";
import type { Clock } from "@heymey/domain/shared";
import { CLOCK, ENTITLEMENTS, PRACTICE_API, PRACTICE_CONTENT_API, PRISMA, SYLLABUS_API } from "../../platform/tokens.js";
import { QuestionsController } from "../content/questions.controller.js";
import { PracticeController } from "./practice.controller.js";

/**
 * HTTP adapter for `practice` + the Phase 2 `content` routes (BOLT-0010, blueprint §10.6, §11, §19.4, §39). Owner: backend.
 * Composition: practice depends on content + billing (module.json). Billing is the Phase 2 stub: everyone Free.
 * CSPRNG for question picking = node:crypto. PRACTICE_API is also used by the offline sync dispatcher (mastery controller).
 */
@Global()
@Module({
  controllers: [PracticeController, QuestionsController],
  providers: [
    { provide: ENTITLEMENTS, useFactory: (): EntitlementReader => createEntitlementStub() },
    {
      provide: PRACTICE_CONTENT_API,
      inject: [PRISMA, SYLLABUS_API],
      useFactory: (prisma: PrismaClient, syllabus: SyllabusApi): PracticeContentApi =>
        createPracticeContent({ prisma, syllabus, randomInt: (max) => randomInt(max) }),
    },
    {
      provide: PRACTICE_API,
      inject: [PRISMA, CLOCK, PRACTICE_CONTENT_API, ENTITLEMENTS],
      useFactory: (prisma: PrismaClient, clock: Clock, content: PracticeContentApi, billing: EntitlementReader) =>
        createPracticeModule({ prisma, clock, content, billing }),
    },
  ],
  exports: [PRACTICE_API, PRACTICE_CONTENT_API, ENTITLEMENTS],
})
export class PracticeHttpModule {}
