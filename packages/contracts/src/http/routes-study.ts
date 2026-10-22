import { z } from "../zod.js";
import { ErrorEnvelope } from "../errors.js";
import { CursorQuery, type HmRoute } from "./common.js";
import { OkResponse } from "./auth.js";
import {
  ApproveExamChangeBody,
  ExamAlertPage,
  ExamChange,
  ExamChangePage,
  ExamChangeQuery,
  ExamCode,
  ExamStructure,
  RejectExamChangeBody,
  SiteChangeAck,
  SiteChangeWebhookBody,
} from "./exams.js";
import { ContentPackList, ContentPackQuery, QuestionReportAck, QuestionReportBody } from "./questions.js";
import {
  CheckResult,
  LessonCompleteBody,
  MasterySummary,
  RelightQueue,
  StartCheckBody,
  SubmitCheckBody,
  TopicCheck,
  TopicState,
  TopicStatePage,
  TopicStateQuery,
} from "./mastery.js";
import {
  ConceptDrillList,
  MistakePage,
  PracticeAnswerBody,
  PracticeAnswerResult,
  PracticeSession,
  PracticeUsage,
  PyqFacetQuery,
  PyqFacets,
  PyqPage,
  PyqQuery,
  StartPracticeBody,
} from "./practice.js";
import {
  MockAnswersSaved,
  MockAttemptPage,
  MockAttemptState,
  MockList,
  MockListQuery,
  MockReport,
  SaveMockAnswersBody,
  StartMockBody,
  StateMockInfo,
  StateMockQuery,
  StatewideRank,
} from "./exam-hall.js";
import { Plan, PlanDays, PlanDaysQuery, PlanItem, PutPlanBody, TodayScreen, UpdatePlanItemBody } from "./plan.js";
import { ReadinessMeter, ReadinessQuery, ReadinessTrend, ReadinessTrendQuery, SundayReport, SundayReportPage } from "./readiness.js";
import { AlertSettings, PushTokenAck, PutAlertSettingsBody, RegisterPushTokenBody } from "./notifications.js";
import { SyncBatchBody, SyncBatchResult } from "./sync.js";

const json = <T extends z.ZodType>(schema: T) => ({ content: { "application/json": { schema } } });
const err = (description: string) => ({ description, ...json(ErrorEnvelope) });
const authErrors = { 400: err("Validation failed"), 401: err("Not signed in"), 403: err("Not allowed"), 429: err("Rate limited (see Retry-After)") };
const idempotency = z.object({ "idempotency-key": z.uuid() });
const bearer = [{ bearerAuth: [] }];
const perUser = (limit: number, windowSeconds: number) => [{ scope: "user" as const, limit, windowSeconds }];
const uuidParam = (name: string) => z.object({ [name]: z.uuid() });

/**
 * Phase 2 (INT-002) routes. Designed in BOLT-0008; each block names the backend bolt that implements it.
 * Until that bolt lands, the API contract test lists these routes as missing (by design).
 */
