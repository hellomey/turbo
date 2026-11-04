/**
 * Public API of the `billing` module. Store receipts, server notifications, entitlements, refunds, gifts, Razorpay.
 * Export use cases and types only. Never export repositories or Prisma models.
 */
export const BillingModule = { name: "billing" } as const;

// ---- BOLT-0010 (practice): Phase 2 entitlement stub (everyone Free). Additive.
export type { Entitlement, EntitlementReader } from "./application/entitlements.js";
export { createEntitlementStub } from "./application/entitlements.js";
