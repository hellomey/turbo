import { DESK_ROLES, ROLES, type Role } from "@heymey/contracts";

/** Desk access = at least one staff or partner role (blueprint §15). Aspirants never qualify. */
export function canUseDesk(roles: readonly Role[]): boolean {
  return roles.some((r) => DESK_ROLES.includes(r));
}

/** Distinct roles in contract order, so tokens and `Me` are stable. */
export function sortRoles(roles: readonly Role[]): Role[] {
  const set = new Set(roles);
  return ROLES.filter((r) => set.has(r));
}

export function isRole(value: string): value is Role {
  return (ROLES as readonly string[]).includes(value);
}
