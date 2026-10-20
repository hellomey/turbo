// THE CONTRACT TEST (blueprint §34.4): the API serves exactly the routes in @heymey/contracts, no more, no less.
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { FastifyAdapter, type NestFastifyApplication } from "@nestjs/platform-fastify";
import { routes } from "@heymey/contracts";
import { createApiApp } from "../src/bootstrap.js";
import { toFastifyPath } from "../src/platform/route-policy.js";
import { setTestEnv } from "./support/env.js";

let app: NestFastifyApplication;
const registered: string[] = [];

beforeAll(async () => {
  setTestEnv();
  const adapter = new FastifyAdapter();
  adapter.getInstance().addHook("onRoute", (r) => {
    for (const m of [r.method].flat()) if (m !== "HEAD" && m !== "OPTIONS") registered.push(`${m} ${r.url}`);
  });
  app = await createApiApp({ logger: false, adapter });
  await app.init();
});

afterAll(async () => {
  await app?.close();
});

describe("contract", () => {
  const contract = routes.map((r) => `${r.method.toUpperCase()} ${toFastifyPath(r.path)}`).sort();

  it("every contract route is implemented by the API", () => {
    const missing = contract.filter((r) => !registered.includes(r));
    expect(missing, "routes in @heymey/contracts without a controller").toEqual([]);
  });

  it("the API serves no route that is not in the contract", () => {
    const extra = registered.filter((r) => !contract.includes(r));
    expect(extra, "controller routes missing from @heymey/contracts").toEqual([]);
  });

  it("every state-changing route requires an Idempotency-Key, and only read-only POSTs opt out", () => {
    const writes = routes.filter((r) => r.method !== "get" && !r.idempotent).map((r) => r.path);
    expect(writes).toEqual(["/v1/eligibility/check"]);
  });
});
