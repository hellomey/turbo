import { Global, Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import type { AuditApi } from "@heymey/domain/modules/audit";
import type { RolesApi } from "@heymey/domain/modules/roles";
import type { Clock } from "@heymey/domain/shared";
import { createUsersModule } from "@heymey/domain/modules/users";
import { AUDIT_API, CLOCK, PRISMA, ROLES_API, USERS_API } from "../../platform/tokens.js";
import { UsersController } from "./users.controller.js";

/**
 * HTTP adapter for the `users` module. Owner: backend (identity track).
 * Scope: GET/PATCH /v1/me, PUT /v1/me/profile, consents. Provides USERS_API (used by auth).
 * The roles API fills the users module's RolesReader port (users does not import roles).
 */
@Global()
@Module({
  controllers: [UsersController],
  providers: [
    {
      provide: USERS_API,
      inject: [PRISMA, AUDIT_API, CLOCK, ROLES_API],
      useFactory: (prisma: PrismaClient, audit: AuditApi, clock: Clock, roles: RolesApi) =>
        createUsersModule({ prisma, audit, clock, roles }),
    },
  ],
  exports: [USERS_API],
})
export class UsersHttpModule {}
