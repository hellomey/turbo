import { z } from "../zod.js";
import { ErrorEnvelope } from "../errors.js";
import type { HmRoute } from "./common.js";
import { HealthResponse } from "./health.js";
import {
  DeleteAccountBody,
  DeleteAccountResponse,
  DeskTotpEnrollBody,
  DeskTotpEnrollResponse,
  DeskTotpVerifyBody,
  OkResponse,
  OtpRequestBody,
  OtpRequestResponse,
  OtpVerifyBody,
  OtpVerifyResponse,
  RefreshBody,
  SessionGranted,
  TokenPair,
} from "./auth.js";
import { ConsentChoicesBody, ConsentNotice, ConsentState, Me, ProfileAnswers, UpdateMeBody } from "./users.js";
import { EligibilityCheckBody, EligibilityResult, ExamCode, ExamDetail, ExamList, UserExams, UserExamsBody } from "./exams.js";
import { GlossaryList, GlossaryQuery, Lesson, StudyMap } from "./study.js";
import { studyRoutes } from "./routes-study.js";

const json = <T extends z.ZodType>(schema: T) => ({ content: { "application/json": { schema } } });
const err = (description: string) => ({ description, ...json(ErrorEnvelope) });
const errors = { 400: err("Validation failed"), 429: err("Rate limited (see Retry-After)") };
const authErrors = { ...errors, 401: err("Not signed in"), 403: err("Not allowed") };
const idempotency = z.object({ "idempotency-key": z.uuid() });
const bearer = [{ bearerAuth: [] }];

/**
 * Every HTTP route the API exposes, with who may call it, whether it needs an Idempotency-Key and its
 * rate limits. The API enforces exactly this list (apps/api/src/platform) and a contract test fails if a
 * route here is missing from the API or vice versa. `pnpm codegen` turns it into openapi.json -> dart/hm_api.
 */
