# Domain model: U-desk (Phase 1 part: sign-in with TOTP)

Status: draft (Phase 1, BOLT-0004) · T2 (Desk access) · G-D by architect + founder pending

Packages: `dart/hm_desk/lib/src/sign_in`, `src/home`; `apps/desk`.

## Ubiquitous language
- **HeyMey Desk**: the web tool for partners and staff (§15). Aspirants cannot sign in.
- **Challenge**: after the email code, the server returns `kind: desk_2fa` with a 5-minute `challengeToken`.
- **Enrolment**: first Desk sign-in creates an authenticator secret, shown once as a QR code + manual secret.
- **Desk session**: short (12 h refresh), kept in memory and secure storage.

## Value objects
`DeskSignInState` (step, email, challengeToken, enrolment {otpauthUri, secret}, error), `DeskUser` (email, roles).

## Invariants (tests)
1. An aspirant gets the server's `DESK_NOT_ALLOWED` message: "HeyMey Desk is only for partners and staff. Please use the HeyMey app."
2. Not enrolled → enrol is called and the QR code + secret are shown before the authenticator code is asked.
3. A correct authenticator code leads to Desk home showing the user's role(s).
4. Every Desk area (Support, Moderation, Review, Ops, Admin, Institution, Studio, Partner) is a placeholder until Phase 4.
5. The server decides access; the UI only reflects roles.

## State machine
```
email --code sent--> code --desk_2fa, enrolled--> totp --verified--> home
code --desk_2fa, not enrolled--> enroll (QR) --continue--> totp
code --DESK_NOT_ALLOWED--> code (error shown)
totp --CHALLENGE_EXPIRED--> email (error shown)
```
