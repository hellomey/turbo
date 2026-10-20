import type { ErrorCode } from "@heymey/contracts";

/**
 * The only error type domain code throws on purpose. The API maps it 1:1 to the error envelope
 * (blueprint §37), so `code` must be one of the stable contract codes.
 */
export class DomainError extends Error {
  constructor(
    readonly code: ErrorCode,
    readonly details?: Record<string, unknown>,
  ) {
    super(code);
    this.name = "DomainError";
  }
}
