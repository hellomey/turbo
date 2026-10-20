# Logical design: U-users

Status: draft (G-D)

## Use cases
| Use case | Trigger | Ports | Idempotency | Authorisation |
|---|---|---|---|---|
| getMe | GET /v1/me | UserRepository, RolesReader | — | user |
| updateMe | PATCH /v1/me | UserRepository | header | user (own record) |
| putProfile | PUT /v1/me/profile | UserRepository, Clock (IST day) | header | user |
| consentNotice | GET /v1/consents/notice | — | — | public |
| recordConsents / getConsents | POST / GET /v1/me/consents | ConsentRepository, Clock | header | user |
| findByEmail / getById / createUser / cancelDeletion / requestDeletion | called by `auth` | UserRepository, Audit | caller's | — |
| eraseDueAccounts | `users.deletion` daily 03:00 IST | UserRepository, Audit | job idempotent (deletedAt guard) | system |

Roles for `Me` come through a structural `RolesReader` port that the composition root fills with the roles API.

## Contract changes
None (implements `packages/contracts/src/http/users.ts`).

## Data
No schema change (User, UserProfile, Consent from `phase1_init`).

## Background work
`users.deletion` (registry: owner users, `0 3 * * *` Asia/Kolkata). The worker then revokes the erased users' sessions through the auth module's session revoker.

## Client
Consent screen with separate unticked optional choices; profile saved after sign-in; deletion entry point in Settings.

## Failure modes
| Failure | Behaviour | User sees |
|---|---|---|
| Under 18 | 422 UNDER_18, nothing stored | "HeyMey is for 18+. See you on your 18th birthday." |
| Stale notice version | 400 VALIDATION_FAILED | "Some details are not right..." (app refetches the notice) |
| core_service not granted | 422 CONSENT_REQUIRED | "Please accept the required item to continue." |

## Test plan
| Level | Cases | Tool |
|---|---|---|
| Domain unit | invariants 2–6, IST boundary on the 18th birthday, leap-day DOB | Vitest + FakeClock |
| Integration | Prisma repositories, erasure | Testcontainers Postgres |
