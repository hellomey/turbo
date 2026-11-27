import type { ConfidenceDuel, DailySpinResult, DailySpinState, DuelResult, GameRules, SubmitDuelBody, z } from "@heymey/contracts";
import { DomainError, istDayKey, type Clock } from "../../../shared/index.js";
import { assertGameEntry, assertGameReward } from "../../economy/index.js";
import type { QuestionDto, QuestionWithKey } from "../../content/index.js";
import { isCorrect } from "../../content/index.js";
import { DUEL_RULES, duelAward, duelPoints, type Confidence } from "../domain/confidence-duel.js";
import { DAILY_SPIN_ODDS, SPIN_TOTAL_WEIGHT, drawSpin, spinOdds, spinPrizeById } from "../domain/daily-spin.js";
import { GAME_LIMITS, gamesAreSleeping } from "../domain/limits.js";

export interface SpinRow {
  userId: string;
  day: string;
  prizeId: string;
  amount: number;
  roll: number;
  oddsVersion: number;
  createdAt: Date;
}

export interface DuelRow {
  id: string;
  userId: string;
  examCode: string;
  questions: { questionId: string; version: number }[];
  startedAt: Date;
  submittedAt: Date | null;
  pointsAwarded: number;
  result: unknown;
}

/** Port: games storage. Adapter: infrastructure/. */
export interface GamesRepository {
  spinOf(userId: string, day: string): Promise<SpinRow | null>;
  /** false = this user already has a spin that IST day (unique (userId, day)). */
  insertSpin(row: SpinRow): Promise<boolean>;
  createDuel(d: Omit<DuelRow, "id" | "submittedAt" | "pointsAwarded" | "result">): Promise<string>;
  duel(id: string): Promise<DuelRow | null>;
  /** false = already submitted (only an open duel is finished). */
  finishDuel(id: string, f: { submittedAt: Date; pointsAwarded: number; result: unknown }): Promise<boolean>;
  duelPointsBetween(userId: string, from: Date, to: Date): Promise<number>;
}

/** Port: the games -> economy firewall API. Points only; idempotent per `sourceKey`. */
export interface GameRewardsPort {
  awardPoints(a: { userId: string; game: string; amount: number; sourceKey: string }): Promise<boolean>;
}

/** Port: published practice questions from `content`, and their keys at the version served. */
export interface DuelQuestionsPort {
  pick(examCode: string, count: number): Promise<QuestionDto[]>;
  keys(refs: readonly { questionId: string; version: number }[]): Promise<QuestionWithKey[]>;
}

export interface GamesDeps {
  repo: GamesRepository;
  clock: Clock;
  rewards: GameRewardsPort;
  questions: DuelQuestionsPort;
  /** CSPRNG (node:crypto randomInt in apps), never Math.random. */
  randomInt: (maxExclusive: number) => number;
}

const IST_MS = 330 * 60_000;
const HOUR_MS = 3_600_000;
const DAY_MS = 24 * HOUR_MS;
const istMidnight = (day: string) => new Date(Date.parse(`${day}T00:00:00.000Z`) - IST_MS);
const WAKE_HOUR = 5;

function nextSpinAt(now: Date, spunToday: boolean): Date {
  const today = istMidnight(istDayKey(now));
  const wakeToday = new Date(today.getTime() + WAKE_HOUR * HOUR_MS);
  if (gamesAreSleeping(now)) return wakeToday;
  return spunToday ? new Date(wakeToday.getTime() + DAY_MS) : now;
}

async function award(d: GamesDeps, userId: string, game: string, amount: number, sourceKey: string): Promise<void> {
  if (amount <= 0) return;
  assertGameReward({ kind: "currency", currency: "POINTS", amount });
  await d.rewards.awardPoints({ userId, game, amount, sourceKey });
}

export function rules(): z.infer<typeof GameRules> {
  return {
    prizeCurrencies: ["POINTS"],
    stake: "none",
    sleep: { from: "00:00", to: `0${WAKE_HOUR}:00`, timeZone: "Asia/Kolkata" },
    dailySpin: { oddsVersion: DAILY_SPIN_ODDS.version, spinsPerDay: GAME_LIMITS.freeSpinsPerDay, prizes: spinOdds() },
    confidenceDuel: duelRules(),
  };
}

function duelRules() {
  const { scoring, ...rest } = DUEL_RULES;
  return { ...rest, scoring: scoring.map((r) => ({ ...r })) };
}

export async function dailySpinState(d: GamesDeps, userId: string): Promise<z.infer<typeof DailySpinState>> {
  const now = d.clock.now();
  const spin = await d.repo.spinOf(userId, istDayKey(now));
  return {
    oddsVersion: DAILY_SPIN_ODDS.version,
    prizes: spinOdds(),
    spunToday: spin !== null,
    todaysPrize: spin ? spinPrizeById(spin.prizeId) : null,
    nextSpinAt: nextSpinAt(now, spin !== null).toISOString(),
    asleep: gamesAreSleeping(now),
  };
}

/**
 * Today's free spin. The server draws with the CSPRNG; the spin row is the idempotency record (one per user per IST
 * day). Points are credited after the row exists with a per-day source key, so a retry after a failed credit heals it
 * without a second draw and never pays twice.
 */
