import type { ApproveExamChangeBody, SiteChangeWebhookBody, z } from "@heymey/contracts";
import type { PrismaClient } from "@heymey/db";
import type { Clock } from "../../../shared/clock.js";
import type { EventPublisher } from "../../../shared/ports.js";
import type { ExamAlertDto, ExamChangeDto, ExamChangeStatus } from "../domain/exam-alerts.js";
import { PrismaExamAlertsRepository, createWebhookSecretVerifier } from "../infrastructure/prisma-exam-alerts-repository.js";
import * as uc from "./exam-alerts.js";

/** Exam Alerts slice of the exams public API (BOLT-0014). Kept apart from ExamsApi so catalogue bolts don't collide. */
export interface ExamAlertsApi {
  receiveSiteChange(secret: string | undefined, parse: () => z.infer<typeof SiteChangeWebhookBody>): Promise<{ received: boolean }>;
  listChanges(q: { status: ExamChangeStatus; cursor?: string | undefined; limit: number }): Promise<uc.Page<ExamChangeDto>>;
  approve(reviewerId: string, changeId: string, body: z.infer<typeof ApproveExamChangeBody>): Promise<ExamChangeDto>;
  reject(reviewerId: string, changeId: string, reason: string): Promise<ExamChangeDto>;
  myAlerts(userId: string, q: { cursor?: string | undefined; limit: number }): Promise<uc.Page<ExamAlertDto>>;
  /** Worker composition root: who follows an exam (UserExamChoice). */
  followersOf(examCode: string): Promise<string[]>;
}

export function createExamAlertsModule(
  deps: ({ prisma: PrismaClient } | { repository: uc.ExamAlertsRepository }) & {
    clock: Clock;
    events: EventPublisher;
    /** CHANGEDETECTION_WEBHOOK_SECRET; omit in processes that don't receive the webhook (always refuses). */
    webhookSecret?: string;
  },
): ExamAlertsApi {
  const repo = "repository" in deps ? deps.repository : new PrismaExamAlertsRepository(deps.prisma);
  const verify = deps.webhookSecret ? createWebhookSecretVerifier(deps.webhookSecret) : () => false;
  const d: uc.ExamAlertsDeps = { repo, clock: deps.clock, events: deps.events, verifySecret: verify };
  return {
    receiveSiteChange: (s, p) => uc.receiveSiteChange(d, s, p),
    listChanges: (q) => uc.listChanges(d, q),
    approve: (r, id, b) => uc.approveChange(d, r, id, b),
    reject: (r, id, reason) => uc.rejectChange(d, r, id, reason),
    myAlerts: (u, q) => uc.myExamAlerts(d, u, q),
    followersOf: (code) => repo.followersOf(code),
  };
}
