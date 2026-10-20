import { Global, Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import type { AuditApi } from "@heymey/domain/modules/audit";
import { createRolesModule } from "@heymey/domain/modules/roles";
import { AUDIT_API, PRISMA, ROLES_API } from "../../platform/tokens.js";

/**
 * HTTP adapter for the `roles` module. Owner: backend (identity track).
 * No routes in Phase 1: provides ROLES_API (role lookups + grants) to users and auth.
 */
@Global()
@Module({
  providers: [
    {
      provide: ROLES_API,
      inject: [PRISMA, AUDIT_API],
      useFactory: (prisma: PrismaClient, audit: AuditApi) => createRolesModule({ prisma, audit }),
    },
  ],
  exports: [ROLES_API],
})
export class RolesHttpModule {}
