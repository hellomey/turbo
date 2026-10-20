<!-- BEGIN:nextjs-agent-rules -->

## This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->

## HeyMey monorepo rules (apps/marketing, port 4570)

Owner: `flutter-ui` (web) with `compliance` review on every copy change. Root `/AGENTS.md` applies.

- Package `@heymey/marketing`, run with `pnpm --filter @heymey/marketing dev` (http://localhost:4570). npm is not used in this repo.
- Read `README.md` here first: **the hero is frozen** (pixel-diff test), `overflow-x: hidden` is intentional, fonts via next/font.
- This site talks to the backend over HTTP only (dependency-cruiser forbids importing `@heymey/db|domain|ai-gateway`).
- Pending alignment with the app-only product (store links instead of web sign-in, leads → `POST /v1/public/leads`, primary domain):
  see `aidlc/inception/intents/INT-005-marketing-alignment.md`. Do not change CTAs or domains before the founder decides.
- Every number and claim must be sourced; no invented stats, testimonials or logos; ™ not ®.
