# BOLT-0004: Phase 1 app + Desk (shell, onboarding, eligibility, OTP sign-in, consent, Study Map, lessons + Listen, Desk TOTP)

| | |
|---|---|
| Unit | U-app-shell, U-design-system, U-app-onboarding, U-app-study (map + lessons), U-desk (sign-in) |
| Stories | INT-001-S01, S02 (app side), S03, S04, S05, S06 |
| Risk tier | T2 (DOB gate, consent, Desk access) |
| Agent | flutter-ui |
| Branch / PR | `bolt/BOLT-0004-app-desk` · not opened (agents do not commit) |
| Status | in review (verification green; not committed, no PR yet) |

## Plan
- Design first: `aidlc/construction/units/{U-app-shell,U-app-onboarding,U-app-study,U-desk}/` domain model + logical design.
- `hm_core`: ApiConfig, HmHttpClient (auth, Idempotency-Key, refresh single-flight, min app version), HmApi wrapper over the
  generated `hm_api` (never edited), TokenStore, DeviceIdStore, session providers.
- `hm_design`: buttons, card, error/loading views, 6-digit code entry, Lamp (shape + colour + semantics).
- `hm_features`: onboarding (§17.1 steps 1–5, 7, 8), eligibility result, Study Map, lessons + Listen, Today, Play/Squad
  "Coming soon", Profile (Calm Mode, log out, log out all, delete account).
- `hm_desk` + `apps/desk`: email code → TOTP enrol (QR) → authenticator code → Desk home (role + Phase 4 placeholders).
- `apps/mobile`: Riverpod + go_router composition root, five tabs, lesson route. No `hm_desk` dependency.
- No contract changes. Tests with fakes only (no running server).

## Result

### What changed
- **Design docs** (written first): `aidlc/construction/units/{U-app-shell,U-app-onboarding,U-app-study,U-desk}/`
  domain-model.md + logical-design.md.
- **hm_core**: `ApiConfig` (`API_BASE_URL` define; `10.0.2.2:4567` on the Android emulator, `localhost:4567` elsewhere),
  `HmHttpClient` (Bearer, UUID `Idempotency-Key` on POST/PUT/PATCH except `/v1/eligibility/check`, one refresh at a time
  on 401 then retry with the same key, sign-out when the refresh is refused, `X-Min-App-Version` → update-required),
  `HmApi` (every Phase 1 route, envelope → `HmApiException(code, message)`, `NETWORK_ERROR` for no connection),
  `TokenStore` (secure / memory / cached for Desk), `DeviceIdStore`, Riverpod providers (session, update-required, clock).
- **hm_design**: `HmPrimaryButton`, `HmSecondaryButton` (≥ 48 dp), `HmCard`, `HmErrorView`, `HmLoadingView`, `HmComingSoon`,
  `HmCodeEntry` (6 digits, paste, "Didn't get it? Check spam.", resend after 60 s), `Lamp` (Lit = solid circle, Steady = 4 arc
  segments, Gold = octagon; semantics names all three rings). Theme: 48 dp button minimums. Dark stays default.
- **hm_features**: onboarding §17.1 steps 1–5, 7, 8 (DOB gate on the IST date + server `UNDER_18`; one-tap answers; eligibility
  result with N, top 5, official links, share; main + up to 2 exams; Study Map preview; email → code; consent with nothing
  pre-ticked); Study Map tab (islands + lamps, Lite list); lesson screen (small markdown renderer, textbook refs, source,
  Listen/Stop via `flutter_tts`); Today card; Play/Squad "Coming soon"; Profile (Calm Mode, your data choices, Privacy/Terms
  links, grievance email, log out, log out of all devices, delete account with the 7-day grace explained).
- **hm_desk + apps/desk**: email code (`client: desk`, `platform: web`) → enrol (QR via `qr_flutter` + manual key) → authenticator
  code → Desk home with role(s) and the 8 Phase 4 placeholders; aspirants see the server's `DESK_NOT_ALLOWED` message.
- **apps/mobile**: Riverpod + go_router (onboarding when signed out, 5-tab `StatefulShellRoute` when signed in, `/lesson/:id`,
  "Please update HeyMey to continue." screen). No `hm_desk` dependency.
