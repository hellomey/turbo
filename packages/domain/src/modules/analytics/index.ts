/**
 * Public API of the `analytics` module. Product analytics event ingestion (partitioned table for Metabase).
 * Export use cases and types only. Never export repositories or Prisma models.
 */
export const AnalyticsModule = { name: "analytics" } as const;
