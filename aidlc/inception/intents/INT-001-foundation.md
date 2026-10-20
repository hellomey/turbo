# INT-001: Week 1 Foundation (sign in, eligibility, Study Map)

| | |
|---|---|
| Status | **elaborating** (ready for G-I once open questions are answered) |
| Blueprint | §17.1, §19.1, §20, §21, §36 (auth, users, roles, exams, syllabus, content), §38, §42, §43 week 1 |
| Risk tier | T2 (auth, personal data, eligibility correctness) |
| Owner | conductor |
| Founder approval (G-I) | _pending_ |

## Why
"A new user can install, check eligibility, sign in by email, and see their Study Map on staging" (§43 week 1, done-when).
Eligibility is the value moment before login (§17.1), so it must be correct and fast.

## Scope
- In: infra live on staging; CI/CD; platform API concerns; email OTP; users + consent; roles + Desk TOTP enrolment;
  exams + eligibility engine; syllabus → Study Map; lesson serving; app shell, onboarding, eligibility result + share
  card, OTP login, Study Map rendering, lessons, Listen Mode.
- Out: practice limits, mocks, games, purchases (later intents).

## Stories

### INT-001-S01: Check eligibility before signing up
As a visitor, I want to enter my date of birth, qualification, community and PSTM status and see which exams I'm
eligible for, so that I know HeyMey is useful before I give my email. (§17.1 steps 1–3, §19.1 Q1, Q4)

- Given a DOB under 18, When I continue, Then I see "HeyMey is for 18+. See you on your 18th birthday." and nothing is stored on the server or the phone.
- Given valid answers, When I submit, Then I see "You're eligible for N exams" with the top 5, each linking to its official notification and showing "Always confirm with the official notification."
- Given age relaxation rules for my community, When eligibility is computed, Then the relaxation is applied and the reason is shown.
- Eligibility rules are data (EligibilityRule), human-checked 100% before publishing (§26.2 rule 5).

### INT-001-S02: Save progress with email OTP
As a visitor who lit a first lamp, I want to save my progress with my email and a 6-digit code. (§17.1 step 7, §38)

- Given an email, When I request a code, Then the API always answers 200, and an email "Your HeyMey code is NNNNNN. It expires in 10 minutes." is queued.
- Given 3 requests for one email in 10 minutes (or 10 per IP per hour), When I request again, Then I get RATE_LIMITED with Retry-After.
- Given a disposable email domain, When I request, Then I get EMAIL_NOT_ALLOWED.
- Given 5 wrong codes, Then that code is locked (OTP_LOCKED). Codes are stored hashed (argon2id + pepper), compared in constant time.
- Given a correct code, Then I get a 15-minute access JWT and a 60-day rotating refresh token bound to my device; resend unlocks after 60 s in the app.
- Given an old refresh token is reused, Then the whole session family is revoked.

### INT-001-S03: Consent (DPDP)
As a new user, I see a short consent screen with separate optional choices, nothing pre-ticked, and my choices are recorded with the notice version. (§17.1 step 8, §23, §30)

### INT-001-S04: Study Map
As a signed-in aspirant, I see my main exam's subjects as islands and topics as lamps (Lit / Steady / Gold rings, shape + colour), with shared lamps tagged by exam colour; Lite Mode shows a static map. (§5.1, §10.6, §10.8)

### INT-001-S05: Lessons + Listen Mode
As an aspirant, I can open a lesson (clean reading view, textbook page reference) and have it read aloud with the phone's TTS, even offline for downloaded content. (§10.6, §19.3 Q27)

### INT-001-S06: Desk staff sign in with TOTP
As a staff member, I sign in to desk.heymey.app with email OTP + an authenticator code; aspirants are refused. (§15, §38.5)

### INT-001-S07: Platform guarantees on every request
Every write requires Idempotency-Key; every error uses the envelope with a stable code and simple-English message;
every response carries X-Min-App-Version; per-user and per-IP rate limits live in Valkey. (§34, §37)

### INT-001-S08: Staging is live
`main` deploys automatically to staging-*.heymey.app on the VPS; backups run and one test restore has passed; Grafana shows api p95 and error rate. (§21, §42)

## Units
U-infra, U-platform-api, U-contracts, U-design-system, U-app-shell, U-audit, U-users, U-auth, U-roles, U-syllabus,
U-exams, U-content, U-app-onboarding, U-app-study (map + lessons part), U-app-profile (consent, deletion entry point).
See `aidlc/inception/units.md`.

## Success metrics
Onboarding to eligibility result p50 < 60 s on a 3 GB RAM phone; OTP email delivered < 30 s for 95% (§32); api p95 ≤ 300 ms.

## Open questions
- [ ] Q1: Which SMTP provider (ZeptoMail / SES / Brevo)? → D-…
- [ ] Q2: Primary domain `heymey.app` (blueprint) vs `heymey.in` (current marketing site)? → see D-2026-10-20-02
- [ ] Q3: JWT signing algorithm: EdDSA (Ed25519) proposed. → D-…
- [ ] Q4: Eligibility data scope for launch: which central exams are in "all major exams" (§1 decision 16)?
