# AGENTS.md: apps/desk (Flutter web, HeyMey Desk, port 4569)

Owner: `flutter-ui`. Root rules apply; also read `/dart/AGENTS.md`.

- For partners and staff only. Aspirants cannot sign in (blueprint §15). Login = email OTP + mandatory TOTP; short sessions.
- Screens come from `hm_desk` (Support, Moderation, Review, Ops, Admin, Institution, Studio, Partner), shown by role.
- Admin/Ops actions are reachable only through the protected access layer and need two-person approval for money/data actions; the server enforces this, the UI just reflects it.
- Built for laptop + keyboard: big tables, bulk upload, keyboard shortcuts. `pnpm --filter @heymey/desk dev` serves on 127.0.0.1:4569.
