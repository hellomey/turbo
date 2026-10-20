import { Body, Controller, HttpCode, Inject, Post, Req } from "@nestjs/common";
import {
  DeleteAccountBody,
  DeskTotpEnrollBody,
  DeskTotpVerifyBody,
  OtpRequestBody,
  OtpVerifyBody,
  RefreshBody,
} from "@heymey/contracts";
import type { AuthApi } from "@heymey/domain/modules/auth";
import { actorOf, requireAuth, type HmRequest } from "../../platform/request-context.js";
import { AUTH_API } from "../../platform/tokens.js";
import { parse } from "../../platform/zod.js";

/** §38 email OTP, §37 sessions, §15 Desk second factor. Thin: contract parse -> one use case. */
@Controller("/v1/auth")
export class AuthController {
  constructor(@Inject(AUTH_API) private readonly auth: AuthApi) {}

  @Post("otp/request")
  @HttpCode(200)
  requestOtp(@Req() req: HmRequest, @Body() body: unknown) {
    const { email, purpose } = parse(OtpRequestBody, body);
    return this.auth.requestOtp({ email, purpose, callerUserId: req.auth?.userId ?? null, ip: req.ip });
  }

  @Post("otp/verify")
  @HttpCode(200)
  verifyOtp(@Body() body: unknown) {
    return this.auth.verifyOtp(parse(OtpVerifyBody, body));
  }

  @Post("refresh")
  @HttpCode(200)
  refresh(@Req() req: HmRequest, @Body() body: unknown) {
    return this.auth.refresh(parse(RefreshBody, body).refreshToken, actorOf(req));
  }

  @Post("logout")
  @HttpCode(200)
  logout(@Req() req: HmRequest) {
    return this.auth.logout(requireAuth(req));
  }

  @Post("logout-all")
  @HttpCode(200)
  logoutAll(@Req() req: HmRequest) {
    return this.auth.logoutAll(requireAuth(req).userId, actorOf(req));
  }

  @Post("desk/totp/enroll")
  @HttpCode(200)
  enrollDeskTotp(@Req() req: HmRequest, @Body() body: unknown) {
    return this.auth.enrollDeskTotp(parse(DeskTotpEnrollBody, body).challengeToken, actorOf(req));
  }

  @Post("desk/totp/verify")
  @HttpCode(200)
  verifyDeskTotp(@Req() req: HmRequest, @Body() body: unknown) {
    const { challengeToken, code } = parse(DeskTotpVerifyBody, body);
    return this.auth.verifyDeskTotp(challengeToken, code, actorOf(req));
  }

  @Post("delete-account")
  @HttpCode(200)
  deleteAccount(@Req() req: HmRequest, @Body() body: unknown) {
    return this.auth.deleteAccount(requireAuth(req).userId, parse(DeleteAccountBody, body).code, actorOf(req));
  }
}
