// e2e/lcp.mjs — real LCP/CLS in Chrome under throttling (mobile 390x844).
// Usage: node e2e/lcp.mjs <url> [runs=3]
// Network ≈ Lighthouse "Slow 4G" (150 ms RTT, 1.6 Mbps down, 750 Kbps up); CPU 4× slower.
import { chromium } from "@playwright/test";

const [url = "http://localhost:4570/", runsArg = "3"] = process.argv.slice(2);
const browser = await chromium.launch({ channel: "chrome" });
const results = [];
for (let run = 0; run < Number(runsArg); run++) {
  const context = await browser.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 2, isMobile: true, hasTouch: true, ignoreHTTPSErrors: true });
  const page = await context.newPage();
  const cdp = await context.newCDPSession(page);
  await cdp.send("Network.enable");
  await cdp.send("Network.setCacheDisabled", { cacheDisabled: true });
  await cdp.send("Network.emulateNetworkConditions", {
    offline: false,
    latency: 150,
    downloadThroughput: (1.6 * 1024 * 1024) / 8,
    uploadThroughput: (750 * 1024) / 8,
  });
  await cdp.send("Emulation.setCPUThrottlingRate", { rate: 4 });
  await page.addInitScript(() => {
    const w = window;
    w.__lcp = [];
    w.__cls = 0;
    new PerformanceObserver((l) => {
      for (const e of l.getEntries()) {
        const el = e.element;
        w.__lcp.push({ t: Math.round(e.startTime), size: e.size, el: el ? el.tagName.toLowerCase() + "." + String(el.className).split(" ")[0] : e.url });
      }
    }).observe({ type: "largest-contentful-paint", buffered: true });
    new PerformanceObserver((l) => {
      for (const e of l.getEntries()) if (!e.hadRecentInput) w.__cls += e.value;
    }).observe({ type: "layout-shift", buffered: true });
  });
  await page.goto(url, { waitUntil: "load", timeout: 120000 });
  await page.waitForTimeout(6000);
  const r = await page.evaluate(() => ({ lcp: window.__lcp, cls: window.__cls, proto: performance.getEntriesByType("navigation")[0].nextHopProtocol }));
  const last = r.lcp[r.lcp.length - 1];
  results.push({ proto: r.proto, lcp: last?.t, el: last?.el, cls: +r.cls.toFixed(4), entries: r.lcp.map((e) => `${e.t}ms ${e.el} (${e.size})`) });
  await context.close();
}
for (const r of results) console.log(JSON.stringify(r));
const sorted = results.map((r) => r.lcp).sort((a, b) => a - b);
console.log(`median LCP ${sorted[Math.floor(sorted.length / 2)]} ms; max CLS ${Math.max(...results.map((r) => r.cls))}`);
await browser.close();
