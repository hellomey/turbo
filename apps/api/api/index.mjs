// Vercel Function entry (Node runtime, Mumbai region). Every request is served by the same NestJS + Fastify app;
// the app is built once per warm instance and holds no per-user state (all state is in Supabase Postgres).

let ready;

/** Start-up failures answer with a short, scrubbed reason (env messages name variables, never values). */
function scrub(e) {
  return String(e?.message ?? e)
    .replace(/[a-z]+:\/\/\S+/gi, "<url>")
    .replace(/[\w.+-]+@[\w-]+\.[\w.-]+/g, "<email>")
    .slice(0, 600);
}

export default async function handler(req, res) {
  try {
    ready ??= (async () => {
      const { createApiApp } = await import("../dist/bootstrap.js");
      const app = await createApiApp({ logger: ["warn", "error"] });
      await app.init();
      const fastify = app.getHttpAdapter().getInstance();
      await fastify.ready();
      return fastify;
    })();
    const fastify = await ready;
    fastify.server.emit("request", req, res);
  } catch (e) {
    ready = undefined; // retry on the next request
    console.error("api boot failed:", scrub(e));
    res.statusCode = 503;
    res.setHeader("content-type", "application/json");
    res.end(JSON.stringify({ error: "API_BOOT_FAILED", reason: scrub(e) }));
  }
}
