# Logical design: U-roles

Status: draft (G-D)

## Use cases
| Use case | Trigger | Ports | Idempotency | Authorisation |
|---|---|---|---|---|
| rolesOf | auth (sign-in, refresh), users (Me) | RoleRepository | — | server only |
| grant | auth on user creation (ASPIRANT); seed | RoleRepository, Audit | natural (active row exists → no-op) | server only (Admin Desk UI in Phase 4) |
| canUseDesk | auth Desk sign-in | RoleRepository | — | — |

No HTTP routes in Phase 1. `ROLES_API` is provided by `apps/api/src/http/roles/roles.http-module.ts`.

## Contract / data
No changes. RoleAssignment from `phase1_init`.

## Test plan
Unit: grant is idempotent and audited; Desk check; ordering. Integration: Prisma repository on real Postgres.
