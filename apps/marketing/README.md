# HeyMey Marketing Site

Next.js 14 (App Router) landing page with GSAP, Lenis and Rive animations.

## Develop

```bash
npm install
npm run dev     # http://localhost:3000
npm run build   # production build
```

## Deploy (Vercel)

Import the repo in Vercel. It auto-detects Next.js; no extra config or env vars needed.

## Structure

- `app/` – layout, page, global styles
- `components/` – page sections
- `lib/animations.ts` – GSAP / Lenis / Rive controllers
- `public/rive/` – Rive animation files
- `public/images/`, `public/*.png|svg` – images
- `public/fonts/` – Geist (SIL OFL, free), used for text inside Rive animations
