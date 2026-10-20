import type { z } from "@heymey/contracts";
import { DomainError } from "@heymey/domain/shared";

/**
 * Validate a request part with the CONTRACT's schema. Controllers call this on body/params/query, so
 * the API accepts exactly what the OpenAPI document (and the Dart client) describe.
 */
export function parse<S extends z.ZodType>(schema: S, value: unknown): z.infer<S> {
  const result = schema.safeParse(value);
  if (!result.success) {
    throw new DomainError("VALIDATION_FAILED", {
      issues: result.error.issues.map((i) => ({ path: i.path.join("."), message: i.message })),
    });
  }
  return result.data;
}
