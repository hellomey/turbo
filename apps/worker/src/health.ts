import { createServer } from "node:http";

/** Minimal health + readiness endpoint for Docker health checks and Uptime Kuma. Not exposed publicly. */
export function startHealthServer(service: string, port: number): void {
  createServer((req, res) => {
    if (req.url === "/health") {
      res.writeHead(200, { "content-type": "application/json" });
      res.end(JSON.stringify({ status: "ok", service, version: process.env.APP_VERSION ?? "dev", checks: {} }));
      return;
    }
    res.writeHead(404).end();
  }).listen(port, "0.0.0.0", () => console.log(`${service} health on :${port}`));
}
