# Domain model: U-app-onboarding

Status: draft (Phase 1, BOLT-0004) · T2 (DOB gate, consent) · G-D by architect + founder pending

Feature folders: `dart/hm_features/lib/src/onboarding`, `src/eligibility`.

## Ubiquitous language
- **Eligibility Checker**: the free check before sign-up (§17.1 steps 1–3, §19.1).
- **Profile answers**: date of birth, qualification, community, Tamil medium (PSTM), special categories (contract `ProfileAnswers`).
- **Main exam**: the exam the Study Map is built for; up to 2 more exams may be added (§17.1 step 4).
- **Save your progress**: email OTP sign-in after the user has seen value (§17.1 step 7).
- **Consent**: DPDP notice with one required purpose and separate optional choices (§17.1 step 8, §23, §30).

## Aggregates and entities
| Aggregate | Value objects | Lives |
|---|---|---|
| `OnboardingState` | step, `ProfileDraft`, `EligibilityView`, chosen exams, email, consent choices | memory only (Riverpod) until sign-in |
| `ProfileDraft` | `dateOfBirth` (calendar date), `QualificationChoice`, `degreeSubject?`, `CommunityChoice`, `pstm`, `Set<SpecialCategoryChoice>` (≤ 3) | memory |
| `EligibilityView` | `eligibleCount`, `top5`, `others`, `disclaimer` | memory |

## Invariants (each is a test)
1. Age is computed on the **IST calendar date** (UTC+05:30). 17 years 364 days → blocked; 18th birthday today → allowed.
2. Under 18 shows exactly "HeyMey is for 18+. See you on your 18th birthday." and the draft is wiped. Nothing is written
   to storage or sent to the server before the check passes. The server's `UNDER_18` gives the same screen.
3. Profile choices are one-tap; the only text field is the optional degree subject, shown only for degree / PG.
4. The result shows "You're eligible for N exams" (N from the server), the top 5 by `fitRank`, each with its official link,
   and "Always confirm with the official notification." Links open outside the app.
5. Main exam is required; at most 2 more exams.
6. Resend is disabled for 60 s after a code is sent; the code field accepts a pasted 6-digit code.
7. Consent: nothing is pre-ticked; Continue is disabled until every required purpose is accepted; optional choices are
   recorded as given (false when untouched).
8. Profile and exams are saved only after consent is recorded.

## State machine
```
dob --adult--> answers --check ok--> result --continue--> pickExams --continue--> mapPreview --save--> email
dob --under 18 (local or UNDER_18)--> under18 (draft wiped)
email --code sent--> code --session--> consent --recorded--> saving --profile+exams saved--> done
start --"I already have an account"--> email (signInOnly) --session--> done
```

## Domain events
None (client). Server records consent with the notice version.

## Firewall impact
None.

## Open questions
- Returning users who sign in from onboarding skip consent (it was recorded at first sign-up). If the notice version changed,
  re-consent should be asked: needs `GET /v1/me/consents` comparison → Phase 2 follow-up.
