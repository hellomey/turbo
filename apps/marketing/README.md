# HeyMey™ marketing site

Next.js (App Router, TypeScript, Tailwind v4). Dark theme only. Served at `heymey.in`; the product app is `app.heymey.in` (local: `heymey-app` on port 4567).

## Run

This app is `@heymey/marketing` in the HeyMey monorepo (pnpm workspace). From the repo root:

```bash
pnpm install
pnpm --filter @heymey/marketing dev      # http://localhost:4570
pnpm --filter @heymey/marketing build && pnpm --filter @heymey/marketing start   # production build, also on 4570
```

`NEXT_PUBLIC_APP_URL` sets where "Sign in", "Get Started" and the contact form go. Dev uses `.env.development` (`http://localhost:4567`). Production defaults to `https://app.heymey.in`. For a local *production* build that talks to the local app:

```bash
NEXT_PUBLIC_APP_URL=http://localhost:4567 npm run build && npm start
```

The contact form posts to the app's `POST /api/public/leads`. That endpoint only accepts browser origins in `LEAD_ALLOWED_ORIGINS` (default: `https://heymey.in`, `https://www.heymey.in`, `http://localhost:4570`).

## Pages

`/` · `/product` · `/exams` · `/about` · `/pricing` · `/creators` · `/contact` · `/legal/privacy` · `/legal/terms` · `/legal/refunds`. Old Vite-era paths (`/studio`, `/journal`, `/begin`, `/faq`, …) redirect permanently (see `next.config.ts`).

## How the motion is built (one job per library)

| Library | Used for |
|---|---|
| Motion (`motion/react-m` + `LazyMotion`) | Navbar (incl. `layoutId` indicator), hero entrance, page intros, magnetic buttons, form tabs, counters |
| GSAP + ScrollTrigger + SplitText (`@gsap/react`) | Every scroll-scrubbed / pinned effect: hero parallax, "Why" word reveal, landscape track, card stack, phone sequence, trust reveal, Kural reveal |
| Lenis | Smooth scrolling, driven by GSAP's ticker; off on touch devices and for reduced motion |
| Three.js (`@react-three/fiber`, `drei`) | Final call-to-action background only; CSS stars instead on reduced motion, Save-Data, ≤4 GB memory or no WebGL |

GSAP, Lenis and Three.js never load in the initial bundle: each section's animation code (`src/components/fx/*`) is fetched only when that section comes within about one viewport (`LazyFx`). All copy is server-rendered, so every word is in the HTML at load.

### Rules that matter when editing

- **The hero is frozen.** `src/styles/hero-legacy.css` is the original hero CSS, verbatim, in its own cascade layer. Don't edit it. `npm run test:hero` diffs the hero against `e2e/baseline/` (must stay < 0.1%; currently 0 px).
- **`html, body { overflow-x: hidden }` is intentional.** It keeps the hero's text anti-aliasing identical. Because of it, CSS `position: sticky` does not work anywhere on this site; use GSAP pins instead.
- **Fonts are next/font.** The hero relies on the families being registered as exactly `"Inter"` and `"Noto Sans Tamil"`.
- **Content honesty.** Every number comes from a cited TNPSC press release (`src/lib/site.ts`). No invented stats, testimonials or logos; use ™, never ®.

## Checks

```bash
npm run lint && npm run typecheck
BASE_URL=http://localhost:4570 npm run test:e2e   # Playwright vs a production build (Chrome)
BASE_URL=http://localhost:4570 npm run test:hero  # hero pixel diff
BASE_URL=http://localhost:4570 npm run perf:lcp   # real LCP/CLS, throttled mobile
```

The e2e suite covers widths 360/390/768/1024/1440/1920 on every route (overflow, console errors, failed requests), 44 px targets, keyboard (skip link, nav order, mobile menu trap/Esc, focus into the pinned track), reduced motion (no pins/scrubs/WebGL/Lenis, final states), motion-on behaviour, old-route redirects, copy present in server HTML, and the real lead form.

`docs/legacy-home/` keeps the pre-redesign page, CSS and globe component for reference.
