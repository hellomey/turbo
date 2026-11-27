import { Global, Logger, Module } from "@nestjs/common";
import { ModuleRef } from "@nestjs/core";
import type { PrismaClient } from "@heymey/db";
import { createEconomyProgression, type EconomyProgressionApi } from "@heymey/domain/modules/economy";
import type { MasteryApi } from "@heymey/domain/modules/mastery";
import type { SyllabusApi } from "@heymey/domain/modules/syllabus";
import type { UsersApi } from "@heymey/domain/modules/users";
import type { Clock, DomainEvent, EventPublisher } from "@heymey/domain/shared";
import { CLOCK, ECONOMY_API, MASTERY_API, PRISMA, SYLLABUS_API, USERS_API } from "../../platform/tokens.js";
import { EconomyController } from "./economy.controller.js";

const log = new Logger("economy");

/**
 * In-process event delivery to economy (there is no event bus yet). A failed award is logged and never fails the
 * learning action that caused it. shortcut: a lost award is not retried; move to the pgmq outbox when it exists.
 */
export function economyEvents(economy: EconomyProgressionApi, next?: EventPublisher): EventPublisher {
  return {
    async publish(e: DomainEvent) {
      await next?.publish(e);
      try {
        await economy.onLearningEvent(e);
      } catch (err) {
        log.error({ event: e.type, error: err instanceof Error ? err.message : String(err) });
      }
    },
  };
}

/** Every lamp of the topic's subject (across the topic's exams) is lit for the user. */
export async function subjectFullyLit(syllabus: SyllabusApi, mastery: MasteryApi, userId: string, topicId: string): Promise<boolean> {
  const topic = await syllabus.topic(topicId);
  if (!topic) return false;
  const all = (await Promise.all(topic.examCodes.map((c) => syllabus.topicsForExam(c)))).flat();
  const ids = [...new Set(all.filter((t) => t.subject.code === topic.subject.code).map((t) => t.id))];
  const lit = new Set((await mastery.statesOf(userId, ids)).filter((s) => s.ring.lit).map((s) => s.topicId));
  return ids.length > 0 && ids.every((id) => lit.has(id));
}

/**
 * HTTP adapter for economy progression (BOLT-0113). Composition: names and guest status come from the users API, lamp
 * facts from syllabus + mastery (resolved lazily: mastery publishes into economy, so a direct inject would be a cycle).
 */
@Global()
@Module({
  controllers: [EconomyController],
  providers: [
    {
      provide: ECONOMY_API,
      inject: [PRISMA, CLOCK, USERS_API, SYLLABUS_API, ModuleRef],
      useFactory: (prisma: PrismaClient, clock: Clock, users: UsersApi, syllabus: SyllabusApi, refs: ModuleRef) =>
        createEconomyProgression({
          prisma,
          clock,
          people: {
            profile: async (id) => {
              const u = await users.getById(id);
              return u && { nickname: u.nickname, isGuest: u.isGuest, hideFromLeaderboards: u.hideFromLeaderboards, deleted: u.deletedAt !== null };
            },
          },
          learning: {
            subjectFullyLit: (userId, topicId) => subjectFullyLit(syllabus, refs.get<MasteryApi>(MASTERY_API, { strict: false }), userId, topicId),
          },
        }),
    },
  ],
  exports: [ECONOMY_API],
})
export class EconomyHttpModule {}
