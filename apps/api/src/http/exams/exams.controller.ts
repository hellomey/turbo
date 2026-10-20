import { Body, Controller, Get, HttpCode, Inject, Param, Put, Post, Req } from "@nestjs/common";
import { EligibilityCheckBody, ExamCode, UserExamsBody } from "@heymey/contracts";
import type { ExamsApi } from "@heymey/domain/modules/exams";
import { type HmRequest, requireAuth } from "../../platform/request-context.js";
import { parse } from "../../platform/zod.js";
import { EXAMS_API } from "../../platform/tokens.js";

/** Exams, Eligibility Checker, my exams (§17.1, §19.1). Thin: parse with the contract, call one use case. */
@Controller()
export class ExamsController {
  constructor(@Inject(EXAMS_API) private readonly exams: ExamsApi) {}

  @Get("v1/exams")
  async list() {
    return { items: await this.exams.list() };
  }

  @Get("v1/exams/:code")
  get(@Param("code") code: string) {
    return this.exams.get(parse(ExamCode, code));
  }

  /** A pure computation (nothing stored), so 200, not 201. */
  @Post("v1/eligibility/check")
  @HttpCode(200)
  check(@Body() body: unknown) {
    return this.exams.checkEligibility(parse(EligibilityCheckBody, body));
  }

  @Get("v1/me/exams")
  mine(@Req() req: HmRequest) {
    return this.exams.getMyExams(requireAuth(req).userId);
  }

  @Put("v1/me/exams")
  @HttpCode(200)
  setMine(@Req() req: HmRequest, @Body() body: unknown) {
    return this.exams.setMyExams(requireAuth(req).userId, parse(UserExamsBody, body));
  }
}
