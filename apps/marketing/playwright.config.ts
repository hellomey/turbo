// Playwright acceptance checks for the marketing site, run against a
// PRODUCTION build (next build && next start), never the dev server.
//   BASE_URL defaults to http://localhost:4570 (the canonical port). If 4570 is
//   busy with a dev server, start the production build elsewhere and set
//   BASE_URL, e.g.  npx next start -p 4590  +  BASE_URL=http://localhost:4590
// The lead-form test also needs the product app (heymey-app) on APP_URL
// (default http://localhost:4567); it is skipped if that is unreachable.
import { defineConfig } from "@playwright/test";
import os from "node:os";
import path from "node:path";

export default defineConfig({
  testDir: "./e2e",
  outputDir: path.join(os.tmpdir(), "heymey-landing-playwright"),
  timeout: 90_000,
  expect: { timeout: 10_000 },
  fullyParallel: false,
  workers: 2,
  reporter: [["list"]],
  use: {
    baseURL: process.env.BASE_URL ?? "http://localhost:4570",
    channel: "chrome",
    trace: "retain-on-failure",
  },
});
