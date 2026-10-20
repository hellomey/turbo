# INT-005: Align the marketing site with the app-only product

| | |
|---|---|
| Status | draft (blocked on D-2026-10-20-02 and D-2026-10-20-03) |
| Blueprint | §1 decision 2 (no web version for aspirants), §28, §31 step 8, §46 |
| Risk tier | T2 (public claims, legal pages, store links) |

## Why
`apps/marketing` was built for the old Next.js product: its "Sign in" / "Get started" buttons go to `app.heymey.in/login`,
and the contact form posts to the old app's `/api/public/leads`. In the new product there is no web app for aspirants;
`heymey.app` becomes the site with store links and the policy pages the stores require.

## Scope (to elaborate into stories)
- Replace web sign-in CTAs with Google Play / App Store links (pre-registration links before launch).
- Post the contact form to `POST /v1/public/leads` on the API (contract already in `@heymey/contracts`), with CORS for the marketing origins only.
- Policies at stable URLs: Privacy, Terms, Refunds, Community Guidelines, Creator/Publisher agreements, Game Rules & Odds, grievance officer (§31).
- Domain and metadata (`metadataBase`, emails like grievance@…) follow the decided primary domain.
- Keep the frozen hero and its pixel-diff test untouched (see `apps/marketing/README.md`).

## Units
U-marketing
