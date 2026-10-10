# HeyMey®

An honest, AI-assisted daily companion for Tamil Nadu's government-exam aspirants. It tells them where they truly stand, and what to do today.

---

## Overview

HeyMey® combines an editorial design aesthetic with web performance engineering. The landing experience features a panoramic cinematic video of Tamil Nadu's coastline, culturally resonant typography, and a responsive layout optimized for all device viewports.

---

## Key Features

- **Ultra-Optimized Video Background**:
  - Dual-codec progressive streaming: **WebM (VP9 + Opus)** for modern browsers and **MP4 (H.264 High + AAC)** with `+faststart` metadata placement.
  - Over 50% bandwidth reduction compared to uncompressed footage.
  - Zero Layout Shift (CLS) with eager-preloaded **WebP poster** (`poster.webp`) and smooth 1s opacity crossfade upon playback.
  - Multi-breakpoint responsive focal positioning (`object-[35%_55%]` on mobile portrait to `object-[50%_65%]` on desktop) ensuring landmarks and sunrise stay centered across any aspect ratio.
  - Layered atmospheric scrims ensuring WCAG AAA legibility for header navigation and typography.
  - Respects `prefers-reduced-motion: reduce` system accessibility preferences.
- **Dynamic Viewport Height**: Built using `min-h-[100dvh]` to eliminate mobile address-bar resize jumps on iOS Safari and Android Chrome.
- **Editorial Typography**: Styled with Instrument Serif and Inter for high-impact editorial aesthetics.
- **Clean Architecture**: Modular React components, fully typed with TypeScript, styled with Tailwind CSS, and linted with Oxlint.

---

## Tech Stack

- **Framework**: [React 19](https://react.dev/)
- **Build Tool**: [Vite 8](https://vitejs.dev/)
- **Language**: [TypeScript](https://www.typescriptlang.org/)
- **Styling**: [Tailwind CSS 3](https://tailwindcss.com/)
- **Linter**: [Oxlint](https://oxc.rs/)

---

## Project Structure

```
heymey/
├── public/
│   ├── favicon.svg          # Site favicon
│   ├── icons.svg            # UI SVG symbols
│   ├── poster.webp          # High-resolution WebP video poster
│   ├── poster.jpg           # Fallback JPEG video poster
│   ├── video.webm           # VP9/Opus web-optimized video stream
│   └── video.mp4            # H.264/AAC faststart video stream
├── src/
│   ├── components/
│   │   ├── Hero.tsx         # Hero section & CTA
│   │   ├── Navbar.tsx       # Navigation bar & mobile menu
│   │   └── VideoBackground.tsx # Responsive video layer & scrims
│   ├── styles/
│   │   ├── fonts.css        # Web font declarations
│   │   └── theme.css        # Design tokens & animation utilities
│   ├── App.tsx              # Root application layout
│   ├── index.css            # Base Tailwind imports & body rules
│   └── main.tsx             # Application entry point
├── index.html               # HTML shell with preload links & SEO metadata
├── tailwind.config.js       # Tailwind design tokens
├── tsconfig.json            # TypeScript configuration
└── package.json             # Dependencies and scripts
```

---

## Getting Started

### Prerequisites

- Node.js 18+
- npm, pnpm, or yarn

### Installation

```bash
git clone https://github.com/hellomey/heymey.git
cd heymey
npm install
```

### Development

Run the development server with Hot Module Replacement:

```bash
npm run dev
```

### Production Build

Typecheck and generate production-optimized bundle:

```bash
npm run build
```

Preview the production build locally:

```bash
npm run preview
```

### Code Quality

Run fast linting checks:

```bash
npm run lint
```

---

## License

Private repository © HeyMey. All rights reserved.
