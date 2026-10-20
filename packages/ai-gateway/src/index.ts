/**
 * AI gateway (blueprint §20.4). Design contract only; the implementation is built in the week-3 bolt.
 *
 * - One OpenRouter key, server-side only. Never shipped in the app.
 * - Per-task model lists live in the database (AiModelRoute, owned by the `ai` module) so they change
 *   without a release. Each call sends OpenRouter's `models: [primary, ...fallbacks]`.
 * - Provider preferences: providers that do not retain or train on our data.
 * - No names, emails, phone numbers or other personal data ever reach a model (`redact` runs first).
 * - Shared outputs (explanations) are generated ONCE per question and cached, never per user.
 * - Monthly budget cap with alerts at 50% / 80% / 100%.
 * - AI never publishes on its own: content needs a cited source + a verifier on a DIFFERENT model family + human checks.
 */

export const AI_TASKS = [
  "explain_question", // offline, bulk, once per question
  "verify_answer", // offline, different model family from the writer
  "doubt_help", // live, streamed (Free 3/month, Pro 30/day)
  "moderate_text", // live, small fast model
  "weekly_report", // nightly batch
] as const;
export type AiTask = (typeof AI_TASKS)[number];

export interface ModelRoute {
  task: AiTask;
  models: [primary: string, ...fallbacks: string[]];
  maxOutputTokens: number;
  temperature: number;
  /** Writer and verifier must differ; enforced when routes are saved from the Desk. */
  modelFamily: string;
}

export interface AiRequest {
  task: AiTask;
  /** Already redacted. Question + context only. */
  messages: { role: "system" | "user" | "assistant"; content: string }[];
  /** Stable key for shareable outputs, e.g. `explain:<questionVersionId>`. */
  cacheKey?: string;
  /** Pseudonymous id for per-user limits. Never sent to the provider. */
  subjectId?: string;
}

export interface AiResponse {
  text: string;
  model: string;
  cached: boolean;
  costMicroUsd: number;
}

export interface AiGateway {
  complete(req: AiRequest): Promise<AiResponse>;
  stream(req: AiRequest): AsyncIterable<string>;
}

/** Thrown when every model in the route failed or the budget is exhausted. Callers degrade gracefully (AI_BUSY). */
export class AiUnavailableError extends Error {
  constructor(readonly reason: "all_models_failed" | "budget_exhausted" | "user_limit") {
    super(reason);
    this.name = "AiUnavailableError";
  }
}

/** Strip obvious personal data before anything leaves the server. Extended in the AI bolt. */
export function redact(text: string): string {
  return text
    .replace(/[\w.+-]+@[\w-]+\.[\w.-]+/g, "[email]")
    .replace(/(?:\+91[\s-]?)?[6-9]\d{9}\b/g, "[phone]");
}
