# BOLT-0020: Compliance review (Phase 2 / INT-002 + BOLT-0021, BOLT-0022)
Reviewer: compliance (read-only; saved by conductor 2026-11-04). Rules: Dark Patterns Guidelines 2023, blueprint §5.2, §5.3, §10.2, §10.7, §13, §19.10 Q100, §30, §31, DPDP Act 2023.

**Verdict: CHANGES REQUIRED.** Blocking: C-P2-1, C-P2-7, C-P2-8.

## Passed
Free-limit sheet (S07); locked report + readiness bars (S10); PYQ / drill Pro labels before tap; offers opt-in off by default (QA to confirm server default `offers=false`); Sunday Report bans selection promises; firewall; no Tamil in UI.

## Findings
- **C-P2-1 (BLOCKING, §5.2)** rank-up overlays omit "Game title. Not an official designation.": `dart/hm_features/lib/src/practice/presentation/check_screen.dart:85-86`, `dart/hm_features/lib/src/today/presentation/today_tab.dart:61-62`. Use the server `rankNote`.
- **C-P2-2 (advisory)** "Lamp lit!" / "Gold earned!" pass; keep "Gold" out of Store/price text.
- **C-P2-3 (verify, §10.7)** static "New rank" result card (`check_screen.dart:346`) must hide in Calm Mode; add widget test.
- **C-P2-4 (advisory)** Sunday Report "Gold earned" field fine.
- **C-P2-5 (INT-007 conditions before G-D)** daily board cap not 12-15 h; no ranking 12-5 AM; no Sparks for focus; visibility off by default; no shaming comparisons.
- **C-P2-6 (advisory, §13)** server-enforced "max one offer per day" + test before any offer template ships.
- **C-P2-7 (BLOCKING, DPDP)** `apps/marketing/src/content/legal.ts` privacy policy outdated: data categories, named processors (Supabase, Cloudflare R2, Firebase, Vercel, Amazon SES, OpenRouter with no personal data, VM provider), cross-border transfer, retention incl. backups, per-purpose consent withdrawal, DPDP rights incl. nominee and Board, Grievance Officer (§31), domain `heymey.in` → `heymey.app`, new effective date. Founder approves.
  - Conductor note: sign-in is **email** OTP only; the review's mention of phone login is incorrect.
- **C-P2-8 (BLOCKING, §31)** missing Community Guidelines and Game Rules & Odds pages; vague refund wording (lines 62, 67) must state the window, conditions, how to cancel and refund time; line 44 rewrite in simple English; one product name ("Pro"), prices incl. GST. Founder approves.


### Fix log (flutter-ui, 2026-11-04)
- **C-P2-1 fixed**: `rankUpSubtitle()` in `hm_features/.../practice_models.dart` builds "You are now <title>. Game title. Not an official designation." from the server note (fallback to the exact text); used in `check_screen.dart` and `today_tab.dart`. Tests in `practice_test.dart`.
- **C-P2-3 fixed**: rank card in `CheckResultBody` hidden when Calm Mode is on (`meProvider.calmMode`); widget test added.
