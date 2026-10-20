// `pnpm codegen` -> openapi/openapi.json. CI regenerates it and fails on any diff (blueprint §42).
import { mkdirSync, writeFileSync } from "node:fs";
import { OpenAPIRegistry, OpenApiGeneratorV31 } from "@asteasolutions/zod-to-openapi";
import { routes } from "../src/http/routes.js";

const registry = new OpenAPIRegistry();
registry.registerComponent("securitySchemes", "bearerAuth", { type: "http", scheme: "bearer", bearerFormat: "JWT" });
// HeyMey-only metadata (auth, idempotent, rateLimit) stays out of the OpenAPI document but is exported as x- extensions.
for (const { auth, idempotent, rateLimit, sensitiveResponse: _sensitive, ...route } of routes) {
  registry.registerPath({ ...route, "x-heymey-auth": auth, "x-heymey-idempotent": idempotent, ...(rateLimit ? { "x-heymey-rate-limit": rateLimit } : {}) } as typeof route);
}

const doc = new OpenApiGeneratorV31(registry.definitions).generateDocument({
  openapi: "3.1.0",
  info: { title: "HeyMey API", version: "1.0.0", description: "Generated from @heymey/contracts. Do not edit." },
  servers: [{ url: "https://api.heymey.app" }, { url: "http://localhost:4567" }],
});

mkdirSync(new URL("../openapi/", import.meta.url), { recursive: true });
writeFileSync(new URL("../openapi/openapi.json", import.meta.url), JSON.stringify(doc, null, 2) + "\n");
console.log(`openapi: ${routes.length} routes written`);
