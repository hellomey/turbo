import { Body, Controller, Get, HttpCode, Inject, Param, Post, Query, Req } from "@nestjs/common";
import { CursorQuery, PracticeAnswerBody, PyqFacetQuery, PyqQuery, StartPracticeBody, z } from "@heymey/contracts";
import type { PracticeApi } from "@heymey/domain/modules/practice";
import { type HmRequest, requireAuth } from "../../platform/request-context.js";
import { parse } from "../../platform/zod.js";
import { PRACTICE_API } from "../../platform/tokens.js";

const Uuid = z.uuid();

/**
 * Practice, free daily limit, mistakes, drills, PYQ Vault (blueprint §10.6, §11, §13, §19.4, §19.6 Q60). Thin: parse with
 * the contract, call one use case. Auth, rate limits and Idempotency-Key come from the contract entry
 * (PlatformGuard + IdempotencyInterceptor).
 */
@Controller()
export class PracticeController {
  constructor(@Inject(PRACTICE_API) private readonly practice: PracticeApi) {}

  @Post("v1/practice/sessions")
  start(@Req() req: HmRequest, @Body() body: unknown) {
    const userId = requireAuth(req).userId;
    return this.practice.startSession(userId, parse(StartPracticeBody, body));
  }

  @Post("v1/practice/sessions/:sessionId/answers")
  @HttpCode(200)
  answer(@Req() req: HmRequest, @Param("sessionId") sessionId: string, @Body() body: unknown) {
    const userId = requireAuth(req).userId;
    return this.practice.answer(userId, parse(Uuid, sessionId), parse(PracticeAnswerBody, body));
  }

  @Get("v1/me/practice/usage")
  usage(@Req() req: HmRequest) {
    return this.practice.usage(requireAuth(req).userId);
  }

  @Get("v1/me/mistakes")
  mistakes(@Req() req: HmRequest, @Query() query: unknown) {
    return this.practice.mistakes(requireAuth(req).userId, parse(CursorQuery, query));
  }

  @Get("v1/me/drills")
  drills(@Req() req: HmRequest) {
    return this.practice.drills(requireAuth(req).userId);
  }

  @Get("v1/pyq")
  pyq(@Req() req: HmRequest, @Query() query: unknown) {
    return this.practice.searchPyqs(requireAuth(req).userId, parse(PyqQuery, query));
  }

  @Get("v1/pyq/facets")
  facets(@Req() req: HmRequest, @Query() query: unknown) {
    return this.practice.pyqFacets(requireAuth(req).userId, parse(PyqFacetQuery, query).examCode);
  }
}
