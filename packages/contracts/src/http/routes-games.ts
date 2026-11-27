import { z } from "../zod.js";
import { ErrorEnvelope } from "../errors.js";
import type { HmRoute } from "./common.js";
import { ConfidenceDuel, ConfidenceDuelQuery, DailySpinResult, DailySpinState, DuelResult, GameRules, SubmitDuelBody } from "./games.js";

const json = <T extends z.ZodType>(schema: T) => ({ content: { "application/json": { schema } } });
const err = (description: string) => ({ description, ...json(ErrorEnvelope) });
const authErrors = { 400: err("Validation failed"), 401: err("Not signed in"), 403: err("Not allowed"), 429: err("Rate limited (see Retry-After)") };
const idempotency = z.object({ "idempotency-key": z.uuid() });
const bearer = [{ bearerAuth: [] }];
const perUser = (limit: number, windowSeconds: number) => [{ scope: "user" as const, limit, windowSeconds }];

/** Games: Daily Spin, solo Confidence Duel, Game Rules & Odds (BOLT-0115). No route takes a stake. */
export const gamesRoutes: HmRoute[] = [
  {
    method: "get", path: "/v1/games/rules", tags: ["games"], operationId: "getGameRules",
    auth: "public", idempotent: false,
    summary: "Game Rules & Odds: the Daily Spin prize table with exact odds, Confidence Duel scoring, limits and sleep hours.",
    responses: { 200: { description: "Rules", ...json(GameRules) }, 429: err("Rate limited") },
  },
  {
    method: "get", path: "/v1/games/daily-spin", tags: ["games"], operationId: "getDailySpin",
    auth: "user", idempotent: false, security: bearer,
    summary: "The published prize table with exact odds, and whether today's free spin is used.",
    responses: { 200: { description: "Spin state", ...json(DailySpinState) }, ...authErrors },
  },
  {
    method: "post", path: "/v1/games/daily-spin", tags: ["games"], operationId: "spinDailySpin",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(20, 3600),
    summary: "Today's one free spin (IST day). The server draws with a CSPRNG. A second call the same day returns the same prize.",
    request: { headers: idempotency },
    responses: { 200: { description: "Prize", ...json(DailySpinResult) }, 409: err("Games are sleeping (12 AM to 5 AM IST)"), ...authErrors },
  },
  {
    method: "get", path: "/v1/games/confidence-duel", tags: ["games"], operationId: "startConfidenceDuel",
    auth: "user", idempotent: false, security: bearer,
    rateLimit: perUser(60, 3600),
    summary: "Start a solo duel against the clock: 5 published practice questions (no answers) and the scoring rules.",
    request: { query: ConfidenceDuelQuery },
    responses: { 200: { description: "Duel", ...json(ConfidenceDuel) }, 404: err("Exam not found"), 409: err("Sleeping or not enough questions"), ...authErrors },
  },
  {
    method: "post", path: "/v1/games/confidence-duel/{duelId}/submit", tags: ["games"], operationId: "submitConfidenceDuel",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(60, 3600),
    summary: "Submit answers with a confidence (1 to 3) each. The server grades and scores calibration; Points are capped per day.",
    request: { headers: idempotency, params: z.object({ duelId: z.uuid() }), body: json(SubmitDuelBody) },
    responses: { 200: { description: "Graded", ...json(DuelResult) }, 404: err("Duel not found"), 409: err("Already submitted"), ...authErrors },
  },
];
