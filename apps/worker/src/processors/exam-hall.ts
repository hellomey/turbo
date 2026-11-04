/**
 * `exam-hall.expire` (every 5 min) and `exam-hall.publish-ranks` (every 10 min), owner: exam-hall (BOLT-0011).
 * Each calls one use case; both are idempotent (finish only in_progress; rank rows inserted once).
 */
export interface ExamHallJobs {
  expireOverdue(): Promise<{ expired: number }>;
  publishRanks(): Promise<{ mocks: number; rows: number }>;
}

export function createExamHallExpireProcessor(hall: Pick<ExamHallJobs, "expireOverdue">) {
  return async () => hall.expireOverdue();
}

export function createExamHallRanksProcessor(hall: Pick<ExamHallJobs, "publishRanks">) {
  return async () => hall.publishRanks();
}
