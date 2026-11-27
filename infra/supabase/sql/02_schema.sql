-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "EntitlementKind" AS ENUM ('pro', 'exam_pass', 'season_pass');

-- CreateEnum
CREATE TYPE "PurchaseStore" AS ENUM ('google_play', 'app_store', 'razorpay', 'invoice');

-- CreateEnum
CREATE TYPE "QuestionKind" AS ENUM ('single_choice', 'multi_choice', 'numeric', 'descriptive');

-- CreateEnum
CREATE TYPE "SparksSource" AS ENUM ('purchase', 'milestone', 'spend', 'reversal');

-- CreateEnum
CREATE TYPE "MockKind" AS ENUM ('full', 'sectional', 'state_mock_sunday');

-- CreateEnum
CREATE TYPE "MockAttemptStatus" AS ENUM ('in_progress', 'submitted', 'expired');

-- CreateEnum
CREATE TYPE "PaperAnswerMode" AS ENUM ('objective_omr', 'objective_cbt', 'descriptive');

-- CreateEnum
CREATE TYPE "DateStatus" AS ENUM ('unknown', 'tentative', 'confirmed');

-- CreateEnum
CREATE TYPE "DimState" AS ENUM ('bright', 'dimming', 'dim');

-- CreateEnum
CREATE TYPE "CheckKind" AS ENUM ('lit', 'recall', 'relight', 'gold');

-- CreateEnum
CREATE TYPE "ActionSource" AS ENUM ('online', 'offline_sync');

