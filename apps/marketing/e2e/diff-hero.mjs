// e2e/diff-hero.mjs — pixel diff between two capture-hero.mjs runs.
// Usage: node e2e/diff-hero.mjs <dirA> <dirB> [maxPercent=0.1]
// Exit 1 if any size differs by more than maxPercent of its pixels, or if the
// sizes don't match (a layout shift is itself a fidelity failure).
import fs from "node:fs";
import path from "node:path";
import { PNG } from "pngjs";
import pixelmatch from "pixelmatch";

const [a, b, maxArg = "0.1"] = process.argv.slice(2);
const max = Number(maxArg);
let failed = false;
for (const file of fs.readdirSync(a).filter((f) => f.endsWith(".png")).sort()) {
  const A = PNG.sync.read(fs.readFileSync(path.join(a, file)));
  const pb = path.join(b, file);
  if (!fs.existsSync(pb)) { console.log(`${file}: MISSING in ${b}`); failed = true; continue; }
  const B = PNG.sync.read(fs.readFileSync(pb));
  if (A.width !== B.width || A.height !== B.height) {
    console.log(`${file}: SIZE ${A.width}x${A.height} vs ${B.width}x${B.height} — FAIL`);
    failed = true;
    continue;
  }
  const diff = new PNG({ width: A.width, height: A.height });
  const n = pixelmatch(A.data, B.data, diff.data, A.width, A.height, { threshold: 0.1 });
  const pct = (100 * n) / (A.width * A.height);
  const ok = pct <= max;
  if (!ok) { failed = true; fs.writeFileSync(path.join(b, file.replace(".png", ".diff.png")), PNG.sync.write(diff)); }
  console.log(`${file}: ${n} px differ = ${pct.toFixed(4)}% ${ok ? "PASS" : "FAIL"} (limit ${max}%)`);
}
process.exit(failed ? 1 : 0);
