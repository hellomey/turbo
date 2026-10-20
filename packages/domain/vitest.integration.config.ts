import { defineConfig } from "vitest/config";

// Integration tests against REAL PostgreSQL + Valkey via Testcontainers (blueprint §44). Needs Docker.
export default defineConfig({
  test: {
    // Count TypeScript sources only (module.json files are not code; QA finding Q-3).
    coverage: { provider: "v8", include: ["src/**/*.ts"] },
    include: ["test/**/*.int.spec.ts"], testTimeout: 60_000, hookTimeout: 180_000, fileParallelism: false },
});
