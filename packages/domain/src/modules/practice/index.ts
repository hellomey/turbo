/**
 * Public API of the `practice` module. Practice sessions, free daily limit, mistake loop.
 * Export use cases and types only. Never export repositories or Prisma models.
 * Design: aidlc/construction/units/U-practice/. Blueprint §10.6, §11, §13, §19.4, §19.6 Q60, §37, §39.
 */
import type { PrismaClient } from "@heymey/db";
import type { Clock, EventPublisher } from "../../shared/index.js";
import type { EntitlementReader } from "../billing/index.js";
import type { PracticeContentApi } from "../content/index.js";
import type { PracticeDeps, PracticeRepository } from "./application/ports.js";
import {
  acceptOfflineAnswer,
  answer,
  getUsage,
  listDrills,
  listMistakes,
  pyqFacets,
  searchPyqs,
  startSession,
  type ConceptDrillListDto,
  type MistakePageDto,
  type PracticeAnswerInput,
  type PracticeAnswerResultDto,
  type PracticeSessionDto,
  type PracticeSyncAction,
  type PracticeSyncResultDto,
  type PyqFacetsDto,
  type PyqPageDto,
  type PyqQueryInput,
  type StartPracticeInput,
} from "./application/practice-service.js";
import type { PracticeUsageDto } from "./domain/limit.js";
import { PrismaPracticeRepository } from "./infrastructure/prisma-practice-repository.js";
import { PrismaExpoRepository } from "./infrastructure/prisma-expo-repository.js";
import {
  myStickerCode,
  redeemStickerCode,
  startChallenge,
  submitChallenge,
  type ExpoChallengeDto,
  type ExpoChallengeResultDto,
  type ExpoDeps,
  type ExpoQuestions,
  type ExpoRepository,
  type MyStickerCodeDto,
  type RedeemTxHook,
  type StickerCodeRedeemedDto,
  type SubmitExpoChallengeInput,
} from "./application/expo-service.js";

export const PracticeModule = { name: "practice" } as const;

export { PRACTICE_CONFIG } from "./domain/config.js";
export { dailyLimitFor, decideCount, isCountedMode, judgedAnswerTime, nextIstMidnight, usageOf } from "./domain/limit.js";
export type { CountDecision, PracticeModeValue, PracticeUsageDto } from "./domain/limit.js";
export { addWrong, drillDue, drillReason, isWeak, type Tally } from "./domain/mistakes.js";
export { decodeCursor, encodeCursor, lockQuestion, unlockedYears } from "./domain/pyq.js";
export type {
  AnswerPlan,
  AnswerTxState,
  CommitOutcome,
  DrillRecord,
  MistakeRow,
  NewAnswer,
  NewSession,
  PracticeRepository,
  SessionRecord,
  StoredAnswer,
} from "./application/ports.js";
export type {
  ConceptDrillListDto,
  MistakePageDto,
  PracticeAnswerInput,
  PracticeAnswerResultDto,
  PracticeSessionDto,
  PracticeSyncAction,
  PracticeSyncResultDto,
  PyqFacetsDto,
  PyqPageDto,
  PyqQueryInput,
  StartPracticeInput,
} from "./application/practice-service.js";

export interface PracticeApi {
  startSession(userId: string, body: StartPracticeInput): Promise<PracticeSessionDto>;
  answer(userId: string, sessionId: string, body: PracticeAnswerInput): Promise<PracticeAnswerResultDto>;
  /** One offline `practice_answer` from the sync dispatcher (§39). */
  syncAnswer(userId: string, action: PracticeSyncAction): Promise<PracticeSyncResultDto>;
  usage(userId: string): Promise<PracticeUsageDto>;
  mistakes(userId: string, q: { cursor?: string | undefined; limit: number }): Promise<MistakePageDto>;
  drills(userId: string): Promise<ConceptDrillListDto>;
  searchPyqs(userId: string, q: PyqQueryInput): Promise<PyqPageDto>;
  pyqFacets(userId: string, examCode: string): Promise<PyqFacetsDto>;
}

const noEvents: EventPublisher = { publish: async () => undefined };

export function createPracticeModule(
  deps: ({ prisma: PrismaClient } | { repository: PracticeRepository }) & {
    clock: Clock;
    content: PracticeContentApi;
    billing: EntitlementReader;
    events?: EventPublisher;
  },
): PracticeApi {
  const d: PracticeDeps = {
    repo: "repository" in deps ? deps.repository : new PrismaPracticeRepository(deps.prisma),
    content: deps.content,
    billing: deps.billing,
    clock: deps.clock,
    events: deps.events ?? noEvents,
  };
  return {
    startSession: (userId, body) => startSession(d, userId, body),
    answer: (userId, sessionId, body) => answer(d, userId, sessionId, body),
    syncAnswer: (userId, action) => acceptOfflineAnswer(d, userId, action),
    usage: (userId) => getUsage(d, userId),
    mistakes: (userId, q) => listMistakes(d, userId, q),
    drills: (userId) => listDrills(d, userId),
    searchPyqs: (userId, q) => searchPyqs(d, userId, q),
    pyqFacets: (userId, examCode) => pyqFacets(d, userId, examCode),
  };
}

// ---------------------------------------------------------------- stall: expo challenge + sticker codes (BOLT-0112)
export { EXPO_CONFIG, STICKER_ALPHABET, canRedeemStickerCodes, gradeExpo, newStickerCode, normalizeStickerCode } from "./domain/expo.js";
export type { StickerReason } from "./domain/expo.js";
export type {
  ExpoChallengeDto,
  ExpoChallengeRecord,
  ExpoChallengeResultDto,
  ExpoQuestions,
  ExpoRepository,
  MyStickerCodeDto,
  RedeemOutcome,
  RedeemTxHook,
  StickerCodeRedeemedDto,
  SubmitExpoChallengeInput,
} from "./application/expo-service.js";

export interface ExpoApi {
  startChallenge(userId: string): Promise<ExpoChallengeDto>;
  submit(userId: string, challengeId: string, body: SubmitExpoChallengeInput): Promise<ExpoChallengeResultDto>;
  myStickerCode(userId: string): Promise<MyStickerCodeDto>;
  /** Staff only (role checked by the caller with `canRedeemStickerCodes`). `inTx` writes the audit row. */
  redeem(staffUserId: string, code: string, inTx?: RedeemTxHook): Promise<StickerCodeRedeemedDto>;
}

export function createExpoModule(
  deps: ({ prisma: PrismaClient } | { repository: ExpoRepository }) & {
    clock: Clock;
    randomInt: (maxExclusive: number) => number;
    /** content: published questions of a named set, with keys (server-side grading). */
    questions: ExpoQuestions;
    /** mastery: has the user lit (or gilded) any lamp. */
    lamps: { hasLitLamp(userId: string): Promise<boolean> };
  },
): ExpoApi {
  const d: ExpoDeps = {
    repo: "repository" in deps ? deps.repository : new PrismaExpoRepository(deps.prisma),
    questions: deps.questions,
    lamps: deps.lamps,
    clock: deps.clock,
    randomInt: deps.randomInt,
  };
  return {
    startChallenge: (userId) => startChallenge(d, userId),
    submit: (userId, id, body) => submitChallenge(d, userId, id, body),
    myStickerCode: (userId) => myStickerCode(d, userId),
    redeem: (staff, code, inTx) => redeemStickerCode(d, staff, code, inTx),
  };
}
