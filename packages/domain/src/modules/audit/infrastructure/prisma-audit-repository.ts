import type { Prisma, PrismaClient } from "@heymey/db";
import type { AuditRepository } from "../application/record-audit.js";
import type { AuditEntry } from "../domain/audit-entry.js";

const json = (v: unknown) => (v === undefined ? undefined : (JSON.parse(JSON.stringify(v)) as object));

export class PrismaAuditRepository implements AuditRepository {
  constructor(private readonly prisma: PrismaClient | Prisma.TransactionClient) {}

  async append(entry: AuditEntry): Promise<void> {
    await this.prisma.auditLog.create({
      data: {
        actorId: entry.actor.userId,
        actorRole: entry.actor.role,
        action: entry.action,
        target: entry.target ?? null,
        before: json(entry.before),
        after: json(entry.after),
        ip: entry.actor.ip ?? null,
        requestId: entry.actor.requestId ?? null,
      },
    });
  }
}
