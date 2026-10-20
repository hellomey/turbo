import { authEnv, baseEnv, databaseEnv, httpEnv, loadEnv, valkeyEnv } from "@heymey/config";

export const apiEnvSchema = baseEnv
  .extend(databaseEnv.shape)
  .extend(valkeyEnv.shape)
  .extend(authEnv.shape)
  .extend(httpEnv.shape);

export type ApiEnv = ReturnType<typeof loadApiEnv>;

export function loadApiEnv(source: Record<string, string | undefined> = process.env) {
  return loadEnv(apiEnvSchema, source);
}
