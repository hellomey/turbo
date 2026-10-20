/**
 * Every background queue and repeatable schedule in one place (blueprint §17.5 "System", §36).
 * Owning module = the domain module whose use case the job calls. Workers never contain business rules.
 * Schedules use Asia/Kolkata so "nightly" and "Sunday" mean the aspirant's night and Sunday.
 */
export interface QueueDef {
  name: string;
  owner: string;
  concurrency: number;
  /** Cron (Asia/Kolkata) if the scheduler should enqueue it repeatedly. */
  repeat?: string;
  description: string;
}

export const QUEUES: readonly QueueDef[] = [
  { name: "email.otp", owner: "auth", concurrency: 20, description: "Send OTP email via SMTP (plain text, no links)" },
  { name: "auth.otp-gc", owner: "auth", concurrency: 1, repeat: "45 * * * *", description: "Delete OTP rows (email, request IP) older than 24 hours (SEC-M3)" },
  { name: "email.transactional", owner: "notifications", concurrency: 10, description: "Invoices, partner mail" },
  { name: "push.send", owner: "notifications", concurrency: 50, description: "FCM / APNs, respecting the 3-a-day budget and quiet hours" },
  { name: "mastery.dimming", owner: "mastery", concurrency: 4, repeat: "*/15 * * * *", description: "Dim overdue lamps, drop Steady rings that stay overdue" },
  { name: "plan.rebalance", owner: "plan", concurrency: 4, repeat: "30 2 * * *", description: "Nightly kind rebalance after missed days" },
  { name: "readiness.sunday-report", owner: "readiness", concurrency: 4, repeat: "0 6 * * 0", description: "Sunday Report" },
  { name: "games.matchmaking-sweep", owner: "games", concurrency: 1, repeat: "*/1 * * * *", description: "Widen trophy ranges, offer practice bots after 30 s" },
  { name: "squads.battle-matching", owner: "squads", concurrency: 1, repeat: "0 6 * * 1,4", description: "Match squads for Tue/Fri battles" },
  { name: "billing.receipt-recheck", owner: "billing", concurrency: 4, repeat: "0 * * * *", description: "Re-verify pending purchases, acknowledge Google purchases within 3 days" },
  { name: "billing.store-notification", owner: "billing", concurrency: 8, description: "Process Google RTDN / Apple ASN V2 payloads" },
  { name: "exams.watch-change", owner: "exams", concurrency: 2, description: "changedetection.io change -> human-check task in Ops Desk" },
  { name: "content.ai-explain", owner: "content", concurrency: 4, description: "Generate explanation once per question version (ai-gateway)" },
  { name: "content.ai-verify", owner: "content", concurrency: 4, description: "Independent answer check on a different model family" },
  { name: "moderation.scan", owner: "moderation", concurrency: 8, description: "AI pre-sort of reports and chat; self-harm alerts first" },
  { name: "users.deletion", owner: "users", concurrency: 1, repeat: "0 3 * * *", description: "Erase accounts past the 7-day grace period" },
  { name: "platform.idempotency-gc", owner: "platform", concurrency: 1, repeat: "15 * * * *", description: "Delete expired idempotency records" },
];
