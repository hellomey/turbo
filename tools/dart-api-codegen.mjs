#!/usr/bin/env node
// Regenerates the WHOLE dart/hm_api package from packages/contracts/openapi/openapi.json with openapi-generator
// (blueprint §20.1, §34.4), then patches its pubspec back into the pub workspace.
// CI runs `pnpm codegen` and fails if `git diff --exit-code dart/hm_api` is not clean. Never hand-edit hm_api.
// Uses the official openapi-generator Docker image, so no Java install is needed.
import { existsSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const spec = join(root, "packages/contracts/openapi/openapi.json");
if (!existsSync(spec)) {
  console.error("openapi.json missing - run `pnpm --filter @heymey/contracts codegen` first");
  process.exit(1);
}

// Fully regenerate: start from an empty package so renamed/removed schemas never leave stale files.
rmSync(join(root, "dart/hm_api"), { recursive: true, force: true });

const GENERATOR_IMAGE = "openapitools/openapi-generator-cli:v7.17.0";
const r = spawnSync(
  "docker",
  [
    "run", "--rm", "-v", `${root}:/local`, GENERATOR_IMAGE, "generate",
    "-i", "/local/packages/contracts/openapi/openapi.json",
    "-g", "dart",
    "-o", "/local/dart/hm_api",
    "--additional-properties=pubName=hm_api,pubDescription=GENERATED from @heymey/contracts. Never hand-edited.",
  ],
  { stdio: "inherit" },
);
if (r.status !== 0) {
  console.warn("dart codegen skipped/failed (is Docker running?). CI enforces it.");
  process.exit(process.env.CI ? 1 : 0);
}

// Drop generator scaffolding we never use (stub tests would need the `test` package).
for (const junk of ["test", "git_push.sh", ".travis.yml", ".openapi-generator-ignore"]) {
  rmSync(join(root, "dart/hm_api", junk), { recursive: true, force: true });
}

// Re-join the pub workspace.
const pubspecPath = join(root, "dart/hm_api/pubspec.yaml");
let pubspec = readFileSync(pubspecPath, "utf8");
if (!/^resolution: workspace/m.test(pubspec)) pubspec = pubspec.replace(/^(name: .*)$/m, "$1\nresolution: workspace\npublish_to: none");
pubspec = pubspec.replace(/^(\s*sdk:\s*).*$/m, "$1^3.9.0");
// Generated pins (an old `test`, unbounded `intl`) fight the Flutter SDK pins in the workspace.
pubspec = pubspec.replace(/^dev_dependencies:[\s\S]*$/m, "").replace(/intl: any/, "intl: '>=0.19.0 <1.0.0'").trimEnd() + "\n";
writeFileSync(pubspecPath, pubspec);
console.log("hm_api regenerated");
