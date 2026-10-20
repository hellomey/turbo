import { Controller, Get, Inject, Param, Query } from "@nestjs/common";
import { ExamCode, GlossaryQuery } from "@heymey/contracts";
import type { ContentApi } from "@heymey/domain/modules/content";
import type { ExamsApi } from "@heymey/domain/modules/exams";
import type { SyllabusApi } from "@heymey/domain/modules/syllabus";
import { parse } from "../../platform/zod.js";
import { CONTENT_API, EXAMS_API, SYLLABUS_API } from "../../platform/tokens.js";

/**
 * Study Map + glossary (§5.1, §10.2). syllabus is a leaf module, so this composition root hands it the two
 * facts it needs from other modules' PUBLIC APIs: which exams are published, which topics have a lesson.
 */
@Controller()
export class SyllabusController {
  constructor(
    @Inject(SYLLABUS_API) private readonly syllabus: SyllabusApi,
    @Inject(EXAMS_API) private readonly exams: ExamsApi,
    @Inject(CONTENT_API) private readonly content: ContentApi,
  ) {}

  @Get("v1/exams/:code/study-map")
  studyMap(@Param("code") code: string) {
    return this.syllabus.studyMap(parse(ExamCode, code), {
      publishedExamCodes: () => this.exams.publishedCodes(),
      topicsWithLesson: (ids) => this.content.topicsWithPublishedLesson(ids),
    });
  }

  @Get("v1/glossary")
  glossary(@Query() query: unknown) {
    return this.syllabus.glossary(parse(GlossaryQuery, query).q);
  }
}
