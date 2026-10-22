import { type ArgumentsHost, Catch, type ExceptionFilter, HttpException, Logger } from "@nestjs/common";
import type { FastifyReply, FastifyRequest } from "fastify";
import { ERROR_CODES, type ErrorCode, type ErrorEnvelope } from "@heymey/contracts";
import { DomainError } from "@heymey/domain/shared";

const STATUS: Partial<Record<ErrorCode, number>> = {
  VALIDATION_FAILED: 400,
  IDEMPOTENCY_KEY_REQUIRED: 400,
  IDEMPOTENCY_KEY_REUSED: 422,
  IDEMPOTENCY_IN_PROGRESS: 409,
  IDEMPOTENT_RESPONSE_UNAVAILABLE: 409,
  TOTP_LOCKED: 429,
  TOTP_INVALID: 400,
  UNAUTHENTICATED: 401,
  SESSION_REVOKED: 401,
  CHALLENGE_EXPIRED: 401,
  DESK_2FA_REQUIRED: 401,
  FORBIDDEN: 403,
  DESK_NOT_ALLOWED: 403,
  FIREWALL_VIOLATION: 403,
  NOT_FOUND: 404,
  EXAM_NOT_FOUND: 404,
  LESSON_NOT_FOUND: 404,
  UNDER_18: 422,
  CONSENT_REQUIRED: 422,
  APP_UPDATE_REQUIRED: 426,
  RATE_LIMITED: 429,
  OTP_LOCKED: 429,
  PRACTICE_DAILY_LIMIT: 429,
  AI_LIMIT_REACHED: 429,
  RANKED_DAILY_CAP: 429,
  // BOLT-0014: Exam Alerts webhook + Desk review (U-exams logical design, failure modes)
  WEBHOOK_UNAUTHORIZED: 401,
  WEBHOOK_REPLAYED: 409,
  EXAM_CHANGE_ALREADY_REVIEWED: 409,
  INTERNAL_ERROR: 500,
  FEATURE_PAUSED: 503,
  AI_BUSY: 503,
};

/** Every error leaves the API in the one envelope format (blueprint §37). Unknown errors never leak details. */
@Catch()
export class DomainErrorFilter implements ExceptionFilter {
  private readonly log = new Logger("errors");

  catch(exception: unknown, host: ArgumentsHost): void {
    const reply = host.switchToHttp().getResponse<FastifyReply>();
    const req = host.switchToHttp().getRequest<FastifyRequest>();

    let code: ErrorCode;
    let status: number;
    let details: Record<string, unknown> | undefined;

    if (exception instanceof DomainError) {
      code = exception.code;
      status = STATUS[code] ?? 400;
      details = exception.details;
    } else if (exception instanceof HttpException) {
      status = exception.getStatus();
      code = status === 404 ? "NOT_FOUND" : status === 401 ? "UNAUTHENTICATED" : status === 403 ? "FORBIDDEN" : status === 429 ? "RATE_LIMITED" : status >= 500 ? "INTERNAL_ERROR" : "VALIDATION_FAILED";
    } else if (isFastifyClientError(exception)) {
      // Malformed JSON, wrong content type, body too large...
      status = exception.statusCode;
      code = "VALIDATION_FAILED";
    } else {
      // Database errors can echo values (emails, codes): redact before logging (SEC-L5).
      const raw = exception instanceof Error ? (exception.stack ?? exception.message) : String(exception);
      this.log.error({ requestId: req.id, err: redactForLog(raw) });
      status = 500;
      code = "INTERNAL_ERROR";
      details = { requestId: String(req.id) };
    }

    if (code === "RATE_LIMITED" && typeof details?.retryAfterSeconds === "number") {
      void reply.header("Retry-After", String(details.retryAfterSeconds));
    }
    const body: ErrorEnvelope = { error: { code, message: ERROR_CODES[code], ...(details ? { details } : {}) } };
    void reply.status(status).send(body);
  }
}

/** Strips emails and 6-digit codes from text that may end up in logs. */
export function redactForLog(text: string): string {
  return text.replace(/[\w.+-]+@[\w-]+(\.[\w-]+)+/g, "[email]").replace(/\b\d{6}\b/g, "[code]");
}

function isFastifyClientError(e: unknown): e is { statusCode: number } {
  const s = (e as { statusCode?: unknown })?.statusCode;
  return typeof s === "number" && s >= 400 && s < 500;
}
