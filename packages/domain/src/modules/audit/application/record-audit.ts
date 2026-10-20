import { type AuditEntry, validateAuditEntry } from "../domain/audit-entry.js";

/** Port: where audit entries are appended. */
export interface AuditRepository {
  append(entry: AuditEntry): Promise<void>;
}

export async function recordAudit(repo: AuditRepository, entry: AuditEntry): Promise<void> {
  await repo.append(validateAuditEntry(entry));
}
