import type { OtpPurpose, Role, z } from "@heymey/contracts";
import { DESK_ROLES } from "@heymey/contracts";

export type Purpose = z.infer<typeof OtpPurpose>;

const MINUTE = 60_000;
const DAY = 24 * 60 * MINUTE;

/** Blueprint §18 "OTP abuse" + §38 + D-2026-10-20-11. */
export const AUTH_POLICY = {
  otpTtlMs: 10 * MINUTE,
  otpMaxAttempts: 5,
  otpPerEmailLimit: 3,
  otpPerEmailWindowSeconds: 10 * 60,
  resendAfterSeconds: 60,
  accessTokenTtlMs: 15 * MINUTE,
  appSessionTtlMs: 60 * DAY,
  deskSessionTtlMs: 12 * 60 * MINUTE,
  deskChallengeTtlMs: 5 * MINUTE,
  totpStepSeconds: 30,
  /** Accept the previous and next 30-s step for phone clock drift. */
  totpDriftSteps: 1,
  /** SEC-H2 (§15 second factor): 5 consecutive wrong authenticator codes lock the user's TOTP for 15 minutes. */
  totpMaxFailures: 5,
  totpLockMs: 15 * MINUTE,
  /** SEC-M4 (interim until D-2026-10-20-20): a pending, unconfirmed secret younger than this cannot be replaced. */
  totpPendingProtectMs: 10 * MINUTE,
  /** SEC-M3 (§38.7, §23): OTP rows (email + request IP) are deleted after 24 hours. */
  otpRetentionMs: DAY,
} as const;

/** Is the user's Desk TOTP locked at `now`? (SEC-H2) */
export function totpLocked(lockedUntil: Date | null, now: Date): boolean {
  return lockedUntil !== null && now.getTime() < lockedUntil.getTime();
}

/** Seconds until a TOTP lock ends (at least 1). */
export function totpRetryAfterSeconds(lockedUntil: Date, now: Date): number {
  return Math.max(1, Math.ceil((lockedUntil.getTime() - now.getTime()) / 1000));
}

/** Lower-case + trim. The one email form the server stores, rate-limits and compares. */
export function normalizeEmail(email: string): string {
  return email.trim().toLowerCase();
}

/**
 * A small built-in list of disposable inbox providers (§18 "Farming free Sparks with fake accounts").
 * Sub-domains count too. Extend here; a data-driven list can replace it later.
 */
export const DISPOSABLE_EMAIL_DOMAINS: readonly string[] = [
  "mailinator.com", "guerrillamail.com", "guerrillamail.net", "guerrillamailblock.com", "sharklasers.com", "grr.la",
  "10minutemail.com", "10minutemail.net", "tempmail.com", "temp-mail.org", "tempmail.net", "tempail.com", "tempr.email",
  "yopmail.com", "yopmail.net", "trashmail.com", "trashmail.de", "getnada.com", "nada.email", "dispostable.com",
  "maildrop.cc", "throwawaymail.com", "fakeinbox.com", "mailnesia.com", "mintemail.com", "emailondeck.com", "moakt.com",
  "mohmal.com", "burnermail.io", "discard.email", "spamgourmet.com", "mailcatch.com", "mytemp.email", "tmpmail.org",
  "getairmail.com", "inboxkitten.com", "mailpoof.com", "spambox.us", "trbvm.com", "fakemail.net",
];

export function isDisposableEmail(normalizedEmail: string): boolean {
  const domain = normalizedEmail.slice(normalizedEmail.lastIndexOf("@") + 1);
  return DISPOSABLE_EMAIL_DOMAINS.some((d) => domain === d || domain.endsWith(`.${d}`));
}

export interface OtpState {
  attempts: number;
  expiresAt: Date;
  usedAt: Date | null;
  lockedAt: Date | null;
}

/**
 * Can this (latest) code still be tried? Expired at exactly `expiresAt`. A used code counts as expired
 * (only the latest code is ever valid). A code with 5 failed attempts is locked.
 */
export function otpStatus(otp: OtpState | null, now: Date): "ok" | "expired" | "locked" {
  if (!otp || otp.usedAt || now.getTime() >= otp.expiresAt.getTime()) return "expired";
  if (otp.lockedAt || otp.attempts >= AUTH_POLICY.otpMaxAttempts) return "locked";
  return "ok";
}

export function hasDeskRole(roles: readonly Role[]): boolean {
  return roles.some((r) => DESK_ROLES.includes(r));
}

/** The 30-s TOTP step that contains `at`. */
export function totpStep(at: Date): number {
  return Math.floor(at.getTime() / 1000 / AUTH_POLICY.totpStepSeconds);
}

/** Steps tried for a code: previous, current, next (oldest first). */
export function candidateSteps(at: Date): number[] {
  const s = totpStep(at);
  const out: number[] = [];
  for (let d = -AUTH_POLICY.totpDriftSteps; d <= AUTH_POLICY.totpDriftSteps; d++) out.push(s + d);
  return out;
}

/** Plain text only: no links, no images (§38 step 2). */
export function composeOtpEmail(purpose: Purpose, code: string): { subject: string; text: string } {
  const ignore = "Never share this code with anyone. If you did not ask for this, ignore this email.";
  const text =
    purpose === "delete_account"
      ? `Your HeyMey code is ${code}. It confirms deleting your HeyMey account. It expires in 10 minutes. ${ignore}`
      : `Your HeyMey code is ${code}. It expires in 10 minutes. ${ignore}`;
  return { subject: "Your HeyMey code", text };
}
