import "reflect-metadata";
import { randomUUID } from "node:crypto";
import { NestFactory } from "@nestjs/core";
import { FastifyAdapter, type NestFastifyApplication } from "@nestjs/platform-fastify";
import { IDEMPOTENCY_HEADER, MIN_APP_VERSION_HEADER } from "@heymey/contracts";
import { AppModule } from "./app.module.js";
import type { ApiEnv } from "./platform/env.js";
import { ENV } from "./platform/tokens.js";

/** proxy-addr trust function: trust exactly the nearest `hops` proxies (hop index 0 = the direct peer). */
export function trustHops(hops: number): (address: string, hop: number) => boolean {
  return (_address, hop) => hop < hops;
}

/** Builds the API application (used by main.ts and by tests). Does not listen. */
export async function createApiApp(options: { logger?: false; adapter?: FastifyAdapter } = {}): Promise<NestFastifyApplication> {
  const adapter =
    options.adapter ??
    new FastifyAdapter({
      // Client IPs drive rate limits, so trust ONLY the configured proxy hops (SEC-H1). In production Caddy is
      // the single hop and overwrites X-Forwarded-For with the Cloudflare-verified client IP. 0 = trust nothing.
      trustProxy: trustHops(Number(process.env.TRUST_PROXY_HOPS ?? 0)),
      bodyLimit: 256 * 1024,
      genReqId: () => randomUUID(),
    });
  const app = await NestFactory.create<NestFastifyApplication>(AppModule, adapter, {
    logger: options.logger ?? ["log", "warn", "error"],
  });
  const env = app.get<ApiEnv>(ENV);
  // On EVERY response, including ones rejected by guards (401/403/429) and 404s (§37, QA Q-2): an outdated
  // signed-out app must still learn it needs an update. A Fastify hook runs before any Nest guard.
  app
    .getHttpAdapter()
    .getInstance()
    .addHook("onRequest", (req, reply, done) => {
      void reply.header(MIN_APP_VERSION_HEADER, env.MIN_APP_VERSION).header("X-Request-Id", String(req.id));
      done();
    });
  app.enableCors({
    origin: env.CORS_ORIGINS,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
    allowedHeaders: ["Authorization", "Content-Type", IDEMPOTENCY_HEADER],
    exposedHeaders: ["X-Min-App-Version", "X-Request-Id", "Retry-After", "Idempotent-Replayed"],
    maxAge: 600,
  });
  app.enableShutdownHooks();
  return app;
}
