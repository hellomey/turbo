# Domain model: U-auth

Status: draft (G-D: architect + founder, T2). Blueprint §15, §18 (OTP abuse), §23, §37, §38. Stories INT-001-S02, S06, S07.

## Ubiquitous language
- **Code (OTP)**: 6-digit number emailed to sign in (`login`) or to confirm deletion (`delete_account`).
- **Session**: one sign-in on one device = one refresh-token **family**. App: 60 days. Desk: 12 hours.
- **Access token**: EdDSA JWT, 15 minutes (`sub`, `sid`, `roles`, `desk`, `iss`, `aud=heymey-api`).
- **Refresh token**: opaque 32 bytes, stored as sha256, rotated on every use.
- **Desk challenge**: EdDSA JWT (`aud=heymey-desk-2fa`, `purpose=desk_2fa`, `sub`, `deviceId`), 5 minutes, issued after the email code for Desk.
- **Second factor (TOTP)**: authenticator secret, AES-256-GCM at rest, each 30-s step usable once.

## Aggregates and entities
| Aggregate | Entities / value objects | Owning module | Table(s) |
|---|---|---|---|
| OtpCode | email (normalised), purpose, codeHash (argon2id + pepper), attempts, expiresAt, usedAt, lockedAt | auth | OtpCode |
| Session | Session, RefreshToken (family), Device binding | auth | Session, RefreshToken, Device |
| TwoFactor | secretEnc, confirmedAt, lastUsedStep | auth | TwoFactor |
| (User, roles) | reached only through the `users` API and a role-directory port wired by the app | users / roles | — |

## Invariants (each is a unit test)
1. Email is trimmed + lower-cased before any use; disposable domains → `EMAIL_NOT_ALLOWED`.
2. Max 3 code requests per email per 10 min (`RATE_LIMITED` + retryAfterSeconds); 10 per IP per hour (contract rule, PlatformGuard).
3. The request answer is always `{resendAfterSeconds: 60}`; it never reveals whether an account exists.
4. A code expires 10 minutes after creation (at exactly +10 min it is expired); only the latest unused code counts.
5. A wrong code adds one attempt; the 5th wrong attempt locks the code (`OTP_LOCKED`); a locked code always answers `OTP_LOCKED`.
6. A code is used at most once (conditional update).
7. A device id is bound to one user; using it for another user → `VALIDATION_FAILED`.
8. A new user gets `ASPIRANT` on creation; signing in to the app cancels a pending deletion.
9. Desk sign-in requires a `DESK_ROLES` role (`DESK_NOT_ALLOWED` otherwise) plus a TOTP code; aspirants are refused (§15).
10. Refresh tokens rotate; presenting a used token revokes the whole session (`token_reuse`, audited) → `SESSION_REVOKED`.
11. Expired or revoked sessions never refresh, and their access tokens fail verification.
12. A TOTP 30-s step is accepted once (`lastUsedStep`); a confirmed enrolment cannot be re-enrolled (`FORBIDDEN`).
13. Account deletion needs a `delete_account` code for the caller's own email; grace period 7 days.
14. No email, code or token in audit payloads or logs.

## State machines
```
OtpCode:   active --correct--> used
           active --wrong (attempts < 5)--> active
           active --5th wrong--> locked
           active --now >= expiresAt--> expired
Session:   active --rotate--> active (new RefreshToken, old one usedAt)
           active --reuse | logout | logout_all | deleted--> revoked
           active --now >= expiresAt--> expired
TwoFactor: pending --first valid code--> confirmed
```

## Domain events
| Event | Published when | Payload | Consumed by |
|---|---|---|---|
| auth.session_revoked | reuse / logout-all / deletion | session or user id, reason | audit log (Phase 1) |
| auth.signed_in | (Phase 2, analytics) | userId, isNewUser | — |

## Rules that touch the money/game firewall (T2)
None. No FW tests added. (§18 "farming free Sparks": blocked disposable domains and one-user-per-device are the hooks Sparks will rely on later.)

## Open questions
- Q-A1: Should a confirmed deletion request sign the user out everywhere? Implemented: yes (sessions revoked, reason `deleted`); signing in again inside 7 days cancels the deletion.
