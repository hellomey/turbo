import { Body, Controller, Get, HttpCode, Inject, Param, Post, Query, Req } from "@nestjs/common";
import { ConfidenceDuelQuery, SubmitDuelBody, z } from "@heymey/contracts";
import type { GamesApi } from "@heymey/domain/modules/games";
import { type HmRequest, requireAuth } from "../../platform/request-context.js";
import { parse } from "../../platform/zod.js";
import { GAMES_API } from "../../platform/tokens.js";

const Uuid = z.uuid();

/**
 * Daily Spin, solo Confidence Duel, Game Rules & Odds (BOLT-0115). Thin: parse with the contract, call one use case.
 * The server draws, grades and scores with server time; auth, rate limits and Idempotency-Key come from the contract.
 */
@Controller()
export class GamesController {
  constructor(@Inject(GAMES_API) private readonly games: GamesApi) {}

  @Get("v1/games/rules")
  rules() {
    return this.games.rules();
  }

  @Get("v1/games/daily-spin")
  spinState(@Req() req: HmRequest) {
    return this.games.dailySpinState(requireAuth(req).userId);
  }

  @Post("v1/games/daily-spin")
  @HttpCode(200)
  spin(@Req() req: HmRequest) {
    return this.games.spin(requireAuth(req).userId);
  }

  @Get("v1/games/confidence-duel")
  startDuel(@Req() req: HmRequest, @Query() query: unknown) {
    return this.games.startDuel(requireAuth(req).userId, parse(ConfidenceDuelQuery, query).examCode);
  }

  @Post("v1/games/confidence-duel/:duelId/submit")
  @HttpCode(200)
  submitDuel(@Req() req: HmRequest, @Param("duelId") duelId: string, @Body() body: unknown) {
    return this.games.submitDuel(requireAuth(req).userId, parse(Uuid, duelId), parse(SubmitDuelBody, body));
  }
}
