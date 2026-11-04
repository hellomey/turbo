import { describe, expect, it } from "vitest";
import { parseDatabaseUrl } from "../src/index.js";

// BOLT-0023: Supabase transaction-pooler URLs (Prisma convention) must become clean node-postgres config.
describe("parseDatabaseUrl", () => {
  it("drops pooler hints and maps connection_limit to the pool max", () => {
    const r = parseDatabaseUrl(
      "postgresql://u:p@aws-0-ap-south-1.pooler.supabase.com:6543/postgres?pgbouncer=true&connection_limit=5&sslmode=require",
    );
    expect(r.max).toBe(5);
    expect(r.connectionString).toBe("postgresql://u:p@aws-0-ap-south-1.pooler.supabase.com:6543/postgres");
    expect(r.ssl).toEqual({ rejectUnauthorized: true }); // SEC-P2-M3: TLS set on the pool
  });

  it("sets TLS for verify-full and not for sslmode=disable", () => {
    expect(parseDatabaseUrl("postgresql://u:p@db.example.com/x?sslmode=verify-full").ssl).toEqual({ rejectUnauthorized: true });
    expect(parseDatabaseUrl("postgresql://u:p@db.example.com/x?sslmode=disable").ssl).toBeUndefined();
  });

  it("leaves a local URL unchanged", () => {
    const r = parseDatabaseUrl("postgresql://heymey:heymey@localhost:4580/heymey");
    expect(r).toEqual({ connectionString: "postgresql://heymey:heymey@localhost:4580/heymey" });
  });
});
