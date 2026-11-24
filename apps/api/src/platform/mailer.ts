import nodemailer from "nodemailer";
import { composeOtpEmail, type OtpMailer } from "@heymey/domain/modules/auth";
import type { ApiEnv } from "./env.js";

type MailEnv = Pick<
  ApiEnv,
  | "EMAIL_PROVIDER" | "EMAIL_FALLBACK_PROVIDER" | "SMTP_HOST" | "SMTP_PORT" | "SMTP_SECURE" | "SMTP_USER" | "SMTP_PASS"
  | "BREVO_API_KEY" | "RESEND_API_KEY" | "EMAIL_FROM" | "EMAIL_FROM_NAME"
>;
type Provider = "smtp" | "brevo" | "resend";
type Message = { to: string; subject: string; text: string };

/** Never put the address or the code in an error: only which provider failed and why in general terms. */
async function viaSmtp(env: MailEnv, m: Message): Promise<void> {
  if (!env.SMTP_USER || !env.SMTP_PASS) throw new Error("mailer: SMTP_USER / SMTP_PASS are not set");
  const transport = nodemailer.createTransport({
    host: env.SMTP_HOST,
    port: env.SMTP_PORT,
    secure: env.SMTP_SECURE,
    auth: { user: env.SMTP_USER, pass: env.SMTP_PASS },
    connectionTimeout: 6000,
    greetingTimeout: 6000,
    socketTimeout: 8000,
  });
  try {
    await transport.sendMail({ from: `${env.EMAIL_FROM_NAME} <${env.EMAIL_FROM}>`, to: m.to, subject: m.subject, text: m.text });
  } finally {
    transport.close();
  }
}

async function viaBrevo(env: MailEnv, m: Message, fetchImpl: typeof fetch): Promise<void> {
  if (!env.BREVO_API_KEY) throw new Error("mailer: BREVO_API_KEY is not set");
  const res = await fetchImpl("https://api.brevo.com/v3/smtp/email", {
    method: "POST",
    headers: { "api-key": env.BREVO_API_KEY, "content-type": "application/json", accept: "application/json" },
    body: JSON.stringify({ sender: { email: env.EMAIL_FROM, name: env.EMAIL_FROM_NAME }, to: [{ email: m.to }], subject: m.subject, textContent: m.text }),
  });
  if (!res.ok) throw new Error(`mailer: brevo responded ${res.status}`);
}

async function viaResend(env: MailEnv, m: Message, fetchImpl: typeof fetch): Promise<void> {
  if (!env.RESEND_API_KEY) throw new Error("mailer: RESEND_API_KEY is not set");
  const res = await fetchImpl("https://api.resend.com/emails", {
    method: "POST",
    headers: { authorization: `Bearer ${env.RESEND_API_KEY}`, "content-type": "application/json" },
    body: JSON.stringify({ from: `${env.EMAIL_FROM_NAME} <${env.EMAIL_FROM}>`, to: [m.to], subject: m.subject, text: m.text }),
  });
  if (!res.ok) throw new Error(`mailer: resend responded ${res.status}`);
}

/**
 * Sends the OTP email from the request: primary provider first, then the fallback if the primary throws (quota, outage,
 * bad credentials). Plain text only. If both fail the request fails visibly. Never logs the address or the code.
 */
export function httpOtpMailer(env: MailEnv, fetchImpl?: typeof fetch): OtpMailer {
  const order: Provider[] = [env.EMAIL_PROVIDER, ...(env.EMAIL_FALLBACK_PROVIDER === "none" || env.EMAIL_FALLBACK_PROVIDER === env.EMAIL_PROVIDER ? [] : [env.EMAIL_FALLBACK_PROVIDER])];
  return {
    async send({ to, code, purpose }) {
      const { subject, text } = composeOtpEmail(purpose, code);
      const m = { to, subject, text };
      const doFetch = fetchImpl ?? globalThis.fetch;
      const errors: string[] = [];
      for (const p of order) {
        try {
          if (p === "smtp") await viaSmtp(env, m);
          else if (p === "brevo") await viaBrevo(env, m, doFetch);
          else await viaResend(env, m, doFetch);
          return;
        } catch (err) {
          errors.push(`${p}: ${err instanceof Error ? err.message.replace(/[\w.+-]+@[\w.-]+/g, "<email>") : "failed"}`);
        }
      }
      throw new Error(`mailer: every provider failed (${errors.join("; ")})`);
    },
  };
}
