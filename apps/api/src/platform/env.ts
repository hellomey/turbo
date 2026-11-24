import { authEnv, baseEnv, databaseEnv, httpEnv, emailEnv, loadEnv, webhookEnv } from "@heymey/config";

export const apiEnvSchema = baseEnv
  .extend(databaseEnv.shape)
  .extend(emailEnv.shape)
  .extend(authEnv.shape)
  .extend(httpEnv.shape)
  .extend(webhookEnv.shape);

export type ApiEnv = ReturnType<typeof loadApiEnv>;

export function loadApiEnv(source: Record<string, string | undefined> = process.env) {
  return loadEnv(apiEnvSchema, source);
}
