import { Global, Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import { createAuditModule } from "@heymey/domain/modules/audit";
import { AUDIT_API, PRISMA } from "../../platform/tokens.js";

/**
 * REFERENCE wiring for a module: build the module API once from shared infrastructure and provide it
 * under its token. Modules that list `audit` in module.json receive it by injecting AUDIT_API.
 * (audit has no HTTP routes; modules with routes add controllers here.)
 */
@Global()
@Module({
  providers: [{ provide: AUDIT_API, inject: [PRISMA], useFactory: (prisma: PrismaClient) => createAuditModule({ prisma }) }],
  exports: [AUDIT_API],
})
export class AuditHttpModule {}
