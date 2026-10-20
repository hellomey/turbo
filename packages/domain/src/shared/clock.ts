/**
 * All timers use SERVER time (blueprint §18 "Changing the phone clock").
 * Inject a Clock everywhere; never call Date.now() in domain code (ESLint enforces it).
 */
export interface Clock {
  now(): Date;
}

export const systemClock: Clock = {
  // eslint-disable-next-line no-restricted-properties -- the one allowed call site
  now: () => new Date(Date.now()),
};

const IST_OFFSET_MINUTES = 5 * 60 + 30;

/** The Asia/Kolkata calendar day ("2026-10-20") used for check-ins, daily limits and games sleep. */
export function istDayKey(at: Date): string {
  const ist = new Date(at.getTime() + IST_OFFSET_MINUTES * 60_000);
  return ist.toISOString().slice(0, 10);
}

/** Hour 0-23 in Asia/Kolkata. */
export function istHour(at: Date): number {
  const ist = new Date(at.getTime() + IST_OFFSET_MINUTES * 60_000);
  return ist.getUTCHours();
}
