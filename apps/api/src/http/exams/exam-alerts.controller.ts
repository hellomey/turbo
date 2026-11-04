import { createHash } from "node:crypto";
import { Body, Controller, Get, HttpCode, Inject, Logger, Param, Post, Query, Req } from "@nestjs/common";
import {
  ApproveExamChangeBody,
  CursorQuery,
  ExamChangeQuery,
  RejectExamChangeBody,
  SITE_CHANGE_SECRET_HEADER,
  SiteChangeWebhookBody,
  z,
} from "@heymey/contracts";
import type { AuditApi } from "@heymey/domain/modules/audit";
import { canReviewExamChanges, type ExamAlertsApi } from "@heymey/domain/modules/exams";
import { DomainError } from "@heymey/domain/shared";
import { actorOf, type HmRequest, requireAuth } from "../../platform/request-context.js";
import { parse } from "../../platform/zod.js";
import { AUDIT_API, EXAM_ALERTS_API } from "../../platform/tokens.js";

const ChangeId = z.uuid();

/**
 * Exam Alerts (blueprint §19.1 Q7, §17.5, §20.2; INT-002-S17; D-2026-10-22-32).
 * Approve/reject: Desk session (PlatformGuard) + role OPS or ADMIN (here) + audit (here: the composition root
 * writes it inside the review transaction via a hook, `exams` does not depend on `audit`; SEC-P2-M1).
 */
@Controller()
export class ExamAlertsController {
  private readonly log = new Logger("exam-alerts");

  constructor(
    @Inject(EXAM_ALERTS_API) private readonly alerts: ExamAlertsApi,
    @Inject(AUDIT_API) private readonly audit: AuditApi,
  ) {}

  @Get("v1/me/exam-alerts")
  mine(@Req() req: HmRequest, @Query() query: unknown) {
    return this.alerts.myAlerts(requireAuth(req).userId, parse(CursorQuery, query));
  }

  /** Machine caller: no Idempotency-Key; (watchUuid, changeId) dedupe. The secret is checked BEFORE the body. */
  @Post("v1/webhooks/changedetection")
  @HttpCode(202)
  async siteChange(@Req() req: HmRequest, @Body() body: unknown) {
    const raw = req.headers[SITE_CHANGE_SECRET_HEADER];
    const secret = typeof raw === "string" ? raw : undefined;
    try {
      return await this.alerts.receiveSiteChange(secret, () => parse(SiteChangeWebhookBody, body));
    } catch (e) {
      if (e instanceof DomainError && (e.code === "WEBHOOK_UNAUTHORIZED" || e.code === "WEBHOOK_REPLAYED")) {
        // Never the secret, never the body: a hashed IP and the request id only.
        const ipHash = createHash("sha256").update(req.ip).digest("hex").slice(0, 12);
        this.log.warn(`changedetection webhook refused code=${e.code} ipHash=${ipHash} requestId=${String(req.id)}`);
      }
      throw e;
    }
  }

  @Get("v1/desk/exam-changes")
  list(@Req() req: HmRequest, @Query() query: unknown) {
    this.requireReviewer(req);
    return this.alerts.listChanges(parse(ExamChangeQuery, query));
  }

  @Post("v1/desk/exam-changes/:changeId/approve")
  @HttpCode(200)
  async approve(@Req() req: HmRequest, @Param("changeId") changeId: string, @Body() body: unknown) {
    const reviewer = this.requireReviewer(req);
    const id = parse(ChangeId, changeId);
    const input = parse(ApproveExamChangeBody, body);
    // SEC-P2-M1: the audit row is written in the approve transaction; if it fails nothing is approved or pushed.
    return this.alerts.approve(reviewer, id, input, (tx, { alertId }) =>
      this.audit.recordIn(tx, {
        actor: actorOf(req),
        action: "exam_change.approve",
        target: `exam_change:${id}`,
        after: { alertId, examCode: input.examCode, kind: input.kind, newStageDate: input.newStageDate ?? null },
      }),
    );
  }

  @Post("v1/desk/exam-changes/:changeId/reject")
  @HttpCode(200)
  async reject(@Req() req: HmRequest, @Param("changeId") changeId: string, @Body() body: unknown) {
    const reviewer = this.requireReviewer(req);
    const id = parse(ChangeId, changeId);
    const { reason } = parse(RejectExamChangeBody, body);
    return this.alerts.reject(reviewer, id, reason, (tx) =>
      this.audit.recordIn(tx, { actor: actorOf(req), action: "exam_change.reject", target: `exam_change:${id}`, after: { reason } }),
    );
  }

  /** D-2026-10-22-32: OPS or ADMIN only. Other Desk roles (REVIEWER, ...) get 403 FORBIDDEN. */
  private requireReviewer(req: HmRequest): string {
    const auth = requireAuth(req);
    if (!canReviewExamChanges(auth.roles)) throw new DomainError("FORBIDDEN");
    return auth.userId;
  }
}
