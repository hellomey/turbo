import type { Role } from "@heymey/contracts";
import type { Actor } from "../../../shared/ports.js";
import type { AuditApi } from "../../audit/index.js";
import { canUseDesk, sortRoles } from "../domain/roles.js";

/** Port: active role assignments. */
export interface RoleRepository {
  /** Active (not revoked) roles of a user, any order. */
  activeRoles(userId: string): Promise<Role[]>;
  /** Creates an active assignment unless one exists. Returns true if a row was created. */
  grantIfAbsent(input: { userId: string; role: Role; grantedBy: string; scopeId?: string | null }): Promise<boolean>;
}

export interface GrantRoleInput {
  userId: string;
  role: Role;
  /** Who grants. `actor.userId` null = the system (e.g. sign-up); then the user id is recorded as grantor. */
  actor: Actor;
  scopeId?: string | null;
}

export async function rolesOf(repo: RoleRepository, userId: string): Promise<Role[]> {
  return sortRoles(await repo.activeRoles(userId));
}

export async function grantRole(repo: RoleRepository, audit: AuditApi, input: GrantRoleInput): Promise<boolean> {
  const created = await repo.grantIfAbsent({
    userId: input.userId,
    role: input.role,
    grantedBy: input.actor.userId ?? input.userId,
    scopeId: input.scopeId ?? null,
  });
  if (created) {
    await audit.record({ actor: input.actor, action: "role.grant", target: `user:${input.userId}`, after: { role: input.role } });
  }
  return created;
}

export async function userCanUseDesk(repo: RoleRepository, userId: string): Promise<boolean> {
  return canUseDesk(await repo.activeRoles(userId));
}
