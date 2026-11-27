-- BOLT-0113: XP award log, trophies (badges) and weekly leaderboard opt-in. Idempotent: safe on a project that was
-- created from infra/supabase/sql (hand-run) as well as on a migrated one.

-- CreateTable
CREATE TABLE IF NOT EXISTS "XpAward" (
    "id" BIGSERIAL NOT NULL,
    "userId" UUID NOT NULL,
    "amount" INTEGER NOT NULL,
    "reason" TEXT NOT NULL,
    "sourceKey" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "XpAward_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "UserTrophy" (
    "userId" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "earnedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "UserTrophy_pkey" PRIMARY KEY ("userId","code")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "LeaderboardOptIn" (
    "userId" UUID NOT NULL,
    "optIn" BOOLEAN NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LeaderboardOptIn_pkey" PRIMARY KEY ("userId")
);

-- CreateIndex
CREATE INDEX IF NOT EXISTS "XpAward_createdAt_idx" ON "XpAward"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "XpAward_userId_sourceKey_key" ON "XpAward"("userId", "sourceKey");

-- Same default as infra/supabase/sql/03_security.sql: no access through the Supabase Data API; the API connects as owner.
ALTER TABLE "XpAward" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "UserTrophy" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "LeaderboardOptIn" ENABLE ROW LEVEL SECURITY;
