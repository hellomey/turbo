import { Body, Controller, Delete, Get, HttpCode, Inject, Param, Post, Put, Req } from "@nestjs/common";
import { PutAlertSettingsBody, RegisterPushTokenBody, z } from "@heymey/contracts";
import type { NotificationsApi } from "@heymey/domain/modules/notifications";
import { type HmRequest, requireAuth } from "../../platform/request-context.js";
import { parse } from "../../platform/zod.js";
import { NOTIFICATIONS_API } from "../../platform/tokens.js";

const DeviceId = z.string().min(8).max(128);

/** Push tokens + alert settings (blueprint §17.1 step 11, §19.8 Q78, §6). Thin: contract parse -> one use case. */
@Controller()
export class NotificationsController {
  constructor(@Inject(NOTIFICATIONS_API) private readonly notifications: NotificationsApi) {}

  @Post("v1/me/push-tokens")
  @HttpCode(200)
  register(@Req() req: HmRequest, @Body() body: unknown) {
    const auth = requireAuth(req);
    return this.notifications.registerToken(auth.userId, parse(RegisterPushTokenBody, body), auth.deviceId);
  }

  @Delete("v1/me/push-tokens/:deviceId")
  @HttpCode(200)
  remove(@Req() req: HmRequest, @Param("deviceId") deviceId: string) {
    return this.notifications.deleteToken(requireAuth(req).userId, parse(DeviceId, deviceId));
  }

  @Get("v1/me/alert-settings")
  get(@Req() req: HmRequest) {
    return this.notifications.getSettings(requireAuth(req).userId);
  }

  @Put("v1/me/alert-settings")
  @HttpCode(200)
  put(@Req() req: HmRequest, @Body() body: unknown) {
    return this.notifications.putSettings(requireAuth(req).userId, parse(PutAlertSettingsBody, body));
  }
}
