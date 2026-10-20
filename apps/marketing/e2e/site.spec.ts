// e2e/site.spec.ts — acceptance checks: hero fidelity, overflow, touch targets,
// console/network errors, keyboard, reduced motion, motion behaviour, redirects,
// content honesty and the real lead form.
import { test, expect, type Page } from "@playwright/test";
import { execFileSync } from "node:child_process";
import os from "node:os";
import path from "node:path";

const BASE = process.env.BASE_URL ?? "http://localhost:4570";
const APP = process.env.APP_URL ?? "http://localhost:4567";
const WIDTHS = [360, 390, 768, 1024, 1440, 1920];
const ROUTES = ["/", "/product", "/exams", "/about", "/pricing", "/creators", "/contact", "/legal/privacy", "/legal/terms", "/legal/refunds"];
const blockVideo = (page: Page) => page.route(/\.(mp4|webm)(\?|$)/, (r) => r.abort());

test.describe("hero fidelity", () => {
  test("hero differs from the pre-change baseline by < 0.1% at 1920/1440/768/390", () => {
    const out = path.join(os.tmpdir(), `hero-check-${Date.now()}`);
    execFileSync("node", ["e2e/capture-hero.mjs", BASE, out], { stdio: "pipe" });
    const result = execFileSync("node", ["e2e/diff-hero.mjs", "e2e/baseline", out, "0.1"], { encoding: "utf8" });
    console.log(result.trim());
    expect(result).not.toContain("FAIL");
  });
});

for (const width of WIDTHS) {
  test.describe(`@${width}px`, () => {
    test.use({ viewport: { width, height: width < 768 ? 844 : 900 } });

    for (const route of ROUTES) {
      test(`${route}: no horizontal overflow, no console errors, no failed requests`, async ({ page }) => {
        const problems: string[] = [];
        page.on("console", (m) => m.type() === "error" && problems.push(`console: ${m.text().slice(0, 160)}`));
        page.on("pageerror", (e) => problems.push(`exception: ${String(e).slice(0, 160)}`));
        page.on("response", (r) => {
          if (r.url().startsWith(BASE) && r.status() >= 400) problems.push(`HTTP ${r.status()} ${r.url().replace(BASE, "")}`);
        });
        page.on("requestfailed", (r) => {
          // The hero video is a third-party CDN stream; aborted range requests are normal.
          if (r.url().startsWith(BASE)) problems.push(`failed ${r.url().replace(BASE, "")} ${r.failure()?.errorText}`);
        });
        await page.goto(route, { waitUntil: "load" });
        await page.waitForTimeout(800);
        // Walk the whole page so lazy sections, pins and scrubs all run.
        const height = await page.evaluate(() => document.documentElement.scrollHeight);
        for (let y = 0; y < height; y += 700) {
          await page.evaluate((top) => window.scrollTo(0, top), y);
          await page.waitForTimeout(60);
          const over = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
          if (over > 1) {
            problems.push(`overflow ${over}px at scrollY=${y}`);
            break;
          }
        }
        expect(problems, problems.join("\n")).toEqual([]);
      });
    }

    test("navigation and footer targets are at least 44px", async ({ page }) => {
      await page.goto("/");
      const small = await page.evaluate(() =>
        Array.from(document.querySelectorAll<HTMLElement>("header a, header button, footer a, #begin a"))
          .filter((el) => el.offsetParent !== null && getComputedStyle(el).visibility !== "hidden")
          .map((el) => ({ t: (el.textContent || el.getAttribute("aria-label") || "").trim(), r: el.getBoundingClientRect() }))
          .filter(({ r }) => r.width > 0 && Math.min(r.height, r.width) < 44)
          .map(({ t, r }) => `${t} ${Math.round(r.width)}x${Math.round(r.height)}`)
      );
      expect(small, small.join("\n")).toEqual([]);
    });
  });
}

