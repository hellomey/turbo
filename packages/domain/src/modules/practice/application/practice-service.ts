import type {
  ConceptDrillList,
  MistakePage,
  PracticeAnswerBody,
  PracticeAnswerResult,
  PracticeSession,
  PyqFacets,
  PyqPage,
  PyqQuery,
  StartPracticeBody,
  SyncAction,
  SyncActionResult,
  z,
} from "@heymey/contracts";
import { DomainError, istDayKey } from "../../../shared/index.js";
import { gradeWithKey, type GradedAnswerDto, type QuestionDto } from "../../content/index.js";
import { PRACTICE_CONFIG } from "../domain/config.js";
import { dailyLimitFor, decideCount, judgedAnswerTime, usageOf, type PracticeModeValue, type PracticeUsageDto } from "../domain/limit.js";
import { addWrong, drillDue, drillReason, isWeak } from "../domain/mistakes.js";
import { decodeCursor, encodeCursor, lockQuestion, unlockedYears } from "../domain/pyq.js";
import type { CommitOutcome, PracticeDeps, StoredAnswer } from "./ports.js";

/** Use cases of `practice` (blueprint §10.6, §11, §13, §19.4, §19.6 Q60, §39; U-practice logical design). */

export type StartPracticeInput = z.input<typeof StartPracticeBody>;
export type PracticeSessionDto = z.infer<typeof PracticeSession>;
export type PracticeAnswerInput = z.infer<typeof PracticeAnswerBody>;
export type PracticeAnswerResultDto = z.infer<typeof PracticeAnswerResult>;
export type MistakePageDto = z.infer<typeof MistakePage>;
export type ConceptDrillListDto = z.infer<typeof ConceptDrillList>;
export type PyqQueryInput = z.infer<typeof PyqQuery>;
export type PyqPageDto = z.infer<typeof PyqPage>;
export type PyqFacetsDto = z.infer<typeof PyqFacets>;
export type PracticeSyncAction = Extract<z.infer<typeof SyncAction>, { kind: "practice_answer" }>;
export type PracticeSyncResultDto = z.infer<typeof SyncActionResult>;

const WEAK_TOPICS_MAX = 5;

async function entitledOf(d: PracticeDeps, userId: string): Promise<boolean> {
  return (await d.billing.entitlementOf(userId)) === "pro";
}

async function usageNow(d: PracticeDeps, userId: string, entitled: boolean): Promise<PracticeUsageDto> {
  const now = d.clock.now();
  return usageOf(now, await d.repo.dayCounter(userId, istDayKey(now)), dailyLimitFor(entitled ? "pro" : "free"));
}

async function weakTopics(d: PracticeDeps, userId: string): Promise<string[]> {
  const now = d.clock.now();
  return (await d.repo.tallies(userId))
    .filter((t) => isWeak(t, now))
    .sort((a, b) => b.wrongCount - a.wrongCount || b.lastWrongAt.getTime() - a.lastWrongAt.getTime())
    .slice(0, WEAK_TOPICS_MAX)
    .map((t) => t.topicId);
}

/** GET /v1/me/practice/usage. */
export async function getUsage(d: PracticeDeps, userId: string): Promise<PracticeUsageDto> {
  return usageNow(d, userId, await entitledOf(d, userId));
}

