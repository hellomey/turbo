/**
 * Every tunable number for `mastery` (blueprint §5.1, §5.2). PROVISIONAL defaults, founder to confirm
 * (aidlc/decisions.md D-2026-10-22-10 ... -16). Changing a value = edit here + bump `version`; no redesign.
 * `version` is stored on checks and ranks so results stay explainable after a change.
 */
export const MASTERY_CONFIG = {
  version: "2026-10-22.1",
  /** Q1 (D-2026-10-22-10): Lit check = 3 questions, pass 2 of 3, retry at once with a new set. */
  litCheck: { questions: 3, passMark: 2 },
  /** Q2 (D-...-11): recall ladder gaps in IST days; Steady from the first passed recall; then maintenance. */
  recall: { questions: 3, passMark: 2, ladderDays: [1, 3, 7, 21] as const, maintenanceDays: 30, failStepsBack: 1, failRetryDays: 1 },
  /** Q3 (D-...-12): dimming at due time; Steady lost after this many days overdue; Gold is never removed by dimming. */
  dimming: { steadyLostAfterOverdueDays: 7, goldLostOnDim: false },
  /** Q5 (D-...-14): relight sized for 2-5 minutes. A pass counts as a passed recall. */
  relight: { questions: 5, passMark: 4, minutesEstimate: 3 },
  /** Q4 (D-...-13): timed exam-level set, >= 80%, needs Lit; Gold is never lost. */
  gold: { questions: 15, secondsPerQuestion: 60, passPercent: 80, minDifficulty: 3, attemptsPerTopicPerIstDay: 2, lateGraceSeconds: 5 },
  /** §39: offline actions older than this when synced become a study log only. */
  offline: { maxAgeDays: 7, syncBatchMax: 100 },
  /** Q6/Q7 (D-...-15, -16): XP = lamp points; rank = % of max lamp points over the user's syllabus (union of exams). */
  xp: { lit: 10, perSteadyStep: 5, gold: 20 },
  /** Level 1..11 thresholds as percent of max XP. Index 0 = level 1. */
  rankThresholdPercent: [0, 2, 5, 10, 18, 27, 37, 48, 60, 75, 90] as const,
  rankNote: "Game title. Not an official designation.",
  /** §5.2 Tamil Nadu family titles; used until exam-family titles (R6, ExamFamily.rankTitles) are exposed by exams. */
  defaultRankTitles: ["Aspirant", "Typist", "Junior Assistant", "Village Officer", "Section Officer", "Deputy Tahsildar", "Tahsildar", "Deputy Collector", "District Collector", "Secretary", "Chief Secretary"] as const,
  /** Untimed checks (Lit, recall, relight) must be submitted within this many hours of being issued (BOLT-0009). */
  checkTtlHours: 24,
  /** Dimming job batch size and optimistic-concurrency retries (logical design). */
  dimmingBatch: 1000,
  writeRetries: 3,
} as const;
