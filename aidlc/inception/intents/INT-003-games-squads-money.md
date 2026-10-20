# INT-003: Week 3 Games, squads, money

| | |
|---|---|
| Status | draft |
| Blueprint | §5.3, §7–§9, §11–§13, §17.4, §18, §20.4, §30, §40, §41, §43 week 3 |
| Risk tier | **T2** (money, game fairness, third-party AI) |

## Why
"Purchases work end to end in the store sandboxes, and games run server-authoritatively with the firewall tests passing" (§43 week 3).

## Scope (to elaborate into stories)
- `economy`: ledgers (append-only, idempotent), check-in track that never resets, cosmetics, Season Pass (cosmetic only), spending limits, earned-Sparks cap
- `games`: Daily Spin / Lucky Slot (CSPRNG, versioned odds shown in app), Confidence Duel (10 ranked/day for all), Clue Poker rooms, games sleep 12–5 AM IST, playtime reminders
- `squads`: squads + roles, chat with filters, Help Requests, Squad Battles, Squad Goal
- `billing`: Google Play + App Store verification and lifecycle notifications, Razorpay webhooks, entitlements, refunds (negative Sparks), gifts, restore purchases
- `ai`: gateway routes with fallbacks, budgets, doubt help limits
- App: check-in, spin, slot, duel, clue poker, squad screens + battles, Store, purchase flows, paywalls with the Dark Patterns checklist, AI doubt help

## Firewall
Every story in this intent lists the FW tests it relies on. New money or game paths must add FW-010+ tests. `compliance` reviews every offer/paywall string.

## Units
U-economy, U-games, U-squads, U-billing, U-ai, U-app-games, U-app-squad, U-app-store