export const routes: HmRoute[] = [
  // ---------------------------------------------------------------- platform
  {
    method: "get", path: "/v1/health", tags: ["platform"], operationId: "getHealth",
    auth: "public", idempotent: false,
    summary: "Liveness + dependency checks",
    responses: { 200: { description: "Healthy", ...json(HealthResponse) }, 503: { description: "Degraded", ...json(HealthResponse) } },
  },

  // ---------------------------------------------------------------- auth (§38)
  {
    method: "post", path: "/v1/auth/otp/request", tags: ["auth"], operationId: "requestOtp",
    auth: "optional", idempotent: true,
    rateLimit: [{ scope: "ip", limit: 10, windowSeconds: 3600 }],
    summary: "Send a 6-digit code. Always 200: never reveals whether the email has an account.",
    request: { headers: idempotency, body: json(OtpRequestBody) },
    responses: { 200: { description: "Queued", ...json(OtpRequestResponse) }, ...errors },
  },
  {
    method: "post", path: "/v1/auth/otp/verify", tags: ["auth"], operationId: "verifyOtp",
    auth: "public", idempotent: true, sensitiveResponse: true,
    rateLimit: [{ scope: "ip", limit: 30, windowSeconds: 3600 }],
    summary: "Exchange email + code for a session bound to this device (or a Desk 2FA challenge).",
    request: { headers: idempotency, body: json(OtpVerifyBody) },
    responses: { 200: { description: "Signed in, or second factor needed", ...json(OtpVerifyResponse) }, ...authErrors },
  },
  {
    method: "post", path: "/v1/auth/refresh", tags: ["auth"], operationId: "refreshSession",
    auth: "public", idempotent: true, sensitiveResponse: true,
    rateLimit: [{ scope: "ip", limit: 120, windowSeconds: 3600 }],
    summary: "Rotate the refresh token. Re-using an old one revokes the whole session family.",
    request: { headers: idempotency, body: json(RefreshBody) },
    responses: { 200: { description: "New pair", ...json(TokenPair) }, ...authErrors },
  },
  {
    method: "post", path: "/v1/auth/logout", tags: ["auth"], operationId: "logout",
    auth: "user", idempotent: true, security: bearer,
    summary: "End this session.",
    request: { headers: idempotency },
    responses: { 200: { description: "Signed out", ...json(OkResponse) }, ...authErrors },
  },
  {
    method: "post", path: "/v1/auth/logout-all", tags: ["auth"], operationId: "logoutAll",
    auth: "user", idempotent: true, security: bearer,
    summary: "Log out of all devices.",
    request: { headers: idempotency },
    responses: { 200: { description: "All sessions ended", ...json(OkResponse) }, ...authErrors },
  },
  {
    method: "post", path: "/v1/auth/desk/totp/enroll", tags: ["auth", "desk"], operationId: "enrollDeskTotp",
    auth: "public", idempotent: true, sensitiveResponse: true,
    rateLimit: [{ scope: "ip", limit: 10, windowSeconds: 3600 }],
    summary: "First Desk sign-in: create the authenticator secret for this staff/partner account.",
    request: { headers: idempotency, body: json(DeskTotpEnrollBody) },
    responses: { 200: { description: "Scan this", ...json(DeskTotpEnrollResponse) }, ...authErrors },
  },
  {
    method: "post", path: "/v1/auth/desk/totp/verify", tags: ["auth", "desk"], operationId: "verifyDeskTotp",
    auth: "public", idempotent: true, sensitiveResponse: true,
    rateLimit: [{ scope: "ip", limit: 20, windowSeconds: 3600 }],
    summary: "Complete Desk sign-in with the authenticator code.",
    request: { headers: idempotency, body: json(DeskTotpVerifyBody) },
    responses: { 200: { description: "Desk session", ...json(SessionGranted) }, ...authErrors },
  },
  {
    method: "post", path: "/v1/auth/delete-account", tags: ["auth"], operationId: "deleteAccount",
    auth: "user", idempotent: true, security: bearer,
    rateLimit: [{ scope: "user", limit: 5, windowSeconds: 3600 }],
    summary: "Confirm account deletion with a `delete_account` code. 7-day grace period (§38.7).",
    request: { headers: idempotency, body: json(DeleteAccountBody) },
    responses: { 200: { description: "Scheduled", ...json(DeleteAccountResponse) }, ...authErrors },
  },

  // ---------------------------------------------------------------- users (§16, §23, §30)
  {
    method: "get", path: "/v1/me", tags: ["users"], operationId: "getMe",
    auth: "user", idempotent: false, security: bearer,
    responses: { 200: { description: "The signed-in user", ...json(Me) }, ...authErrors },
  },
  {
    method: "patch", path: "/v1/me", tags: ["users"], operationId: "updateMe",
    auth: "user", idempotent: true, security: bearer,
    request: { headers: idempotency, body: json(UpdateMeBody) },
    responses: { 200: { description: "Updated", ...json(Me) }, ...authErrors },
  },
  {
    method: "put", path: "/v1/me/profile", tags: ["users"], operationId: "putProfile",
    auth: "user", idempotent: true, security: bearer,
    summary: "Save the onboarding eligibility answers. Under 18 is refused (UNDER_18).",
    request: { headers: idempotency, body: json(ProfileAnswers) },
    responses: { 200: { description: "Saved", ...json(Me) }, ...authErrors },
  },
  {
    method: "get", path: "/v1/consents/notice", tags: ["users"], operationId: "getConsentNotice",
    auth: "public", idempotent: false,
    summary: "The current DPDP notice: purposes, which are required, nothing pre-ticked.",
    responses: { 200: { description: "Notice", ...json(ConsentNotice) } },
  },
  {
    method: "get", path: "/v1/me/consents", tags: ["users"], operationId: "getMyConsents",
    auth: "user", idempotent: false, security: bearer,
    responses: { 200: { description: "Latest choice per purpose", ...json(ConsentState) }, ...authErrors },
  },
  {
    method: "post", path: "/v1/me/consents", tags: ["users"], operationId: "recordConsents",
    auth: "user", idempotent: true, security: bearer,
    request: { headers: idempotency, body: json(ConsentChoicesBody) },
    responses: { 200: { description: "Recorded", ...json(ConsentState) }, ...authErrors },
  },

  // ---------------------------------------------------------------- exams (§19.1)
  {
    method: "get", path: "/v1/exams", tags: ["exams"], operationId: "listExams",
    auth: "public", idempotent: false,
    responses: { 200: { description: "Published exams", ...json(ExamList) } },
  },
  {
    method: "get", path: "/v1/exams/{code}", tags: ["exams"], operationId: "getExam",
    auth: "public", idempotent: false,
    request: { params: z.object({ code: ExamCode }) },
    responses: { 200: { description: "Exam page", ...json(ExamDetail) }, 404: err("No such exam") },
  },
  {
    method: "post", path: "/v1/eligibility/check", tags: ["exams"], operationId: "checkEligibility",
    auth: "public", idempotent: false,
    rateLimit: [{ scope: "ip", limit: 60, windowSeconds: 600 }],
    summary: "Eligibility Checker. A pure computation: nothing is stored. Under 18 returns UNDER_18.",
    request: { body: json(EligibilityCheckBody) },
    responses: { 200: { description: "Result", ...json(EligibilityResult) }, 422: err("Under 18"), ...errors },
  },
  {
    method: "get", path: "/v1/me/exams", tags: ["exams"], operationId: "getMyExams",
    auth: "user", idempotent: false, security: bearer,
    responses: { 200: { description: "Main exam + up to 2 more", ...json(UserExams) }, ...authErrors },
  },
  {
    method: "put", path: "/v1/me/exams", tags: ["exams"], operationId: "putMyExams",
    auth: "user", idempotent: true, security: bearer,
    request: { headers: idempotency, body: json(UserExamsBody) },
    responses: { 200: { description: "Saved", ...json(UserExams) }, ...authErrors },
  },

  // ---------------------------------------------------------------- study map + lessons (§5.1, §10.6)
  {
    method: "get", path: "/v1/exams/{code}/study-map", tags: ["syllabus"], operationId: "getStudyMap",
    auth: "optional", idempotent: false,
    request: { params: z.object({ code: ExamCode }) },
    responses: { 200: { description: "Subjects and lamps", ...json(StudyMap) }, 404: err("No such exam") },
  },
  {
    method: "get", path: "/v1/topics/{topicId}/lesson", tags: ["content"], operationId: "getLesson",
    auth: "optional", idempotent: false,
    request: { params: z.object({ topicId: z.uuid() }) },
    responses: { 200: { description: "Published lesson", ...json(Lesson) }, 404: err("No lesson yet") },
  },
  {
    method: "get", path: "/v1/glossary", tags: ["syllabus"], operationId: "searchGlossary",
    auth: "public", idempotent: false,
    request: { query: GlossaryQuery },
    responses: { 200: { description: "Tap-to-see meanings", ...json(GlossaryList) } },
  },

  // ---------------------------------------------------------------- Phase 2 core study (BOLT-0008)
  ...studyRoutes,
];
