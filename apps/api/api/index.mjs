// Vercel Function entry (Node runtime, Mumbai region). Every request is served by the same NestJS + Fastify app;
// the app is built once per warm instance and holds no per-user state (all state is in Supabase Postgres).
import { createApiApp } from "../dist/bootstrap.js";

let ready;

export default async function handler(req, res) {
  ready ??= (async () => {
    const app = await createApiApp({ logger: false });
    await app.init();
    const fastify = app.getHttpAdapter().getInstance();
    await fastify.ready();
    return fastify;
  })();
  const fastify = await ready;
  fastify.server.emit("request", req, res);
}
