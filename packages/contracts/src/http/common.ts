import type { RouteConfig } from "@asteasolutions/zod-to-openapi";
import { z } from "../zod.js";

/** Required on every state-changing POST/PUT/PATCH (blueprint §34.3, §37). Stored with the response for 24h. */
export const IDEMPOTENCY_HEADER = "Idempotency-Key";
/** Sent on every response. Older apps show "Update needed". */
export const MIN_APP_VERSION_HEADER = "X-Min-App-Version";
export const API_VERSION_PREFIX = "/v1";

export const IdempotencyKey = z.uuid().openapi({ description: "Client-generated UUID" });

export const CursorQuery = z.object({
  cursor: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export const cursorPage = <T extends z.ZodType>(item: T) =>
  z.object({ items: z.array(item), nextCursor: z.string().nullable() });

/** All timestamps on the wire are UTC ISO-8601. */
export const Timestamp = z.iso.datetime();
/** Calendar dates (date of birth, exam dates) are YYYY-MM-DD. */
export const CalendarDate = z.iso.date();

/**
 * Who may call a route. Enforced by the API platform from THIS list, so the contract and the
 * enforcement can never disagree (apps/api/src/platform/route-policy.ts).
 *   public    no token needed
 *   optional  token used if present (anonymous allowed)
 *   user      a valid app or Desk session
 *   desk      a Desk session (email OTP + TOTP) with a staff or partner role
 */
export type RouteAuth = "public" | "optional" | "user" | "desk";

export interface RateLimitRule {
  scope: "ip" | "user";
  limit: number;
  windowSeconds: number;
}

export interface HmRoute extends RouteConfig {
  auth: RouteAuth;
  /** State-changing routes require an Idempotency-Key. Pure computations sent as POST set this to false. */
  idempotent: boolean;
  rateLimit?: RateLimitRule[];
  /**
   * The success response carries secrets (tokens, TOTP seeds). The idempotency store then keeps only a
   * fingerprint, never the body: a replayed key gets IDEMPOTENT_RESPONSE_UNAVAILABLE (SEC-M2).
   */
  sensitiveResponse?: boolean;
}

/** Applied to every route on top of its own rules. */
export const DEFAULT_RATE_LIMIT: RateLimitRule = { scope: "ip", limit: 300, windowSeconds: 60 };
