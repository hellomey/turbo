/**
 * Public API of the `ai` module. AI tasks, model routes, usage and budgets (via @heymey/ai-gateway).
 * Export use cases and types only. Never export repositories or Prisma models.
 */
export const AiModule = { name: "ai" } as const;
