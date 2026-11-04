import { Body, Controller, Get, Inject, Param, Post, Query, Req } from "@nestjs/common";
import { ContentPackQuery, QuestionReportBody, z } from "@heymey/contracts";
import type { EntitlementReader } from "@heymey/domain/modules/billing";
import type { PracticeContentApi } from "@heymey/domain/modules/content";
import { type HmRequest, requireAuth } from "../../platform/request-context.js";
import { parse } from "../../platform/zod.js";
import { ENTITLEMENTS, PRACTICE_CONTENT_API } from "../../platform/tokens.js";

const Uuid = z.uuid();

/**
 * Phase 2 `content` routes (BOLT-0010, U-practice logical design): question reports (§19.4 Q34) and offline packs (§39).
 * Packs are locked by entitlement through API composition with billing (content does not depend on billing).
 */
@Controller()
export class QuestionsController {
  constructor(
    @Inject(PRACTICE_CONTENT_API) private readonly content: PracticeContentApi,
    @Inject(ENTITLEMENTS) private readonly billing: EntitlementReader,
  ) {}

  @Post("v1/questions/:questionId/reports")
  report(@Req() req: HmRequest, @Param("questionId") questionId: string, @Body() body: unknown) {
    const userId = requireAuth(req).userId;
    return this.content.report(userId, parse(Uuid, questionId), parse(QuestionReportBody, body));
  }

  @Get("v1/content/packs")
  async packs(@Req() req: HmRequest, @Query() query: unknown) {
    const userId = requireAuth(req).userId;
    const { examCode } = parse(ContentPackQuery, query);
    return this.content.packs(examCode, (await this.billing.entitlementOf(userId)) === "pro");
  }
}
