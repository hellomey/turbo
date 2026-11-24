-- CreateTable
CREATE TABLE "RateLimitCounter" (
    "key" TEXT NOT NULL,
    "count" INTEGER NOT NULL,
    "resetAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RateLimitCounter_pkey" PRIMARY KEY ("key")
);

-- CreateTable
CREATE TABLE "OneTimeToken" (
    "jti" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "OneTimeToken_pkey" PRIMARY KEY ("jti")
);

-- CreateTable
CREATE TABLE "JobQueueItem" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "queue" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "jobId" TEXT,
    "data" JSONB NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "runAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lockedUntil" TIMESTAMP(3),
    "lastError" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "JobQueueItem_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "RateLimitCounter_resetAt_idx" ON "RateLimitCounter"("resetAt");

-- CreateIndex
CREATE INDEX "OneTimeToken_expiresAt_idx" ON "OneTimeToken"("expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "JobQueueItem_jobId_key" ON "JobQueueItem"("jobId");

-- CreateIndex
CREATE INDEX "JobQueueItem_queue_status_runAt_idx" ON "JobQueueItem"("queue", "status", "runAt");
