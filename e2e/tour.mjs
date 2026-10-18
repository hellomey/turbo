// e2e/tour.mjs — visual tour: screenshots while scrolling, assembled into a contact sheet.
// Usage: node e2e/tour.mjs <url> <width> <height> <outPng> [reduced]
import { chromium } from "@playwright/test";
import sharp from "sharp";

const [url, w, h, out, reduced] = process.argv.slice(2);
const W = Number(w), H = Number(h);
const browser = await chromium.launch({ channel: "chrome" });
const context = await browser.newContext({ viewport: { width: W, height: H }, reducedMotion: reduced ? "reduce" : "no-preference" });
const page = await context.newPage();
await page.goto(url, { waitUntil: "load" });
await page.waitForTimeout(2500);
const shots = [];
const total = await page.evaluate(() => document.documentElement.scrollHeight);
for (let y = 0, i = 0; y < total && i < 40; y += Math.round(H * 0.9), i++) {
  await page.mouse.wheel(0, 0);
  await page.evaluate((top) => window.scrollTo(0, top), y);
  await page.waitForTimeout(900);
  shots.push(await page.screenshot());
}
const thumbW = Math.round(W / (W > 800 ? 4 : 2));
const thumbH = Math.round((thumbW / W) * H);
const cols = W > 800 ? 4 : 6;
const rows = Math.ceil(shots.length / cols);
const tiles = await Promise.all(shots.map((s) => sharp(s).resize(thumbW, thumbH).toBuffer()));
await sharp({ create: { width: cols * (thumbW + 6), height: rows * (thumbH + 6), channels: 3, background: "#ff00ff" } })
  .composite(tiles.map((input, i) => ({ input, left: (i % cols) * (thumbW + 6), top: Math.floor(i / cols) * (thumbH + 6) })))
  .png()
  .toFile(out);
console.log(`${shots.length} frames, page height ${total}px → ${out}`);
await browser.close();
