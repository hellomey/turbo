import { composeOtpEmail } from "@heymey/domain/modules/auth";

export interface MailTransport {
  sendMail(message: { from: string; to: string; subject: string; text: string }): Promise<unknown>;
}

export interface EmailOtpJob {
  to: string;
  code: string;
  purpose: "login" | "delete_account";
}

function isEmailOtpJob(data: unknown): data is EmailOtpJob {
  const d = data as Partial<EmailOtpJob> | null;
  return (
    typeof d?.to === "string" &&
    typeof d.code === "string" &&
    /^\d{6}$/.test(d.code) &&
    (d.purpose === "login" || d.purpose === "delete_account")
  );
}

/**
 * `email.otp` (owner: auth, §38 step 2). Plain text only: no links, no images, no HTML part.
 * Never logs the address or the code. A retried job re-sends the same code (jobId = OtpCode id), which is safe.
 */
export function createEmailOtpProcessor(deps: { transport: MailTransport; from: string }) {
  return async (data: unknown): Promise<void> => {
    if (!isEmailOtpJob(data)) throw new Error("email.otp: malformed job data");
    const { subject, text } = composeOtpEmail(data.purpose, data.code);
    await deps.transport.sendMail({ from: deps.from, to: data.to, subject, text });
  };
}
