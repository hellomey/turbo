import type { PrismaClient } from "@heymey/db";

/**
 * Test stand-in for the OTP mail queue. The API now sends email over HTTPS (Brevo), so tests replace global fetch
 * BEFORE the app is created, record every message, and expose the same `getJobs` shape the old BullMQ reader had.
 */
export interface CapturedOtp {
  data: { to: string; code: string; purpose: "login" | "delete_account" };
  timestamp: number;
}

export function captureMailQueue(): { getJobs(states?: string[]): Promise<CapturedOtp[]>; close(): Promise<void> } {
  const sent: CapturedOtp[] = [];
  globalThis.fetch = (async (input: unknown, init?: { body?: string }) => {
    if (!String(input).includes("api.brevo.com")) throw new Error(`unexpected outbound request in test: ${String(input)}`);
    const body = JSON.parse(init?.body ?? "{}") as { to: { email: string }[]; textContent: string };
    const code = /Your HeyMey code is (\d{6})/.exec(body.textContent)?.[1] ?? "";
    sent.push({
      data: { to: body.to[0]?.email ?? "", code, purpose: body.textContent.includes("deleting your HeyMey account") ? "delete_account" : "login" },
      timestamp: Date.now() + sent.length, // strictly increasing, so "newest" is unambiguous
    });
    return new Response("{}", { status: 201 });
  }) as typeof fetch;
  return { getJobs: async () => [...sent], close: async () => {} };
}

/** Reads the Postgres job queue the way the notifications tests used to read BullMQ. */
export function pgQueue(prisma: PrismaClient, queue: string) {
  return {
    count: () => prisma.jobQueueItem.count({ where: { queue } }),
    getJob: (jobId: string) => prisma.jobQueueItem.findUnique({ where: { jobId } }),
    close: async () => {},
  };
}
