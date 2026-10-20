/* eslint-disable @typescript-eslint/no-non-null-assertion -- tests assert presence right after creating the row */
import { describe, expect, it } from "vitest";
import { canUseDesk } from "../../src/modules/roles/index.js";
import { ACTOR, identityHarness } from "./auth.fakes.js";

const UID = "0192f0c4-0000-7000-8000-000000000001";

describe("roles", () => {
  it("grant is idempotent and audited once", async () => {
    const h = identityHarness();
    expect(await h.roles.grant({ userId: UID, role: "OPS", actor: ACTOR })).toBe(true);
    expect(await h.roles.grant({ userId: UID, role: "OPS", actor: ACTOR })).toBe(false);
    expect(h.roleRepo.rows).toHaveLength(1);
    expect(h.auditRows.filter((a) => a.action === "role.grant")).toEqual([
      { actor: ACTOR, action: "role.grant", target: `user:${UID}`, after: { role: "OPS" } },
    ]);
  });

  it("system grants record the user as grantor", async () => {
    const h = identityHarness();
    await h.roles.grant({ userId: UID, role: "ASPIRANT", actor: { userId: null, role: "SYSTEM" } });
    expect(h.roleRepo.rows[0]!.grantedBy).toBe(UID);
  });

  it("lists roles in contract order", async () => {
    const h = identityHarness();
    await h.roles.grant({ userId: UID, role: "ADMIN", actor: ACTOR });
    await h.roles.grant({ userId: UID, role: "ASPIRANT", actor: ACTOR });
    await h.roles.grant({ userId: UID, role: "OPS", actor: ACTOR });
    expect(await h.roles.rolesOf(UID)).toEqual(["ASPIRANT", "OPS", "ADMIN"]);
  });

  it("Desk access needs a staff/partner role; aspirants never", async () => {
    const h = identityHarness();
    expect(canUseDesk(["ASPIRANT", "SUPPORTER", "MENTOR"])).toBe(false);
    expect(canUseDesk(["ASPIRANT", "REVIEWER"])).toBe(true);
    await h.roles.grant({ userId: UID, role: "ASPIRANT", actor: ACTOR });
    expect(await h.roles.canUseDesk(UID)).toBe(false);
    await h.roles.grant({ userId: UID, role: "MODERATOR", actor: ACTOR });
    expect(await h.roles.canUseDesk(UID)).toBe(true);
  });
});