-- CreateEnum
CREATE TYPE "PracticeMode" AS ENUM ('practice', 'pyq', 'mistakes', 'drill');

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
    "failedAttempts" INTEGER NOT NULL DEFAULT 0,
    "lockedUntil" TIMESTAMP(3),
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
CREATE TABLE "Source" (
    "id" UUID NOT NULL,
    "citation" TEXT NOT NULL,
    "url" TEXT,
    "kind" TEXT NOT NULL,
    "setName" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Source_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Question" (
    "id" UUID NOT NULL,
    "topicId" UUID NOT NULL,
    "kind" "QuestionKind" NOT NULL DEFAULT 'single_choice',
    "language" TEXT NOT NULL DEFAULT 'en',
    "difficulty" INTEGER NOT NULL DEFAULT 3,
    "currentVersion" INTEGER NOT NULL DEFAULT 1,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "pyqExamCode" TEXT,
    "pyqPaperCode" TEXT,
    "pyqYear" INTEGER,
    "pyqNumber" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Question_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "QuestionVersion" (
    "id" UUID NOT NULL,
    "questionId" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "stem" TEXT NOT NULL,
    "options" JSONB NOT NULL,
    "correctOptionIds" TEXT[],
    "explanationMarkdown" TEXT NOT NULL,
    "whyWrong" JSONB,
    "affectedNote" TEXT,
    "sourceId" UUID,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "reviewedBy" UUID,
    "publishedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "QuestionVersion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Correction" (
    "id" UUID NOT NULL,
    "questionId" UUID NOT NULL,
    "fromVersion" INTEGER NOT NULL,
    "toVersion" INTEGER NOT NULL,
    "summary" TEXT NOT NULL,
    "publishedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Correction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "QuestionReport" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "questionId" UUID NOT NULL,
    "questionVersion" INTEGER NOT NULL,
    "reason" TEXT NOT NULL,
    "note" TEXT,
    "status" TEXT NOT NULL DEFAULT 'received',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "QuestionReport_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ContentPack" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "examCode" TEXT NOT NULL,
    "subjectCode" TEXT,
    "version" INTEGER NOT NULL,
    "url" TEXT NOT NULL,
    "sha256" TEXT NOT NULL,
    "sizeBytes" INTEGER NOT NULL,
    "tier" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "publishedAt" TIMESTAMP(3),

    CONSTRAINT "ContentPack_pkey" PRIMARY KEY ("id")
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
CREATE TABLE "XpAward" (
    "id" BIGSERIAL NOT NULL,
    "userId" UUID NOT NULL,
    "amount" INTEGER NOT NULL,
    "reason" TEXT NOT NULL,
    "sourceKey" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "XpAward_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserTrophy" (
    "userId" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "earnedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "UserTrophy_pkey" PRIMARY KEY ("userId","code")
);

-- CreateTable
CREATE TABLE "LeaderboardOptIn" (
    "userId" UUID NOT NULL,
    "optIn" BOOLEAN NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LeaderboardOptIn_pkey" PRIMARY KEY ("userId")
);

-- CreateTable
CREATE TABLE "Mock" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "examCode" TEXT NOT NULL,
    "paperId" UUID NOT NULL,
    "schemeVersion" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "kind" "MockKind" NOT NULL,
    "sections" JSONB NOT NULL,
    "opensAt" TIMESTAMP(3),
    "lateJoinUntil" TIMESTAMP(3),
    "closesAt" TIMESTAMP(3),
    "rankPublishAt" TIMESTAMP(3),
    "free" BOOLEAN NOT NULL DEFAULT false,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Mock_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MockAttempt" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "mockId" UUID NOT NULL,
    "mode" TEXT NOT NULL,
    "status" "MockAttemptStatus" NOT NULL DEFAULT 'in_progress',
    "startedAt" TIMESTAMP(3) NOT NULL,
    "deadlineAt" TIMESTAMP(3) NOT NULL,
    "submittedAt" TIMESTAMP(3),
    "ranked" BOOLEAN NOT NULL DEFAULT false,
    "schemeVersion" INTEGER NOT NULL,
    "istMonth" TEXT NOT NULL,
    "scoreNum" INTEGER,
    "scoreDen" INTEGER,
    "correct" INTEGER,
    "wrong" INTEGER,
    "unanswered" INTEGER,
    "sectionResults" JSONB,

    CONSTRAINT "MockAttempt_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MockAnswer" (
    "attemptId" UUID NOT NULL,
    "questionId" UUID NOT NULL,
    "chosenOptionIds" TEXT[],
    "markedForReview" BOOLEAN NOT NULL DEFAULT false,
    "savedAt" TIMESTAMP(3) NOT NULL,
    "clientAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MockAnswer_pkey" PRIMARY KEY ("attemptId","questionId")
);

-- CreateTable
CREATE TABLE "MockAllowanceUse" (
    "userId" UUID NOT NULL,
    "istMonth" TEXT NOT NULL,
    "attemptId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "MockAllowanceUse_pkey" PRIMARY KEY ("userId","istMonth")
);

-- CreateTable
CREATE TABLE "MockRank" (
    "mockId" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "rank" INTEGER NOT NULL,
    "percentile" INTEGER NOT NULL,
    "candidates" INTEGER NOT NULL,
    "publishedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MockRank_pkey" PRIMARY KEY ("mockId","userId")
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
    "familyId" UUID,

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
    "attemptCycleId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "UserExamChoice_pkey" PRIMARY KEY ("userId","examCode")
);

-- CreateTable
CREATE TABLE "ExamFamily" (
    "id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "rankScope" TEXT NOT NULL,
    "rankTitles" JSONB NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "sourceUrl" TEXT NOT NULL,
    "verifiedBy" UUID,
    "verifiedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ExamFamily_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ExamStage" (
    "id" UUID NOT NULL,
    "examId" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "order" INTEGER NOT NULL,

    CONSTRAINT "ExamStage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Paper" (
    "id" UUID NOT NULL,
    "stageId" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "order" INTEGER NOT NULL,
    "answerMode" "PaperAnswerMode" NOT NULL,
    "contentLanguage" TEXT NOT NULL DEFAULT 'en',
    "qualifyingOnly" BOOLEAN NOT NULL DEFAULT false,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "sourceUrl" TEXT NOT NULL,
    "verifiedBy" UUID,
    "verifiedAt" TIMESTAMP(3),

    CONSTRAINT "Paper_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MarkingScheme" (
    "id" UUID NOT NULL,
    "paperId" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "durationMinutes" INTEGER NOT NULL,
    "totalQuestions" INTEGER NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'draft',
    "sourceUrl" TEXT NOT NULL,
    "verifiedBy" UUID,
    "verifiedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "MarkingScheme_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PaperSection" (
    "id" UUID NOT NULL,
    "schemeId" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "order" INTEGER NOT NULL,
    "questionCount" INTEGER NOT NULL,
    "attemptLimit" INTEGER,
    "correctMarksNum" INTEGER NOT NULL,
    "correctMarksDen" INTEGER NOT NULL DEFAULT 1,
    "wrongPenaltyNum" INTEGER NOT NULL DEFAULT 0,
    "wrongPenaltyDen" INTEGER NOT NULL DEFAULT 1,
    "sectionMinutes" INTEGER,

    CONSTRAINT "PaperSection_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ExamAttemptCycle" (
    "id" UUID NOT NULL,
    "examId" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'expected',
    "stageDates" JSONB NOT NULL,
    "sourceUrl" TEXT NOT NULL,
    "verifiedBy" UUID,
    "verifiedAt" TIMESTAMP(3),
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ExamAttemptCycle_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ExamWatchChange" (
    "id" UUID NOT NULL,
    "watchUuid" UUID NOT NULL,
    "changeId" TEXT NOT NULL,
    "watchUrl" TEXT NOT NULL,
    "title" TEXT,
    "diffSummary" TEXT,
    "receivedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "reviewedBy" UUID,
    "reviewedAt" TIMESTAMP(3),
    "reviewNote" TEXT,
    "alertId" UUID,

    CONSTRAINT "ExamWatchChange_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ExamAlert" (
    "id" UUID NOT NULL,
    "examId" UUID NOT NULL,
    "changeId" UUID,
    "kind" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "summary" TEXT NOT NULL,
    "officialUrl" TEXT NOT NULL,
    "publishedBy" UUID NOT NULL,
    "publishedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ExamAlert_pkey" PRIMARY KEY ("id")
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
    "lessonCompletedAt" TIMESTAMP(3),
    "steadyEarnedAt" TIMESTAMP(3),
    "dimSince" TIMESTAMP(3),
    "lastCheckAt" TIMESTAMP(3),
    "rowVersion" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "UserTopicState_pkey" PRIMARY KEY ("userId","topicId")
);

-- CreateTable
CREATE TABLE "TopicCheck" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "topicId" UUID NOT NULL,
    "kind" "CheckKind" NOT NULL,
    "questionIds" UUID[],
    "passMark" INTEGER NOT NULL,
    "issuedAt" TIMESTAMP(3) NOT NULL,
    "deadlineAt" TIMESTAMP(3),
    "submittedAt" TIMESTAMP(3),
    "correct" INTEGER,
    "passed" BOOLEAN,
    "source" "ActionSource" NOT NULL DEFAULT 'online',
    "configVersion" TEXT NOT NULL,

    CONSTRAINT "TopicCheck_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RingEvent" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "topicId" UUID NOT NULL,
    "kind" TEXT NOT NULL,
    "at" TIMESTAMP(3) NOT NULL,
    "source" "ActionSource" NOT NULL,
    "clientActionId" UUID,
    "checkId" UUID,
    "details" JSONB,

    CONSTRAINT "RingEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserRank" (
    "userId" UUID NOT NULL,
    "familyCode" TEXT,
    "level" INTEGER NOT NULL,
    "xp" INTEGER NOT NULL,
    "configVersion" TEXT NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "UserRank_pkey" PRIMARY KEY ("userId")
);

-- CreateTable
CREATE TABLE "PushToken" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "deviceId" TEXT NOT NULL,
    "platform" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSeenAt" TIMESTAMP(3) NOT NULL,
    "revokedAt" TIMESTAMP(3),

    CONSTRAINT "PushToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AlertPreference" (
    "userId" UUID NOT NULL,
    "studyReminders" BOOLEAN NOT NULL DEFAULT true,
    "examAlerts" BOOLEAN NOT NULL DEFAULT true,
    "offers" BOOLEAN NOT NULL DEFAULT false,
    "quietEnabled" BOOLEAN NOT NULL DEFAULT true,
    "quietStartMinute" INTEGER NOT NULL,
    "quietEndMinute" INTEGER NOT NULL,
    "morningAlertMinute" INTEGER NOT NULL,
    "dailyLimit" INTEGER NOT NULL DEFAULT 3,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AlertPreference_pkey" PRIMARY KEY ("userId")
);

-- CreateTable
CREATE TABLE "SendLog" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "category" TEXT NOT NULL,
    "templateKey" TEXT NOT NULL,
    "dedupeKey" TEXT NOT NULL,
    "istDay" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sentAt" TIMESTAMP(3),

    CONSTRAINT "SendLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Plan" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "weekdayMinutes" INTEGER NOT NULL,
    "weekendMinutes" INTEGER NOT NULL,
    "pocketMinutes" INTEGER NOT NULL DEFAULT 10,
    "balance" INTEGER NOT NULL DEFAULT 0,
    "starterPathUntil" TEXT,
    "stretch" TEXT NOT NULL DEFAULT 'normal',
    "lastActiveIstDay" TEXT,
    "lastRebalancedAt" TIMESTAMP(3),
    "configVersion" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Plan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PlanExam" (
    "planId" UUID NOT NULL,
    "examCode" TEXT NOT NULL,
    "attemptCycleId" UUID,
    "examDate" DATE,
    "priority" INTEGER NOT NULL,

    CONSTRAINT "PlanExam_pkey" PRIMARY KEY ("planId","examCode")
);

-- CreateTable
CREATE TABLE "PlanItem" (
    "id" UUID NOT NULL,
    "planId" UUID NOT NULL,
    "istDay" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "examCode" TEXT,
    "topicId" UUID,
    "title" TEXT NOT NULL,
    "minutes" INTEGER NOT NULL,
    "order" INTEGER NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "doneAt" TIMESTAMP(3),

    CONSTRAINT "PlanItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StudyLog" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "kind" TEXT NOT NULL,
    "topicId" UUID,
    "minutes" INTEGER NOT NULL DEFAULT 0,
    "at" TIMESTAMP(3) NOT NULL,
    "istDay" TEXT NOT NULL,
    "source" TEXT NOT NULL,
    "clientActionId" UUID,
    "details" JSONB,

    CONSTRAINT "StudyLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PracticeSession" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "mode" "PracticeMode" NOT NULL,
    "examCode" TEXT NOT NULL,
    "subjectCode" TEXT,
    "topicId" UUID,
    "drillId" UUID,
    "questionIds" UUID[],
    "startedAt" TIMESTAMP(3) NOT NULL,
    "closedAt" TIMESTAMP(3),

    CONSTRAINT "PracticeSession_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PracticeAnswer" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "clientActionId" UUID NOT NULL,
    "sessionId" UUID,
    "questionId" UUID NOT NULL,
    "questionVersion" INTEGER NOT NULL,
    "topicId" UUID NOT NULL,
    "mode" "PracticeMode" NOT NULL,
    "chosenOptionIds" TEXT[],
    "correct" BOOLEAN NOT NULL,
    "timeMs" INTEGER NOT NULL,
    "confidence" TEXT,
    "answeredAt" TIMESTAMP(3) NOT NULL,
    "istDay" TEXT NOT NULL,
    "countsToLimit" BOOLEAN NOT NULL,
    "studyLogOnly" BOOLEAN NOT NULL DEFAULT false,
    "source" TEXT NOT NULL DEFAULT 'online',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PracticeAnswer_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PracticeDayCounter" (
    "userId" UUID NOT NULL,
    "istDay" TEXT NOT NULL,
    "counted" INTEGER NOT NULL DEFAULT 0,
    "limitSheetShown" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "PracticeDayCounter_pkey" PRIMARY KEY ("userId","istDay")
);

-- CreateTable
CREATE TABLE "MistakeTally" (
    "userId" UUID NOT NULL,
    "topicId" UUID NOT NULL,
    "wrongCount" INTEGER NOT NULL DEFAULT 0,
    "windowStart" TIMESTAMP(3) NOT NULL,
    "lastWrongAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MistakeTally_pkey" PRIMARY KEY ("userId","topicId")
);

-- CreateTable
CREATE TABLE "ConceptDrill" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "topicId" UUID NOT NULL,
    "reason" TEXT NOT NULL,
    "questionIds" UUID[],
    "status" TEXT NOT NULL DEFAULT 'open',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ConceptDrill_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ExpoChallenge" (
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
CREATE TABLE "StickerCode" (
    "userId" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL,
    "redeemedAt" TIMESTAMP(3),
    "redeemedBy" UUID,

    CONSTRAINT "StickerCode_pkey" PRIMARY KEY ("userId")
);

-- CreateTable
CREATE TABLE "ReadinessSnapshot" (
    "userId" UUID NOT NULL,
    "examCode" TEXT NOT NULL,
    "istDay" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "coverage" INTEGER,
    "memory" INTEGER,
    "examPerformance" INTEGER,
    "speed" INTEGER,
    "litPct" INTEGER NOT NULL,
    "steadyPct" INTEGER NOT NULL,
    "goldPct" INTEGER NOT NULL,
    "configVersion" TEXT NOT NULL,
    "computedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ReadinessSnapshot_pkey" PRIMARY KEY ("userId","examCode","istDay")
);

-- CreateTable
CREATE TABLE "SundayReport" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "weekStart" TEXT NOT NULL,
    "tier" TEXT NOT NULL,
    "body" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sentAt" TIMESTAMP(3),

    CONSTRAINT "SundayReport_pkey" PRIMARY KEY ("id")
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
    "priority" INTEGER NOT NULL DEFAULT 0,

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
    "email" TEXT,
    "isGuest" BOOLEAN NOT NULL DEFAULT false,
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
CREATE INDEX "RateLimitCounter_resetAt_idx" ON "RateLimitCounter"("resetAt");

-- CreateIndex
CREATE INDEX "OneTimeToken_expiresAt_idx" ON "OneTimeToken"("expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "JobQueueItem_jobId_key" ON "JobQueueItem"("jobId");

-- CreateIndex
CREATE INDEX "JobQueueItem_queue_status_runAt_idx" ON "JobQueueItem"("queue", "status", "runAt");

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
CREATE UNIQUE INDEX "Source_setName_key" ON "Source"("setName");

-- CreateIndex
CREATE INDEX "Question_topicId_status_difficulty_idx" ON "Question"("topicId", "status", "difficulty");

-- CreateIndex
CREATE INDEX "Question_pyqExamCode_pyqYear_status_idx" ON "Question"("pyqExamCode", "pyqYear", "status");

-- CreateIndex
CREATE UNIQUE INDEX "QuestionVersion_questionId_version_key" ON "QuestionVersion"("questionId", "version");

-- CreateIndex
CREATE INDEX "Correction_questionId_idx" ON "Correction"("questionId");

-- CreateIndex
CREATE INDEX "QuestionReport_questionId_status_idx" ON "QuestionReport"("questionId", "status");

-- CreateIndex
CREATE INDEX "QuestionReport_userId_createdAt_idx" ON "QuestionReport"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "ContentPack_examCode_status_idx" ON "ContentPack"("examCode", "status");

-- CreateIndex
CREATE UNIQUE INDEX "ContentPack_code_version_key" ON "ContentPack"("code", "version");

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
CREATE INDEX "XpAward_createdAt_idx" ON "XpAward"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "XpAward_userId_sourceKey_key" ON "XpAward"("userId", "sourceKey");

-- CreateIndex
CREATE UNIQUE INDEX "Mock_code_key" ON "Mock"("code");

-- CreateIndex
CREATE INDEX "Mock_examCode_status_idx" ON "Mock"("examCode", "status");

-- CreateIndex
CREATE INDEX "Mock_kind_opensAt_idx" ON "Mock"("kind", "opensAt");

-- CreateIndex
CREATE INDEX "MockAttempt_userId_startedAt_idx" ON "MockAttempt"("userId", "startedAt");

-- CreateIndex
CREATE INDEX "MockAttempt_mockId_ranked_status_idx" ON "MockAttempt"("mockId", "ranked", "status");

-- CreateIndex
CREATE UNIQUE INDEX "MockAllowanceUse_attemptId_key" ON "MockAllowanceUse"("attemptId");

-- CreateIndex
CREATE INDEX "MockRank_mockId_rank_idx" ON "MockRank"("mockId", "rank");

-- CreateIndex
CREATE UNIQUE INDEX "Exam_code_key" ON "Exam"("code");

-- CreateIndex
CREATE UNIQUE INDEX "EligibilityRule_examId_version_key" ON "EligibilityRule"("examId", "version");

-- CreateIndex
CREATE INDEX "UserExamChoice_userId_idx" ON "UserExamChoice"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "ExamFamily_code_key" ON "ExamFamily"("code");

-- CreateIndex
CREATE UNIQUE INDEX "ExamStage_examId_code_key" ON "ExamStage"("examId", "code");

-- CreateIndex
CREATE UNIQUE INDEX "Paper_stageId_code_key" ON "Paper"("stageId", "code");

-- CreateIndex
CREATE UNIQUE INDEX "MarkingScheme_paperId_version_key" ON "MarkingScheme"("paperId", "version");

-- CreateIndex
CREATE UNIQUE INDEX "PaperSection_schemeId_code_key" ON "PaperSection"("schemeId", "code");

-- CreateIndex
CREATE UNIQUE INDEX "ExamAttemptCycle_examId_code_key" ON "ExamAttemptCycle"("examId", "code");

-- CreateIndex
CREATE INDEX "ExamWatchChange_status_receivedAt_idx" ON "ExamWatchChange"("status", "receivedAt");

-- CreateIndex
CREATE UNIQUE INDEX "ExamWatchChange_watchUuid_changeId_key" ON "ExamWatchChange"("watchUuid", "changeId");

-- CreateIndex
CREATE UNIQUE INDEX "ExamAlert_changeId_key" ON "ExamAlert"("changeId");

-- CreateIndex
CREATE INDEX "ExamAlert_examId_publishedAt_idx" ON "ExamAlert"("examId", "publishedAt");

-- CreateIndex
CREATE UNIQUE INDEX "OddsConfig_game_version_key" ON "OddsConfig"("game", "version");

-- CreateIndex
CREATE INDEX "GameResult_userId_game_createdAt_idx" ON "GameResult"("userId", "game", "createdAt");

-- CreateIndex
CREATE INDEX "UserTopicState_nextDueAt_idx" ON "UserTopicState"("nextDueAt");

-- CreateIndex
CREATE INDEX "UserTopicState_userId_updatedAt_idx" ON "UserTopicState"("userId", "updatedAt");

-- CreateIndex
CREATE INDEX "UserTopicState_dimState_dimSince_idx" ON "UserTopicState"("dimState", "dimSince");

-- CreateIndex
CREATE INDEX "TopicCheck_userId_topicId_issuedAt_idx" ON "TopicCheck"("userId", "topicId", "issuedAt");

-- CreateIndex
CREATE INDEX "RingEvent_userId_at_idx" ON "RingEvent"("userId", "at");

-- CreateIndex
CREATE INDEX "RingEvent_userId_topicId_at_idx" ON "RingEvent"("userId", "topicId", "at");

-- CreateIndex
CREATE UNIQUE INDEX "RingEvent_userId_clientActionId_key" ON "RingEvent"("userId", "clientActionId");

-- CreateIndex
CREATE UNIQUE INDEX "PushToken_token_key" ON "PushToken"("token");

-- CreateIndex
CREATE UNIQUE INDEX "PushToken_userId_deviceId_key" ON "PushToken"("userId", "deviceId");

-- CreateIndex
CREATE UNIQUE INDEX "SendLog_dedupeKey_key" ON "SendLog"("dedupeKey");

-- CreateIndex
CREATE INDEX "SendLog_userId_istDay_category_idx" ON "SendLog"("userId", "istDay", "category");

-- CreateIndex
CREATE UNIQUE INDEX "Plan_userId_key" ON "Plan"("userId");

-- CreateIndex
CREATE INDEX "PlanItem_planId_istDay_idx" ON "PlanItem"("planId", "istDay");

-- CreateIndex
CREATE INDEX "StudyLog_userId_istDay_idx" ON "StudyLog"("userId", "istDay");

-- CreateIndex
CREATE UNIQUE INDEX "StudyLog_userId_clientActionId_key" ON "StudyLog"("userId", "clientActionId");

-- CreateIndex
CREATE INDEX "PracticeSession_userId_startedAt_idx" ON "PracticeSession"("userId", "startedAt");

-- CreateIndex
CREATE INDEX "PracticeAnswer_userId_istDay_idx" ON "PracticeAnswer"("userId", "istDay");

-- CreateIndex
CREATE INDEX "PracticeAnswer_userId_correct_answeredAt_idx" ON "PracticeAnswer"("userId", "correct", "answeredAt");

-- CreateIndex
CREATE INDEX "PracticeAnswer_userId_topicId_idx" ON "PracticeAnswer"("userId", "topicId");

-- CreateIndex
CREATE UNIQUE INDEX "PracticeAnswer_userId_clientActionId_key" ON "PracticeAnswer"("userId", "clientActionId");

-- CreateIndex
CREATE INDEX "ConceptDrill_userId_status_idx" ON "ConceptDrill"("userId", "status");

-- CreateIndex
CREATE INDEX "ExpoChallenge_userId_createdAt_idx" ON "ExpoChallenge"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "StickerCode_code_key" ON "StickerCode"("code");

-- CreateIndex
CREATE INDEX "SundayReport_userId_createdAt_idx" ON "SundayReport"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "SundayReport_userId_weekStart_key" ON "SundayReport"("userId", "weekStart");

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
ALTER TABLE "QuestionVersion" ADD CONSTRAINT "QuestionVersion_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES "Question"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MockAttempt" ADD CONSTRAINT "MockAttempt_mockId_fkey" FOREIGN KEY ("mockId") REFERENCES "Mock"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MockAnswer" ADD CONSTRAINT "MockAnswer_attemptId_fkey" FOREIGN KEY ("attemptId") REFERENCES "MockAttempt"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Exam" ADD CONSTRAINT "Exam_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES "ExamFamily"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EligibilityRule" ADD CONSTRAINT "EligibilityRule_examId_fkey" FOREIGN KEY ("examId") REFERENCES "Exam"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ExamStage" ADD CONSTRAINT "ExamStage_examId_fkey" FOREIGN KEY ("examId") REFERENCES "Exam"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Paper" ADD CONSTRAINT "Paper_stageId_fkey" FOREIGN KEY ("stageId") REFERENCES "ExamStage"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MarkingScheme" ADD CONSTRAINT "MarkingScheme_paperId_fkey" FOREIGN KEY ("paperId") REFERENCES "Paper"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PaperSection" ADD CONSTRAINT "PaperSection_schemeId_fkey" FOREIGN KEY ("schemeId") REFERENCES "MarkingScheme"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ExamAttemptCycle" ADD CONSTRAINT "ExamAttemptCycle_examId_fkey" FOREIGN KEY ("examId") REFERENCES "Exam"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ExamAlert" ADD CONSTRAINT "ExamAlert_examId_fkey" FOREIGN KEY ("examId") REFERENCES "Exam"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlanExam" ADD CONSTRAINT "PlanExam_planId_fkey" FOREIGN KEY ("planId") REFERENCES "Plan"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlanItem" ADD CONSTRAINT "PlanItem_planId_fkey" FOREIGN KEY ("planId") REFERENCES "Plan"("id") ON DELETE CASCADE ON UPDATE CASCADE;

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

