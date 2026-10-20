export { startPostgres, startValkey, type StartedDb } from "./containers.js";

/** A controllable clock. Every time-based rule (dimming, daily limits, games sleep, OTP expiry) is tested with it. */
export class FakeClock {
  private current: Date;

  constructor(start: Date | string = "2026-01-01T00:00:00.000Z") {
    this.current = new Date(start);
  }

  now(): Date {
    return new Date(this.current);
  }

  set(at: Date | string): void {
    this.current = new Date(at);
  }

  advance(ms: number): void {
    this.current = new Date(this.current.getTime() + ms);
  }

  advanceMinutes(minutes: number): void {
    this.advance(minutes * 60_000);
  }

  advanceDays(days: number): void {
    this.advance(days * 24 * 60 * 60 * 1000);
  }
}
