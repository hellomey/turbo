# Logical design: U-app-onboarding

Status: draft (Phase 1, BOLT-0004)

## Use cases
| Use case | Route | Idempotency key | Auth |
|---|---|---|---|
| Check eligibility | `POST /v1/eligibility/check` | none (pure computation) | public |
| Study Map preview | `GET /v1/exams/{code}/study-map` | — | optional |
| Send code | `POST /v1/auth/otp/request {email, purpose: login}` | fresh UUID | optional |
| Verify code | `POST /v1/auth/otp/verify {email, code, deviceId, platform: android/ios, client: app}` | fresh UUID | public |
| Read notice | `GET /v1/consents/notice` | — | public |
| Record consent | `POST /v1/me/consents {noticeVersion, choices}` | fresh UUID | user |
| Save answers | `PUT /v1/me/profile` | fresh UUID | user |
| Save exams | `PUT /v1/me/exams {mainExamCode, otherExamCodes}` | fresh UUID | user |

## Contract changes
None.

## Client
- Layers: `domain/` (`AgeGate`, `ProfileDraft`, choice enums with plain-English labels, `EligibilityView`),
  `data/` (`OnboardingRepository` + `ApiOnboardingRepository` over `HmApi`), `application/` (`OnboardingController`
  Notifier), `presentation/` (`OnboardingFlow` + one screen per step).
- Steps 6, 9, 10, 11 of §17.1 are out of Phase 1 (D-2026-10-20-14) and are skipped.
- Share: plain text via `share_plus` ("I'm eligible for N exams on HeyMey…"). Image share card later.
- Nothing is persisted before sign-in; after sign-in only tokens + device id are on the phone.

## Failure modes
| Failure | User sees |
|---|---|
| Under 18 (local or `UNDER_18`) | "HeyMey is for 18+. See you on your 18th birthday." |
| `RATE_LIMITED` on send code | server message; resend stays locked |
| `OTP_INVALID` / `OTP_EXPIRED` / `OTP_LOCKED` | server message under the code field |
| `EMAIL_NOT_ALLOWED` | server message under the email field |
| `CONSENT_REQUIRED` | server message (UI already blocks it) |
| No network | "No internet connection. Please check and try again." + Try again |

## Test plan
Unit: `AgeGate` (IST boundary, 17y364d, 18 today, UTC-evening edge). Widget: DOB gate message; profile answers
(degree subject only for degree/PG, Check button enabled when complete, body sent); eligibility result (N, top 5,
disclaimer, link opens); OTP (paste, resend after 60 s, fake async); consent (nothing ticked, required gating, choices
sent); full flow to done with a fake repository. Goldens: eligibility result dark + light.