export async function spin(d: GamesDeps, userId: string): Promise<z.infer<typeof DailySpinResult>> {
  assertGameEntry(null);
  const now = d.clock.now();
  if (gamesAreSleeping(now)) throw new DomainError("GAMES_SLEEPING");
  const day = istDayKey(now);
  let row = await d.repo.spinOf(userId, day);
  let alreadySpun = row !== null;
  if (!row) {
    const roll = d.randomInt(SPIN_TOTAL_WEIGHT);
    const prize = drawSpin(roll);
    const fresh: SpinRow = { userId, day, prizeId: prize.id, amount: prize.amount, roll, oddsVersion: DAILY_SPIN_ODDS.version, createdAt: now };
    if (await d.repo.insertSpin(fresh)) row = fresh;
    else {
      // Lost a race with a parallel request: that request's draw stands.
      row = await d.repo.spinOf(userId, day);
      alreadySpun = true;
    }
  }
  /* c8 ignore next */
  if (!row) throw new DomainError("INTERNAL_ERROR");
  await award(d, userId, "daily_spin", row.amount, `daily_spin:${userId}:${day}`);
  const prize = spinPrizeById(row.prizeId);
  /* c8 ignore next */
  if (!prize) throw new DomainError("INTERNAL_ERROR", { prizeId: row.prizeId });
  return { prize, oddsVersion: row.oddsVersion, odds: spinOdds(), nextSpinAt: nextSpinAt(now, true).toISOString(), alreadySpun };
}

async function pointsToday(d: GamesDeps, userId: string, now: Date): Promise<number> {
  const from = istMidnight(istDayKey(now));
  return d.repo.duelPointsBetween(userId, from, new Date(from.getTime() + DAY_MS));
}

export async function startDuel(d: GamesDeps, userId: string, examCode: string): Promise<z.infer<typeof ConfidenceDuel>> {
  assertGameEntry(null);
  const now = d.clock.now();
  if (gamesAreSleeping(now)) throw new DomainError("GAMES_SLEEPING");
  const questions = await d.questions.pick(examCode, DUEL_RULES.questionsPerDuel);
  if (questions.length < DUEL_RULES.questionsPerDuel) throw new DomainError("DUEL_NO_QUESTIONS", { examCode });
  const duelId = await d.repo.createDuel({ userId, examCode, questions: questions.map((q) => ({ questionId: q.id, version: q.version })), startedAt: now });
  return { duelId, examCode, startedAt: now.toISOString(), questions, rules: duelRules(), pointsToday: await pointsToday(d, userId, now) };
}

/**
 * Grade on the server with server time. Too fast, too late (past the limit plus the reconnect grace) or over today's
 * cap: still graded, Points withheld. shortcut: two submits racing at the cap edge can each see the old total and pass
 * the cap by at most one duel's score; move the cap check into the finishDuel transaction if that is ever seen.
 */
export async function submitDuel(d: GamesDeps, userId: string, duelId: string, body: z.infer<typeof SubmitDuelBody>): Promise<z.infer<typeof DuelResult>> {
  const now = d.clock.now();
  const duel = await d.repo.duel(duelId);
  if (!duel || duel.userId !== userId) throw new DomainError("DUEL_NOT_FOUND");
  if (duel.submittedAt) throw new DomainError("DUEL_ALREADY_SUBMITTED");

  const chosen = new Map<string, { optionId: string; confidence: Confidence }>();
  for (const a of body.answers) if (!chosen.has(a.questionId)) chosen.set(a.questionId, { optionId: a.optionId, confidence: a.confidence as Confidence });
  const keys = new Map((await d.questions.keys(duel.questions)).map((k) => [k.key.questionId, k.key]));

  const results: z.infer<typeof DuelResult>["results"] = [];
  for (const ref of duel.questions) {
    const key = keys.get(ref.questionId);
    if (!key) continue;
    const a = chosen.get(ref.questionId);
    const correct = a ? isCorrect(key.correctOptionIds, [a.optionId]) : false;
    results.push({
      questionId: ref.questionId,
      correct,
      correctOptionIds: [...key.correctOptionIds],
      chosenOptionId: a?.optionId ?? null,
      confidence: a?.confidence ?? null,
      explanationMarkdown: key.explanationMarkdown,
      points: duelPoints(correct, a?.confidence ?? null),
    });
  }
  const score = results.reduce((s, r) => s + r.points, 0);
  const before = await pointsToday(d, userId, now);
  const { points, withheld } = duelAward(score, now.getTime() - duel.startedAt.getTime(), before);
  const out = { duelId, results, score, pointsAwarded: points, pointsWithheld: withheld, pointsToday: before + points, dailyPointsCap: DUEL_RULES.dailyPointsCap };
  if (!(await d.repo.finishDuel(duelId, { submittedAt: now, pointsAwarded: points, result: out }))) throw new DomainError("DUEL_ALREADY_SUBMITTED");
  await award(d, userId, "confidence_duel", points, `confidence_duel:${duelId}`);
  return out;
}