- **Compliance review fixes (BOLT-0006 C1, C3, M6, M7, M8 + special-categories hint)**: Profile "Your data choices" (optional
  purposes as switches; saves ALL purposes with the CURRENT notice version, required stay granted), Privacy/Terms links and
  "Questions or complaints: grievance@heymey.app"; consent footer + "Read our Privacy Policy" + button "Save my choices and
  continue"; empty-result copy with "Change answers"; confirm line shown once; new share text.

### Packages added (pub, via `flutter pub add`)
hm_core: `flutter_riverpod ^3.4.3`, `flutter_secure_storage ^11.2.0`, `http ^1.6.0`, `uuid ^4.6.0` ·
hm_features: `flutter_riverpod ^3.4.3`, `url_launcher ^6.3.3`, `share_plus ^13.3.1`, `flutter_tts ^4.2.5` ·
hm_desk: `flutter_riverpod ^3.4.3`, `qr_flutter ^4.1.0` · apps/mobile + apps/desk: `flutter_riverpod ^3.4.3`, `go_router ^18.1.0`.
No platform-folder changes.

### Evidence (run 2026-10-20 on Windows, Flutter 3.47.5 / Dart 3.13.4)
- `flutter pub get` (root): OK.
- `dart format --output=none --set-exit-if-changed` on apps/mobile, apps/desk and every owned `dart/` package: 0 changed, exit 0.
  The literal command over all of `dart/` exits 1 **only** because of 71 unformatted GENERATED files in `dart/hm_api`
  (not formatted, per instructions).
- `flutter analyze` (root): **No issues found.**
- `node tools/flutter-test-all.mjs`: **71 tests, all pass** (mobile 2, desk 1, hm_design 9, hm_core 21, hm_features 34, hm_desk 4).
- Goldens: `dart/hm_features/test/goldens/eligibility_result_{dark,light}.png`, generated with
  `flutter test --update-goldens test/eligibility_golden_test.dart` on Windows (default test font; may differ on Linux CI,
  regenerate there if needed).
- `apps/desk`: `flutter build web --release` → built.
- `apps/mobile`: `flutter build apk --debug` → **not possible here: "No Android SDK found"**. Compile check instead:
  `flutter build web --release` with a temporary `web/` folder (copied from apps/desk, deleted afterwards) → built.
  No web target ships for aspirants.
- `graphify update .` → graph updated.

### Blocker / follow-ups
1. **`dart/hm_api` does not compile** (3 errors in `ok_response.dart`, `health_response.dart`). `HmApi` therefore calls the
   routes directly (see U-app-shell logical design). Architect: fix the contract (`OkResponse.ok`, `HealthResponse.checks`)
   or codegen, regenerate, then switch `HmApi`'s transport to the generated `ApiClient`. The generator's other gaps
   (oneOf `OtpVerifyResponse`, nullable `Me.profile` / `UserExams.main`, nulls in request bodies, `dateOfBirth.toUtc()`)
   are listed there too.
2. Fonts (Plus Jakarta Sans, Sora) not bundled yet (§10.4).
3. Lite Mode automatic RAM detection (≤ 3 GB) not done: Lite comes from `Me.liteMode` only.
4. Image share card (§10.6) → plain text share for now. "Open email app" button and syllabus-overlap figure (§17.1 step 4) deferred.
5. Offline lesson packs (S05 "offline for downloaded content") need `hm_data` content packs → Phase 2. Listen itself works offline.
6. Returning users signing in skip consent; re-consent on a new notice version needs a `GET /v1/me/consents` comparison → Phase 2.
7. Goldens exist only for the eligibility result (dark/light); high-contrast, Calm and large-text goldens for every key screen are
   still owed (200% text is covered by a no-overflow widget test instead).
8. Not tested against a running API (backend bolts 0002/0003 in progress); all tests use fakes / `MockClient`.

### Out of Phase 1 (skipped cleanly, D-2026-10-20-14)
§17.1 steps 6 (first lamp), 9 (hours/plan), 10 (squad), 11 (alert permission).
