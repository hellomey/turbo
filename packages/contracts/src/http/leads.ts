import { z } from "../zod.js";

/**
 * Marketing-site contact form (apps/marketing -> POST /v1/public/leads on the API, port 4567).
 * Replaces the old product app's /api/public/leads. CORS-restricted to the marketing origins.
 */
export const LeadBody = z
  .object({
    kind: z.enum(["aspirant", "institution", "creator", "publisher", "press", "other"]),
    name: z.string().min(1).max(120),
    email: z.email(),
    message: z.string().max(2000).optional(),
    consentToContact: z.literal(true),
  })
  .openapi("LeadBody");
