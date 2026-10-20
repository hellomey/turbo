-- Extensions (blueprint §20.2: pg_trgm for search + duplicate detection).
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- CreateEnum
CREATE TYPE "EntitlementKind" AS ENUM ('pro', 'exam_pass', 'season_pass');

-- CreateEnum
CREATE TYPE "PurchaseStore" AS ENUM ('google_play', 'app_store', 'razorpay', 'invoice');

-- CreateEnum
CREATE TYPE "SparksSource" AS ENUM ('purchase', 'milestone', 'spend', 'reversal');

-- CreateEnum
CREATE TYPE "DimState" AS ENUM ('bright', 'dimming', 'dim');

-- CreateEnum
CREATE TYPE "Role" AS ENUM ('VISITOR', 'ASPIRANT', 'SUPPORTER', 'MENTOR', 'CREATOR', 'REVIEWER', 'PUBLISHER', 'INSTITUTION_ADMIN', 'SUPPORT_AGENT', 'MODERATOR', 'OPS', 'ADMIN', 'SYSTEM');

-- CreateTable
CREATE TABLE "IdempotencyRecord" (
    "scope" TEXT NOT NULL,
    "key" UUID NOT NULL,
    "requestHash" TEXT NOT NULL,
    "status" INTEGER NOT NULL,
    "body" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "IdempotencyRecord_pkey" PRIMARY KEY ("scope","key")
);

-- CreateTable
CREATE TABLE "SyncReceipt" (
    "clientActionId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "kind" TEXT NOT NULL,
    "acceptedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "clientAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SyncReceipt_pkey" PRIMARY KEY ("clientActionId")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" BIGSERIAL NOT NULL,
    "at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actorId" UUID,
    "actorRole" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "target" TEXT,
    "before" JSONB,
    "after" JSONB,
    "ip" TEXT,
    "requestId" TEXT,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OtpCode" (
    "id" UUID NOT NULL,
    "email" TEXT NOT NULL,
    "purpose" TEXT NOT NULL DEFAULT 'login',
    "codeHash" TEXT NOT NULL,
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),
    "lockedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "requestIp" TEXT,

    CONSTRAINT "OtpCode_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Device" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "platform" TEXT NOT NULL,
    "attestation" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSeenAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Device_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Session" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "deviceId" UUID NOT NULL,
    "isDesk" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastUsedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "revokedAt" TIMESTAMP(3),
    "revokedReason" TEXT,

    CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RefreshToken" (
    "id" UUID NOT NULL,
    "sessionId" UUID NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RefreshToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TwoFactor" (
    "userId" UUID NOT NULL,
    "secretEnc" TEXT NOT NULL,
    "confirmedAt" TIMESTAMP(3),
    "lastUsedStep" BIGINT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TwoFactor_pkey" PRIMARY KEY ("userId")
);

