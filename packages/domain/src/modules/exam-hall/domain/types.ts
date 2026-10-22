import type { Fraction } from "./fraction.js";

/** Records the exam-hall use cases work with. Adapters map Prisma rows / other modules' APIs into these. */

export type MockKind = "full" | "sectional" | "state_mock_sunday";
export type AttemptStatus = "in_progress" | "submitted" | "expired";
export type AttemptMode = "omr" | "cbt";

export interface MockSectionRef {
  sectionCode: string;
  questionIds: string[];
}

export interface MockRecord {
  id: string;
  code: string;
  examCode: string;
  paperId: string;
  schemeVersion: number;
  title: string;
  kind: MockKind;
  sections: MockSectionRef[];
  opensAt: Date | null;
  lateJoinUntil: Date | null;
  closesAt: Date | null;
  rankPublishAt: Date | null;
  free: boolean;
  status: string;
}

/** One section of a paper's marking scheme (from `exams`, exact fractions). */
export interface SchemeSection {
  code: string;
  name: string;
  order: number;
  questionCount: number;
  attemptLimit: number | null;
  marksPerCorrect: Fraction;
  penaltyPerWrong: Fraction;
  minutes: number | null;
}

export interface SchemeView {
  version: number;
  status: string;
  durationMinutes: number;
  totalQuestions: number;
  sections: SchemeSection[];
}

/** What exam-hall needs to know about the paper a mock is built for (ExamsApi.paperForMock). */
export interface PaperView {
  examCode: string;
  paperCode: string;
  answerMode: "objective_omr" | "objective_cbt" | "descriptive";
  qualifyingOnly: boolean;
  /** Family rank scope label, e.g. "statewide" (R6). */
  rankScope: string;
  scheme: SchemeView;
}

export interface SavedAnswer {
  questionId: string;
  chosenOptionIds: string[];
  markedForReview: boolean;
  savedAt: Date;
  clientAt: Date;
}

export interface SectionScore {
  code: string;
  name: string;
  correct: number;
  wrong: number;
  unanswered: number;
  score: Fraction;
  maxScore: Fraction;
}

export interface AttemptScore {
  score: Fraction;
  maxScore: Fraction;
  correct: number;
  wrong: number;
  unanswered: number;
  sections: SectionScore[];
}

export interface AttemptRecord {
  id: string;
  userId: string;
  mockId: string;
  mode: AttemptMode;
  status: AttemptStatus;
  startedAt: Date;
  deadlineAt: Date;
  submittedAt: Date | null;
  ranked: boolean;
  schemeVersion: number;
  istMonth: string;
  result: AttemptScore | null;
}

/** The answer key for one question (from `content`). Never sent to the app while the attempt is open. */
export interface AnswerKey {
  questionId: string;
  topicId: string;
  correctOptionIds: string[];
}
