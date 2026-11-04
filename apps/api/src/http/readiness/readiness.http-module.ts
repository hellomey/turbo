import { Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import type { ExamHallApi } from "@heymey/domain/modules/exam-hall";
import type { ExamsApi } from "@heymey/domain/modules/exams";
import { createMasteryActivity, type MasteryApi } from "@heymey/domain/modules/mastery";
import { createReadinessModule } from "@heymey/domain/modules/readiness";
import { DomainError, type Clock } from "@heymey/domain/shared";
import { CLOCK, EXAM_HALL_API, EXAMS_API, MASTERY_API, PRISMA, READINESS_API } from "../../platform/tokens.js";
import { ExamHallHttpModule } from "../exam-hall/exam-hall.http-module.js";
import { ReadinessController } from "./readiness.controller.js";

/**
 * HTTP adapter for the `readiness` module (BOLT-0013, blueprint §19.5, §11). Provides READINESS_API.
 * Composition: readiness reads mastery and exam-hall through their public APIs (module.json). The exam facts (conducting
 * body for Q27 TN-only labels, paper seconds per question for Speed) come from the exams public API here, so readiness
 * gains no new dependency. Practice (BOLT-0010) and billing (Phase 3) are not wired yet: no practice evidence, everyone free.
 */
@Module({
  imports: [ExamHallHttpModule],
  controllers: [ReadinessController],
  providers: [
    {
      provide: READINESS_API,
      inject: [PRISMA, CLOCK, MASTERY_API, EXAM_HALL_API, EXAMS_API],
      useFactory: (prisma: PrismaClient, clock: Clock, mastery: MasteryApi, examHall: ExamHallApi, exams: ExamsApi) =>
        createReadinessModule({
          prisma,
          clock,
          mastery,
          masteryActivity: createMasteryActivity({ prisma }),
          examHall,
          exams: {
            examInfo: async (code) => {
              try {
                const e = await exams.get(code);
                const { questions, durationMinutes } = e.pattern;
                return { conductingBody: e.conductingBody, paperSecondsPerQuestion: questions && durationMinutes ? (durationMinutes * 60) / questions : null };
              } catch (err) {
                if (err instanceof DomainError && err.code === "EXAM_NOT_FOUND") return null;
                throw err;
              }
            },
          },
        }),
    },
  ],
  exports: [READINESS_API],
})
export class ReadinessHttpModule {}
