import { Controller, Get, Inject, Param } from "@nestjs/common";
import { z } from "@heymey/contracts";
import type { ContentApi } from "@heymey/domain/modules/content";
import { parse } from "../../platform/zod.js";
import { CONTENT_API } from "../../platform/tokens.js";

const TopicId = z.uuid();

/** Lessons (§10.6, §19.3). No Pro gating in Phase 1 (D-2026-10-20-13). */
@Controller()
export class ContentController {
  constructor(@Inject(CONTENT_API) private readonly content: ContentApi) {}

  @Get("v1/topics/:topicId/lesson")
  lesson(@Param("topicId") topicId: string) {
    return this.content.lesson(parse(TopicId, topicId));
  }
}
