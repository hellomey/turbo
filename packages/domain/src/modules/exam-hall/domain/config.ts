/** Every tunable number for `exam-hall` (§9.9, §11, §19.4). PROVISIONAL, founder to confirm (D-2026-10-22-21 ... -24). */
export const EXAM_HALL_CONFIG = {
  version: "2026-10-22.1",
  /** Q12: free = 1 full mock per IST calendar month + every State Mock Sunday. */
  freeFullMocksPerIstMonth: 1,
  /** Q13: 1st and 3rd Sunday (IST). Times are IST minutes after midnight. Exact dates/times live on Mock rows (data). */
  stateMockSunday: { sundaysOfMonth: [1, 3] as const, opensAtMinute: 10 * 60, lateJoinMinutes: 30, practiceUntilMinute: 23 * 60 + 59, rankPublishMinute: 20 * 60 },
  /** Q25: start needs a connection; answers arriving after the deadline + grace are ignored; any late answer = unranked. */
  answerGraceSeconds: 120,
  rankedRequiresOnTimeAnswers: true,
  /** Display rounding only; scores are exact fractions. */
  scoreDisplayDecimals: 2,
} as const;
