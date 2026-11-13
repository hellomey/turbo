#!/usr/bin/env node
// Runs `flutter test` in every workspace member that has a test/ folder. Used by `turbo run test` via dart/package.json.
import { existsSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const members = ["apps/mobile", "apps/desk", "dart/hm_design", "dart/hm_core", "dart/hm_data", "dart/hm_games", "dart/hm_features", "dart/hm_desk"];

let failed = false;
for (const m of members) {
  if (!existsSync(join(root, m, "test"))) continue;
  console.log(`\n> flutter test ${m}`);
  // nosemgrep: javascript.lang.security.audit.spawn-shell-true.spawn-shell-true -- constant args, flutter.bat needs a shell on Windows
  const r = spawnSync("flutter", ["test"], { cwd: join(root, m), stdio: "inherit", shell: process.platform === "win32" });
  if (r.status !== 0) failed = true;
}
process.exit(failed ? 1 : 0);
