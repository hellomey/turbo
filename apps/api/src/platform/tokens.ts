/**
 * Dependency-injection tokens for the composition root. Infrastructure singletons are provided by
 * InfraModule; each `<module>.http-module.ts` provides its module's API object under its token so other
 * http modules can receive it (only if that module declares the dependency in module.json).
 */
export const ENV = Symbol("ENV");
export const PRISMA = Symbol("PRISMA");
export const VALKEY = Symbol("VALKEY");
export const CLOCK = Symbol("CLOCK");
export const RATE_LIMITER = Symbol("RATE_LIMITER");
export const IDEMPOTENCY_STORE = Symbol("IDEMPOTENCY_STORE");
export const JOB_QUEUE = Symbol("JOB_QUEUE");

/** Provided by AuthHttpModule: turns a bearer token into an AuthContext (or null). */
export const ACCESS_TOKEN_VERIFIER = Symbol("ACCESS_TOKEN_VERIFIER");

export const AUDIT_API = Symbol("AUDIT_API");
export const USERS_API = Symbol("USERS_API");
export const ROLES_API = Symbol("ROLES_API");
export const AUTH_API = Symbol("AUTH_API");
export const EXAMS_API = Symbol("EXAMS_API");
export const SYLLABUS_API = Symbol("SYLLABUS_API");
export const CONTENT_API = Symbol("CONTENT_API");
export const NOTIFICATIONS_API = Symbol("NOTIFICATIONS_API"); // BOLT-0014
export const EXAM_ALERTS_API = Symbol("EXAM_ALERTS_API"); // BOLT-0014
export const EXAM_HALL_API = Symbol("EXAM_HALL_API"); // BOLT-0011
export const EXAM_CATALOGUE_API = Symbol("EXAM_CATALOGUE_API"); // BOLT-0011
export const MASTERY_API = Symbol("MASTERY_API"); // BOLT-0009
export const READINESS_API = Symbol("READINESS_API"); // BOLT-0013
export const PRACTICE_API = Symbol("PRACTICE_API"); // BOLT-0010
export const PRACTICE_CONTENT_API = Symbol("PRACTICE_CONTENT_API"); // BOLT-0010 (content: practice questions, PYQ, reports, packs)
export const ENTITLEMENTS = Symbol("ENTITLEMENTS"); // BOLT-0010 (billing Phase 2 stub: everyone Free)
export const PLAN_API = Symbol("PLAN_API"); // BOLT-0012
