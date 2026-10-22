# Domain model: U-app-shell (+ U-design-system)

Status: draft (Phase 1, BOLT-0004) · G-D by architect pending

Packages: `dart/hm_core` (session, networking), `dart/hm_design` (tokens, widgets), `apps/mobile`, `apps/desk` (composition roots).

## Ubiquitous language
- **Session**: the signed-in state of this install: an access token (15 min) + a rotating refresh token (60 days app, 12 h Desk), §38.
- **Device id**: a random UUID created once per install and kept in secure storage; sent as `deviceId` on OTP verify.
- **Idempotency-Key**: a fresh UUID on every state-changing request (§34.3), reused only when the same request is retried.
- **Update required**: the server's `X-Min-App-Version` is higher than this app's version (§37).
- **Tabs**: Today, Study Map, Play, Squad, Profile (§10.5).
- **Lamp**: a topic on the Study Map with three rings, Lit / Steady / Gold (§5.1). Rings differ by shape and colour (§10.9).

## Aggregates and entities
| Aggregate | Entities / value objects | Owner | Storage |
|---|---|---|---|
| Session | `StoredTokens` (access, refresh, expiresAt), `SessionStatus` (unknown / signedOut / signedIn) | hm_core | flutter_secure_storage (`TokenStore`), memory copy for Desk |
| Device | `deviceId` (UUID v4) | hm_core | flutter_secure_storage |
| API error | `HmApiException(code, message, statusCode)` from the envelope `{error:{code,message}}` | hm_core | — |
| Lamp visual | `HmLampState(lit, steadyLevel 0..4, gold, dim)` | hm_design | — |

## Invariants (each is a test)
1. Every POST/PUT/PATCH carries a UUID `Idempotency-Key`, except `POST /v1/eligibility/check` (contract `idempotent: false`).
2. A 401 triggers at most ONE refresh at a time (single flight); concurrent 401s wait for it and retry once.
3. If the refresh is refused (e.g. `SESSION_REVOKED`), tokens are cleared and the session becomes signed out.
4. Every API error becomes `HmApiException` with the server's `code` and simple-English `message`; network failures get code `NETWORK_ERROR`.
5. `X-Min-App-Version` greater than the app version raises the "update required" signal.
6. A lamp's semantics label names all three rings (no colour-only meaning).
7. Tap targets of HeyMey buttons are at least 48 dp.

## State machines
```
SessionStatus: unknown --tokens found--> signedIn
               unknown --no tokens--> signedOut
               signedOut --onboarding/sign-in finished--> signedIn
               signedIn --logout / logout-all / delete / refresh refused--> signedOut
```

## Domain events
None published to the server. Client-side: `onSignedOut` callback from the HTTP layer → session controller.

## Firewall impact
None (no money, no games).

## Open questions
- Fonts (Plus Jakarta Sans, Sora) are named in the theme but not yet bundled: bundle them with licences in a later bolt (§10.4).


---

## Phase 2 extension
The offline outbox, Drift tables, pack downloader and Calm/Lite rules (domain model + invariants) are in
[logical-design.md, "Phase 2 extension"](logical-design.md). Designed in BOLT-0008, built in BOLT-0016.
