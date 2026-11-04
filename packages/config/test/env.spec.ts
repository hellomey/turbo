import { describe, expect, it } from "vitest";
import { baseEnv, databaseEnv, databaseTlsIssues, loadEnv } from "../src/env.js";

// SEC-P2-M3: staging/production refuse a remote DB URL without TLS; the error names the variable, never the value.
const schema = baseEnv.extend(databaseEnv.shape);
const REMOTE = "postgresql://u:s3cretPw@aws-0-ap-south-1.pooler.supabase.com:6543/postgres";

describe("database TLS validation", () => {
  it("production refuses a remote DATABASE_URL without sslmode, naming the variable only", () => {
    let msg = "";
    try {
      loadEnv(schema, { HEYMEY_ENV: "production", DATABASE_URL: REMOTE });
    } catch (e) {
      msg = (e as Error).message;
    }
    expect(msg).toContain("DATABASE_URL");
    expect(msg).not.toContain("s3cretPw");
    expect(msg).not.toContain("supabase.com");
  });

  it("staging refuses DIRECT_URL with sslmode=disable or prefer", () => {
    expect(databaseTlsIssues({ HEYMEY_ENV: "staging", DATABASE_URL: `${REMOTE}?sslmode=require`, DIRECT_URL: `${REMOTE}?sslmode=prefer` })).toEqual([
      expect.stringContaining("DIRECT_URL"),
    ]);
    expect(databaseTlsIssues({ HEYMEY_ENV: "staging", DATABASE_URL: `${REMOTE}?sslmode=disable` })).toHaveLength(1);
  });

  it("accepts require / verify-full remotely, localhost without TLS, and any URL locally", () => {
    expect(loadEnv(schema, { HEYMEY_ENV: "production", DATABASE_URL: `${REMOTE}?pgbouncer=true&sslmode=require`, DIRECT_URL: `${REMOTE}?sslmode=verify-full` }).HEYMEY_ENV).toBe("production");
    expect(databaseTlsIssues({ HEYMEY_ENV: "production", DATABASE_URL: "postgresql://u:p@localhost:4580/heymey" })).toEqual([]);
    expect(databaseTlsIssues({ HEYMEY_ENV: "production", DATABASE_URL: "postgresql://u:p@127.0.0.1:4580/heymey" })).toEqual([]);
    expect(databaseTlsIssues({ HEYMEY_ENV: "local", DATABASE_URL: REMOTE })).toEqual([]);
    expect(databaseTlsIssues({ HEYMEY_ENV: "test", DATABASE_URL: REMOTE })).toEqual([]);
  });
});
