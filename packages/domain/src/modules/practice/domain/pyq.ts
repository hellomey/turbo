import { DomainError } from "../../../shared/index.js";
import { PRACTICE_CONFIG } from "./config.js";

/**
 * PYQ Vault rules (blueprint §11 "PYQ: latest years free", §19.4; U-practice invariant 10). Pure.
 * Free users see full items only for the latest N exam years held for that exam; older years are `locked`.
 */
export function unlockedYears(yearsHeld: readonly number[], entitled: boolean): ReadonlySet<number> {
  const sorted = [...new Set(yearsHeld)].sort((a, b) => b - a);
  return new Set(entitled ? sorted : sorted.slice(0, PRACTICE_CONFIG.pyqFreeLatestYears));
}

/** Keyset cursor over (year desc, id asc). Opaque base64url for the client. */
export function encodeCursor(c: { year: number; id: string }): string {
  return Buffer.from(`${c.year}:${c.id}`, "utf8").toString("base64url");
}

export function decodeCursor(raw: string | undefined): { year: number; id: string } | undefined {
  if (!raw) return undefined;
  const [y, id] = Buffer.from(raw, "base64url").toString("utf8").split(":");
  const year = Number(y);
  if (!Number.isInteger(year) || !id || !/^[0-9a-f-]{36}$/i.test(id)) throw new DomainError("VALIDATION_FAILED", { field: "cursor" });
  return { year, id };
}

/** A locked item carries no stem or option text (inv. 10): only facts the filter already shows. */
export function lockQuestion<T extends { stem: string; options: unknown[]; affectedNote: string | null }>(q: T): T {
  return { ...q, stem: "", options: [], affectedNote: null };
}
