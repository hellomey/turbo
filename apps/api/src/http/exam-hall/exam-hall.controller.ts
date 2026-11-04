import { Body, Controller, Get, HttpCode, Inject, Param, Post, Put, Query, Req } from "@nestjs/common";
import { CursorQuery, MockListQuery, SaveMockAnswersBody, StartMockBody, StateMockQuery, z } from "@heymey/contracts";
import type { ExamHallApi } from "@heymey/domain/modules/exam-hall";
import { type HmRequest, requireAuth } from "../../platform/request-context.js";
import { parse } from "../../platform/zod.js";
import { EXAM_HALL_API } from "../../platform/tokens.js";

const Uuid = z.uuid();

/** Exam Hall (§9.9, §9.10, §10.6, §19.4 Q36-Q38). Thin: parse with the contract, call one use case. */
@Controller()
export class ExamHallController {
  constructor(@Inject(EXAM_HALL_API) private readonly hall: ExamHallApi) {}

  @Get("v1/mocks")
  list(@Req() req: HmRequest, @Query() query: unknown) {
    return this.hall.listMocks(requireAuth(req).userId, parse(MockListQuery, query).examCode);
  }

  @Post("v1/mocks/:mockId/attempts")
  @HttpCode(201)
  start(@Req() req: HmRequest, @Param("mockId") mockId: string, @Body() body: unknown) {
    return this.hall.start(requireAuth(req).userId, parse(Uuid, mockId), parse(StartMockBody, body).mode);
  }

  @Get("v1/mock-attempts/:attemptId")
  get(@Req() req: HmRequest, @Param("attemptId") attemptId: string) {
    return this.hall.get(requireAuth(req).userId, parse(Uuid, attemptId));
  }

  @Put("v1/mock-attempts/:attemptId/answers")
  @HttpCode(200)
  save(@Req() req: HmRequest, @Param("attemptId") attemptId: string, @Body() body: unknown) {
    return this.hall.saveAnswers(requireAuth(req).userId, parse(Uuid, attemptId), parse(SaveMockAnswersBody, body).answers);
  }

  @Post("v1/mock-attempts/:attemptId/submit")
  @HttpCode(200)
  submit(@Req() req: HmRequest, @Param("attemptId") attemptId: string) {
    return this.hall.submit(requireAuth(req).userId, parse(Uuid, attemptId));
  }

  @Get("v1/mock-attempts/:attemptId/report")
  report(@Req() req: HmRequest, @Param("attemptId") attemptId: string) {
    return this.hall.report(requireAuth(req).userId, parse(Uuid, attemptId));
  }

  @Get("v1/me/mock-attempts")
  history(@Req() req: HmRequest, @Query() query: unknown) {
    const q = parse(CursorQuery, query);
    return this.hall.history(requireAuth(req).userId, q.cursor ?? null, q.limit);
  }

  @Get("v1/state-mock-sunday")
  stateMock(@Query() query: unknown) {
    return this.hall.stateMockSunday(parse(StateMockQuery, query).examCode);
  }

  @Get("v1/mocks/:mockId/statewide-rank")
  rank(@Req() req: HmRequest, @Param("mockId") mockId: string) {
    return this.hall.statewideRank(requireAuth(req).userId, parse(Uuid, mockId));
  }
}
