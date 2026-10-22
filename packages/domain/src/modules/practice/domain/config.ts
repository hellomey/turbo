/** Every tunable number for `practice` (§11, §13, §19.4). PROVISIONAL, founder to confirm (D-2026-10-22-17 ... -20). */
export const PRACTICE_CONFIG = {
  version: "2026-10-22.1",
  /** §11: free answers per IST day. Q8: only `practice` and `pyq` modes count (not checks, relights, Gold, mocks, drills). */
  freeDailyLimit: 30,
  countedModes: ["practice", "pyq"] as const,
  /** Q8: offline answers count on the IST day of clientAt, clamped to [serverNow - 7 days, serverNow]. Over the limit = study log only. */
  offlineClampDays: 7,
  /** §13: the limit sheet is shown at most once per IST day. Q10: no price line until Pro can be bought. */
  limitSheetPerDay: 1,
  showProPriceLine: false,
  /** Q9: drill after 3 wrong answers on the same lamp within 14 days; drills are Pro (billing stub = free -> locked). */
  mistakeLoop: { wrongCount: 3, windowDays: 14, drillQuestions: 8, proOnly: true },
  /** Q23: free users see the 2 most recent exam years held for that exam. */
  pyqFreeLatestYears: 2,
  sessionMaxQuestions: 50,
} as const;
