import { Body, Controller, Get, HttpCode, Inject, Param, Post, Put, Query, Req } from "@nestjs/common";
import { PlanDaysQuery, PutPlanBody, UpdatePlanItemBody, z } from "@heymey/contracts";
import type { PlanApi } from "@heymey/domain/modules/plan";
import { type HmRequest, requireAuth } from "../../platform/request-context.js";
import { parse } from "../../platform/zod.js";
import { PLAN_API } from "../../platform/tokens.js";

const Uuid = z.uuid();

/**
 * My Plan + Today (§10.6 Today, §17.1 step 9, §17.3, §19.2 Q11–Q20). Thin: parse with the contract, call one use case.
 * Auth, rate limits and Idempotency-Key come from the contract entry (PlatformGuard + IdempotencyInterceptor).
 */
@Controller()
export class PlanController {
  constructor(@Inject(PLAN_API) private readonly plan: PlanApi) {}

  @Get("v1/me/today")
  today(@Req() req: HmRequest) {
    return this.plan.today(requireAuth(req).userId);
  }

  @Get("v1/me/plan")
  get(@Req() req: HmRequest) {
    return this.plan.get(requireAuth(req).userId);
  }

  @Put("v1/me/plan")
  @HttpCode(200)
  put(@Req() req: HmRequest, @Body() body: unknown) {
    const userId = requireAuth(req).userId;
    return this.plan.put(userId, parse(PutPlanBody, body));
  }

  @Get("v1/me/plan/days")
  days(@Req() req: HmRequest, @Query() query: unknown) {
    const userId = requireAuth(req).userId;
    const q = parse(PlanDaysQuery, query);
    return this.plan.days(userId, q.from, q.to);
  }

  @Post("v1/me/plan/items/:itemId/status")
  @HttpCode(200)
  updateItem(@Req() req: HmRequest, @Param("itemId") itemId: string, @Body() body: unknown) {
    const userId = requireAuth(req).userId;
    return this.plan.updateItem(userId, parse(Uuid, itemId), parse(UpdatePlanItemBody, body).status);
  }

  @Post("v1/me/plan/rebalance")
  @HttpCode(200)
  rebalance(@Req() req: HmRequest) {
    return this.plan.rebalance(requireAuth(req).userId);
  }
}