test.describe("keyboard", () => {
  test("desktop: skip link first, then the four nav links in order, and they work", async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 900 });
    await page.goto("/");
    await page.keyboard.press("Tab");
    await expect(page.locator(":focus")).toHaveText("Skip to content");
    const order: string[] = [];
    for (let i = 0; i < 8; i++) {
      await page.keyboard.press("Tab");
      order.push(((await page.locator(":focus").textContent()) ?? "").trim());
    }
    expect(order.slice(0, 7)).toEqual(["HeyMey", "Product", "Exams", "About", "Pricing", "Sign in", "Get Started →"]);
    // Focus is always visible.
    const outline = await page.locator(":focus").evaluate((el) => getComputedStyle(el).outlineStyle);
    expect(outline).not.toBe("none");
    // Activate "Exams" from the keyboard.
    await page.goto("/");
    await page.getByRole("link", { name: "Exams", exact: true }).first().focus();
    await page.keyboard.press("Enter");
    await expect(page).toHaveURL(/\/exams$/);
    await expect(page.locator('nav[aria-label="Main"] a[aria-current="page"]')).toHaveText("Exams");
  });

  test("mobile menu: opens from keyboard, traps focus, Esc closes and returns focus", async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto("/");
    const toggle = page.getByRole("button", { name: "Open menu" });
    await toggle.focus();
    await page.keyboard.press("Enter");
    const dialog = page.getByRole("dialog", { name: "Menu" });
    await expect(dialog).toBeVisible();
    const count = await dialog.locator("a[href], button").count();
    for (let i = 0; i < count + 2; i++) await page.keyboard.press("Tab");
    expect(await page.evaluate(() => !!document.activeElement?.closest('[role="dialog"]'))).toBe(true);
    await page.keyboard.press("Escape");
    await expect(dialog).toBeHidden();
    await expect(page.getByRole("button", { name: "Open menu" })).toBeFocused();
  });

  test("tabbing into the pinned landscape scrolls its panel into view", async ({ page }) => {
    await page.setViewportSize({ width: 1440, height: 900 });
    await page.goto("/");
    await page.evaluate(() => document.querySelector("#how")!.scrollIntoView());
    await page.waitForTimeout(1500);
    await expect(page.locator("#how")).toHaveAttribute("data-fx", "pinned");
    await page.evaluate(() => window.scrollTo(0, 0));
    await page.waitForTimeout(400);
    const link = page.getByRole("link", { name: /See supported exams/ });
    await link.focus();
    await page.waitForTimeout(600);
    const box = await link.boundingBox();
    expect(box).not.toBeNull();
    expect(box!.x).toBeGreaterThanOrEqual(0);
    expect(box!.x + box!.width).toBeLessThanOrEqual(1440);
    expect(box!.y).toBeGreaterThanOrEqual(0);
    expect(box!.y).toBeLessThanOrEqual(900);
  });
});

test.describe("reduced motion", () => {
  test.use({ reducedMotion: "reduce" });

  for (const width of [390, 1440]) {
    test(`@${width}: no pins, no scrubs, no WebGL, final states visible`, async ({ page }) => {
      await page.setViewportSize({ width, height: 900 });
      await blockVideo(page);
      await page.goto("/");
      await page.waitForTimeout(1500);
      const height = await page.evaluate(() => document.documentElement.scrollHeight);
      for (let y = 0; y < height; y += 900) {
        await page.evaluate((top) => window.scrollTo(0, top), y);
        await page.waitForTimeout(40);
      }
      await page.waitForTimeout(800);
      expect(await page.locator(".pin-spacer").count()).toBe(0);
      expect(await page.locator("canvas").count()).toBe(0);
      expect(await page.locator("[data-fx]").count()).toBe(0);
      expect(await page.locator(".why-word").count()).toBe(0); // SplitText never ran
      // Landscape panels are stacked vertically, not a horizontal track.
      const xs = await page.locator("[data-panel]").evaluateAll((els) => els.map((e) => Math.round(e.getBoundingClientRect().left)));
      expect(new Set(xs).size).toBeLessThanOrEqual(2);
      // Nothing left half-faded.
      const faded = await page.evaluate(() =>
        Array.from(document.querySelectorAll<HTMLElement>("main h1, main h2, main h3, main p")).filter((el) => Number(getComputedStyle(el).opacity) < 1).length
      );
      expect(faded).toBe(0);
      expect(await page.evaluate(() => document.documentElement.classList.contains("lenis"))).toBe(false);
    });
  }

  test("about: the Kural is fully visible without animation", async ({ page }) => {
    await page.goto("/about");
    await expect(page.locator("[data-kural]")).toContainText("மெய்ப்பொருள்");
    expect(await page.locator("[data-kural] [style*='opacity']").count()).toBe(0);
  });
});

