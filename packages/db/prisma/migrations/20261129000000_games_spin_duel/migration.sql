-- BOLT-0115: Daily Spin (one row per user per IST day) and solo Confidence Duel. Idempotent: safe on a project that was
-- created from infra/supabase/sql (hand-run) as well as on a migrated one.

-- CreateTable
CREATE TABLE IF NOT EXISTS "DailySpin" (
    "userId" UUID NOT NULL,
    "day" TEXT NOT NULL,
    "prizeId" TEXT NOT NULL,
    "amount" INTEGER NOT NULL,
    "roll" INTEGER NOT NULL,
    "oddsVersion" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DailySpin_pkey" PRIMARY KEY ("userId","day")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "ConfidenceDuel" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "examCode" TEXT NOT NULL,
    "questions" JSONB NOT NULL,
    "startedAt" TIMESTAMP(3) NOT NULL,
    "submittedAt" TIMESTAMP(3),
    "pointsAwarded" INTEGER NOT NULL DEFAULT 0,
    "result" JSONB,

    CONSTRAINT "ConfidenceDuel_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX IF NOT EXISTS "ConfidenceDuel_userId_submittedAt_idx" ON "ConfidenceDuel"("userId", "submittedAt");

-- Same default as infra/supabase/sql/03_security.sql: no access through the Supabase Data API; the API connects as owner.
ALTER TABLE "DailySpin" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "ConfidenceDuel" ENABLE ROW LEVEL SECURITY;
