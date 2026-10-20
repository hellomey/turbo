// Identity seed (BOLT-0002): local staff + one aspirant so the Desk and app sign-in flows can be tried locally.
// LOCAL / STAGING ONLY. No real personal data: @heymey.app addresses only; sign-in still needs the emailed code
// (Mailpit on :4585 locally) and, for the Desk, an authenticator app (TOTP is enrolled on first Desk sign-in).
// Idempotent: users are upserted by email, roles are created only if the active assignment is missing.
import type { PrismaClient, Role } from "@heymey/db";

const SEED_USERS: { email: string; role: Role }[] = [
  { email: "admin@heymey.app", role: "ADMIN" },
  { email: "ops@heymey.app", role: "OPS" },
  { email: "aspirant@heymey.app", role: "ASPIRANT" },
];

export const seeder = {
  name: "identity",
  async run(prisma: PrismaClient): Promise<string> {
    // SEC-M4 (BOLT-0007): never create staff accounts in production. Seeded ADMIN/OPS users have no authenticator yet,
    // so whoever controls their mailbox first could enroll one (trust on first use; ceremony: D-2026-10-20-20).
    // Checked here as well as in seed.ts because HEYMEY_ENV may come from the env file loaded after that check.
    if (process.env.HEYMEY_ENV === "production") throw new Error("identity seed: refusing to run in production");
    let createdUsers = 0;
    let grantedRoles = 0;
    for (const s of SEED_USERS) {
      const existing = await prisma.user.findUnique({ where: { email: s.email }, select: { id: true } });
      const user = existing ?? (await prisma.user.create({ data: { email: s.email }, select: { id: true } }));
      if (!existing) createdUsers++;
      const held = await prisma.roleAssignment.findFirst({
        where: { userId: user.id, role: s.role, revokedAt: null, scopeId: null },
        select: { id: true },
      });
      if (!held) {
        await prisma.roleAssignment.create({ data: { userId: user.id, role: s.role, grantedBy: user.id } });
        await prisma.auditLog.create({
          data: { actorId: null, actorRole: "SYSTEM", action: "role.grant", target: `user:${user.id}`, after: { role: s.role, source: "seed" } },
        });
        grantedRoles++;
      }
    }
    return `${SEED_USERS.length} users (${createdUsers} new), ${grantedRoles} roles granted`;
  },
};
