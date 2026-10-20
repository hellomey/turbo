// Integration: real PostgreSQL via Testcontainers (blueprint §44). Run with `pnpm test:integration`.
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPrismaClient, type PrismaClient } from "@heymey/db";
import { startPostgres, type StartedDb } from "@heymey/testing";
import { createAuditModule } from "../../src/modules/audit/index.js";

let db: StartedDb;
let prisma: PrismaClient;

beforeAll(async () => {
  db = await startPostgres();
  prisma = createPrismaClient(db.url);
});

afterAll(async () => {
  await prisma?.$disconnect();
  await db?.stop();
});

describe("audit (integration)", () => {
  it("writes an append-only row", async () => {
    const audit = createAuditModule({ prisma });
    await audit.record({ actor: { userId: null, role: "SYSTEM", requestId: "req-1" }, action: "seed.run", after: { exams: 3 } });
    const rows = await prisma.auditLog.findMany();
    expect(rows).toHaveLength(1);
    expect(rows[0]).toMatchObject({ action: "seed.run", actorRole: "SYSTEM", actorId: null, requestId: "req-1" });
  });

  // BOLT-0006 QA additions (§15 audit trail, §36 audit module).
  it("maps every field of a staff action, including actor ip, target and JSON before/after", async () => {
    const audit = createAuditModule({ prisma });
    const actorId = "0192f0c4-0000-7000-8000-0000000000aa";
    await audit.record({
      actor: { userId: actorId, role: "ADMIN", ip: "203.0.113.7", requestId: "req-2" },
      action: "role.grant",
      target: "user:0192f0c4-0000-7000-8000-0000000000bb",
      before: { roles: [] },
      after: { roles: ["OPS"], grantedAt: new Date("2026-10-20T05:30:00.000Z") },
    });
    const row = await prisma.auditLog.findFirstOrThrow({ where: { action: "role.grant" } });
    expect(row).toMatchObject({
      actorId,
      actorRole: "ADMIN",
      target: "user:0192f0c4-0000-7000-8000-0000000000bb",
      ip: "203.0.113.7",
      requestId: "req-2",
      before: { roles: [] },
      // Dates are stored as ISO strings (JSON round-trip in the adapter).
      after: { roles: ["OPS"], grantedAt: "2026-10-20T05:30:00.000Z" },
    });
    expect(row.at).toBeInstanceOf(Date);
  });

  it("absent target, ip, before and after are stored as NULL", async () => {
    const audit = createAuditModule({ prisma });
    await audit.record({ actor: { userId: null, role: "SYSTEM" }, action: "backup.verified" });
    const row = await prisma.auditLog.findFirstOrThrow({ where: { action: "backup.verified" } });
    expect(row).toMatchObject({ target: null, ip: null, requestId: null, before: null, after: null, actorId: null });
  });

  it("each record() appends a new row; the same action twice gives two rows with increasing ids", async () => {
    const audit = createAuditModule({ prisma });
    const actor = { userId: null, role: "SYSTEM" };
    await audit.record({ actor, action: "flag.toggle", after: { on: true } });
    await audit.record({ actor, action: "flag.toggle", after: { on: false } });
    const rows = await prisma.auditLog.findMany({ where: { action: "flag.toggle" }, orderBy: { id: "asc" } });
    expect(rows.map((r) => r.after)).toEqual([{ on: true }, { on: false }]);
    const [first, second] = rows.map((r) => r.id);
    expect(first !== undefined && second !== undefined && second > first).toBe(true);
  });

  it("an invalid entry writes nothing", async () => {
    const audit = createAuditModule({ prisma });
    const before = await prisma.auditLog.count();
    await expect(audit.record({ actor: { userId: null, role: "SYSTEM" }, action: "BAD" })).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
    await expect(
      audit.record({ actor: { userId: null, role: "SYSTEM" }, action: "user.update", after: { email: "a@b.c" } }),
    ).rejects.toMatchObject({ code: "VALIDATION_FAILED" });
    expect(await prisma.auditLog.count()).toBe(before);
  });
});