/** POST /v1/practice/sessions: server-picked questions without answers (§34.1). */
export async function startSession(d: PracticeDeps, userId: string, body: StartPracticeInput): Promise<PracticeSessionDto> {
  const entitled = await entitledOf(d, userId);
  const size = Math.min(body.size ?? 10, PRACTICE_CONFIG.sessionMaxQuestions);
  let questions: QuestionDto[];
  let drillId: string | null = null;

  if (body.mode === "drill") {
    if (!body.drillId) throw new DomainError("VALIDATION_FAILED", { field: "drillId" });
    if (!entitled) throw new DomainError("PRO_REQUIRED");
    const drill = await d.repo.getDrill(body.drillId);
    if (!drill || drill.userId !== userId) throw new DomainError("NOT_FOUND");
    if (drill.status !== "open") throw new DomainError("PRACTICE_SESSION_CLOSED");
    drillId = drill.id;
    questions = await d.content.questions(drill.questionIds);
  } else {
    const topicIds = await d.content.scope({ examCode: body.examCode, subjectCode: body.subjectCode, topicId: body.topicId });
    if (body.mode === "practice") {
      questions = await d.content.pick({ topicIds, count: size });
    } else if (body.mode === "pyq") {
      const years = unlockedYears((await d.content.pyqYears(body.examCode)).map((y) => y.year), entitled);
      questions = years.size ? await d.content.pick({ topicIds, count: size, pyqExamCode: body.examCode, pyqYears: [...years] }) : [];
    } else {
      const rows = await d.repo.mistakes(userId, { topicIds, take: size });
      questions = await d.content.questions(rows.map((r) => r.questionId));
    }
  }

  const s = await d.repo.createSession({
    userId,
    mode: body.mode,
    examCode: body.examCode,
    subjectCode: body.subjectCode ?? null,
    topicId: body.topicId ?? null,
    drillId,
    questionIds: questions.map((q) => q.id),
    startedAt: d.clock.now(),
  });
  return {
    sessionId: s.id,
    mode: s.mode,
    examCode: s.examCode,
    questions,
    usage: await usageNow(d, userId, entitled),
    startedAt: s.startedAt.toISOString(),
  };
}

async function regrade(d: PracticeDeps, a: Pick<StoredAnswer, "questionId" | "questionVersion" | "chosenOptionIds">): Promise<GradedAnswerDto> {
  const [k] = await d.content.atVersion([{ questionId: a.questionId, version: a.questionVersion }]);
  if (!k) throw new DomainError("QUESTION_NOT_FOUND");
  return gradeWithKey(k.key, a.chosenOptionIds);
}

interface RecordInput {
  userId: string;
  clientActionId: string;
  sessionId: string | null;
  mode: PracticeModeValue;
  graded: GradedAnswerDto;
  questionVersion: number;
  timeMs: number;
  confidence: string | null;
  /** Offline only: the phone's time, clamped (inv. 5). */
  clientAt: Date | null;
}

/** The shared write path for online and offline answers (inv. 1-9). */
async function record(d: PracticeDeps, r: RecordInput, entitled: boolean): Promise<CommitOutcome> {
  const now = d.clock.now();
  const offline = r.clientAt !== null;
  const answeredAt = judgedAnswerTime(now, r.clientAt);
  const istDay = istDayKey(answeredAt);
  const limit = dailyLimitFor(entitled ? "pro" : "free");
  const topicId = r.graded.topicId;
  // Drill questions are picked outside the transaction (CSPRNG read); only Pro users can get a drill (inv. 9).
  const drillQuestionIds =
    !r.graded.correct && entitled
      ? (await d.content.pick({ topicIds: [topicId], count: PRACTICE_CONFIG.mistakeLoop.drillQuestions })).map((q) => q.id)
      : [];

  const outcome = await d.repo.commitAnswer(
    {
      clientActionId: r.clientActionId,
      userId: r.userId,
      sessionId: r.sessionId,
      questionId: r.graded.questionId,
      questionVersion: r.questionVersion,
      topicId,
      mode: r.mode,
      chosenOptionIds: r.graded.chosenOptionIds,
      correct: r.graded.correct,
      answeredAt,
      istDay,
      countsToLimit: false,
      studyLogOnly: false,
      timeMs: r.timeMs,
      confidence: r.confidence,
      source: offline ? "offline_sync" : "online",
    },
    (s) => {
      const decision = decideCount(r.mode, s.counted, limit);
      const over = decision === "over_limit";
      if (over && !offline) return { count: false, refuse: true, studyLogOnly: false, tally: null, drill: null };
      const tally = r.graded.correct ? null : addWrong(s.tally, answeredAt);
      const drill = tally && drillQuestionIds.length && drillDue(tally, entitled, s.hasOpenDrill) ? { reason: drillReason(tally), questionIds: drillQuestionIds } : null;
      return { count: decision === "count", refuse: false, studyLogOnly: over, tally, drill };
    },
  );

  if (outcome.kind === "stored") {
    await d.events.publish({
      type: "practice.answered",
      occurredAt: now,
      payload: { userId: r.userId, topicId, correct: r.graded.correct, mode: r.mode, istDay, counted: outcome.plan.count },
    });
  }
  return outcome;
}

