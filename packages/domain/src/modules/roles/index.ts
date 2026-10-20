/**
 * Public API of the `roles` module. Role assignments and server-side permission checks (blueprint §15, §16).
 * Export use cases and types only. Never export repositories or Prisma models.
 */
import type { Role } from "@heymey/contracts";
import type { PrismaClient } from "@heymey/db";
import type { AuditApi } from "../audit/index.js";
import { grantRole, rolesOf, userCanUseDesk, type GrantRoleInput, type RoleRepository } from "./application/roles-service.js";
import { PrismaRoleRepository } from "./infrastructure/prisma-role-repository.js";

export const RolesModule = { name: "roles" } as const;

export type { GrantRoleInput, RoleRepository } from "./application/roles-service.js";
export { canUseDesk } from "./domain/roles.js";

export interface RolesApi {
  /** Active roles in contract order. */
  rolesOf(userId: string): Promise<Role[]>;
  /** Grant a role (no-op if already held). Audited as `role.grant`. Returns true if newly granted. */
  grant(input: GrantRoleInput): Promise<boolean>;
  canUseDesk(userId: string): Promise<boolean>;
}

export function createRolesModule(
  deps: ({ prisma: PrismaClient } | { repository: RoleRepository }) & { audit: AuditApi },
): RolesApi {
  const repo = "repository" in deps ? deps.repository : new PrismaRoleRepository(deps.prisma);
  return {
    rolesOf: (userId) => rolesOf(repo, userId),
    grant: (input) => grantRole(repo, deps.audit, input),
    canUseDesk: (userId) => userCanUseDesk(repo, userId),
  };
}
