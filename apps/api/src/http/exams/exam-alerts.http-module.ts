import { Global, Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import { createExamAlertsModule } from "@heymey/domain/modules/exams";
import type { Clock, DomainEvent, EventPublisher } from "@heymey/domain/shared";
import type { ApiEnv } from "../../platform/env.js";
import type { JobQueue } from "../../platform/infra.module.js";
import { CLOCK, ENV, EXAM_ALERTS_API, JOB_QUEUE, PRISMA } from "../../platform/tokens.js";
import { ExamAlertsController } from "./exam-alerts.controller.js";

/**
 * Domain events from `exams` leave the API as BullMQ jobs (apps/worker/src/queues/registry.ts). The jobId makes a
 * re-publish of the same alert a no-op. The worker composition root does the fan-out, so `notifications` gains no
 * dependency on `exams` (U-notifications logical design).
 */
export function jobEventPublisher(jobs: JobQueue): EventPublisher {
  return {
    async publish(event: DomainEvent) {
      const p = event.payload as Record<string, unknown>;
      if (event.type === "exams.notification_published") {
        await jobs.add("notifications.exam-alert", event.type, p, { jobId: `exam-alert-${String(p.alertId)}` });
      } else if (event.type === "exams.date_changed") {
        await jobs.add("exams.date-changed", event.type, p);
      }
    },
  };
}

/** HTTP adapter for the Exam Alerts slice of `exams` (BOLT-0014). Owner: backend. */
@Global()
@Module({
  controllers: [ExamAlertsController],
  providers: [
    {
      provide: EXAM_ALERTS_API,
      inject: [PRISMA, CLOCK, JOB_QUEUE, ENV],
      useFactory: (prisma: PrismaClient, clock: Clock, jobs: JobQueue, env: ApiEnv) =>
        createExamAlertsModule({ prisma, clock, events: jobEventPublisher(jobs), webhookSecret: env.CHANGEDETECTION_WEBHOOK_SECRET }),
    },
  ],
  exports: [EXAM_ALERTS_API],
})
export class ExamAlertsHttpModule {}
