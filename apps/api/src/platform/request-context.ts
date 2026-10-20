import type { FastifyRequest } from "fastify";
import type { HmRoute, Role } from "@heymey/contracts";
import type { Actor } from "@heymey/domain/shared";

/** Who is calling, established by PlatformGuard from the access token. */
export interface AuthContext {
  userId: string;
  sessionId: string;
  roles: Role[];
  isDesk: boolean;
}

export interface AccessTokenVerifier {
  /** Returns null for any invalid, expired or revoked token. Never throws for bad input. */
  verify(token: string): Promise<AuthContext | null>;
}

export type HmRequest = FastifyRequest & { auth?: AuthContext; hmRoute?: HmRoute };

/** The authenticated caller, or a 401 if the route forgot to require auth (defensive). */
export function requireAuth(req: HmRequest): AuthContext {
  if (!req.auth) throw new Error("requireAuth on a route without auth: fix the contract's `auth` level");
  return req.auth;
}

/** Actor for the audit log. */
export function actorOf(req: HmRequest): Actor {
  return {
    userId: req.auth?.userId ?? null,
    role: req.auth ? (req.auth.roles[0] ?? "ASPIRANT") : "VISITOR",
    ip: req.ip,
    requestId: String(req.id),
  };
}
