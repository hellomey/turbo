import { composeOtpEmail, type OtpMailer } from "@heymey/domain/modules/auth";
import type { ApiEnv } from "./env.js";

/**
 * Sends the OTP email straight from the request over HTTPS (Brevo primary, Resend fallback, switch with EMAIL_PROVIDER).
 * Plain text only. Never logs the address or the code. A failed send throws, so the request fails visibly instead of
 * the user waiting for a code that never comes.
 */
export function httpOtpMailer(env: Pick<ApiEnv, "EMAIL_PROVIDER" | "BREVO_API_KEY" | "RESEND_API_KEY" | "EMAIL_FROM" | "EMAIL_FROM_NAME">, fetchImpl?: typeof fetch): OtpMailer {
  return {
    async send({ to, code, purpose }) {
      const fetch = fetchImpl ?? globalThis.fetch;
      const { subject, text } = composeOtpEmail(purpose, code);
      if (env.EMAIL_PROVIDER === "brevo") {
        if (!env.BREVO_API_KEY) throw new Error("mailer: BREVO_API_KEY is not set");
        const res = await fetch("https://api.brevo.com/v3/smtp/email", {
          method: "POST",
          headers: { "api-key": env.BREVO_API_KEY, "content-type": "application/json", accept: "application/json" },
          body: JSON.stringify({ sender: { email: env.EMAIL_FROM, name: env.EMAIL_FROM_NAME }, to: [{ email: to }], subject, textContent: text }),
        });
        if (!res.ok) throw new Error(`mailer: brevo responded ${res.status}`);
        return;
      }
      if (!env.RESEND_API_KEY) throw new Error("mailer: RESEND_API_KEY is not set");
      const res = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: { authorization: `Bearer ${env.RESEND_API_KEY}`, "content-type": "application/json" },
        body: JSON.stringify({ from: `${env.EMAIL_FROM_NAME} <${env.EMAIL_FROM}>`, to: [to], subject, text }),
      });
      if (!res.ok) throw new Error(`mailer: resend responded ${res.status}`);
    },
  };
}
