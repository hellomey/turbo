import { Body, Controller, Get, HttpCode, Inject, Logger, Param, Post, Req } from "@nestjs/common";
import { RedeemStickerCodeBody, SubmitExpoChallengeBody, z } from "@heymey/contracts";
import type { AuditApi } from "@heymey/domain/modules/audit";
import type { EconomyProgressionApi } from "@heymey/domain/modules/economy";
import { canRedeemStickerCodes, normalizeStickerCode, type ExpoApi } from "@heymey/domain/modules/practice";
import { DomainError } from "@heymey/domain/shared";
import { actorOf, type HmRequest, requireAuth } from "../../platform/request-context.js";
import { parse } from "../../platform/zod.js";
import { AUDIT_API, ECONOMY_API, EXPO_API } from "../../platform/tokens.js";

const Uuid = z.uuid();

/**
 * Stall (CLAUDE.md section 8, BOLT-0112): expo challenge, my sticker code, Desk redeem. Thin: auth, rate limits and
 * Idempotency-Key come from the contract entry (PlatformGuard + IdempotencyInterceptor). Redeem: Desk session + role
 * OPS, ADMIN or SUPPORT_AGENT (here) + an audit row written in the redeem transaction.
 */
@Controller()
export class ExpoController {
  private readonly log = new Logger("expo");

  constructor(
    @Inject(EXPO_API) private readonly expo: ExpoApi,
    @Inject(AUDIT_API) private readonly audit: AuditApi,
    @Inject(ECONOMY_API) private readonly economy: EconomyProgressionApi,
  ) {}

  @Get("v1/expo/challenge")
  start(@Req() req: HmRequest) {
    return this.expo.startChallenge(requireAuth(req).userId);
  }

  @Post("v1/expo/challenge/:challengeId/submit")
  @HttpCode(200)
  async submit(@Req() req: HmRequest, @Param("challengeId") challengeId: string, @Body() body: unknown) {
    const userId = requireAuth(req).userId;
    const result = await this.expo.submit(userId, parse(Uuid, challengeId), parse(SubmitExpoChallengeBody, body));
    // Idempotent trophy (economy). A failed award is logged and never fails the submit.
    await this.economy.awardTrophy(userId, "expo_challenge").catch((e: unknown) => {
      this.log.warn(`expo_challenge trophy award failed requestId=${String(req.id)} error=${e instanceof Error ? e.name : "unknown"}`);
    });
    return result;
  }

  @Get("v1/me/sticker-code")
  mine(@Req() req: HmRequest) {
    return this.expo.myStickerCode(requireAuth(req).userId);
  }

  @Post("v1/desk/sticker-codes/redeem")
  @HttpCode(200)
  redeem(@Req() req: HmRequest, @Body() body: unknown) {
    const auth = requireAuth(req);
    if (!canRedeemStickerCodes(auth.roles)) throw new DomainError("FORBIDDEN");
    const { code } = parse(RedeemStickerCodeBody, body);
    return this.expo.redeem(auth.userId, code, (tx) =>
      this.audit.recordIn(tx, {
        actor: actorOf(req),
        action: "sticker_code.redeem",
        target: `sticker_code:${normalizeStickerCode(code) ?? "invalid"}`,
      }),
    );
  }
}
