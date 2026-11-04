/** Every tunable number for `readiness` (§19.5). PROVISIONAL, founder to confirm (D-2026-10-22-29, -30). */
export const READINESS_CONFIG = {
  version: "2026-10-22.1",
  /** Q14: label rules, checked from the top. Percent of each bar's own evidence. Never one overall percentage. */
  labels: [
    { label: "mock_ready", minCoverage: 80, minMemory: 70, minExamPerformance: 60 },
    { label: "close", minCoverage: 60, minMemory: 50, minExamPerformance: null },
    { label: "building", minCoverage: 20, minMemory: null, minExamPerformance: null },
  ] as const,
  /** Q14: "Ready for full mocks" badge. */
  fullMocksBadge: { minCoverage: 60, minMemory: 50 },
  /** Exam performance uses the last N submitted mocks. */
  examPerformanceLastMocks: 3,
  freeBars: ["coverage", "memory"] as const,
  /** Q15: Sunday 08:00 IST, template text only in Phase 2 (AI notes need `ai`, Phase 3). */
  sundayReport: { cron: "0 8 * * 0", aiNotes: false, activeWithinDays: 14, batchSize: 500 },
  /** Q27: label rules are TN-only in Phase 2. Other exams show their bars with label not_yet until their wave. */
  labelledConductingBodies: ["TNPSC", "TNUSRB", "TRB"] as readonly string[],
  /** How far back the meter looks in mock history for this exam's last N submitted mocks. */
  mockHistoryScan: 50,
  /** Snapshots are kept 400 days (logical design "Data"). Trend windows (§19.5): 7, 30, 90 days. */
  snapshotRetentionDays: 400,
} as const;
