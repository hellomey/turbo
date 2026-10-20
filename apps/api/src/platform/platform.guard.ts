import { type CanActivate, type ExecutionContext, Inject, Injectable } from "@nestjs/common";
import { DEFAULT_RATE_LIMIT, DESK_ROLES } from "@heymey/contracts";
import { DomainError, type RateLimiter } from "@heymey/domain/shared";
import type { AccessTokenVerifier, HmRequest } from "./request-context.js";
import { policyFor } from "./route-policy.js";
import { ACCESS_TOKEN_VERIFIER, RATE_LIMITER } from "./tokens.js";

/**
 * IPv4 as-is; IPv6 bucketed per /64 (one subscriber usually owns a whole /64, so per-address limits are trivial
 * to dodge, SEC-H1). IPv4-mapped IPv6 ("::ffff:1.2.3.4") counts as the IPv4 address.
 */
export function rateLimitIpKey(ip: string): string {
  const mapped = /^::ffff:(\d+\.\d+\.\d+\.\d+)$/i.exec(ip);
  if (mapped?.[1]) return mapped[1];
  if (!ip.includes(":")) return ip;
  const [head = "", tail = ""] = ip.toLowerCase().split("::");
  const left = head ? head.split(":") : [];
  const right = tail ? tail.split(":") : [];
  const full = [...left, ...Array<string>(Math.max(0, 8 - left.length - right.length)).fill("0"), ...right];
  return `${full.slice(0, 4).map((h) => h.replace(/^0+(?=.)/, "")).join(":")}::/64`;
}

/**
 * Runs before every handler. Everything comes from the contract (@heymey/contracts `routes`):
 *  1. the route must exist in the contract (otherwise it is a bug: 500 in tests, NOT_FOUND here),
 *  2. authentication per `auth` level: public | optional | user | desk,
 *  3. rate limits: DEFAULT_RATE_LIMIT + the route's own rules (per IP or per user), in Valkey.
 * Hiding a button is never security (blueprint §16): this guard is.
 */
@Injectable()
export class PlatformGuard implements CanActivate {
  constructor(
    @Inject(ACCESS_TOKEN_VERIFIER) private readonly verifier: AccessTokenVerifier,
    @Inject(RATE_LIMITER) private readonly limiter: RateLimiter,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const req = context.switchToHttp().getRequest<HmRequest>();
    const route = policyFor(req.method, req.routeOptions.url);
    if (!route) throw new DomainError("NOT_FOUND");
    req.hmRoute = route;

    if (route.auth !== "public") {
      const header = req.headers.authorization;
      const token = header?.startsWith("Bearer ") ? header.slice(7).trim() : undefined;
      const auth = token ? await this.verifier.verify(token) : null;
      if (auth) req.auth = auth;
      if (route.auth === "user" && !auth) throw new DomainError("UNAUTHENTICATED");
      if (route.auth === "desk") {
        if (!auth) throw new DomainError("UNAUTHENTICATED");
        if (!auth.isDesk) throw new DomainError("DESK_2FA_REQUIRED");
        if (!auth.roles.some((r) => DESK_ROLES.includes(r))) throw new DomainError("DESK_NOT_ALLOWED");
      }
    }

    for (const rule of [DEFAULT_RATE_LIMIT, ...(route.rateLimit ?? [])]) {
      const who = rule.scope === "user" && req.auth ? `u:${req.auth.userId}` : `ip:${rateLimitIpKey(req.ip)}`;
      const key = `rl:${route.method}:${route.path}:${rule.limit}/${rule.windowSeconds}:${who}`;
      const { allowed, retryAfterSeconds } = await this.limiter.hit(key, rule.limit, rule.windowSeconds);
      if (!allowed) throw new DomainError("RATE_LIMITED", { retryAfterSeconds });
    }
    return true;
  }
}
