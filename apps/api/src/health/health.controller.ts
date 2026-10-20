import { Controller, Get, Inject, Res } from "@nestjs/common";
import type { FastifyReply } from "fastify";
import type { Redis } from "ioredis";
import type { HealthResponse } from "@heymey/contracts";
import type { PrismaClient } from "@heymey/db";
import { PRISMA, VALKEY } from "../platform/tokens.js";

const withTimeout = <T>(p: Promise<T>, ms: number) =>
  Promise.race([p, new Promise<never>((_, reject) => setTimeout(() => reject(new Error("timeout")), ms))]);

@Controller("v1/health")
export class HealthController {
  constructor(
    @Inject(PRISMA) private readonly prisma: PrismaClient,
    @Inject(VALKEY) private readonly valkey: Redis,
  ) {}

  @Get()
  async health(@Res({ passthrough: true }) reply: FastifyReply): Promise<HealthResponse> {
    const [postgres, valkey] = await Promise.allSettled([
      withTimeout(this.prisma.$queryRawUnsafe("SELECT 1"), 2000),
      withTimeout(this.valkey.ping(), 2000),
    ]);
    const checks = {
      postgres: postgres.status === "fulfilled" ? "ok" : "fail",
      valkey: valkey.status === "fulfilled" ? "ok" : "fail",
    } as const;
    const ok = Object.values(checks).every((c) => c === "ok");
    void reply.status(ok ? 200 : 503);
    return { status: ok ? "ok" : "degraded", service: "api", version: process.env.APP_VERSION ?? "dev", checks };
  }
}
