# Logical design: U-notifications

Status: draft (BOLT-0008) · awaiting G-D · implemented by BOLT-0014 (backend) together with the U-exams extension

## Use cases
| Use case | Trigger | Ports | Idempotency | Auth |
|---|---|---|---|---|
| registerToken | `POST /v1/me/push-tokens` | TokenRepo, Clock | Idempotency-Key; upsert (user, device) | user 20/h |
| deleteToken | `DELETE /v1/me/push-tokens/{deviceId}` | TokenRepo | Idempotency-Key | owner |
| get/putSettings | `GET/PUT /v1/me/alert-settings` | PrefRepo, UsersApi (offers consent) | Idempotency-Key | user 30/h |
| enqueue(alert) | called by worker processors | PrefRepo, SendLogRepo, Clock | dedupeKey | system |
| send | worker `push.send` | Sender port (FCM/APNs or log-only), TokenRepo | job = SendLog id | system |
| morningDimming | worker `notifications.morning` `*/15 * * * *` (acts at each user's morning minute) | MasteryApi via composition | dedupe user+day | system |

Dependencies: `users`, `liveops` (declared). Exam Alert fan-out, mastery counts and Exam Hall activity are passed in by
the worker composition root (`apps/worker`), so no module dependency is added (answers the INT-002 unit-table question:
**no new dependency**).

## Contract
`src/http/notifications.ts`. Non-breaking.

## Data
`notifications.prisma`: `PushToken` (unique token, unique user+device), `AlertPreference` (defaults from config at
first read), `SendLog` (unique dedupeKey, index user+day+category). Retention: SendLog 90 days.

## Background work
`push.send` (exists), `notifications.morning` (new), `notifications.release-held` `*/15 * * * *` (new: sends held Exam Alerts after quiet hours).

## Client
Token registration after consent step 11; settings screen; FCM/APNs handled by the app shell. Offline: settings change needs a connection.

## Flags
`NOTIFICATIONS_CONFIG` (`senderMode`), liveops stub flag `notifications.paused`.

## Failure modes
| Failure | Behaviour | User sees |
|---|---|---|
| Token invalid (FCM 404) | revoke token | nothing |
| Offers on without consent | 400 CONSENT_REQUIRED | "Please tick ... to continue." |
| Sender down | retry with backoff 3x, then `failed` | nothing |

## Test plan (≥ 70 %)
Domain: invariants 1–9 (IST quiet-hours windows crossing midnight, budget at exactly 3). Integration: dedupe, token
lifecycle on logout/deletion. API: all routes.
