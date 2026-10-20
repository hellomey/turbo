# Logical design: U-app-shell (+ U-design-system)

Status: draft (Phase 1, BOLT-0004)

## Use cases (client)
| Use case | Trigger | Ports | Idempotency key | Auth |
|---|---|---|---|---|
| Start-up | app launch | `TokenStore.read` | — | — |
| Call any route | feature repository | `HmApi` → generated `hm_api` `ApiClient` over `HmHttpClient` | fresh UUID per write (not eligibility check) | Bearer when tokens exist |
| Silent refresh | 401 from any call | `POST /v1/auth/refresh` | fresh UUID | refresh token |
| Sign out | refresh refused / logout | `TokenStore.clear` | — | — |

## Contract changes
None. Uses BOLT-0001 routes as generated.

### Generated-client gaps (wrapped, not edited; follow-up for architect)
**Blocker found in BOLT-0004:** `dart/hm_api` does not compile today. `model/ok_response.dart` (`ok: z.literal(true)`
→ a bool enum built from the string `'true'`) and `model/health_response.dart` (`checks` record of an enum → `Map<String,String>`
passed where `Map<String, HealthResponseChecksEnum>` is expected) give 3 compile errors. `hm_api` is one library
(`part of`), so ANY import breaks the build. Until the contract or codegen is fixed, `HmApi` calls the routes from
`routes.ts` directly over `HmHttpClient` and returns small typed results / JSON that feature repositories map to their
domain models. Callers do not change when the transport switches back to `ApiClient(..)..client = HmHttpClient(..)`.
Suggested fix: `OkResponse.ok` → `z.boolean()` (or post-process literals) and `HealthResponse.checks` →
`z.record(z.string(), z.string())`, then `pnpm codegen`.

Further `openapi-generator dart` gaps that the swap-back must keep working around:
1. `OtpVerifyResponse` (oneOf on `kind`) is generated as one class with every field required: decoding a `session`
   answer would crash. `HmApi.verifyOtp` reads the raw response and decodes `SessionGranted` or `DeskChallenge` by `kind`.
2. Nullable object fields are decoded with `!` (`Me.profile`, `UserExams.main`): a new user would crash. `HmApi.getMe`
   and `getMyExams` decode those responses themselves.
3. Request models write `null` for unset optional fields (`purpose`, `client`, `degreeSubject`, `UpdateMeBody.*`) and
   the server's Zod `.optional()` rejects `null`; `dateOfBirth` is formatted after `toUtc()`, which moves an IST date
   one day back. `HmApi` builds those bodies itself and sends them through `ApiClient.invokeAPI`.
Fix proposal: generator option / schema post-processing in `tools/dart-api-codegen.mjs` (devops/architect).

## Client (Flutter)
- `hm_core`: `ApiConfig` (`--dart-define=API_BASE_URL`; default `http://10.0.2.2:4567` on the Android emulator,
  `http://localhost:4567` elsewhere; production builds pass `https://api.heymey.app`), `HmHttpClient` (auth header,
  Idempotency-Key, refresh single-flight, min-version), `HmApi` (typed calls, error envelope), `TokenStore`
  (`SecureTokenStore`, `MemoryTokenStore`, `CachedTokenStore` for Desk), `DeviceIdStore`, Riverpod providers
  (`hmApiProvider`, `sessionProvider`, `updateRequiredProvider`, `clockProvider`).
- `hm_design`: `HmPrimaryButton`, `HmSecondaryButton`, `HmCard`, `HmErrorView`, `HmLoadingView`, `HmCodeEntry`
  (6 digits, paste, 60 s resend), `Lamp` (3 rings by shape + colour + semantics). Dark theme default.
- `apps/mobile`: `ProviderScope` + `go_router`: `/start` (onboarding) when signed out, a 5-tab
  `StatefulShellRoute` when signed in, `/lesson/:topicId`. "Update needed" screen when the signal is raised.
  Never depends on `hm_desk`.
- `apps/desk`: `ProviderScope` + `go_router`: `/` sign-in, `/home` when the Desk session exists.
- Offline (§39): Phase 1 has no offline writes. Reads fail with a "No internet" message and a Try again button.
- Calm Mode is stored on the server (`PATCH /v1/me`); the Phase 1 Today tab is already the simple one.
- Lite Mode: `liteModeProvider` (from `Me.liteMode`; automatic RAM detection deferred) switches the map to a list.

## Failure modes
| Failure | Behaviour | User sees |
|---|---|---|
| No network | `HmApiException(NETWORK_ERROR)` | "No internet connection. Please check and try again." + Try again |
| Refresh refused | tokens cleared, router goes to start | "You were signed out. Please sign in again." (server message) |
| App too old | `updateRequiredProvider` true | "Please update HeyMey to continue." |
| Any envelope error | message shown as-is (simple English by contract) | server `message` |

## Non-functional budget
Cold start ≤ 2.5 s (no network before first frame), install ≤ 40 MB (only small pure-Dart packages + 4 plugins).

## Test plan
| Level | Cases |
|---|---|
| Unit (hm_core) | Idempotency-Key on writes and not on eligibility; envelope parsing; network error; refresh single flight; refresh refused → signed out; min-version signal; oneOf decode |
| Widget (hm_design) | Lamp semantics label; button min size 48; code entry paste + resend after 60 s (fake async) |
| Widget (apps) | shell shows 5 tabs; Desk boots to sign-in |

## Bolts
- BOLT-0004: everything above (Phase 1).
