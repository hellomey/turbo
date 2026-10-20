import { AUTH_POLICY } from "@heymey/domain/modules/auth";
import type { Clock } from "@heymey/domain/shared";

export interface OtpGcDeps {
  otps: { purgeExpiredOtpCodes(olderThan: Date): Promise<number> };
  clock: Clock;
}

/**
 * `auth.otp-gc` (owner: auth, hourly, SEC-M3, §23 data minimisation): delete OTP rows (email, code hash, request IP)
 * older than 24 hours. Codes live 10 minutes; a day is kept for abuse investigation only. Idempotent.
 */
export function createOtpGcProcessor(deps: OtpGcDeps) {
  return async (): Promise<{ deleted: number }> => {
    const olderThan = new Date(deps.clock.now().getTime() - AUTH_POLICY.otpRetentionMs);
    return { deleted: await deps.otps.purgeExpiredOtpCodes(olderThan) };
  };
}
