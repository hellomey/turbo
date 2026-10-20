// Platform helpers behind BOLT-0007 security fixes (SEC-H1 rate-limit keys, SEC-L5 log redaction).
import { describe, expect, it } from "vitest";
import { rateLimitIpKey } from "../src/platform/platform.guard.js";
import { redactForLog } from "../src/platform/domain-error.filter.js";

describe("rateLimitIpKey (SEC-H1)", () => {
  it("keeps IPv4 addresses as they are", () => {
    expect(rateLimitIpKey("203.0.113.7")).toBe("203.0.113.7");
  });

  it("counts IPv4-mapped IPv6 as the IPv4 address", () => {
    expect(rateLimitIpKey("::ffff:203.0.113.7")).toBe("203.0.113.7");
  });

  it("buckets IPv6 by /64 so rotating the interface id does not reset the limit", () => {
    const a = rateLimitIpKey("2001:db8:abcd:12:1:2:3:4");
    const b = rateLimitIpKey("2001:db8:abcd:12:ffff:eeee:dddd:cccc");
    expect(a).toBe("2001:db8:abcd:12::/64");
    expect(b).toBe(a);
  });

  it("expands :: shorthand before bucketing", () => {
    expect(rateLimitIpKey("2001:db8::1")).toBe("2001:db8:0:0::/64");
    expect(rateLimitIpKey("::1")).toBe("0:0:0:0::/64");
  });

  it("different /64 networks get different buckets", () => {
    expect(rateLimitIpKey("2001:db8:0:1::1")).not.toBe(rateLimitIpKey("2001:db8:0:2::1"));
  });
});

describe("redactForLog (SEC-L5)", () => {
  it("removes email addresses and 6-digit codes", () => {
    const out = redactForLog('Unique constraint failed on email "priya.k+exam@gmail.com" with code 482913');
    expect(out).toBe('Unique constraint failed on email "[email]" with code [code]');
  });

  it("leaves other text alone", () => {
    expect(redactForLog("Error: connect ECONNREFUSED 127.0.0.1:4580")).toBe("Error: connect ECONNREFUSED 127.0.0.1:4580");
  });
});
