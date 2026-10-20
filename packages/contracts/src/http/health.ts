import { z } from "../zod.js";

export const HealthResponse = z
  .object({
    status: z.enum(["ok", "degraded"]),
    service: z.string(),
    version: z.string(),
    // Values are "ok" | "fail". Plain string record: the Dart generator cannot compile enum-valued maps.
    checks: z.record(z.string(), z.string().openapi({ example: "ok" })),
  })
  .openapi("HealthResponse");
export type HealthResponse = z.infer<typeof HealthResponse>;
