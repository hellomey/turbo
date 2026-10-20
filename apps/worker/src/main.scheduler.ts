import { Queue } from "bullmq";
import { BUSINESS_TIMEZONE, PORTS, baseEnv, loadEnv, loadLocalEnv, valkeyEnv } from "@heymey/config";
import { startHealthServer } from "./health.js";
import { bullConnection, isImplemented } from "./processors/index.js";
import { QUEUES } from "./queues/registry.js";

loadLocalEnv(); // local development only
const env = loadEnv(baseEnv.extend(valkeyEnv.shape));
startHealthServer("scheduler", Number(process.env.PORT ?? PORTS.SCHEDULER));

// Exactly ONE scheduler replica. Upserts a BullMQ job scheduler (Asia/Kolkata cron) for every repeatable queue
// that has a processor in this build; the others are scheduled when their module lands.
const connection = bullConnection(env.VALKEY_URL);
const repeatable = QUEUES.filter((q) => q.repeat && isImplemented(q.name));

async function main(): Promise<void> {
  for (const q of repeatable) {
    const queue = new Queue(q.name, { connection });
    await queue.upsertJobScheduler(`${q.name}:schedule`, { pattern: q.repeat, tz: BUSINESS_TIMEZONE }, { name: "run", data: {} });
    await queue.close();
  }
  console.log(`scheduler (${env.HEYMEY_ENV}, ${BUSINESS_TIMEZONE}) owns ${repeatable.map((q) => q.name).join(", ") || "no"} schedules`);
}

void main();
