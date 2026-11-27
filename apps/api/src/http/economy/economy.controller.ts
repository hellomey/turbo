import { Body, Controller, Get, HttpCode, Inject, Post, Put, Req } from "@nestjs/common";
import { LeaderboardOptInBody } from "@heymey/contracts";
import type { EconomyProgressionApi } from "@heymey/domain/modules/economy";
import { type HmRequest, requireAuth } from "../../platform/request-context.js";
import { parse } from "../../platform/zod.js";
import { ECONOMY_API } from "../../platform/tokens.js";

/**
 * XP, Points, daily check-in, trophies, opt-in weekly leaderboard (BOLT-0113). Thin: parse with the contract, call one
 * use case. Auth, rate limits and Idempotency-Key come from the contract entry (PlatformGuard + IdempotencyInterceptor).
 */
@Controller()
export class EconomyController {
  constructor(@Inject(ECONOMY_API) private readonly economy: EconomyProgressionApi) {}

  @Get("v1/me/progress")
  progress(@Req() req: HmRequest) {
    return this.economy.progress(requireAuth(req).userId);
  }

  @Post("v1/me/check-in")
  @HttpCode(200)
  checkIn(@Req() req: HmRequest) {
    return this.economy.checkIn(requireAuth(req).userId);
  }

  @Get("v1/leaderboard/weekly")
  weekly(@Req() req: HmRequest) {
    return this.economy.weeklyLeaderboard(requireAuth(req).userId);
  }

  @Put("v1/me/leaderboard-opt-in")
  optIn(@Req() req: HmRequest, @Body() body: unknown) {
    return this.economy.setOptIn(requireAuth(req).userId, parse(LeaderboardOptInBody, body).optIn);
  }
}
