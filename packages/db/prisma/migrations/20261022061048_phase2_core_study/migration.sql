-- CreateEnum
CREATE TYPE "QuestionKind" AS ENUM ('single_choice', 'multi_choice', 'numeric', 'descriptive');

-- CreateEnum
CREATE TYPE "MockKind" AS ENUM ('full', 'sectional', 'state_mock_sunday');

-- CreateEnum
CREATE TYPE "MockAttemptStatus" AS ENUM ('in_progress', 'submitted', 'expired');

-- CreateEnum
CREATE TYPE "PaperAnswerMode" AS ENUM ('objective_omr', 'objective_cbt', 'descriptive');

-- CreateEnum
CREATE TYPE "DateStatus" AS ENUM ('unknown', 'tentative', 'confirmed');

-- CreateEnum
CREATE TYPE "CheckKind" AS ENUM ('lit', 'recall', 'relight', 'gold');

-- CreateEnum
CREATE TYPE "ActionSource" AS ENUM ('online', 'offline_sync');

-- CreateEnum
CREATE TYPE "PracticeMode" AS ENUM ('practice', 'pyq', 'mistakes', 'drill');

-- AlterTable
ALTER TABLE "Exam" ADD COLUMN     "familyId" UUID;

-- AlterTable
ALTER TABLE "TopicExamTag" ADD COLUMN     "priority" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "UserExamChoice" ADD COLUMN     "attemptCycleId" UUID;

-- AlterTable
ALTER TABLE "UserTopicState" ADD COLUMN     "dimSince" TIMESTAMP(3),
ADD COLUMN     "lastCheckAt" TIMESTAMP(3),
ADD COLUMN     "lessonCompletedAt" TIMESTAMP(3),
ADD COLUMN     "rowVersion" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "steadyEarnedAt" TIMESTAMP(3);

-- CreateTable
CREATE TABLE "Source" (
    "id" UUID NOT NULL,
    "citation" TEXT NOT NULL,
    "url" TEXT,
    "kind" TEXT NOT NULL,
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
CREATE INDEX "TopicCheck_userId_topicId_issuedAt_idx" ON "TopicCheck"("userId", "topicId", "issuedAt");

-- CreateIndex
CREATE UNIQUE INDEX "RingEvent_clientActionId_key" ON "RingEvent"("clientActionId");

-- CreateIndex
CREATE INDEX "RingEvent_userId_at_idx" ON "RingEvent"("userId", "at");

-- CreateIndex
CREATE INDEX "RingEvent_userId_topicId_at_idx" ON "RingEvent"("userId", "topicId", "at");

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
CREATE UNIQUE INDEX "StudyLog_clientActionId_key" ON "StudyLog"("clientActionId");

-- CreateIndex
CREATE INDEX "StudyLog_userId_istDay_idx" ON "StudyLog"("userId", "istDay");

-- CreateIndex
CREATE INDEX "PracticeSession_userId_startedAt_idx" ON "PracticeSession"("userId", "startedAt");

-- CreateIndex
CREATE INDEX "PracticeAnswer_userId_istDay_idx" ON "PracticeAnswer"("userId", "istDay");

-- CreateIndex
CREATE INDEX "PracticeAnswer_userId_correct_answeredAt_idx" ON "PracticeAnswer"("userId", "correct", "answeredAt");

-- CreateIndex
CREATE INDEX "PracticeAnswer_userId_topicId_idx" ON "PracticeAnswer"("userId", "topicId");

-- CreateIndex
CREATE INDEX "ConceptDrill_userId_status_idx" ON "ConceptDrill"("userId", "status");

-- CreateIndex
CREATE INDEX "SundayReport_userId_createdAt_idx" ON "SundayReport"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "SundayReport_userId_weekStart_key" ON "SundayReport"("userId", "weekStart");

-- CreateIndex
CREATE INDEX "UserTopicState_userId_updatedAt_idx" ON "UserTopicState"("userId", "updatedAt");

-- CreateIndex
CREATE INDEX "UserTopicState_dimState_dimSince_idx" ON "UserTopicState"("dimState", "dimSince");

-- AddForeignKey
ALTER TABLE "QuestionVersion" ADD CONSTRAINT "QuestionVersion_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES "Question"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MockAttempt" ADD CONSTRAINT "MockAttempt_mockId_fkey" FOREIGN KEY ("mockId") REFERENCES "Mock"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MockAnswer" ADD CONSTRAINT "MockAnswer_attemptId_fkey" FOREIGN KEY ("attemptId") REFERENCES "MockAttempt"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Exam" ADD CONSTRAINT "Exam_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES "ExamFamily"("id") ON DELETE SET NULL ON UPDATE CASCADE;

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
