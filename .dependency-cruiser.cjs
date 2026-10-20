// Architecture boundaries, enforced in CI (`pnpm boundaries`). See docs/architecture/module-boundaries.md.
// Per-module allowed dependencies come from packages/domain/src/modules/*/module.json ("dependsOn").
const fs = require("node:fs");
const path = require("node:path");

const MODULES_DIR = path.join(__dirname, "packages/domain/src/modules");
const MOD = "^packages/domain/src/modules";

const modules = fs
  .readdirSync(MODULES_DIR)
  .filter((m) => fs.existsSync(path.join(MODULES_DIR, m, "module.json")))
  .map((m) => JSON.parse(fs.readFileSync(path.join(MODULES_DIR, m, "module.json"), "utf8")));

const esc = (s) => s.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&");

// One rule per module: it may only import itself or the modules it declares.
const declaredDependencyRules = modules.map((m) => ({
  name: `module-${m.name}-undeclared-dependency`,
  comment: `${m.name} may only depend on: ${m.dependsOn.join(", ") || "(nothing)"}. Change module.json via an ADR.`,
  severity: "error",
  from: { path: `${MOD}/${esc(m.name)}/` },
  to: {
    path: `${MOD}/[^/]+/`,
    pathNot: [`${MOD}/${esc(m.name)}/`, ...m.dependsOn.map((d) => `${MOD}/${esc(d)}/`)],
  },
}));

/** @type {import('dependency-cruiser').IConfiguration} */
module.exports = {
  forbidden: [
    {
      name: "no-circular",
      severity: "error",
      from: {},
      to: { circular: true },
    },
    {
      name: "module-public-api-only",
      comment: "Import another module only through its index.ts (blueprint §34.8).",
      severity: "error",
      from: { path: `${MOD}/([^/]+)/` },
      to: { path: `${MOD}/[^/]+/.+`, pathNot: [`${MOD}/$1/`, `${MOD}/[^/]+/index\\.ts$`] },
    },
    ...declaredDependencyRules,
    {
      name: "games-never-touch-billing-or-sparks",
      comment: "Firewall rule 4 + 3: games never read entitlements or credit Sparks.",
      severity: "error",
      from: { path: `${MOD}/games/` },
      to: { path: [`${MOD}/billing/`, `${MOD}/marketplace/`, `${MOD}/economy/application/sparks`] },
    },
    {
      name: "domain-layer-is-pure",
      comment: "domain/ holds pure rules: no I/O, no framework, no Prisma, no other layers.",
      severity: "error",
      from: { path: `${MOD}/[^/]+/domain/` },
      to: {
        path: [
          `${MOD}/[^/]+/(application|infrastructure)/`,
          "^packages/db/",
          "node_modules/(@prisma|@nestjs|bullmq|socket\\.io|iovalkey|ioredis|fastify)",
        ],
      },
    },
    {
      name: "only-infrastructure-touches-db",
      severity: "error",
      from: { path: `${MOD}/[^/]+/(domain|application)/` },
      to: { path: ["^packages/db/", "node_modules/@prisma/"] },
    },
    {
      name: "apps-use-domain-public-api",
      severity: "error",
      from: { path: "^apps/" },
      to: { path: `${MOD}/[^/]+/(domain|application|infrastructure)/` },
    },
    {
      name: "marketing-is-isolated",
      comment: "The marketing site talks to the API over HTTP only.",
      severity: "error",
      from: { path: "^apps/marketing/" },
      to: { path: "^packages/(db|domain|ai-gateway|testing)/" },
    },
    {
      name: "ai-only-through-gateway",
      comment: "Every AI call goes through @heymey/ai-gateway (blueprint §20.4). One key, server-only.",
      severity: "error",
      from: { pathNot: "^packages/ai-gateway/" },
      to: { path: "node_modules/(openai|@openrouter)" },
    },
    {
      name: "no-test-code-in-production",
      severity: "error",
      from: { path: "^(apps|packages)/[^/]+/src/", pathNot: ["\\.(spec|test)\\.ts$", "^packages/testing/"] },
      to: { path: ["^packages/testing/", "\\.(spec|test)\\.ts$"] },
    },
  ],
  options: {
    doNotFollow: { path: "node_modules" },
    exclude: { path: ["/dist/", "/\\.next/", "/generated/", "/coverage/", "^apps/(mobile|desk)/", "^dart/"] },
    tsPreCompilationDeps: true,
    tsConfig: { fileName: "tsconfig.base.json" },
    enhancedResolveOptions: { exportsFields: ["exports"], conditionNames: ["import", "require", "node", "default", "types"] },
  },
};
