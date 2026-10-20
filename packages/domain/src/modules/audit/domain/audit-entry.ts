import { DomainError } from "../../../shared/errors.js";
import type { Actor } from "../../../shared/ports.js";

/** One staff/system action. Append-only: never updated, never deleted (blueprint §15, §36). */
export interface AuditEntry {
  actor: Actor;
  /** dotted lower-case verb, e.g. "role.grant", "auth.session_revoked", "odds.publish" */
  action: string;
  target?: string;
  before?: unknown;
  after?: unknown;
}

const ACTION = /^[a-z][a-z_]*(\.[a-z][a-z_]*)+$/;
/** Fields that must never be written into the audit log (personal data / secrets). Exact key names, any case. */
const FORBIDDEN_KEYS =
  /^(email|emailAddress|phone|phoneNumber|mobile|code|otp|password|token|refreshToken|accessToken|secret|dateOfBirth|dob)$/i;
const MAX_DEPTH = 6;

/** First forbidden key anywhere in a value (objects and arrays, nested), or undefined. QA finding Q-1. */
function findForbiddenKey(value: unknown, depth = 0): string | undefined {
  if (!value || typeof value !== "object" || depth > MAX_DEPTH) return undefined;
  if (Array.isArray(value)) {
    for (const item of value) {
      const hit = findForbiddenKey(item, depth + 1);
      if (hit) return hit;
    }
    return undefined;
  }
  for (const [key, child] of Object.entries(value)) {
    if (FORBIDDEN_KEYS.test(key)) return key;
    const hit = findForbiddenKey(child, depth + 1);
    if (hit) return hit;
  }
  return undefined;
}

export function validateAuditEntry(entry: AuditEntry): AuditEntry {
  if (!ACTION.test(entry.action)) throw new DomainError("VALIDATION_FAILED", { field: "action", value: entry.action });
  for (const side of [entry.before, entry.after]) {
    const bad = findForbiddenKey(side);
    if (bad) throw new DomainError("VALIDATION_FAILED", { field: bad, reason: "personal data or secret in audit log" });
  }
  return entry;
}
