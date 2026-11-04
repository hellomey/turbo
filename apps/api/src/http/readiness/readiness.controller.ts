import { Controller, Get, Inject, Param, Query, Req } from "@nestjs/common";
import { CursorQuery, ReadinessQuery, ReadinessTrendQuery, z } from "@heymey/contracts";
import type { ReadinessApi } from "@heymey/domain/modules/readiness";
import { type HmRequest, requireAuth } from "../../platform/request-context.js";
import { parse } from "../../platform/zod.js";
import { READINESS_API } from "../../platform/tokens.js";

const Uuid = z.uuid();

/**
 * Readiness Meter, trends, Sunday Reports (§19.5 Q41-Q50, §11). Read-only routes. Thin: parse with the contract, call one
 * use case. Auth and rate limits come from the contract entry (PlatformGuard). Owner checks live in the use case.
 */
@Controller()
export class ReadinessController {
  constructor(@Inject(READINESS_API) private readonly readiness: ReadinessApi) {}

  @Get("v1/me/readiness")
  meter(@Req() req: HmRequest, @Query() query: unknown) {
    const userId = requireAuth(req).userId;
    return this.readiness.meter(userId, parse(ReadinessQuery, query).examCode);
  }

  @Get("v1/me/readiness/trend")
  trend(@Req() req: HmRequest, @Query() query: unknown) {
    const userId = requireAuth(req).userId;
    const q = parse(ReadinessTrendQuery, query);
    return this.readiness.trend(userId, q.examCode, q.days);
  }

  @Get("v1/me/sunday-reports")
  list(@Req() req: HmRequest, @Query() query: unknown) {
    const userId = requireAuth(req).userId;
    return this.readiness.listReports(userId, parse(CursorQuery, query));
  }

  @Get("v1/me/sunday-reports/:reportId")
  get(@Req() req: HmRequest, @Param("reportId") reportId: string) {
    const userId = requireAuth(req).userId;
    return this.readiness.getReport(userId, parse(Uuid, reportId));
  }
}
