import { existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { z } from "zod";

/** Which deployment we are in. "Day" logic always uses Asia/Kolkata regardless (blueprint §37). */
export const HeyMeyEnv = z.enum(["local", "test", "staging", "production"]);
export type HeyMeyEnv = z.infer<typeof HeyMeyEnv>;

export const baseEnv = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  HEYMEY_ENV: HeyMeyEnv.default("local"),
  LOG_LEVEL: z.enum(["trace", "debug", "info", "warn", "error", "fatal"]).default("info"),
  GLITCHTIP_DSN: z.url().optional(),
});

export const databaseEnv = z.object({
  /** Through pgbouncer in staging/production. */
  DATABASE_URL: z.url(),
});

export const valkeyEnv = z.object({
  VALKEY_URL: z.url(),
});

export const s3Env = z.object({
  S3_ENDPOINT: z.url(),
  S3_BUCKET_CONTENT: z.string().default("heymey-content"),
  S3_ACCESS_KEY: z.string(),
  S3_SECRET_KEY: z.string(),
});

const pem = (label: string) =>
  z
    .string()
    .transform((v) => v.replace(/\\n/g, "\n"))
    .refine((v) => v.includes(`-----BEGIN ${label}-----`), `must be a PEM ${label}`);

export const authEnv = z.object({
  JWT_ISSUER: z.string().default("https://api.heymey.app"),
  /** Ed25519 keys (EdDSA), PKCS#8 / SPKI PEM. From SOPS in staging/production; `pnpm env:dev` locally. */
  JWT_PRIVATE_KEY: pem("PRIVATE KEY"),
  JWT_PUBLIC_KEY: pem("PUBLIC KEY"),
  /** Server-side secret mixed into OTP hashes. */
  OTP_PEPPER: z.string().min(32),
  /** 32-byte key (base64) for AES-256-GCM encryption of Desk TOTP secrets at rest. */
  TOTP_ENC_KEY: z.string().refine((v) => Buffer.from(v, "base64").length === 32, "must be 32 bytes, base64"),
});

export const smtpEnv = z.object({
  SMTP_HOST: z.string(),
  SMTP_PORT: z.coerce.number().int(),
  SMTP_SECURE: z.stringbool().default(false),
  SMTP_USER: z.string().optional(),
  SMTP_PASS: z.string().optional(),
  MAIL_FROM: z.string().default("HeyMey <no-reply@mail.heymey.app>"),
});

export const httpEnv = z.object({
  /** Comma-separated browser origins allowed to call the API (Desk, marketing). */
  CORS_ORIGINS: z
    .string()
    .default("https://desk.heymey.app,https://heymey.app,https://www.heymey.app")
    .transform((v) => v.split(",").map((s) => s.trim()).filter(Boolean)),
  MIN_APP_VERSION: z.string().default("1.0.0"),
  /**
   * Reverse-proxy hops to trust for the client IP (SEC-H1). 0 = trust nothing (local, tests).
   * Production/staging: 1 (Caddy, which overwrites X-Forwarded-For with the Cloudflare-verified client IP).
   */
  TRUST_PROXY_HOPS: z.coerce.number().int().min(0).max(3).default(0),
});

export const openRouterEnv = z.object({
  OPENROUTER_API_KEY: z.string().min(1),
  OPENROUTER_BASE_URL: z.url().default("https://openrouter.ai/api/v1"),
  AI_MONTHLY_BUDGET_INR: z.coerce.number().positive(),
});

/**
 * Parse env once at boot and fail fast with a readable message.
 * Services compose the schemas they need, e.g. `baseEnv.extend(databaseEnv.shape)`.
 */
export function loadEnv<T extends z.ZodType>(schema: T, source: Record<string, string | undefined> = process.env): z.infer<T> {
  const parsed = schema.safeParse(source);
  if (!parsed.success) {
    const issues = parsed.error.issues.map((i) => `  - ${i.path.join(".")}: ${i.message}`).join("\n");
    throw new Error(`Invalid environment:\n${issues}\n(local development: run \`pnpm env:dev\` once)`);
  }
  return parsed.data;
}

/**
 * Local development only: load the repo-root `.env` written by `pnpm env:dev`.
 * Never used in staging/production, where env comes from SOPS-decrypted files via Compose.
 */
export function loadLocalEnv(startDir: string = process.cwd()): string | null {
  if (process.env.HEYMEY_ENV && process.env.HEYMEY_ENV !== "local") return null;
  let dir = startDir;
  for (let i = 0; i < 6; i++) {
    const file = join(dir, ".env");
    if (existsSync(join(dir, "pnpm-workspace.yaml")) && existsSync(file)) {
      process.loadEnvFile(file);
      return file;
    }
    dir = dirname(dir);
  }
  return null;
}
