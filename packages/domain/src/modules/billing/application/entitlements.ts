/**
 * Entitlements are read only from the server (blueprint §11, §34.1; billing module.json "entitlements read only from server").
 * Phase 2 stub (U-practice logical design, D-2026-10-22-17..20): everyone is on Free until Pro can be bought (Phase 3, §43).
 */
export type Entitlement = "free" | "pro";

export interface EntitlementReader {
  entitlementOf(userId: string): Promise<Entitlement>;
}

/** Phase 2: no purchases exist, so every user is `free`. Replaced by the real billing read model in Phase 3. */
export function createEntitlementStub(): EntitlementReader {
  return { entitlementOf: async () => "free" };
}
