# Module: `auth`

Email OTP login, sessions, refresh-token rotation, device binding, Desk TOTP.

| | |
|---|---|
| Build week (blueprint §43) | 1 |
| Coverage target (§44) | 90% |
| Founder approval on every change | **Yes** (money / personal data / game fairness) |

## Owns (tables, in `packages/db/prisma/schema/auth.prisma`)
- User credential link
- OtpCode
- Session
- RefreshToken (family)
- Device
- TwoFactor

## Responsibilities
- Email OTP request/verify with rate limits
- JWT access tokens
- rotating refresh tokens with family revocation
- device binding
- Desk TOTP second factor
- account deletion grace period

## May depend on (public `index.ts` only)
- `users`
- `audit`

## Publishes domain events
- `auth.signed_in`
- `auth.session_revoked`

## Layout
```
auth/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/auth/` (domain-model.md, logical-design.md) once its first bolt starts.
