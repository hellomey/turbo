#!/usr/bin/env node
// CI guard for the permanent money/game firewall tests (blueprint §26.2 rule 3).
// Fails if: an ID in MANIFEST.json has no matching test title, a firewall test is skipped / focused,
// or the manifest itself lost IDs compared with the main branch copy (checked in CI via git).
import { readdirSync, readFileSync } from "node:fs";
import { execSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const dir = join(root, "packages/domain/test/firewall");
const manifestPath = join(dir, "MANIFEST.json");
const manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
const ids = Object.keys(manifest.tests);

const sources = readdirSync(dir)
  .filter((f) => f.endsWith(".spec.ts"))
  .map((f) => readFileSync(join(dir, f), "utf8"))
  .join("\n");

const errors = [];
for (const id of ids) {
  if (!new RegExp(`\\bit\\(\\s*["'\`]${id}\\b`).test(sources)) errors.push(`${id} has no test: "${manifest.tests[id]}"`);
}
if (/\b(it|describe|test)\.(skip|only|todo)\b|\bx(it|describe)\(/.test(sources)) errors.push("firewall tests must not be skipped, focused or todo");

// IDs may only grow. Compare with the base branch if git knows it.
try {
  const base = process.env.FIREWALL_BASE_REF ?? "origin/main";
  const old = JSON.parse(execSync(`git show ${base}:packages/domain/test/firewall/MANIFEST.json`, { stdio: ["ignore", "pipe", "ignore"], cwd: root }).toString());
  for (const id of Object.keys(old.tests)) if (!ids.includes(id)) errors.push(`${id} was removed from MANIFEST.json (never allowed)`);
} catch {
  // no base branch yet (first commit / local run without remote) - nothing to compare against
}

if (errors.length) {
  console.error("FIREWALL CHECK FAILED\n  " + errors.join("\n  "));
  process.exit(1);
}
console.log(`firewall: ${ids.length} permanent tests present`);
