/**
 * Public API of the `exam-hall` module. OMR/CBT mocks, State Mock Sunday, scoring, reports.
 * Export use cases and types only. Never export repositories or Prisma models.
 * Design: aidlc/construction/units/U-exam-hall/. Built in BOLT-0011.
 */
import type { PrismaClient } from "@heymey/db";
import type { Clock } from "../../shared/clock.js";
import type { EventPublisher } from "../../shared/ports.js";
import { createQuestionReader } from "../content/index.js";
import { createExamCatalogueModule } from "../exams/index.js";
import { getAttempt, saveAnswers, startAttempt, type AnswerInput } from "./application/attempts.js";
import { listMocks, stateMockInfo } from "./application/mocks.js";
import type {
  Entitlements,
  ExamHallDeps,
  ExamHallRepository,
  MockAnswersSavedDto,
  MockAttemptListItemDto,
  MockAttemptStateDto,
  MockListDto,
  MockReportDto,
  PaperSource,
  QuestionSource,
  StateMockInfoDto,
  StatewideRankDto,
} from "./application/ports.js";
import { expireOverdueAttempts, publishDueRanks, statewideRank } from "./application/ranks.js";
import { getReport, history, submitAttempt } from "./application/results.js";
import type { AttemptMode } from "./domain/types.js";
import { examsPaperSource } from "./infrastructure/exams-paper-source.js";
import { PrismaExamHallRepository } from "./infrastructure/prisma-exam-hall-repository.js";

export const ExamHallModule = { name: "exam-hall" } as const;

export { EXAM_HALL_CONFIG } from "./domain/config.js";
export type { AnswerInput } from "./application/attempts.js";
export type { Entitlements, ExamHallRepository, PaperSource, QuestionSource } from "./application/ports.js";

export interface ExamHallApi {
  listMocks(userId: string, examCode: string): Promise<MockListDto>;
  start(userId: string, mockId: string, mode: AttemptMode): Promise<MockAttemptStateDto>;
  get(userId: string, attemptId: string): Promise<MockAttemptStateDto>;
  saveAnswers(userId: string, attemptId: string, answers: AnswerInput[]): Promise<MockAnswersSavedDto>;
  submit(userId: string, attemptId: string): Promise<MockReportDto>;
  report(userId: string, attemptId: string): Promise<MockReportDto>;
  history(userId: string, cursor: string | null, limit: number): Promise<{ items: MockAttemptListItemDto[]; nextCursor: string | null }>;
  stateMockSunday(examCode: string): Promise<StateMockInfoDto>;
  statewideRank(userId: string, mockId: string): Promise<StatewideRankDto>;
  /** Worker `exam-hall.expire`. */
  expireOverdue(): Promise<{ expired: number }>;
  /** Worker `exam-hall.publish-ranks`. */
  publishRanks(): Promise<{ mocks: number; rows: number }>;
}

/** Until `billing` lands (Phase 3) everyone is a free user: allowance applies, full report is locked (§11). */
export const FREE_FOR_EVERYONE: Entitlements = { isPro: async () => false };

export type ExamHallModuleDeps = (
  | { prisma: PrismaClient }
  | { repository: ExamHallRepository; papers: PaperSource; questions: QuestionSource }
) & { clock: Clock; entitlements?: Entitlements; events?: EventPublisher };

export function createExamHallModule(deps: ExamHallModuleDeps): ExamHallApi {
  const d: ExamHallDeps =
    "prisma" in deps
      ? {
          repo: new PrismaExamHallRepository(deps.prisma),
          papers: examsPaperSource(createExamCatalogueModule({ prisma: deps.prisma })),
          questions: createQuestionReader({ prisma: deps.prisma }),
          entitlements: deps.entitlements ?? FREE_FOR_EVERYONE,
          clock: deps.clock,
          ...(deps.events ? { events: deps.events } : {}),
        }
      : {
          repo: deps.repository,
          papers: deps.papers,
          questions: deps.questions,
          entitlements: deps.entitlements ?? FREE_FOR_EVERYONE,
          clock: deps.clock,
          ...(deps.events ? { events: deps.events } : {}),
        };
  return {
    listMocks: (u, e) => listMocks(d, u, e),
    start: (u, m, mode) => startAttempt(d, u, m, mode),
    get: (u, a) => getAttempt(d, u, a),
    saveAnswers: (u, a, x) => saveAnswers(d, u, a, x),
    submit: (u, a) => submitAttempt(d, u, a),
    report: (u, a) => getReport(d, u, a),
    history: (u, c, l) => history(d, u, c, l),
    stateMockSunday: (e) => stateMockInfo(d, e),
    statewideRank: (u, m) => statewideRank(d, u, m),
    expireOverdue: () => expireOverdueAttempts(d),
    publishRanks: () => publishDueRanks(d),
  };
}