-- CreateTable
CREATE TABLE "Purchase" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "store" "PurchaseStore" NOT NULL,
    "productId" TEXT NOT NULL,
    "storeTxnId" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "amountPaise" INTEGER,
    "rawPayload" JSONB NOT NULL,
    "verifiedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Purchase_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Entitlement" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "kind" "EntitlementKind" NOT NULL,
    "examId" UUID,
    "startsAt" TIMESTAMP(3) NOT NULL,
    "endsAt" TIMESTAMP(3),
    "source" TEXT NOT NULL,
    "revokedAt" TIMESTAMP(3),

    CONSTRAINT "Entitlement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Lesson" (
    "id" UUID NOT NULL,
    "topicId" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "bodyMarkdown" TEXT NOT NULL,
    "readingMinutes" INTEGER NOT NULL,
    "sourceCitation" TEXT NOT NULL,
    "sourceUrl" TEXT,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "reviewedBy" UUID,
    "publishedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Lesson_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SparksLedger" (
    "id" BIGSERIAL NOT NULL,
    "userId" UUID NOT NULL,
    "delta" INTEGER NOT NULL,
    "source" "SparksSource" NOT NULL,
    "reference" TEXT NOT NULL,
    "idempotencyKey" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SparksLedger_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PointsLedger" (
    "id" BIGSERIAL NOT NULL,
    "userId" UUID NOT NULL,
    "delta" INTEGER NOT NULL,
    "reason" TEXT NOT NULL,
    "idempotencyKey" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PointsLedger_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TrophyLedger" (
    "id" BIGSERIAL NOT NULL,
    "userId" UUID NOT NULL,
    "seasonId" UUID NOT NULL,
    "delta" INTEGER NOT NULL,
    "reason" TEXT NOT NULL,
    "idempotencyKey" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TrophyLedger_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Exam" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "conductingBody" TEXT NOT NULL,
    "level" TEXT NOT NULL,
    "minQualification" TEXT NOT NULL,
    "fullPrep" BOOLEAN NOT NULL DEFAULT false,
    "description" TEXT NOT NULL,
    "stages" TEXT[],
    "patternMode" TEXT NOT NULL,
    "patternQuestions" INTEGER,
    "patternMinutes" INTEGER,
    "negativeMarking" BOOLEAN NOT NULL DEFAULT false,
    "officialUrl" TEXT NOT NULL,
    "notificationUrl" TEXT,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "sourceUrl" TEXT NOT NULL,
    "verifiedBy" UUID,
    "verifiedAt" TIMESTAMP(3),
    "lastCheckedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Exam_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EligibilityRule" (
    "id" UUID NOT NULL,
    "examId" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "ageAsOf" DATE NOT NULL,
    "minAge" INTEGER NOT NULL,
    "maxAgeByCommunity" JSONB NOT NULL,
    "relaxationYears" JSONB NOT NULL,
    "qualifications" TEXT[],
    "degreeSubjects" TEXT[],
    "pstmNote" TEXT,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "sourceUrl" TEXT NOT NULL,
    "verifiedBy" UUID,
    "verifiedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EligibilityRule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserExamChoice" (
    "userId" UUID NOT NULL,
    "examCode" TEXT NOT NULL,
    "isMain" BOOLEAN NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "UserExamChoice_pkey" PRIMARY KEY ("userId","examCode")
);

-- CreateTable
CREATE TABLE "OddsConfig" (
    "id" UUID NOT NULL,
    "game" TEXT NOT NULL,
    "version" INTEGER NOT NULL,
    "table" JSONB NOT NULL,
    "publishedBy" UUID NOT NULL,
    "publishedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "OddsConfig_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GameResult" (
    "id" UUID NOT NULL,
    "game" TEXT NOT NULL,
    "matchId" UUID,
    "userId" UUID NOT NULL,
    "ranked" BOOLEAN NOT NULL,
    "vsBot" BOOLEAN NOT NULL DEFAULT false,
    "outcome" JSONB NOT NULL,
    "oddsVersion" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "GameResult_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FeatureFlag" (
    "key" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT false,
    "rules" JSONB,
    "updatedBy" UUID NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "FeatureFlag_pkey" PRIMARY KEY ("key")
);

-- CreateTable
CREATE TABLE "EmergencySwitch" (
    "key" TEXT NOT NULL,
    "on" BOOLEAN NOT NULL DEFAULT false,
    "reason" TEXT,
    "updatedBy" UUID NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "EmergencySwitch_pkey" PRIMARY KEY ("key")
);

-- CreateTable
CREATE TABLE "UserTopicState" (
    "userId" UUID NOT NULL,
    "topicId" UUID NOT NULL,
    "litAt" TIMESTAMP(3),
    "steadyLevel" INTEGER NOT NULL DEFAULT 0,
    "goldAt" TIMESTAMP(3),
    "nextDueAt" TIMESTAMP(3),
    "dimState" "DimState" NOT NULL DEFAULT 'bright',
    "shieldUntil" TIMESTAMP(3),
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "UserTopicState_pkey" PRIMARY KEY ("userId","topicId")
);

-- CreateTable
CREATE TABLE "RoleAssignment" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "role" "Role" NOT NULL,
    "scopeId" UUID,
    "grantedBy" UUID NOT NULL,
    "grantedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "revokedAt" TIMESTAMP(3),

    CONSTRAINT "RoleAssignment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ApprovalRequest" (
    "id" UUID NOT NULL,
    "action" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "requestedBy" UUID NOT NULL,
    "approvedBy" UUID,
    "decidedAt" TIMESTAMP(3),
    "status" TEXT NOT NULL DEFAULT 'pending',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ApprovalRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Subject" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "order" INTEGER NOT NULL,

    CONSTRAINT "Subject_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Topic" (
    "id" UUID NOT NULL,
    "subjectId" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "order" INTEGER NOT NULL,

    CONSTRAINT "Topic_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TopicExamTag" (
    "topicId" UUID NOT NULL,
    "examCode" TEXT NOT NULL,

    CONSTRAINT "TopicExamTag_pkey" PRIMARY KEY ("topicId","examCode")
);

-- CreateTable
CREATE TABLE "TextbookRef" (
    "id" UUID NOT NULL,
    "topicId" UUID NOT NULL,
    "book" TEXT NOT NULL,
    "classLevel" INTEGER,
    "chapter" TEXT,
    "pages" TEXT,
    "url" TEXT,

    CONSTRAINT "TextbookRef_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GlossaryTerm" (
    "id" UUID NOT NULL,
    "term" TEXT NOT NULL,
    "meaning" TEXT NOT NULL,

    CONSTRAINT "GlossaryTerm_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "User" (
    "id" UUID NOT NULL,
    "email" TEXT NOT NULL,
    "nickname" TEXT,
    "district" TEXT,
    "calmMode" BOOLEAN NOT NULL DEFAULT false,
    "liteMode" BOOLEAN,
    "hideFromLeaderboards" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletionRequestedAt" TIMESTAMP(3),
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserProfile" (
    "userId" UUID NOT NULL,
    "dateOfBirth" DATE NOT NULL,
    "qualification" TEXT NOT NULL,
    "degreeSubject" TEXT,
    "community" TEXT NOT NULL,
    "pstm" BOOLEAN NOT NULL,
    "specialCategories" TEXT[],
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "UserProfile_pkey" PRIMARY KEY ("userId")
);

-- CreateTable
CREATE TABLE "Consent" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "purpose" TEXT NOT NULL,
    "granted" BOOLEAN NOT NULL,
    "noticeVersion" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Consent_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "IdempotencyRecord_expiresAt_idx" ON "IdempotencyRecord"("expiresAt");

-- CreateIndex
CREATE INDEX "SyncReceipt_userId_acceptedAt_idx" ON "SyncReceipt"("userId", "acceptedAt");

-- CreateIndex
CREATE INDEX "AuditLog_actorId_at_idx" ON "AuditLog"("actorId", "at");

-- CreateIndex
CREATE INDEX "AuditLog_action_at_idx" ON "AuditLog"("action", "at");

-- CreateIndex
CREATE INDEX "OtpCode_email_purpose_createdAt_idx" ON "OtpCode"("email", "purpose", "createdAt");

-- CreateIndex
CREATE INDEX "OtpCode_expiresAt_idx" ON "OtpCode"("expiresAt");

-- CreateIndex
CREATE INDEX "Device_userId_idx" ON "Device"("userId");

-- CreateIndex
CREATE INDEX "Session_userId_idx" ON "Session"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "RefreshToken_tokenHash_key" ON "RefreshToken"("tokenHash");

-- CreateIndex
CREATE INDEX "RefreshToken_sessionId_idx" ON "RefreshToken"("sessionId");

-- CreateIndex
CREATE UNIQUE INDEX "Purchase_storeTxnId_key" ON "Purchase"("storeTxnId");

-- CreateIndex
CREATE INDEX "Purchase_userId_idx" ON "Purchase"("userId");

-- CreateIndex
CREATE INDEX "Entitlement_userId_kind_idx" ON "Entitlement"("userId", "kind");

-- CreateIndex
CREATE INDEX "Lesson_topicId_status_idx" ON "Lesson"("topicId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "Lesson_topicId_version_key" ON "Lesson"("topicId", "version");

-- CreateIndex
CREATE UNIQUE INDEX "SparksLedger_idempotencyKey_key" ON "SparksLedger"("idempotencyKey");

-- CreateIndex
CREATE INDEX "SparksLedger_userId_createdAt_idx" ON "SparksLedger"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "PointsLedger_idempotencyKey_key" ON "PointsLedger"("idempotencyKey");

-- CreateIndex
CREATE INDEX "PointsLedger_userId_createdAt_idx" ON "PointsLedger"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "TrophyLedger_idempotencyKey_key" ON "TrophyLedger"("idempotencyKey");

-- CreateIndex
CREATE INDEX "TrophyLedger_userId_seasonId_idx" ON "TrophyLedger"("userId", "seasonId");

-- CreateIndex
CREATE UNIQUE INDEX "Exam_code_key" ON "Exam"("code");

-- CreateIndex
CREATE UNIQUE INDEX "EligibilityRule_examId_version_key" ON "EligibilityRule"("examId", "version");

-- CreateIndex
CREATE INDEX "UserExamChoice_userId_idx" ON "UserExamChoice"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "OddsConfig_game_version_key" ON "OddsConfig"("game", "version");

-- CreateIndex
CREATE INDEX "GameResult_userId_game_createdAt_idx" ON "GameResult"("userId", "game", "createdAt");

-- CreateIndex
CREATE INDEX "UserTopicState_nextDueAt_idx" ON "UserTopicState"("nextDueAt");

-- CreateIndex
CREATE INDEX "RoleAssignment_userId_role_idx" ON "RoleAssignment"("userId", "role");

-- CreateIndex
CREATE UNIQUE INDEX "Subject_code_key" ON "Subject"("code");

-- CreateIndex
CREATE UNIQUE INDEX "Topic_code_key" ON "Topic"("code");

-- CreateIndex
CREATE INDEX "Topic_subjectId_order_idx" ON "Topic"("subjectId", "order");

-- CreateIndex
CREATE INDEX "TopicExamTag_examCode_idx" ON "TopicExamTag"("examCode");

-- CreateIndex
CREATE INDEX "TextbookRef_topicId_idx" ON "TextbookRef"("topicId");

-- CreateIndex
CREATE UNIQUE INDEX "GlossaryTerm_term_key" ON "GlossaryTerm"("term");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "Consent_userId_purpose_createdAt_idx" ON "Consent"("userId", "purpose", "createdAt");

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_deviceId_fkey" FOREIGN KEY ("deviceId") REFERENCES "Device"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RefreshToken" ADD CONSTRAINT "RefreshToken_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "Session"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EligibilityRule" ADD CONSTRAINT "EligibilityRule_examId_fkey" FOREIGN KEY ("examId") REFERENCES "Exam"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Topic" ADD CONSTRAINT "Topic_subjectId_fkey" FOREIGN KEY ("subjectId") REFERENCES "Subject"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TopicExamTag" ADD CONSTRAINT "TopicExamTag_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES "Topic"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TextbookRef" ADD CONSTRAINT "TextbookRef_topicId_fkey" FOREIGN KEY ("topicId") REFERENCES "Topic"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserProfile" ADD CONSTRAINT "UserProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Consent" ADD CONSTRAINT "Consent_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
