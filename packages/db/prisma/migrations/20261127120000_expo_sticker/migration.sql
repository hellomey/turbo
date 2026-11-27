-- BOLT-0112 stall: expo challenge + sticker codes. Idempotent: the Supabase projects were created from hand-run SQL.

-- AlterTable
ALTER TABLE "Source" ADD COLUMN IF NOT EXISTS "setName" TEXT;

-- CreateTable
CREATE TABLE IF NOT EXISTS "ExpoChallenge" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "questionIds" UUID[],
    "createdAt" TIMESTAMP(3) NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "submittedAt" TIMESTAMP(3),
    "score" INTEGER,

    CONSTRAINT "ExpoChallenge_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "StickerCode" (
    "userId" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL,
    "redeemedAt" TIMESTAMP(3),
    "redeemedBy" UUID,

    CONSTRAINT "StickerCode_pkey" PRIMARY KEY ("userId")
);

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "Source_setName_key" ON "Source"("setName");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "ExpoChallenge_userId_createdAt_idx" ON "ExpoChallenge"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "StickerCode_code_key" ON "StickerCode"("code");
