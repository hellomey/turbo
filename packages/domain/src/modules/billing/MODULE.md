# Module: `billing`

Store receipts, server notifications, entitlements, refunds, gifts, Razorpay.

| | |
|---|---|
| Build week (blueprint §43) | 3 |
| Coverage target (§44) | 90% |
| Founder approval on every change | **Yes** (money / personal data / game fairness) |

## Owns (tables, in `packages/db/prisma/schema/billing.prisma`)
- Product
- Purchase
- Entitlement
- Refund
- Gift
- RazorpayOrder

## Responsibilities
- Google Play + App Store verification and lifecycle notifications
- Razorpay webhooks with signature check
- entitlements read only from server
- refunds reverse Sparks (balance may go negative)

## May depend on (public `index.ts` only)
- `economy`
- `audit`

## Publishes domain events
- `billing.entitlement_changed`
- `billing.refunded`

## Layout
```
billing/
├─ index.ts          PUBLIC API. The only file other modules / apps may import.
├─ module.json       Boundary metadata (read by dependency-cruiser in CI). Change via an ADR.
├─ domain/           Entities, value objects, pure rules. No I/O, no framework, no Prisma.
├─ application/      Use cases. Orchestrate domain + ports. One file per use case.
└─ infrastructure/   Port adapters (Prisma repositories, Valkey, queues). Only place that touches @heymey/db.
```

## AIDLC
Unit of work: see `aidlc/inception/units.md`. Design artefacts for this module live in
`aidlc/construction/units/billing/` (domain-model.md, logical-design.md) once its first bolt starts.
