/** Every tunable number for `plan` (§17.3, §19.2, §19.10). PROVISIONAL, founder to confirm (D-2026-10-22-25 ... -28). */
export const PLAN_CONFIG = {
  version: "2026-10-22.1",
  starterPathDays: 7,
  pocketMinutes: [5, 10, 15] as const,
  /** Q19: rebalance after this many missed plan days (days with items and none done). */
  rebalanceAfterMissedDays: 2,
  /** Q19: mix by days left to the next stage date of the attempt cycle (percent of minutes). */
  mixByDaysLeft: [
    { minDaysLeft: 91, newTopics: 60, relight: 20, pyq: 15, mocks: 5 },
    { minDaysLeft: 61, newTopics: 45, relight: 25, pyq: 20, mocks: 10 },
    { minDaysLeft: 31, newTopics: 30, relight: 30, pyq: 20, mocks: 20 },
    { minDaysLeft: 8, newTopics: 5, relight: 40, pyq: 25, mocks: 30 },
    { minDaysLeft: 0, newTopics: 0, relight: 50, pyq: 30, mocks: 20 },
  ] as const,
  /** Balance dial step moves this many percentage points between new topics and relight. */
  balanceStepPercent: 10,
  /** Q18: Final Stretch phases; "critical" = TopicExamTag.priority >= this. */
  stretchDays: { d90: 90, d60: 60, d30: 30, d7: 7 },
  criticalPriority: 2,
  /** Q24: one daily budget; main exam share, others split the rest; nearest date gets this boost inside 60 days. */
  multiExam: { mainSharePercent: 60, nearestDateBoostPercent: 15, nearestDateWindowDays: 60 },
  /** BOLT-0012 (logical design "Data"): items are generated for a rolling horizon of this many IST days. */
  horizonDays: 14,
  /** GET /v1/me/plan/days: at most this many days per request. */
  maxDaysPerRequest: 62,
  /** §39: offline plan_item_status older than this is kept as study history only. */
  offlineMaxAgeDays: 7,
  /** Size of one generated item (minutes). Same for every exam (R1). */
  itemMinutes: { lesson: 10, litCheck: 5, minBlock: 5, mockMin: 20, checklist: 10 },
} as const;
