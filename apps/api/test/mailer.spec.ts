import { describe, expect, it, vi } from "vitest";
import { httpOtpMailer } from "../src/platform/mailer.js";

const base = {
  EMAIL_PROVIDER: "smtp" as const,
  EMAIL_FALLBACK_PROVIDER: "brevo" as const,
  SMTP_HOST: "smtp.gmail.com",
  SMTP_PORT: 465,
  SMTP_SECURE: true,
  EMAIL_FROM: "sender@example.com",
  EMAIL_FROM_NAME: "HeyMey",
};
const msg = { otpId: "o1", to: "user@example.com", code: "123456", purpose: "login" as const };

describe("httpOtpMailer", () => {
  it("falls back to Brevo when the SMTP primary cannot send", async () => {
    const fetchImpl = vi.fn(async () => new Response("{}", { status: 201 }));
    // No SMTP_USER/SMTP_PASS: the primary fails before any network call.
    await httpOtpMailer({ ...base, BREVO_API_KEY: "k" }, fetchImpl as unknown as typeof fetch).send(msg);
    expect(fetchImpl).toHaveBeenCalledTimes(1);
    const [url, init] = fetchImpl.mock.calls[0] as unknown as [string, { body: string }];
    expect(url).toBe("https://api.brevo.com/v3/smtp/email");
    expect(JSON.parse(init.body).textContent).toContain("123456");
  });

  it("fails visibly, without leaking the address, when every provider fails", async () => {
    const fetchImpl = vi.fn(async () => new Response("no", { status: 500 }));
    const err = await httpOtpMailer({ ...base, BREVO_API_KEY: "k" }, fetchImpl as unknown as typeof fetch)
      .send(msg)
      .catch((e: Error) => e);
    expect((err as Error).message).toContain("every provider failed");
    expect((err as Error).message).not.toContain("user@example.com");
  });

  it("does not fall back when the fallback is none", async () => {
    const fetchImpl = vi.fn();
    await expect(httpOtpMailer({ ...base, EMAIL_FALLBACK_PROVIDER: "none" }, fetchImpl as unknown as typeof fetch).send(msg)).rejects.toThrow();
    expect(fetchImpl).not.toHaveBeenCalled();
  });
});
