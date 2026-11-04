import { Module } from "@nestjs/common";
import { APP_FILTER, APP_GUARD, APP_INTERCEPTOR } from "@nestjs/core";
import { HealthController } from "./health/health.controller.js";
import { AuditHttpModule } from "./http/audit/audit.http-module.js";
import { AuthHttpModule } from "./http/auth/auth.http-module.js";
import { ContentHttpModule } from "./http/content/content.http-module.js";
import { ExamHallHttpModule } from "./http/exam-hall/exam-hall.http-module.js";
import { ExamAlertsHttpModule } from "./http/exams/exam-alerts.http-module.js";
import { ExamsHttpModule } from "./http/exams/exams.http-module.js";
import { MasteryHttpModule } from "./http/mastery/mastery.http-module.js";
import { PlanHttpModule } from "./http/plan/plan.http-module.js";
import { PracticeHttpModule } from "./http/practice/practice.http-module.js";
import { ReadinessHttpModule } from "./http/readiness/readiness.http-module.js";
import { NotificationsHttpModule } from "./http/notifications/notifications.http-module.js";
import { RolesHttpModule } from "./http/roles/roles.http-module.js";
import { SyllabusHttpModule } from "./http/syllabus/syllabus.http-module.js";
import { UsersHttpModule } from "./http/users/users.http-module.js";
import { DomainErrorFilter } from "./platform/domain-error.filter.js";
import { IdempotencyInterceptor } from "./platform/idempotency.interceptor.js";
import { InfraModule } from "./platform/infra.module.js";
import { PlatformGuard } from "./platform/platform.guard.js";

/**
 * Composition root. Each business module has an HTTP adapter in src/http/<module>/ that builds the
 * module API from @heymey/domain and exposes the routes declared in @heymey/contracts.
 * Every request: onRequest hook (X-Min-App-Version, X-Request-Id) -> PlatformGuard (contract lookup -> auth -> rate limits) -> Idempotency
 * -> controller (contract Zod parse -> one use case) -> DomainErrorFilter on any error.
 */
@Module({
  imports: [
    InfraModule,
    AuditHttpModule,
    UsersHttpModule,
    RolesHttpModule,
    AuthHttpModule,
    ExamsHttpModule,
    ExamHallHttpModule,
    ExamAlertsHttpModule,
    NotificationsHttpModule,
    SyllabusHttpModule,
    ContentHttpModule,
    MasteryHttpModule,
    PracticeHttpModule,
    ReadinessHttpModule,
    PlanHttpModule, // BOLT-0012
  ],
  controllers: [HealthController],
  providers: [
    { provide: APP_GUARD, useClass: PlatformGuard },
    { provide: APP_FILTER, useClass: DomainErrorFilter },
    { provide: APP_INTERCEPTOR, useClass: IdempotencyInterceptor },
  ],
})
export class AppModule {}
