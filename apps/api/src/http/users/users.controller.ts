import { Body, Controller, Get, HttpCode, Inject, Patch, Post, Put, Req } from "@nestjs/common";
import { ConsentChoicesBody, ProfileAnswers, UpdateMeBody } from "@heymey/contracts";
import type { UsersApi } from "@heymey/domain/modules/users";
import { requireAuth, type HmRequest } from "../../platform/request-context.js";
import { USERS_API } from "../../platform/tokens.js";
import { parse } from "../../platform/zod.js";

/** §16, §17.1, §23, §30. Thin: contract parse -> one use case. */
@Controller()
export class UsersController {
  constructor(@Inject(USERS_API) private readonly users: UsersApi) {}

  @Get("/v1/me")
  getMe(@Req() req: HmRequest) {
    return this.users.getMe(requireAuth(req).userId);
  }

  @Patch("/v1/me")
  updateMe(@Req() req: HmRequest, @Body() body: unknown) {
    return this.users.updateMe(requireAuth(req).userId, parse(UpdateMeBody, body ?? {}));
  }

  @Put("/v1/me/profile")
  putProfile(@Req() req: HmRequest, @Body() body: unknown) {
    return this.users.putProfile(requireAuth(req).userId, parse(ProfileAnswers, body));
  }

  @Get("/v1/consents/notice")
  consentNotice() {
    return this.users.consentNotice();
  }

  @Get("/v1/me/consents")
  getConsents(@Req() req: HmRequest) {
    return this.users.getConsents(requireAuth(req).userId);
  }

  @Post("/v1/me/consents")
  @HttpCode(200)
  recordConsents(@Req() req: HmRequest, @Body() body: unknown) {
    return this.users.recordConsents(requireAuth(req).userId, parse(ConsentChoicesBody, body));
  }
}
