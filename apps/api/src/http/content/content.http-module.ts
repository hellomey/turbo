import { Global, Module } from "@nestjs/common";
import type { PrismaClient } from "@heymey/db";
import { createContentModule } from "@heymey/domain/modules/content";
import type { SyllabusApi } from "@heymey/domain/modules/syllabus";
import { CONTENT_API, PRISMA, SYLLABUS_API } from "../../platform/tokens.js";
import { ContentController } from "./content.controller.js";

/**
 * HTTP adapter for the `content` module. Owner: backend (catalog track).
 * Scope: content: lessons. Provides CONTENT_API (content depends on syllabus, declared in module.json).
 */
@Global()
@Module({
  controllers: [ContentController],
  providers: [
    {
      provide: CONTENT_API,
      inject: [PRISMA, SYLLABUS_API],
      useFactory: (prisma: PrismaClient, syllabus: SyllabusApi) => createContentModule({ prisma, syllabus }),
    },
  ],
  exports: [CONTENT_API],
})
export class ContentHttpModule {}
