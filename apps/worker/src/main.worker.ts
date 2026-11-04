import { randomInt } from "node:crypto";
import { Queue, Worker } from "bullmq";
import nodemailer from "nodemailer";
import { PORTS, baseEnv, databaseEnv, loadEnv, loadLocalEnv, smtpEnv, valkeyEnv } from "@heymey/config";
import { createPrismaClient } from "@heymey/db";
import { createExamHallModule } from "@heymey/domain/modules/exam-hall";
import { createAuditModule } from "@heymey/domain/modules/audit";
import { createExamAlertsModule, createExamsModule } from "@heymey/domain/modules/exams";
import { createContentModule, createQuestionBank } from "@heymey/domain/modules/content";
import { createSyllabusModule } from "@heymey/domain/modules/syllabus";
import { createReadinessModule } from "@heymey/domain/modules/readiness";
import { createPlanModule, planPortsFrom } from "@heymey/domain/modules/plan";
import { createMasteryActivity, createMasteryDimming, createMasteryModule } from "@heymey/domain/modules/mastery";
import { createLogOnlyPushSender, createNotificationsModule } from "@heymey/domain/modules/notifications";
import { createOtpMaintenance, createSessionRevoker } from "@heymey/domain/modules/auth";
import { createRolesModule } from "@heymey/domain/modules/roles";
import { createUsersModule } from "@heymey/domain/modules/users";
import { systemClock } from "@heymey/domain/shared";
import { startHealthServer } from "./health.js";
import { createExamHallExpireProcessor, createExamHallRanksProcessor } from "./processors/exam-hall.js";
import { createOtpGcProcessor } from "./processors/auth-otp-gc.js";
import { createMasteryDimmingProcessor } from "./processors/mastery-dimming.js";
import { createPlanDateChangedProcessor, createPlanRebalanceProcessor } from "./processors/plan.js";
import { createSundayReportProcessor, sundayReportPush } from "./processors/readiness.js";
import { createEmailOtpProcessor } from "./processors/email-otp.js";
import { createExamAlertFanOutProcessor, createPushSendProcessor, createReleaseHeldProcessor } from "./processors/notifications.js";
import { bullConnection, isImplemented } from "./processors/index.js";
import { createUsersDeletionProcessor } from "./processors/users-deletion.js";
import { QUEUES } from "./queues/registry.js";

loadLocalEnv(); // local development only
const env = loadEnv(baseEnv.extend(databaseEnv.shape).extend(valkeyEnv.shape).extend(smtpEnv.shape));
startHealthServer("worker", Number(process.env.PORT ?? PORTS.WORKER));

// Composition root: build module APIs once, one processor per implemented queue, each calling one use case.
const prisma = createPrismaClient(env.DATABASE_URL);
const audit = createAuditModule({ prisma });
const roles = createRolesModule({ prisma, audit });
const users = createUsersModule({ prisma, audit, clock: systemClock, roles });
const sessions = createSessionRevoker({ prisma, audit, clock: systemClock });
const otps = createOtpMaintenance({ prisma });
const transport = nodemailer.createTransport({
  host: env.SMTP_HOST,
  port: env.SMTP_PORT,
  secure: env.SMTP_SECURE,
  ...(env.SMTP_USER ? { auth: { user: env.SMTP_USER, pass: env.SMTP_PASS ?? "" } } : {}),
});

// BOLT-0014: notifications. Sender is log-only until Firebase/APNs exist (D-2026-10-22-33). Exam Alert fan-out joins
// exams (followers) and notifications here, so neither module depends on the other.
const pushQueue = new Queue("push.send", { connection: bullConnection(env.VALKEY_URL) });
const notifications = createNotificationsModule({
  prisma,
  clock: systemClock,
  consent: { offersGranted: async (userId) => (await users.getConsents(userId)).choices.some((c) => c.purpose === "offers_email" && c.granted) },
  sender: createLogOnlyPushSender((line) => console.log(line)),
  dispatcher: {
    dispatch: async (sendLogId) => {
      await pushQueue.add("send", { sendLogId }, { jobId: `send-${sendLogId}`, attempts: 3, backoff: { type: "exponential", delay: 5000 }, removeOnComplete: true });
    },
  },
});
const examAlerts = createExamAlertsModule({ prisma, clock: systemClock, events: { publish: async () => {} } });

