import { Controller, Get, Inject, Param } from "@nestjs/common";
import { ExamCode } from "@heymey/contracts";
import type { ExamCatalogueApi } from "@heymey/domain/modules/exams";
import { parse } from "../../platform/zod.js";
import { EXAM_CATALOGUE_API } from "../../platform/tokens.js";

/** GET /v1/exams/{code}/structure (ADR-0013, §1a, §22). Public. BOLT-0011. */
@Controller()
export class ExamStructureController {
  constructor(@Inject(EXAM_CATALOGUE_API) private readonly catalogue: ExamCatalogueApi) {}

  @Get("v1/exams/:code/structure")
  structure(@Param("code") code: string) {
    return this.catalogue.structure(parse(ExamCode, code));
  }
}
