import "reflect-metadata";
import { NestFactory } from "@nestjs/core";
import { FastifyAdapter, type NestFastifyApplication } from "@nestjs/platform-fastify";
import { IoAdapter } from "@nestjs/platform-socket.io";
import { PORTS, baseEnv, loadEnv } from "@heymey/config";
import { RealtimeModule } from "./realtime.module.js";

async function bootstrap(): Promise<void> {
  const env = loadEnv(baseEnv);
  const app = await NestFactory.create<NestFastifyApplication>(RealtimeModule, new FastifyAdapter({ trustProxy: true }));
  // Construction (week 3): replace with a Valkey-backed adapter (@socket.io/redis-adapter) so the
  // 2+ realtime replicas share rooms (blueprint §40).
  app.useWebSocketAdapter(new IoAdapter(app));
  app.enableShutdownHooks();

  const port = Number(process.env.PORT ?? PORTS.REALTIME);
  await app.listen(port, "0.0.0.0");
  console.log(`realtime listening on :${port} (${env.HEYMEY_ENV})`);
}

void bootstrap();
