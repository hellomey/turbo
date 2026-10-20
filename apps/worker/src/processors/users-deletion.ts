import type { Actor } from "@heymey/domain/shared";

export interface UsersDeletionDeps {
  users: { eraseDueAccounts(hooks: { beforeErase(user: { id: string; email: string }): Promise<void> }): Promise<string[]> };
  sessions: { revokeAllForUser(userId: string, reason: "deleted", actor: Actor): Promise<number> };
  /** auth's OTP retention API (SEC-M3): OTP rows keep the plain email and request IP. */
  otps: { purgeOtpCodesFor(email: string): Promise<number> };
}

const SYSTEM: Actor = { userId: null, role: "SYSTEM" };

/**
 * `users.deletion` (owner: users, daily 03:00 IST, §38.7, §23): erase accounts past the 7-day grace period, then
 * make sure none of their sessions survive. Before an account's email is replaced, auth deletes the OTP rows sent to
 * it (SEC-M3a); users re-checks each account atomically, so one cancelled in the meantime is skipped (SEC-M3b).
 * Idempotent: erased users are never picked again, purging/revoking twice is a no-op.
 * Returns counts only (ids and emails are never logged).
 */
export function createUsersDeletionProcessor(deps: UsersDeletionDeps) {
  return async (): Promise<{ erased: number; otpRowsPurged: number }> => {
    let otpRowsPurged = 0;
    const ids = await deps.users.eraseDueAccounts({
      beforeErase: async (user) => {
        otpRowsPurged += await deps.otps.purgeOtpCodesFor(user.email);
      },
    });
    for (const id of ids) await deps.sessions.revokeAllForUser(id, "deleted", SYSTEM);
    return { erased: ids.length, otpRowsPurged };
  };
}
