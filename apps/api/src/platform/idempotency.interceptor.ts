import { createHash } from "node:crypto";
import { type CallHandler, type ExecutionContext, Inject, Injectable, type NestInterceptor } from "@nestjs/common";
import type { FastifyReply } from "fastify";
import { type Observable, from, of, switchMap, tap, catchError, throwError } from "rxjs";
import { DomainError } from "@heymey/domain/shared";
import type { HmRequest } from "./request-context.js";
import { successStatus } from "./route-policy.js";
import { IDEMPOTENCY_STORE } from "./tokens.js";
import type { ValkeyIdempotencyStore } from "./valkey.js";

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const TTL_SECONDS = 24 * 60 * 60;

/**
 * Every state-changing route (contract `idempotent: true`) requires an Idempotency-Key (blueprint §34.3, §37):
 *  - first request: runs, and the response is stored for 24h,
 *  - same key + same body again: the stored response is replayed (no second effect),
 *  - same key + different body: IDEMPOTENCY_KEY_REUSED,
 *  - same key while the first is still running: IDEMPOTENCY_IN_PROGRESS.
 * Keys are scoped to the caller (user, else IP) and the route.
 */
@Injectable()
export class IdempotencyInterceptor implements NestInterceptor {
  constructor(@Inject(IDEMPOTENCY_STORE) private readonly store: ValkeyIdempotencyStore) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const req = context.switchToHttp().getRequest<HmRequest>();
    const reply = context.switchToHttp().getResponse<FastifyReply>();
    const route = req.hmRoute;
    if (!route?.idempotent) return next.handle();

    const key = req.headers["idempotency-key"];
    if (typeof key !== "string" || !UUID.test(key)) throw new DomainError("IDEMPOTENCY_KEY_REQUIRED");

    const scope = `${req.auth ? `u:${req.auth.userId}` : `ip:${req.ip}`}:${route.method}:${route.path}`;
    const hash = createHash("sha256").update(JSON.stringify(req.body ?? null)).digest("hex");

    return from(this.store.begin(scope, key, hash)).pipe(
      switchMap((state) => {
        if (state.kind === "replay") {
          // Secret-bearing responses were never stored (SEC-M2): the client must start the flow again.
          if (route.sensitiveResponse) throw new DomainError("IDEMPOTENT_RESPONSE_UNAVAILABLE");
          void reply.status(state.status).header("Idempotent-Replayed", "true");
          return of(state.body);
        }
        if (state.kind === "conflict") throw new DomainError("IDEMPOTENCY_KEY_REUSED");
        if (state.kind === "in_progress") throw new DomainError("IDEMPOTENCY_IN_PROGRESS");
        return next.handle().pipe(
          tap(
            (body) =>
              void this.store.complete(scope, key, hash, successStatus(route), route.sensitiveResponse ? null : (body ?? null), TTL_SECONDS),
          ),
          catchError((err: unknown) => from(this.store.abandon(scope, key)).pipe(switchMap(() => throwError(() => err)))),
        );
      }),
    );
  }
}
