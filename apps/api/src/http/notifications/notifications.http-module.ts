import { Global, Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import { createNotificationsModule } from "@heymey/domain/modules/notifications";
import type { UsersApi } from "@heymey/domain/modules/users";
import type { Clock } from "@heymey/domain/shared";
import { CLOCK, NOTIFICATIONS_API, PRISMA, USERS_API } from "../../platform/tokens.js";
import { NotificationsController } from "./notifications.controller.js";

/**
 * HTTP adapter for the `notifications` module (BOLT-0014). Owner: backend.
 * The users API fills the OffersConsentReader port (`notifications` lists `users` in module.json).
 * Sending runs in apps/worker; the API only stores tokens and settings.
 */
@Global()
@Module({
  controllers: [NotificationsController],
  providers: [
    {
      provide: NOTIFICATIONS_API,
      inject: [PRISMA, CLOCK, USERS_API],
      useFactory: (prisma: PrismaClient, clock: Clock, users: UsersApi) =>
        createNotificationsModule({
          prisma,
          clock,
          consent: {
            offersGranted: async (userId) =>
              (await users.getConsents(userId)).choices.some((c) => c.purpose === "offers_email" && c.granted),
          },
        }),
    },
  ],
  exports: [NOTIFICATIONS_API],
})
export class NotificationsHttpModule {}
