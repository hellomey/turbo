import { describe, expect, it, vi } from "vitest";
import { createAuditModule, type AuditEntry } from "../../src/modules/audit/index.js";

const actor = { userId: "0192f0c4-0000-7000-8000-000000000001", role: "ADMIN" };

describe("audit (unit)", () => {
  it("appends a valid entry", async () => {
    const rows: AuditEntry[] = [];
    const audit = createAuditModule({ repository: { append: async (e) => void rows.push(e) } });
    await audit.record({ actor, action: "role.grant", target: "user:x", after: { role: "OPS" } });
    expect(rows).toHaveLength(1);
  });

  it("rejects a malformed action", async () => {
    const audit = createAuditModule({ repository: { append: async () => {} } });
    await expect(audit.record({ actor, action: "Grant Role" })).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
  });

  it("refuses personal data or secrets in before/after", async () => {
    const audit = createAuditModule({ repository: { append: async () => {} } });
    await expect(audit.record({ actor, action: "user.update", after: { email: "a@b.c" } })).rejects.toMatchObject({
      code: "VALIDATION_FAILED",
    });
  });
});

// BOLT-0006 QA additions. Blueprint §15 (Desk audit trail), §30 (no personal data where it is not needed), §36 (audit module).
describe("audit action format (dotted lower-case verb)", () => {
  const rows: AuditEntry[] = [];
  const audit = createAuditModule({ repository: { append: async (e) => void rows.push(e) } });

  it.each(["role.grant", "auth.session_revoked", "odds.publish", "billing.refund.override", "seed.run"])(
    "accepts %s",
    async (action) => {
      await expect(audit.record({ actor, action })).resolves.toBeUndefined();
    },
  );

  it.each(["grant", "Role.grant", "role.Grant", "role.", ".grant", "role..grant", "role.grant-1", "1role.grant", "role grant", ""])(
    "rejects %j with VALIDATION_FAILED on field action",
    async (action) => {
      await expect(audit.record({ actor, action })).rejects.toMatchObject({
        code: "VALIDATION_FAILED",
        details: { field: "action", value: action },
      });
    },
  );
});

describe("audit personal-data guard", () => {
  const forbidden = ["email", "code", "otp", "password", "token", "refreshToken", "accessToken", "secret", "dateOfBirth"];

  it.each(forbidden)("refuses %s in after", async (key) => {
    const append = vi.fn(async () => {});
    const audit = createAuditModule({ repository: { append } });
    await expect(audit.record({ actor, action: "user.update", after: { [key]: "x" } })).rejects.toMatchObject({
      code: "VALIDATION_FAILED",
      details: { field: key, reason: "personal data or secret in audit log" },
    });
    expect(append).not.toHaveBeenCalled();
  });

  it.each(forbidden)("refuses %s in before", async (key) => {
    const audit = createAuditModule({ repository: { append: async () => {} } });
    await expect(audit.record({ actor, action: "user.update", before: { [key]: "x" } })).rejects.toMatchObject({
      code: "VALIDATION_FAILED",
    });
  });

  it("the key check is case-insensitive", async () => {
    const audit = createAuditModule({ repository: { append: async () => {} } });
    for (const key of ["EMAIL", "Password", "REFRESHTOKEN", "DateOfBirth"]) {
      await expect(audit.record({ actor, action: "user.update", after: { [key]: "x" } })).rejects.toMatchObject({
        code: "VALIDATION_FAILED",
      });
    }
  });

  it("keys that merely contain a forbidden word are allowed (e.g. emailVerified, otpLocked)", async () => {
    const rows: AuditEntry[] = [];
    const audit = createAuditModule({ repository: { append: async (e) => void rows.push(e) } });
    await audit.record({ actor, action: "auth.otp_locked", after: { emailVerified: true, otpLocked: true, role: "OPS" } });
    expect(rows).toHaveLength(1);
  });

  it("non-object before/after (string, number, null, undefined) are passed through unchanged", async () => {
    const rows: AuditEntry[] = [];
    const audit = createAuditModule({ repository: { append: async (e) => void rows.push(e) } });
    await audit.record({ actor, action: "flag.set", before: "off", after: 1 });
    await audit.record({ actor, action: "flag.set", before: null, after: undefined });
    expect(rows.map((r) => [r.before, r.after])).toEqual([
      ["off", 1],
      [null, undefined],
    ]);
  });

  it("the validated entry is passed to the repository as-is (target, actor, before, after)", async () => {
    const rows: AuditEntry[] = [];
    const audit = createAuditModule({ repository: { append: async (e) => void rows.push(e) } });
    const entry: AuditEntry = {
      actor: { ...actor, ip: "203.0.113.7", requestId: "req-9" },
      action: "role.revoke",
      target: "user:0192f0c4-0000-7000-8000-000000000002",
      before: { role: "OPS" },
      after: { role: null },
    };
    await audit.record(entry);
    expect(rows).toEqual([entry]);
  });

  it("a repository failure propagates to the caller (no silent loss of an audit row)", async () => {
    const audit = createAuditModule({
      repository: {
        append: async () => {
          throw new Error("db down");
        },
      },
    });
    await expect(audit.record({ actor, action: "role.grant" })).rejects.toThrow("db down");
  });

  it("the public API is write-only: record() + recordIn(tx) (SEC-P2-M1) and nothing that reads, updates or deletes", () => {
    const audit = createAuditModule({ repository: { append: async () => {} } });
    expect(Object.keys(audit).sort()).toEqual(["record", "recordIn"]);
    for (const k of Object.keys(audit)) expect(k).not.toMatch(/get|find|list|read|update|delete|remove|purge/i);
  });

  it("recordIn appends through the caller's transaction client and validates first", async () => {
    const audit = createAuditModule({ repository: { append: async () => {} } });
    const created: unknown[] = [];
    const tx = { auditLog: { create: async (a: unknown) => void created.push(a) } } as unknown as Parameters<typeof audit.recordIn>[0];
    await audit.recordIn(tx, { actor, action: "exam_change.reject", target: "exam_change:x", after: { reason: "r" } });
    expect(created).toHaveLength(1);
    await expect(audit.recordIn(tx, { actor, action: "Bad Action" })).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
    expect(created).toHaveLength(1);
  });

  // QA finding Q-1 (fixed in BOLT-0007): nested personal data and more key names are refused.
  it.each([
    { user: { email: "a@b.c" } },
    { users: [{ id: 1 }, { phone: "9876543210" }] },
    { profile: { contact: { emailAddress: "a@b.c" } } },
    { DOB: "2000-01-01" },
    { mobile: "9876543210" },
  ])("refuses personal data nested or under other names: %j", async (after) => {
    const append = vi.fn(async () => {});
    const audit = createAuditModule({ repository: { append } });
    await expect(audit.record({ actor, action: "user.update", after })).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
    expect(append).not.toHaveBeenCalled();
  });
});