/** POST /v1/practice/sessions/{sessionId}/answers: grade on the server, count atomically (§11, §34.1, §37). */
export async function answer(d: PracticeDeps, userId: string, sessionId: string, body: PracticeAnswerInput): Promise<PracticeAnswerResultDto> {
  const session = await d.repo.getSession(sessionId);
  if (!session || session.userId !== userId) throw new DomainError("NOT_FOUND");
  const entitled = await entitledOf(d, userId);

  // Dedupe is per (userId, clientActionId) (SEC-P2-L2), so a replay is always this user's own answer.
  const replay = async (a: StoredAnswer): Promise<PracticeAnswerResultDto> => {
    return { graded: await regrade(d, a), usage: await usageNow(d, userId, entitled), weakTopicIds: await weakTopics(d, userId) };
  };

  const existing = await d.repo.findAnswer(userId, body.clientActionId);
  if (existing) return replay(existing);
  if (session.closedAt) throw new DomainError("PRACTICE_SESSION_CLOSED");
  if (!session.questionIds.includes(body.questionId)) throw new DomainError("QUESTION_NOT_FOUND");
  const graded = await regrade(d, { questionId: body.questionId, questionVersion: body.questionVersion, chosenOptionIds: body.chosenOptionIds });

  const outcome = await record(
    d,
    {
      userId,
      clientActionId: body.clientActionId,
      sessionId,
      mode: session.mode,
      graded,
      questionVersion: body.questionVersion,
      timeMs: body.timeMs,
      confidence: body.confidence ?? null,
      clientAt: null,
    },
    entitled,
  );
  if (outcome.kind === "duplicate") return replay(outcome.answer);
  if (outcome.kind === "refused") {
    const usage = await usageNow(d, userId, entitled);
    throw new DomainError("PRACTICE_DAILY_LIMIT", { usage, showLimitSheet: outcome.sheetFirstTime, showProPriceLine: PRACTICE_CONFIG.showProPriceLine });
  }
  return { graded, usage: await usageNow(d, userId, entitled), weakTopicIds: await weakTopics(d, userId) };
}

/** Offline outbox `practice_answer` (§39, inv. 5, 6): accepted once; over the day's limit = study log only, no error. */
export async function acceptOfflineAnswer(d: PracticeDeps, userId: string, a: PracticeSyncAction): Promise<PracticeSyncResultDto> {
  const res = (status: PracticeSyncResultDto["status"], errorCode: PracticeSyncResultDto["errorCode"] = null): PracticeSyncResultDto => ({
    clientActionId: a.clientActionId,
    status,
    errorCode,
  });
  if (await d.repo.findAnswer(userId, a.clientActionId)) return res("duplicate");
  const entitled = await entitledOf(d, userId);
  if (a.mode === "drill" && !entitled) return res("rejected", "PRO_REQUIRED");
  const [k] = await d.content.atVersion([{ questionId: a.questionId, version: a.questionVersion }]);
  if (!k) return res("rejected", "QUESTION_NOT_FOUND");
  const outcome = await record(
    d,
    {
      userId,
      clientActionId: a.clientActionId,
      sessionId: null,
      mode: a.mode,
      graded: gradeWithKey(k.key, a.chosenOptionIds),
      questionVersion: a.questionVersion,
      timeMs: a.timeMs,
      confidence: null,
      clientAt: new Date(a.clientAt),
    },
    entitled,
  );
  if (outcome.kind === "duplicate") return res("duplicate");
  if (outcome.kind === "stored" && outcome.plan.studyLogOnly) return res("study_log_only", "PRACTICE_DAILY_LIMIT");
  return res("accepted");
}

