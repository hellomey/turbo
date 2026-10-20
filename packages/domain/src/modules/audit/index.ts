/**
 * Public API of the `audit` module: append-only audit log of every staff and system action.
 *
 * REFERENCE IMPLEMENTATION of the module pattern every module follows:
 *   domain/          pure rules           (validateAuditEntry)
 *   application/     use cases + ports    (recordAudit, AuditRepository)
 *   infrastructure/  adapters             (PrismaAuditRepository)
 *   index.ts         a factory taking its dependencies and returning a small API object.
 * Apps call `createAuditModule({ prisma })` once in their composition root and pass the result to
 * the modules that declare `audit` in module.json.
 */
import type { PrismaClient } from "@heymey/db";
import { recordAudit, type AuditRepository } from "./application/record-audit.js";
import type { AuditEntry } from "./domain/audit-entry.js";
import { PrismaAuditRepository } from "./infrastructure/prisma-audit-repository.js";

export const AuditModule = { name: "audit" } as const;

export type { AuditEntry } from "./domain/audit-entry.js";
export type { AuditRepository } from "./application/record-audit.js";

export interface AuditApi {
  record(entry: AuditEntry): Promise<void>;
}

export function createAuditModule(deps: { prisma: PrismaClient } | { repository: AuditRepository }): AuditApi {
  const repo = "repository" in deps ? deps.repository : new PrismaAuditRepository(deps.prisma);
  return { record: (entry) => recordAudit(repo, entry) };
}
