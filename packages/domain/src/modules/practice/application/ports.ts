import type { Clock, EventPublisher } from "../../../shared/index.js";
import type { EntitlementReader } from "../../billing/index.js";
import type { PracticeContentApi } from "../../content/index.js";
import type { PracticeModeValue } from "../domain/limit.js";
import type { Tally } from "../domain/mistakes.js";

/** Ports of the `practice` use cases (U-practice logical design). Adapters: infrastructure/ (Prisma), apps (composition). */

export interface SessionRecord {
  id: string;
  userId: string;
  mode: PracticeModeValue;
  examCode: string;
  questionIds: string[];
  startedAt: Date;
  closedAt: Date | null;
}

export interface NewSession {
  userId: string;
  mode: PracticeModeValue;
  examCode: string;
  subjectCode: string | null;
  topicId: string | null;
  drillId: string | null;
  questionIds: string[];
  startedAt: Date;
}

export interface StoredAnswer {
  id: string;
  userId: string;
  /** Offline/replay dedupe key: unique per (userId, clientActionId), not global (SEC-P2-L2). */
  clientActionId: string;
  sessionId: string | null;
  questionId: string;
  questionVersion: number;
  topicId: string;
  mode: PracticeModeValue;
  chosenOptionIds: string[];
  correct: boolean;
  answeredAt: Date;
  istDay: string;
  countsToLimit: boolean;
  studyLogOnly: boolean;
}

export interface NewAnswer extends Omit<StoredAnswer, "id"> {
  timeMs: number;
  confidence: string | null;
  source: "online" | "offline_sync";
}

/** What the transaction sees under its row locks. */
export interface AnswerTxState {
  counted: number;
  limitSheetShown: boolean;
  tally: Tally | null;
  hasOpenDrill: boolean;
}

/** What the use case decided from that state. */
export interface AnswerPlan {
  /** Increment the day counter (counted mode under the limit). */
  count: boolean;
  /** Online answer over the limit: store nothing, mark the limit sheet as shown (inv. 1, 12). */
  refuse: boolean;
  /** Offline answer over the limit: store as study log only (inv. 5). */
  studyLogOnly: boolean;
  /** New tally for a wrong answer (null = correct, no change). */
  tally: Tally | null;
  drill: { reason: string; questionIds: string[] } | null;
}

export type CommitOutcome =
  | { kind: "stored"; plan: AnswerPlan }
  | { kind: "duplicate"; answer: StoredAnswer }
  | { kind: "refused"; sheetFirstTime: boolean };

export interface MistakeRow {
  questionId: string;
  questionVersion: number;
  topicId: string;
  chosenOptionIds: string[];
  lastWrongAt: Date;
  wrongCount: number;
}

export interface DrillRecord {
  id: string;
  userId: string;
  topicId: string;
  reason: string;
  questionIds: string[];
  status: "open" | "done";
  createdAt: Date;
}

export interface PracticeRepository {
  /** Creates the session and closes the user's other open sessions (state machine "new session -> closed"). */
  createSession(s: NewSession): Promise<SessionRecord>;
  getSession(id: string): Promise<SessionRecord | null>;
  findAnswer(userId: string, clientActionId: string): Promise<StoredAnswer | null>;
  /**
   * ONE transaction (inv. 3): lock the (user, istDay) counter row, call `decide`, then insert the answer, bump the
   * counter, update the tally, open a drill, close a full session. A replayed (userId, clientActionId) returns `duplicate` (inv. 6).
   */
  commitAnswer(a: NewAnswer, decide: (s: AnswerTxState) => AnswerPlan): Promise<CommitOutcome>;
  dayCounter(userId: string, istDay: string): Promise<{ counted: number; limitSheetShown: boolean } | null>;
  tallies(userId: string): Promise<(Tally & { topicId: string })[]>;
  /** Questions whose latest answer is wrong, newest first, keyset after (lastWrongAt, questionId). */
  mistakes(userId: string, q: { topicIds?: readonly string[] | undefined; after?: { at: Date; questionId: string } | undefined; take: number }): Promise<MistakeRow[]>;
  drills(userId: string): Promise<DrillRecord[]>;
  getDrill(id: string): Promise<DrillRecord | null>;
}

export interface PracticeDeps {
  repo: PracticeRepository;
  content: PracticeContentApi;
  billing: EntitlementReader;
  clock: Clock;
  events: EventPublisher;
}
