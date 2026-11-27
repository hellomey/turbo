import { z } from "../zod.js";

/** Email OTP login. Blueprint §38. */
export const OtpPurpose = z.enum(["login", "delete_account"]).openapi("OtpPurpose");

export const OtpRequestBody = z
  .object({
    email: z.email().max(254),
    /** `delete_account` requires a signed-in session for the same email. */
    purpose: OtpPurpose.default("login"),
  })
  .openapi("OtpRequestBody");

export const OtpRequestResponse = z
  .object({ resendAfterSeconds: z.number().int() })
  .openapi("OtpRequestResponse", { description: "Always returned, whether or not the email has an account." });

export const ClientKind = z.enum(["app", "desk"]).openapi("ClientKind");

export const OtpVerifyBody = z
  .object({
    email: z.email().max(254),
    code: z.string().regex(/^\d{6}$/),
    deviceId: z.uuid(),
    platform: z.enum(["android", "ios", "web"]),
    client: ClientKind.default("app"),
  })
  .openapi("OtpVerifyBody");

export const TokenPair = z
  .object({
    accessToken: z.string().openapi({ description: "JWT (EdDSA), 15 minutes" }),
    refreshToken: z.string().openapi({ description: "Opaque, rotates on every use. 60 days (app), 12 hours (Desk)" }),
    accessTokenExpiresAt: z.iso.datetime(),
  })
  .openapi("TokenPair");

export const SessionGranted = z
  .object({
    kind: z.literal("session"),
    tokens: TokenPair,
    isNewUser: z.boolean(),
    /** True when signing in cancelled a pending account deletion (§38.7). */
    deletionCancelled: z.boolean(),
    /**
     * Set only when a guest signed in with an email (guest mode, D-2026-11-27). `kept`: the email was new, so the
     * guest account became this account and all progress stays. `not_merged`: the email already had an account;
     * you are now in that account and the guest progress was NOT moved into it.
     */
    guestProgress: z.enum(["kept", "not_merged"]).optional(),
  })
  .openapi("SessionGranted");

/** Guest mode (D-2026-11-27): try the app without an email. Adults only; under-18s join the waitlist (DPDP). */
export const GuestSessionBody = z
  .object({
    deviceId: z.uuid(),
    platform: z.enum(["android", "ios", "web"]),
    /** Must be true; the server answers UNDER_18 otherwise. */
    ageConfirmed18: z.boolean(),
  })
  .openapi("GuestSessionBody");

/** Desk sign-in needs a second factor. The challenge token lives 5 minutes. */
export const DeskChallenge = z
  .object({
    kind: z.literal("desk_2fa"),
    challengeToken: z.string(),
    totpEnrolled: z.boolean(),
  })
  .openapi("DeskChallenge");

export const OtpVerifyResponse = z
  .discriminatedUnion("kind", [SessionGranted, DeskChallenge])
  .openapi("OtpVerifyResponse");

export const RefreshBody = z.object({ refreshToken: z.string().min(20) }).openapi("RefreshBody");

export const DeskTotpEnrollBody = z.object({ challengeToken: z.string() }).openapi("DeskTotpEnrollBody");
export const DeskTotpEnrollResponse = z
  .object({
    otpauthUri: z.string().openapi({ description: "Show as a QR code. Shown only until the first successful verify." }),
    secret: z.string().openapi({ description: "Base32, for manual entry" }),
  })
  .openapi("DeskTotpEnrollResponse");

export const DeskTotpVerifyBody = z
  .object({ challengeToken: z.string(), code: z.string().regex(/^\d{6}$/) })
  .openapi("DeskTotpVerifyBody");

export const DeleteAccountBody = z.object({ code: z.string().regex(/^\d{6}$/) }).openapi("DeleteAccountBody");
export const DeleteAccountResponse = z
  .object({ deletionScheduledFor: z.iso.datetime() })
  .openapi("DeleteAccountResponse", { description: "Sign in before this time to cancel." });

// `ok` is a plain boolean (always true): openapi-generator `dart` cannot compile boolean literal enums.
export const OkResponse = z.object({ ok: z.boolean() }).openapi("OkResponse");
