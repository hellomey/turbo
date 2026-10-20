import { generateKeyPairSync, randomBytes } from "node:crypto";

/**
 * A complete, throwaway API environment for tests. Pass real container URLs for integration tests;
 * unit/contract tests can use the defaults (connections are lazy and never opened).
 */
export function setTestEnv(overrides: { DATABASE_URL?: string; VALKEY_URL?: string } = {}): void {
  const { privateKey, publicKey } = generateKeyPairSync("ed25519");
  Object.assign(process.env, {
    HEYMEY_ENV: "test",
    NODE_ENV: "test",
    DATABASE_URL: overrides.DATABASE_URL ?? "postgresql://test:test@127.0.0.1:1/test",
    VALKEY_URL: overrides.VALKEY_URL ?? "redis://127.0.0.1:1",
    JWT_ISSUER: "http://localhost:4567",
    JWT_PRIVATE_KEY: privateKey.export({ type: "pkcs8", format: "pem" }).toString(),
    JWT_PUBLIC_KEY: publicKey.export({ type: "spki", format: "pem" }).toString(),
    OTP_PEPPER: randomBytes(32).toString("hex"),
    TOTP_ENC_KEY: randomBytes(32).toString("base64"),
    CORS_ORIGINS: "http://localhost:4569",
    MIN_APP_VERSION: "1.0.0",
  });
}
