# Logical design: U-desk (Phase 1 part)

Status: draft (Phase 1, BOLT-0004)

## Use cases
| Use case | Route | Idempotency key | Auth |
|---|---|---|---|
| Send code | `POST /v1/auth/otp/request {email}` | fresh UUID | optional |
| Verify code | `POST /v1/auth/otp/verify {client: desk, platform: web}` → `DeskChallenge` | fresh UUID | public |
| Enrol | `POST /v1/auth/desk/totp/enroll {challengeToken}` | fresh UUID | public |
| Second factor | `POST /v1/auth/desk/totp/verify {challengeToken, code}` → session | fresh UUID | public |
| Who am I | `GET /v1/me` (roles) | — | user |
| Log out | `POST /v1/auth/logout` | fresh UUID | user |

## Contract changes
None.

## Client
`hm_desk/src/sign_in`: `DeskAuthRepository` (+ API impl), `DeskSignInController`, `DeskSignInFlow` (email, code, enrol
with `qr_flutter`, authenticator code). `hm_desk/src/home`: `DeskHome` with the role list and eight Phase 4 placeholders.
Desk tokens: `CachedTokenStore` (memory + secure storage). Laptop layout: max width 480 for sign-in, grid for home.

## Failure modes
| Failure | User sees (server message) |
|---|---|
| Aspirant | "HeyMey Desk is only for partners and staff. Please use the HeyMey app." |
| `TOTP_INVALID` | "That authenticator code is not right. Please try again." |
| `CHALLENGE_EXPIRED` | "Your sign-in took too long. Please start again." (back to email) |

## Test plan
Widget with a fake repository: aspirant refused message; not enrolled → QR + secret shown; TOTP verify → home with role.
