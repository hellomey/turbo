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
  sundayReport: { cron: "0 8 * * 0", aiNotes: false },
} as const;
