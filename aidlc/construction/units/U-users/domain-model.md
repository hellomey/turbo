# Domain model: U-users

Status: draft (G-D, T2: personal data). Blueprint §17.1 steps 1 and 8, §23, §30, §38.7. Story INT-001-S03.

## Ubiquitous language
- **Me**: the signed-in user's settings, profile, roles and pending deletion.
- **Profile**: onboarding eligibility answers (DOB, qualification, community, PSTM, special categories).
- **Consent notice**: versioned list of purposes (`2026-10-v1`); only `core_service` is required; nothing pre-ticked.
- **Grace period**: 7 days between a deletion request and erasure; signing in cancels it.

## Aggregates and entities
| Aggregate | Entities / value objects | Owning module | Table(s) |
|---|---|---|---|
| User | settings (nickname, district, calmMode, liteMode, hideFromLeaderboards), deletionRequestedAt, deletedAt | users | User |
| Profile | ProfileAnswers | users | UserProfile |
| Consent | append-only rows (purpose, granted, noticeVersion, at) | users | Consent |

## Invariants
1. Email is unique and normalised (auth normalises before calling).
2. A profile is stored only for users aged 18+ on today's Asia/Kolkata date (`UNDER_18`, nothing stored).
3. Consent choices must name the current notice version; `core_service` must be granted (`CONSENT_REQUIRED`); one row per choice, never updated; a purpose may appear once per request.
4. Consent state = latest row per purpose.
5. Deletion: `deletionScheduledFor = requestedAt + 7 days`; a repeated request keeps the first date; signing in clears it.
6. Erasure (after the grace period): email → `deleted+<id>@invalid.heymey.app`, nickname/district null, profile + consents deleted, `deletedAt` set; audited without personal data; running twice is harmless.

## State machines
```
active --requestDeletion--> deletion_pending --sign in--> active
deletion_pending --now >= requestedAt + 7d (daily job)--> erased
```

## Domain events
| Event | Published when | Payload | Consumed by |
|---|---|---|---|
| users.deletion_requested | delete-account confirmed | userId, scheduledFor | audit |
| users.deleted | erased by the daily job | userId | audit; worker asks auth to revoke sessions |

## Rules that touch the money/game firewall (T2)
None.

## Open questions
- Q-U1: Financial-record retention on erasure arrives with billing (Phase 3); Phase 1 has no financial rows.
