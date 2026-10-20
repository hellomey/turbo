import type { OtpMailer } from "../application/ports.js";

/** The slice of the apps' JobQueue this adapter needs. */
export interface JobQueueLike {
  add(queue: string, name: string, data: Record<string, unknown>, opts?: { delayMs?: number; jobId?: string }): Promise<void>;
}

export const OTP_EMAIL_QUEUE = "email.otp";

/** Queues `email.otp` with jobId = OtpCode id, so a retried request never sends the same code twice. */
export function jobQueueOtpMailer(queue: JobQueueLike): OtpMailer {
  return {
    send: ({ otpId, to, code, purpose }) => queue.add(OTP_EMAIL_QUEUE, "send", { to, code, purpose }, { jobId: otpId }),
  };
}
