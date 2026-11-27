# Stall day runbook

Products of PSG Products expo, CODISSIA, Coimbatore. Hall A, stall A130. Dec 9 to 13.

## Rule: no deploys during stall hours

No merges to `main`, no Vercel promotions, no migrations and no Supabase setting changes while the stall is open.
`main` pushes trigger the Android beta and web deploys, so a merge counts as a deploy. Critical fixes only, after
hours, with the normal CI and backup gates. If something breaks during the day, work around it at the stall and fix it
that evening.

## Morning checks (before doors open)

1. From a laptop on the repo: `node tools/stall/check-live.mjs`. Every row must read `ok`. It checks API health, the
   exam list, the web app (index, `sqlite3.wasm`, `drift_worker.js`, manifest), Desk, CORS from the app and Desk
   origins, and `/try`. It only reads; it creates nothing.
2. On the demo phone, over mobile data, not hall Wi-Fi: scan the flex, poster and table-tent QR codes. Each opens
   `www.heymey.app/try` with its `src` tag.
3. On the demo phone: open `app.heymey.app`, start as a guest, light a first lamp. It should take about a minute.
4. On a test Android phone: download the APK from the `/try` page and install it with the 3-step guide.
5. On the staff phone: sign in to `desk.heymey.app` with TOTP, and keep that session for the day.
6. Supabase dashboard: the production project is not paused, and database and connection use look normal.
7. Sentry: no new error spike since the previous evening. UptimeRobot: all monitors up.

## Giving out stickers

A visitor earns a sticker by lighting a first lamp in the app. The app shows a "Collect your sticker" screen with a
one-time code.

1. Ask the visitor to show the code on their own phone.
2. Enter it on the Desk sticker-code page on the staff phone.
3. Hand over a sticker only when Desk accepts the code. A used or unknown code gets no sticker; explain kindly and
   offer to help them light a lamp.
4. Never give a sticker for a screenshot, a code read aloud, or a promise to try later.

Status at the time of writing: the in-app code screen and the Desk sticker-code page are not in the repo yet (no
`sticker` route exists in the API or Desk). Until they ship, staff confirm a lit lamp on the visitor's own Study Map
before handing over a sticker. Do not invent a substitute code scheme at the stall.

## If the API is down

Signs: the app shows network errors, `check-live.mjs` fails on API rows, or UptimeRobot alerts.

1. Check status pages: Vercel (`vercel-status.com`) and Supabase (`status.supabase.com`). If either reports an
   incident, wait it out; nothing at the stall can fix it.
2. Check whether the Supabase production project paused (Free projects pause after a week idle). If it did, restore
   it from the Supabase dashboard, then re-run `check-live.mjs`.
3. Look at Vercel logs for `api.heymey.app` and at Sentry for the first error.
4. Meanwhile at the stall: keep visitors talking with the A3 poster and the table tent. Say plainly that the server
   is having a problem and that the QR code still works later. Take no names, emails or phone numbers on paper.
   Under-18 visitors go to the waitlist, as always.
5. Do not redeploy, roll back or change settings during stall hours unless the founder decides it is critical. A
   Vercel instant rollback to the previous production deployment is the only change allowed, and only on that call.
6. Write what happened in the day's stand-up: start time, cause, how long, what visitors saw.

## Evening

- Re-run `check-live.mjs`.
- Confirm last night's `pg_dump` to R2 ran.
- Count stickers given against codes accepted on Desk.
- After-hours fixes only, through the normal PR and CI path.
