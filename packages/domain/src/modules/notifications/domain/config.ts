/** Every tunable number for `notifications` (§19.8 Q78, §6). PROVISIONAL, founder to confirm (D-2026-10-22-31 ... -33). */
export const NOTIFICATIONS_CONFIG = {
  version: "2026-10-22.1",
  /** §19.8 Q78: max non-exam alerts per IST day. Exam Alerts are separate. */
  maxNonExamPerIstDay: 3,
  /** Q16: defaults, IST minutes after midnight. Exam Alerts in quiet hours are HELD until quiet hours end. */
  quietHoursDefault: { enabled: true, startMinute: 22 * 60, endMinute: 7 * 60 },
  examAlertsDuringQuietHours: "hold" as "hold" | "send",
  morningAlertMinute: 7 * 60 + 30,
  /** Q21: until the founder sets up Firebase/APNs, the sender logs instead of sending. */
  senderMode: "log_only" as "log_only" | "live",
} as const;
