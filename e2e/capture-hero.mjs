// e2e/capture-hero.mjs — deterministic hero screenshots for fidelity diffs.
// Usage: node e2e/capture-hero.mjs <baseURL> <outDir>
//
// Normalisation (applied identically to baseline and every later comparison):
//  - the hero video is blocked, so its poster (sky.png) is what renders;
//  - prefers-reduced-motion: reduce, scroll position 0, fonts loaded;
//  - the site header is hidden (the navbar is redesigned by design and floats
//    over the hero, so it is excluded from hero fidelity);
//  - the badge's infinite "breathing" loop is frozen at rest.
import { chromium } from "@playwright/test";
import fs from "node:fs";
import path from "node:path";

const [base = "http://localhost:4570", outDir = "e2e/baseline"] = process.argv.slice(2);
export const SIZES = [
  [1920, 1080],
  [1440, 900],
  [768, 1024],
  [390, 844],
];

fs.mkdirSync(outDir, { recursive: true });
const browser = await chromium.launch({ channel: "chrome" });
for (const [width, height] of SIZES) {
  const context = await browser.newContext({ viewport: { width, height }, reducedMotion: "reduce", deviceScaleFactor: 1 });
  const page = await context.newPage();
  await page.route(/\.(mp4|webm)(\?|$)/, (r) => r.abort());
  await page.goto(base + "/", { waitUntil: "load" });
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(3500); // entrance animations settle to their final state
  await page.addStyleTag({
    content: `header{visibility:hidden!important}
      nextjs-portal{display:none!important}
      .mey-tamil-badge{transform:none!important;translate:none!important}
      html{scroll-behavior:auto!important}
      ${process.env.EXTRA_CSS ?? ""}`,
  });
  await page.evaluate(() => window.scrollTo(0, 0));
  await page.waitForTimeout(300);
  const hero = page.locator(".hero-wrapper");
  const box = await hero.boundingBox();
  const clip = { x: 0, y: Math.max(0, box.y), width, height: Math.min(height, box.height) };
  const file = path.join(outDir, `hero-${width}x${height}.png`);
  await page.screenshot({ path: file, clip });
  console.log("wrote", file, JSON.stringify(clip));
  await context.close();
}
await browser.close();
