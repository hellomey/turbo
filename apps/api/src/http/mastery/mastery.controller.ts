import { Body, Controller, Get, HttpCode, Inject, Param, Post, Query, Req } from "@nestjs/common";
import { LessonCompleteBody, StartCheckBody, SubmitCheckBody, SyncBatchBody, TopicStateQuery, z } from "@heymey/contracts";
import type { MasteryApi, SyncActionResultDto } from "@heymey/domain/modules/mastery";
import { type HmRequest, requireAuth } from "../../platform/request-context.js";
import { parse } from "../../platform/zod.js";
import type { Clock } from "@heymey/domain/shared";
import type { PracticeApi } from "@heymey/domain/modules/practice";
import type { PlanApi } from "@heymey/domain/modules/plan";
import { CLOCK, MASTERY_API, PLAN_API, PRACTICE_API } from "../../platform/tokens.js";

const Uuid = z.uuid();

/**
 * Rings, checks, relight, Career Ladder, offline sync (§5.1, §5.2, §39). Thin: parse with the contract, call one use
 * case. Auth, rate limits and Idempotency-Key come from the contract entry (PlatformGuard + IdempotencyInterceptor).
 */
@Controller()
export class MasteryController {
  constructor(
    @Inject(MASTERY_API) private readonly mastery: MasteryApi,
    @Inject(CLOCK) private readonly clock: Clock,
    @Inject(PRACTICE_API) private readonly practice: PracticeApi,
    @Inject(PLAN_API) private readonly plan: PlanApi, // BOLT-0012
  ) {}

  @Get("v1/me/mastery")
  summary(@Req() req: HmRequest) {
    return this.mastery.summary(requireAuth(req).userId);
  }

  @Get("v1/me/topic-states")
  topicStates(@Req() req: HmRequest, @Query() query: unknown) {
    return this.mastery.topicStates(requireAuth(req).userId, parse(TopicStateQuery, query));
  }

  @Get("v1/me/relight-queue")
  relightQueue(@Req() req: HmRequest) {
    return this.mastery.relightQueue(requireAuth(req).userId);
  }

  @Post("v1/topics/:topicId/lesson-complete")
  @HttpCode(200)
  lessonComplete(@Req() req: HmRequest, @Param("topicId") topicId: string, @Body() body: unknown) {
    const userId = requireAuth(req).userId;
    parse(LessonCompleteBody, body);
    return this.mastery.completeLesson(userId, parse(Uuid, topicId));
  }

  @Post("v1/topics/:topicId/checks")
  startCheck(@Req() req: HmRequest, @Param("topicId") topicId: string, @Body() body: unknown) {
    const userId = requireAuth(req).userId;
    return this.mastery.startCheck(userId, parse(Uuid, topicId), parse(StartCheckBody, body).kind);
  }

  @Post("v1/checks/:checkId/submit")
  @HttpCode(200)
  submit(@Req() req: HmRequest, @Param("checkId") checkId: string, @Body() body: unknown) {
    const userId = requireAuth(req).userId;
    return this.mastery.submitCheck(userId, parse(Uuid, checkId), parse(SubmitCheckBody, body).answers);
  }

  /**
   * Offline outbox dispatcher (§39, logical design "syncStudyActions"). Actions run in order; mastery kinds go to
   * mastery; practice_answer goes to practice through PracticeApi (BOLT-0010, API composition, no module dependency).
   * plan_item_status goes to plan through PlanApi (BOLT-0012, API composition, no module dependency). Unknown kinds
   * come back `rejected` + FEATURE_PAUSED and the app keeps them in its outbox to retry.
   */
  @Post("v1/sync/study-actions")
  @HttpCode(200)
  async sync(@Req() req: HmRequest, @Body() body: unknown) {
    const userId = requireAuth(req).userId;
    const batch = parse(SyncBatchBody, body);
    const results: SyncActionResultDto[] = [];
    const touched: string[] = [];
    for (const a of batch.actions) {
      if (a.kind === "lesson_complete" || a.kind === "topic_check") {
        const r = await this.mastery.syncAction(userId, a);
        results.push(r);
        touched.push(a.topicId);
      } else if (a.kind === "practice_answer") {
        results.push(await this.practice.syncAnswer(userId, a));
      } else if (a.kind === "plan_item_status") {
        // BOLT-0012: plan owns item status (invariant 10); applied once per clientActionId via PlanApi.
        results.push(await this.plan.syncAction(userId, a));
      } else {
        // Every contract kind is routed above; a kind added to the contract later is paused until its bolt ships.
        results.push({ clientActionId: (a as { clientActionId: string }).clientActionId, status: "rejected", errorCode: "FEATURE_PAUSED" });
      }
    }
    return { results, topicStates: await this.mastery.statesOf(userId, touched), serverNow: this.clock.now().toISOString() };
  }
}
