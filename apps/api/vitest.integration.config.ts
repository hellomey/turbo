import swc from "unplugin-swc";
import { defineConfig } from "vitest/config";

// Integration tests run against REAL Postgres + Valkey via Testcontainers (blueprint §44).
export default defineConfig({
  plugins: [swc.vite()],
  test: { include: ["test/integration/**/*.spec.ts"], testTimeout: 60_000, hookTimeout: 120_000 },
});
