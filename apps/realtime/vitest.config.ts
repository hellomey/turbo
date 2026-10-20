import swc from "unplugin-swc";
import { defineConfig } from "vitest/config";

// SWC (not esbuild) so Nest decorator metadata works in tests.
export default defineConfig({
  plugins: [swc.vite()],
  test: { include: ["test/**/*.spec.ts", "src/**/*.spec.ts"], exclude: ["test/integration/**"] },
});