/** GET /v1/me/mistakes: why mine was wrong, why the answer is right, which lamp to relight (§19.4 Q38). */
export async function listMistakes(d: PracticeDeps, userId: string, q: { cursor?: string | undefined; limit: number }): Promise<MistakePageDto> {
  const after = decodeMistakeCursor(q.cursor);
  const rows = await d.repo.mistakes(userId, { after, take: q.limit + 1 });
  const page = rows.slice(0, q.limit);
  const keys = new Map(
    (await d.content.atVersion(page.map((r) => ({ questionId: r.questionId, version: r.questionVersion })))).map((k) => [
      `${k.question.id}:${k.question.version}`,
      k,
    ]),
  );
  const items = page.flatMap((r) => {
    const k = keys.get(`${r.questionId}:${r.questionVersion}`);
    if (!k) return [];
    return [
      {
        questionId: r.questionId,
        topicId: r.topicId,
        stem: k.question.stem,
        wrongCount: r.wrongCount,
        lastWrongAt: r.lastWrongAt.toISOString(),
        graded: gradeWithKey(k.key, r.chosenOptionIds),
      },
    ];
  });
  const last = page[page.length - 1];
  return { items, nextCursor: rows.length > q.limit && last ? encodeMistakeCursor(last.lastWrongAt, last.questionId) : null };
}

function encodeMistakeCursor(at: Date, questionId: string): string {
  return Buffer.from(`${at.toISOString()}|${questionId}`, "utf8").toString("base64url");
}

function decodeMistakeCursor(raw: string | undefined): { at: Date; questionId: string } | undefined {
  if (!raw) return undefined;
  const [iso, questionId] = Buffer.from(raw, "base64url").toString("utf8").split("|");
  const at = new Date(iso ?? "");
  if (Number.isNaN(at.getTime()) || !questionId || !/^[0-9a-f-]{36}$/i.test(questionId)) throw new DomainError("VALIDATION_FAILED", { field: "cursor" });
  return { at, questionId };
}

/** GET /v1/me/drills: Pro feature (§19.6 Q60). Free users see `locked: true`. */
export async function listDrills(d: PracticeDeps, userId: string): Promise<ConceptDrillListDto> {
  const entitled = await entitledOf(d, userId);
  const items = (await d.repo.drills(userId)).map((x) => ({
    id: x.id,
    topicId: x.topicId,
    reason: x.reason,
    questionCount: Math.max(1, x.questionIds.length),
    createdAt: x.createdAt.toISOString(),
    status: x.status,
  }));
  return { items, locked: !entitled };
}

/** GET /v1/pyq: PYQ Vault with filters; older years locked for Free (inv. 10). */
export async function searchPyqs(d: PracticeDeps, userId: string, q: PyqQueryInput): Promise<PyqPageDto> {
  const scoped = q.subjectCode !== undefined || q.topicId !== undefined;
  const topicIds = await d.content.scope({ examCode: q.examCode, subjectCode: q.subjectCode, topicId: q.topicId });
  const unlocked = unlockedYears((await d.content.pyqYears(q.examCode)).map((y) => y.year), await entitledOf(d, userId));
  const rows = await d.content.pyqPage({
    examCode: q.examCode,
    topicIds: scoped ? topicIds : undefined,
    year: q.year,
    difficulty: q.difficulty,
    after: decodeCursor(q.cursor),
    take: q.limit + 1,
  });
  const page = rows.slice(0, q.limit);
  const items = page.map((r) => {
    const locked = !unlocked.has(r.year);
    return { question: locked ? lockQuestion(r.question) : r.question, locked };
  });
  const last = page[page.length - 1];
  return { items, nextCursor: rows.length > q.limit && last ? encodeCursor({ year: last.year, id: last.question.id }) : null };
}

/** GET /v1/pyq/facets: years (with lock flags) and subjects for the filter chips. */
export async function pyqFacets(d: PracticeDeps, userId: string, examCode: string): Promise<PyqFacetsDto> {
  await d.content.scope({ examCode });
  const years = await d.content.pyqYears(examCode);
  const unlocked = unlockedYears(years.map((y) => y.year), await entitledOf(d, userId));
  return {
    examCode,
    years: years.map((y) => ({ year: y.year, count: y.count, locked: !unlocked.has(y.year) })),
    subjects: await d.content.pyqSubjects(examCode),
  };
}
