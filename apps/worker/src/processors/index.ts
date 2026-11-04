/** Queues from ./queues/registry.ts that have a processor in this build. Only these get a BullMQ Worker. */
export const IMPLEMENTED_QUEUES = ["email.otp", "users.deletion", "auth.otp-gc", "push.send", "notifications.exam-alert", "notifications.release-held", "exam-hall.expire", "exam-hall.publish-ranks", "mastery.dimming", "readiness.sunday-report", "plan.rebalance", "exams.date-changed"] as const;
export type ImplementedQueue = (typeof IMPLEMENTED_QUEUES)[number];

export function isImplemented(name: string): name is ImplementedQueue {
  return (IMPLEMENTED_QUEUES as readonly string[]).includes(name);
}

/** BullMQ connection options from a redis:// URL. */
export function bullConnection(valkeyUrl: string) {
  const url = new URL(valkeyUrl);
  return {
    host: url.hostname,
    port: Number(url.port || 6379),
    ...(url.password ? { password: decodeURIComponent(url.password) } : {}),
    maxRetriesPerRequest: null,
  };
}