const examHall = createExamHallModule({ prisma, clock: systemClock }); // BOLT-0011

// BOLT-0013: readiness reads mastery + exam-hall through their public APIs; exams facts and the push are joined here.
const exams = createExamsModule({ prisma, clock: systemClock });
const syllabus = createSyllabusModule({ prisma });
const content = createContentModule({ prisma, syllabus });
const mastery = createMasteryModule({
  prisma,
  clock: systemClock,
  syllabus,
  questions: createQuestionBank({ prisma, randomInt: (max) => randomInt(max) }),
  openableTopics: (ids) => content.topicsWithPublishedLesson(ids),
  learner: {
    examCodes: async (userId) => {
      const mine = await exams.getMyExams(userId);
      return [...(mine.main ? [mine.main.code] : []), ...mine.others.map((e) => e.code)];
    },
    publishedExamCodes: () => exams.publishedCodes(),
  },
});
// BOLT-0012: plan reads exams, syllabus and mastery through their public APIs.
const plan = createPlanModule({ prisma, clock: systemClock, ports: planPortsFrom({ exams, syllabus, mastery }) });
const readiness = createReadinessModule({
  prisma,
  clock: systemClock,
  mastery,
  masteryActivity: createMasteryActivity({ prisma }),
  examHall,
  // The Sunday job does not read exam facts (only the meter does); the API composition root wires the real ones.
  exams: { examInfo: async () => null },
});

const processors: Record<string, (data: unknown) => Promise<unknown>> = {
  "readiness.sunday-report": createSundayReportProcessor({ readiness, notify: sundayReportPush(notifications) }),
  "plan.rebalance": createPlanRebalanceProcessor(plan),
  "exams.date-changed": createPlanDateChangedProcessor(plan),
  "mastery.dimming": createMasteryDimmingProcessor({ dimming: createMasteryDimming({ prisma, clock: systemClock }) }),
  "exam-hall.expire": createExamHallExpireProcessor(examHall),
  "exam-hall.publish-ranks": createExamHallRanksProcessor(examHall),
  "email.otp": createEmailOtpProcessor({ transport, from: env.MAIL_FROM }),
  "users.deletion": createUsersDeletionProcessor({ users, sessions, otps, pushTokens: notifications }),
  "auth.otp-gc": createOtpGcProcessor({ otps, clock: systemClock }),
  "push.send": createPushSendProcessor({ notifications }),
  "notifications.exam-alert": createExamAlertFanOutProcessor({ followersOf: (code) => examAlerts.followersOf(code), notifications }),
  "notifications.release-held": createReleaseHeldProcessor({ notifications }),
};

const connection = bullConnection(env.VALKEY_URL);
const workers = QUEUES.filter((q) => isImplemented(q.name)).map((q) => {
  const run = processors[q.name];
  if (!run) throw new Error(`no processor for ${q.name}`);
  const w = new Worker(q.name, (job) => run(job.data), { connection, concurrency: q.concurrency });
  // Ids only: never log job data (emails, codes).
  w.on("failed", (job, err) => console.error(`job failed queue=${q.name} id=${job?.id ?? "?"} attempts=${job?.attemptsMade ?? 0} error=${err.name}`));
  return w;
});

console.log(`worker (${env.HEYMEY_ENV}) processing ${workers.map((w) => w.name).join(", ")} of ${QUEUES.length} registered queues`);

async function shutdown(): Promise<void> {
  await Promise.allSettled([...workers.map((w) => w.close()), pushQueue.close()]);
  transport.close();
  await prisma.$disconnect();
  process.exit(0);
}
process.on("SIGTERM", () => void shutdown());
process.on("SIGINT", () => void shutdown());
