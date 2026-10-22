import type { AlertCategory, AlertPrefs, SendStatus } from "../domain/policy.js";

export interface PushTokenRow {
  deviceId: string;
  platform: "android" | "ios";
  token: string;
}

/** Port: device push tokens, one per (user, device). */
export interface PushTokenRepository {
  upsert(input: { userId: string; deviceId: string; platform: "android" | "ios"; token: string; at: Date }): Promise<void>;
  /** Hard delete of the device's token. Returns true when a row existed. */
  remove(userId: string, deviceId: string): Promise<boolean>;
  removeAllForUser(userId: string): Promise<number>;
  activeForUser(userId: string): Promise<PushTokenRow[]>;
  revokeToken(token: string, at: Date): Promise<void>;
}

export interface AlertPreferenceRepository {
  get(userId: string): Promise<AlertPrefs | null>;
  put(userId: string, prefs: AlertPrefs): Promise<void>;
}

export interface SendLogRow {
  id: string;
  userId: string;
  category: AlertCategory;
  templateKey: string;
  dedupeKey: string;
  istDay: string;
  status: SendStatus;
}

export interface SendLogRepository {
  /**
   * Atomically (per user): if dedupeKey exists return it unchanged; else count today's counted non-exam rows,
   * ask `decide` for a status and insert. Serialised per user so the 3-a-day budget holds under concurrency.
   */
  record(
    input: { userId: string; category: AlertCategory; templateKey: string; dedupeKey: string; istDay: string },
    decide: (nonExamCountedToday: number) => SendStatus,
  ): Promise<{ row: SendLogRow; created: boolean }>;
  get(id: string): Promise<SendLogRow | null>;
  /** Moves `from` -> `to` only if the row is still in `from`. Returns true when it moved. */
  transition(id: string, from: SendStatus, to: SendStatus, sentAt?: Date): Promise<boolean>;
  listHeld(limit: number): Promise<SendLogRow[]>;
}

/** Port filled by the composition root from the users module (offers consent purpose). */
export interface OffersConsentReader {
  offersGranted(userId: string): Promise<boolean>;
}

/** Port: FCM/APNs. Until D-2026-10-22-33 the adapter only logs ids. */
export interface PushSender {
  send(msg: { sendLogId: string; deviceId: string; platform: "android" | "ios"; token: string; templateKey: string }): Promise<"sent" | "invalid_token">;
}

/** Port: hands a queued SendLog id to the `push.send` queue. */
export interface SendDispatcher {
  dispatch(sendLogId: string): Promise<void>;
}