test.describe("motion on (desktop)", () => {
  test.use({ viewport: { width: 1440, height: 900 }, reducedMotion: "no-preference" });

  test("landscape pins and moves right-to-left as you scroll; progress line advances", async ({ page }) => {
    await page.goto("/");
    await page.evaluate(() => document.querySelector("#how")!.scrollIntoView());
    await page.waitForTimeout(1500);
    const section = page.locator("#how");
    await expect(section).toHaveAttribute("data-fx", "pinned");
    await section.scrollIntoViewIfNeeded();
    const top = await page.evaluate(() => document.querySelector<HTMLElement>("#how .ls-viewport")!.getBoundingClientRect().top + window.scrollY);
    await page.evaluate((y) => window.scrollTo(0, y + 10), top);
    await page.waitForTimeout(700);
    const x0 = await page.locator("[data-panel]").first().evaluate((e) => e.getBoundingClientRect().left);
    await page.evaluate((y) => window.scrollTo(0, y + 1800), top);
    await page.waitForTimeout(1200);
    const x1 = await page.locator("[data-panel]").first().evaluate((e) => e.getBoundingClientRect().left);
    expect(x1).toBeLessThan(x0 - 900);
    const scale = await page.locator(".ls-progress > span").evaluate((e) => new DOMMatrix(getComputedStyle(e).transform).a);
    expect(scale).toBeGreaterThan(0.2);
  });

  test("Why: words reveal and the accent phrases turn mint", async ({ page }) => {
    await page.goto("/");
    await page.waitForTimeout(1500);
    expect(await page.locator(".why-word").count()).toBeGreaterThan(50);
    await page.locator("#why").scrollIntoViewIfNeeded();
    await page.evaluate(() => window.scrollBy(0, 900));
    await page.waitForTimeout(1200);
    const color = await page.locator("[data-accent] .why-word").first().evaluate((e) => getComputedStyle(e).color);
    expect(color).toBe("rgb(177, 240, 207)");
  });

  test("final CTA: a WebGL canvas, or the CSS star fallback, renders", async ({ page }) => {
    await page.goto("/");
    await page.locator("#begin").scrollIntoViewIfNeeded();
    await page.waitForTimeout(2500);
    const canvas = await page.locator("#begin canvas").count();
    const stars = await page.locator("#begin .css-stars").count();
    expect(canvas + stars).toBeGreaterThan(0);
    console.log(`final CTA: ${canvas ? "WebGL canvas" : "CSS fallback"}`);
  });
});

test.describe("routes, content and honesty", () => {
  const OLD = {
    "/studio": "/creators",
    "/journal": "/about",
    "/result-day": "/exams",
    "/trust": "/about",
    "/faq": "/product",
    "/begin": "/contact",
    "/institutions": "/contact",
    "/exams/tnpsc-group-4": "/exams",
  };
  for (const [from, to] of Object.entries(OLD)) {
    test(`old route ${from} permanently redirects to ${to}`, async ({ request }) => {
      const res = await request.get(from, { maxRedirects: 0 });
      expect([301, 308]).toContain(res.status());
      expect(res.headers()["location"]).toContain(to);
    });
  }

  test("all copy is in the server HTML at load; ™ only; independence line on every page", async ({ request }) => {
    const home = await (await request.get("/")).text();
    for (const s of ["Truth beneath the noise.", "almost none of them can say honestly where they", "Where you truly stand.", "Ready for every stage.", "Trust is the", "3,935"]) {
      expect(home, s).toContain(s);
    }
    const about = await (await request.get("/about")).text();
    expect(about).toContain("மெய்ப்பொருள்");
    expect(about).toContain("Thirukkural 423");
    for (const route of ROUTES) {
      const html = await (await request.get(route)).text();
      expect(html, route).toContain("HeyMey is independent and is not affiliated with TNPSC or the Government of Tamil Nadu.");
      expect(html.includes("®"), `${route} contains ®`).toBe(false);
    }
  });

  test("lead form shows the server's error and never a fake success when the app is unreachable", async ({ page }) => {
    await page.route("**/api/public/leads", (r) => r.abort("connectionrefused"));
    await page.goto("/contact");
    await page.getByLabel("Email address").fill("e2e-landing-fail@e2e.test");
    await page.getByLabel(/18 years of age/).check();
    await page.getByLabel(/I consent/).check();
    await page.getByRole("button", { name: "Request an invitation" }).click();
    await expect(page.locator("form p[role=alert]")).toContainText("couldn't reach");
    await expect(page.getByText("You're on the list.")).toHaveCount(0);
  });

  test("lead form persists a real lead in the app", async ({ page, request }) => {
    const up = await request.get(`${APP}/api/health`).then((r) => r.ok()).catch(() => false);
    test.skip(!up, `product app not reachable at ${APP}`);
    let status = 0;
    page.on("response", (r) => r.url().includes("/api/public/leads") && r.request().method() === "POST" && (status = r.status()));
    await page.goto("/contact");
    await page.getByLabel("Email address").fill(`e2e-landing-${Date.now()}@e2e.test`);
    await page.getByLabel(/18 years of age/).check();
    await page.getByLabel(/I consent/).check();
    await page.getByRole("button", { name: "Request an invitation" }).click();
    await expect(page.getByText("You're on the list.")).toBeVisible();
    expect(status).toBe(200);
  });
});
