# Domain model: U-roles

Status: draft (G-D, T2: security). Blueprint §15, §16.

## Ubiquitous language
- **Role**: one of the 13 contract roles (`ROLES`). **Desk roles**: `DESK_ROLES` (staff + partners). Aspirants never are.
- **Grant**: an active RoleAssignment (`revokedAt` null).

## Aggregates and entities
| Aggregate | Entities | Owning module | Table(s) |
|---|---|---|---|
| RoleAssignment | userId, role, scopeId, grantedBy, grantedAt, revokedAt | roles | RoleAssignment |

## Invariants
1. A user holds a role at most once while active (granting again is a no-op).
2. Every new grant is audited (`role.grant`, no personal data).
3. Desk access = at least one active role in `DESK_ROLES`.
4. Roles are returned active only, in contract order.

## Domain events
| Event | When | Payload | Consumed by |
|---|---|---|---|
| roles.granted | a grant creates a row | userId, role | audit |

## Rules that touch the money/game firewall
None. Two-person approval (ApprovalRequest) arrives with the Admin Desk (Phase 4).
