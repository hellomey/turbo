import { defineConfig } from "vitest/config";

// Unit tests only. Integration tests (*.int.spec.ts, real Postgres/Valkey) run via vitest.integration.config.ts.
export default defineConfig({
  test: {
    // Count TypeScript sources only (module.json files are not code; QA finding Q-3).
    coverage: { provider: "v8", include: ["src/**/*.ts"] },
    include: ["test/**/*.spec.ts"], exclude: ["test/**/*.int.spec.ts"] },
});
