import { Global, Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import { createSyllabusModule } from "@heymey/domain/modules/syllabus";
import { PRISMA, SYLLABUS_API } from "../../platform/tokens.js";
import { SyllabusController } from "./syllabus.controller.js";

/**
 * HTTP adapter for the `syllabus` module. Owner: backend (catalog track).
 * Scope: syllabus: study map, glossary. Provides SYLLABUS_API.
 */
@Global()
@Module({
  controllers: [SyllabusController],
  providers: [{ provide: SYLLABUS_API, inject: [PRISMA], useFactory: (prisma: PrismaClient) => createSyllabusModule({ prisma }) }],
  exports: [SYLLABUS_API],
})
export class SyllabusHttpModule {}
