import type { Role } from "@heymey/contracts";
import type { PrismaClient } from "@heymey/db";
import type { RoleRepository } from "../application/roles-service.js";
import { isRole } from "../domain/roles.js";

export class PrismaRoleRepository implements RoleRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async activeRoles(userId: string): Promise<Role[]> {
    const rows = await this.prisma.roleAssignment.findMany({ where: { userId, revokedAt: null }, select: { role: true } });
    return rows.map((r) => String(r.role)).filter(isRole);
  }

  async grantIfAbsent(input: { userId: string; role: Role; grantedBy: string; scopeId?: string | null }): Promise<boolean> {
    // Serialised per user so two concurrent grants of the same role cannot both insert.
    return this.prisma.$transaction(async (tx) => {
      await tx.$executeRaw`SELECT pg_advisory_xact_lock(hashtext(${`role:${input.userId}`}))`;
      const existing = await tx.roleAssignment.findFirst({
        where: { userId: input.userId, role: input.role, revokedAt: null, scopeId: input.scopeId ?? null },
        select: { id: true },
      });
      if (existing) return false;
      await tx.roleAssignment.create({
        data: { userId: input.userId, role: input.role, grantedBy: input.grantedBy, scopeId: input.scopeId ?? null },
      });
      return true;
    });
  }
}