export const studyRoutes: HmRoute[] = [
  // ------------------------------------------------ exams: structure, Exam Alerts, changedetection (BOLT-0011 / BOLT-0014)
  {
    method: "get", path: "/v1/exams/{code}/structure", tags: ["exams"], operationId: "getExamStructure",
    auth: "public", idempotent: false,
    summary: "Stages, papers and marking schemes (exam-agnostic, ADR-0013). Unverified schemes say so.",
    request: { params: z.object({ code: ExamCode }) },
    responses: { 200: { description: "Structure", ...json(ExamStructure) }, 404: err("No such exam") },
  },
  {
    method: "get", path: "/v1/me/exam-alerts", tags: ["exams"], operationId: "listMyExamAlerts",
    auth: "user", idempotent: false, security: bearer,
    summary: "Human-checked Exam Alerts for the exams I follow, newest first.",
    request: { query: CursorQuery },
    responses: { 200: { description: "Alerts", ...json(ExamAlertPage) }, ...authErrors },
  },
  {
    method: "post", path: "/v1/webhooks/changedetection", tags: ["exams", "webhooks"], operationId: "receiveSiteChange",
    // Machine caller: no Idempotency-Key. Each (watchUuid, changeId) is stored once; a replay gets 409 WEBHOOK_REPLAYED.
    auth: "public", idempotent: false,
    rateLimit: [{ scope: "ip", limit: 60, windowSeconds: 60 }],
    summary: "changedetection.io site-change webhook. Stores a pending change; NOTHING is sent to users (§17.5).",
    request: { headers: z.object({ "x-heymey-webhook-secret": z.string().min(32) }), body: json(SiteChangeWebhookBody) },
    responses: {
      202: { description: "Stored for human check", ...json(SiteChangeAck) },
      400: err("Validation failed"), 401: err("Bad secret"), 409: err("Already received"), 429: err("Rate limited"),
    },
  },
  {
    method: "get", path: "/v1/desk/exam-changes", tags: ["exams", "desk"], operationId: "listExamChanges",
    auth: "desk", idempotent: false, security: bearer,
    summary: "Ops queue of official-site changes waiting for a human check. Role OPS or ADMIN (checked in the handler).",
    request: { query: ExamChangeQuery },
    responses: { 200: { description: "Changes", ...json(ExamChangePage) }, ...authErrors },
  },
  {
    method: "post", path: "/v1/desk/exam-changes/{changeId}/approve", tags: ["exams", "desk"], operationId: "approveExamChange",
    auth: "desk", idempotent: true, security: bearer,
    rateLimit: perUser(60, 3600),
    summary: "Human-approved: publishes an Exam Alert (exams.notification_published) to followers. Audited.",
    request: { params: uuidParam("changeId"), headers: idempotency, body: json(ApproveExamChangeBody) },
    responses: { 200: { description: "Published", ...json(ExamChange) }, 404: err("No such change"), 409: err("Already reviewed"), ...authErrors },
  },
  {
    method: "post", path: "/v1/desk/exam-changes/{changeId}/reject", tags: ["exams", "desk"], operationId: "rejectExamChange",
    auth: "desk", idempotent: true, security: bearer,
    rateLimit: perUser(120, 3600),
    request: { params: uuidParam("changeId"), headers: idempotency, body: json(RejectExamChangeBody) },
    responses: { 200: { description: "Rejected", ...json(ExamChange) }, 404: err("No such change"), 409: err("Already reviewed"), ...authErrors },
  },

  // ------------------------------------------------ mastery (§5.1, §5.2, §39) - BOLT-0009
  {
    method: "get", path: "/v1/me/mastery", tags: ["mastery"], operationId: "getMyMastery",
    auth: "user", idempotent: false, security: bearer,
    summary: "Rank (from lamps only), XP and ring counts across my exams.",
    responses: { 200: { description: "Summary", ...json(MasterySummary) }, ...authErrors },
  },
  {
    method: "get", path: "/v1/me/topic-states", tags: ["mastery"], operationId: "listMyTopicStates",
    auth: "user", idempotent: false, security: bearer,
    summary: "Authoritative lamp states for one exam's map; `since` for incremental Drift sync.",
    request: { query: TopicStateQuery },
    responses: { 200: { description: "States", ...json(TopicStatePage) }, 404: err("No such exam"), ...authErrors },
  },
  {
    method: "get", path: "/v1/me/relight-queue", tags: ["mastery"], operationId: "getRelightQueue",
    auth: "user", idempotent: false, security: bearer,
    summary: "Dimming lamps I can open, oldest first, with minutes (\"Relight 4 · 8 min\").",
    responses: { 200: { description: "Queue", ...json(RelightQueue) }, ...authErrors },
  },
  {
    method: "post", path: "/v1/topics/{topicId}/lesson-complete", tags: ["mastery"], operationId: "completeLesson",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(300, 3600),
    summary: "I finished the lesson or the mapped textbook pages. Opens the 3-question Lit check.",
    request: { params: uuidParam("topicId"), headers: idempotency, body: json(LessonCompleteBody) },
    responses: { 200: { description: "Lamp state", ...json(TopicState) }, 404: err("No such topic"), ...authErrors },
  },
  {
    method: "post", path: "/v1/topics/{topicId}/checks", tags: ["mastery"], operationId: "startTopicCheck",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(120, 3600),
    summary: "Start a Lit / recall / relight / Gold check. The server picks the questions and sets any deadline.",
    request: { params: uuidParam("topicId"), headers: idempotency, body: json(StartCheckBody) },
    responses: {
      201: { description: "Check issued", ...json(TopicCheck) },
      404: err("No such topic"), 409: err("Check not available now"), ...authErrors,
    },
  },
  {
    method: "post", path: "/v1/checks/{checkId}/submit", tags: ["mastery"], operationId: "submitTopicCheck",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(120, 3600),
    summary: "Grade a check on the server and move the rings. Late Gold answers are not counted.",
    request: { params: uuidParam("checkId"), headers: idempotency, body: json(SubmitCheckBody) },
    responses: {
      200: { description: "Result + authoritative lamp state", ...json(CheckResult) },
      404: err("No such check"), 409: err("Already submitted or expired"), ...authErrors,
    },
  },
  {
    method: "post", path: "/v1/sync/study-actions", tags: ["mastery", "sync"], operationId: "syncStudyActions",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(120, 3600),
    summary: "Offline outbox batch (§39). Each clientActionId is accepted once; returns authoritative lamp states.",
    request: { headers: idempotency, body: json(SyncBatchBody) },
    responses: { 200: { description: "Per-action results", ...json(SyncBatchResult) }, ...authErrors },
  },

  // ------------------------------------------------ practice + PYQ Vault + content (§10.6, §11, §19.4) - BOLT-0010
  {
    method: "post", path: "/v1/practice/sessions", tags: ["practice"], operationId: "startPracticeSession",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(120, 3600),
    summary: "Start practice, PYQ, mistakes or drill. Questions come without answers.",
    request: { headers: idempotency, body: json(StartPracticeBody) },
    responses: { 201: { description: "Session", ...json(PracticeSession) }, 404: err("No such exam/topic"), ...authErrors },
  },
  {
    method: "post", path: "/v1/practice/sessions/{sessionId}/answers", tags: ["practice"], operationId: "answerPracticeQuestion",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(600, 3600),
    summary: "Grade one answer. The 31st counted answer of the IST day returns PRACTICE_DAILY_LIMIT for free users.",
    request: { params: uuidParam("sessionId"), headers: idempotency, body: json(PracticeAnswerBody) },
    responses: {
      200: { description: "Graded", ...json(PracticeAnswerResult) },
      404: err("No such session/question"), 409: err("Session closed"), ...authErrors,
    },
  },
  {
    method: "get", path: "/v1/me/practice/usage", tags: ["practice"], operationId: "getPracticeUsage",
    auth: "user", idempotent: false, security: bearer,
    responses: { 200: { description: "Today's usage (IST)", ...json(PracticeUsage) }, ...authErrors },
  },
  {
    method: "get", path: "/v1/me/mistakes", tags: ["practice"], operationId: "listMyMistakes",
    auth: "user", idempotent: false, security: bearer,
    summary: "Mistake review: why mine was wrong, why the answer is right, which lamp to relight (§19.4 Q38).",
    request: { query: CursorQuery },
    responses: { 200: { description: "Mistakes", ...json(MistakePage) }, ...authErrors },
  },
  {
    method: "get", path: "/v1/me/drills", tags: ["practice"], operationId: "listMyDrills",
    auth: "user", idempotent: false, security: bearer,
    summary: "Concept drills from repeated mistakes (Pro, §19.6 Q60). `locked` for free users.",
    responses: { 200: { description: "Drills", ...json(ConceptDrillList) }, ...authErrors },
  },
  {
    method: "get", path: "/v1/pyq", tags: ["practice"], operationId: "searchPyqs",
    auth: "user", idempotent: false, security: bearer,
    rateLimit: perUser(600, 3600),
    summary: "PYQ Vault. Free: latest 2 exam years held for the exam; older years come back `locked`.",
    request: { query: PyqQuery },
    responses: { 200: { description: "Page", ...json(PyqPage) }, 404: err("No such exam"), ...authErrors },
  },
  {
    method: "get", path: "/v1/pyq/facets", tags: ["practice"], operationId: "getPyqFacets",
    auth: "user", idempotent: false, security: bearer,
    request: { query: PyqFacetQuery },
    responses: { 200: { description: "Years and subjects", ...json(PyqFacets) }, 404: err("No such exam"), ...authErrors },
  },
  {
    method: "post", path: "/v1/questions/{questionId}/reports", tags: ["content"], operationId: "reportQuestion",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(30, 3600),
    summary: "Report a problem with a question (§19.4 Q34). Goes to the content fix loop.",
    request: { params: uuidParam("questionId"), headers: idempotency, body: json(QuestionReportBody) },
    responses: { 201: { description: "Received", ...json(QuestionReportAck) }, 404: err("No such question"), ...authErrors },
  },
  {
    method: "get", path: "/v1/content/packs", tags: ["content"], operationId: "listContentPacks",
    auth: "user", idempotent: false, security: bearer,
    summary: "Offline packs for an exam with SHA-256 checksums (§39). Free users: free packs only.",
    request: { query: ContentPackQuery },
    responses: { 200: { description: "Packs", ...json(ContentPackList) }, ...authErrors },
  },

  // ------------------------------------------------ exam-hall (§9.9, §9.10, §10.6) - BOLT-0011
  {
    method: "get", path: "/v1/mocks", tags: ["exam-hall"], operationId: "listMocks",
    auth: "user", idempotent: false, security: bearer,
    request: { query: MockListQuery },
    responses: { 200: { description: "Mocks + my free allowance", ...json(MockList) }, ...authErrors },
  },
  {
    method: "post", path: "/v1/mocks/{mockId}/attempts", tags: ["exam-hall"], operationId: "startMockAttempt",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(20, 3600),
    summary: "Start (or return my in-progress) attempt. The server sets start time and deadline.",
    request: { params: uuidParam("mockId"), headers: idempotency, body: json(StartMockBody) },
    responses: {
      201: { description: "Attempt", ...json(MockAttemptState) },
      404: err("No such mock"), 409: err("Not open / closed / monthly limit / paper type"), ...authErrors,
    },
  },
  {
    method: "get", path: "/v1/mock-attempts/{attemptId}", tags: ["exam-hall"], operationId: "getMockAttempt",
    auth: "user", idempotent: false, security: bearer,
    summary: "Resume exactly where I left off, with server remaining time (§19.8 Q76).",
    request: { params: uuidParam("attemptId") },
    responses: { 200: { description: "Attempt", ...json(MockAttemptState) }, 404: err("No such attempt"), ...authErrors },
  },
  {
    method: "put", path: "/v1/mock-attempts/{attemptId}/answers", tags: ["exam-hall"], operationId: "saveMockAnswers",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(1200, 3600),
    summary: "Save answers (last write per question wins until the deadline). Late answers are ignored.",
    request: { params: uuidParam("attemptId"), headers: idempotency, body: json(SaveMockAnswersBody) },
    responses: {
      200: { description: "Saved", ...json(MockAnswersSaved) },
      404: err("No such attempt"), 409: err("Submitted or deadline passed"), ...authErrors,
    },
  },
  {
    method: "post", path: "/v1/mock-attempts/{attemptId}/submit", tags: ["exam-hall"], operationId: "submitMockAttempt",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(20, 3600),
    summary: "Submit and score on the server with the paper's marking scheme.",
    request: { params: uuidParam("attemptId"), headers: idempotency },
    responses: { 200: { description: "Report", ...json(MockReport) }, 404: err("No such attempt"), 409: err("Already submitted"), ...authErrors },
  },
  {
    method: "get", path: "/v1/mock-attempts/{attemptId}/report", tags: ["exam-hall"], operationId: "getMockReport",
    auth: "user", idempotent: false, security: bearer,
    request: { params: uuidParam("attemptId") },
    responses: { 200: { description: "Report", ...json(MockReport) }, 404: err("No such attempt"), 409: err("Not submitted"), ...authErrors },
  },
  {
    method: "get", path: "/v1/me/mock-attempts", tags: ["exam-hall"], operationId: "listMyMockAttempts",
    auth: "user", idempotent: false, security: bearer,
    request: { query: CursorQuery },
    responses: { 200: { description: "History", ...json(MockAttemptPage) }, ...authErrors },
  },
  {
    method: "get", path: "/v1/state-mock-sunday", tags: ["exam-hall"], operationId: "getStateMockSunday",
    auth: "optional", idempotent: false,
    summary: "The next State Mock Sunday for an exam (1st and 3rd Sunday, IST).",
    request: { query: StateMockQuery },
    responses: { 200: { description: "Next", ...json(StateMockInfo) }, 400: err("Validation failed") },
  },
  {
    method: "get", path: "/v1/mocks/{mockId}/statewide-rank", tags: ["exam-hall"], operationId: "getMyStatewideRank",
    auth: "user", idempotent: false, security: bearer,
    summary: "My statewide rank. Only live, online, on-time attempts are ranked (§18, §39).",
    request: { params: uuidParam("mockId") },
    responses: { 200: { description: "Rank", ...json(StatewideRank) }, 404: err("Not ranked"), 409: err("Not ready"), ...authErrors },
  },

  // ------------------------------------------------ plan + Today (§10.6, §17.3, §19.2) - BOLT-0012
  {
    method: "get", path: "/v1/me/today", tags: ["plan"], operationId: "getToday",
    auth: "user", idempotent: false, security: bearer,
    responses: { 200: { description: "Today screen", ...json(TodayScreen) }, ...authErrors },
  },
  {
    method: "get", path: "/v1/me/plan", tags: ["plan"], operationId: "getMyPlan",
    auth: "user", idempotent: false, security: bearer,
    responses: { 200: { description: "My Plan", ...json(Plan) }, 404: err("No plan yet"), ...authErrors },
  },
  {
    method: "put", path: "/v1/me/plan", tags: ["plan"], operationId: "putMyPlan",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(30, 3600),
    summary: "Create or change My Plan from study hours; exam dates come from `exams` (§17.1 step 9).",
    request: { headers: idempotency, body: json(PutPlanBody) },
    responses: { 200: { description: "Plan", ...json(Plan) }, ...authErrors },
  },
  {
    method: "get", path: "/v1/me/plan/days", tags: ["plan"], operationId: "getPlanDays",
    auth: "user", idempotent: false, security: bearer,
    summary: "Calendar view (max 62 days per request).",
    request: { query: PlanDaysQuery },
    responses: { 200: { description: "Days", ...json(PlanDays) }, 404: err("No plan yet"), ...authErrors },
  },
  {
    method: "post", path: "/v1/me/plan/items/{itemId}/status", tags: ["plan"], operationId: "updatePlanItem",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(300, 3600),
    request: { params: uuidParam("itemId"), headers: idempotency, body: json(UpdatePlanItemBody) },
    responses: { 200: { description: "Item", ...json(PlanItem) }, 404: err("No such item"), ...authErrors },
  },
  {
    method: "post", path: "/v1/me/plan/rebalance", tags: ["plan"], operationId: "rebalanceMyPlan",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(10, 3600),
    request: { headers: idempotency },
    responses: { 200: { description: "Rebalanced plan", ...json(Plan) }, 404: err("No plan yet"), ...authErrors },
  },

  // ------------------------------------------------ readiness (§19.5) - BOLT-0013
  {
    method: "get", path: "/v1/me/readiness", tags: ["readiness"], operationId: "getMyReadiness",
    auth: "user", idempotent: false, security: bearer,
    summary: "Four evidence bars + a plain label. Never one overall percentage.",
    request: { query: ReadinessQuery },
    responses: { 200: { description: "Meter", ...json(ReadinessMeter) }, ...authErrors },
  },
  {
    method: "get", path: "/v1/me/readiness/trend", tags: ["readiness"], operationId: "getMyReadinessTrend",
    auth: "user", idempotent: false, security: bearer,
    summary: "7/30/90-day trends (Pro: PRO_REQUIRED for free users).",
    request: { query: ReadinessTrendQuery },
    responses: { 200: { description: "Trend", ...json(ReadinessTrend) }, ...authErrors },
  },
  {
    method: "get", path: "/v1/me/sunday-reports", tags: ["readiness"], operationId: "listMySundayReports",
    auth: "user", idempotent: false, security: bearer,
    request: { query: CursorQuery },
    responses: { 200: { description: "Reports", ...json(SundayReportPage) }, ...authErrors },
  },
  {
    method: "get", path: "/v1/me/sunday-reports/{reportId}", tags: ["readiness"], operationId: "getSundayReport",
    auth: "user", idempotent: false, security: bearer,
    request: { params: uuidParam("reportId") },
    responses: { 200: { description: "Report", ...json(SundayReport) }, 404: err("No such report"), ...authErrors },
  },

  // ------------------------------------------------ notifications (§19.8 Q78) - BOLT-0014
  {
    method: "post", path: "/v1/me/push-tokens", tags: ["notifications"], operationId: "registerPushToken",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(20, 3600),
    request: { headers: idempotency, body: json(RegisterPushTokenBody) },
    responses: { 200: { description: "Registered", ...json(PushTokenAck) }, ...authErrors },
  },
  {
    method: "delete", path: "/v1/me/push-tokens/{deviceId}", tags: ["notifications"], operationId: "deletePushToken",
    auth: "user", idempotent: true, security: bearer,
    request: { params: z.object({ deviceId: z.string().min(8).max(128) }), headers: idempotency },
    responses: { 200: { description: "Removed", ...json(OkResponse) }, ...authErrors },
  },
  {
    method: "get", path: "/v1/me/alert-settings", tags: ["notifications"], operationId: "getAlertSettings",
    auth: "user", idempotent: false, security: bearer,
    responses: { 200: { description: "Settings", ...json(AlertSettings) }, ...authErrors },
  },
  {
    method: "put", path: "/v1/me/alert-settings", tags: ["notifications"], operationId: "putAlertSettings",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: perUser(30, 3600),
    summary: "Offers can be on only with the offers consent; dailyLimit is capped at 3.",
    request: { headers: idempotency, body: json(PutAlertSettingsBody) },
    responses: { 200: { description: "Saved", ...json(AlertSettings) }, ...authErrors },
  },
];
