import type { TopicState, z } from "@heymey/contracts";
import { nextCheck, ringOf, type LampState } from "./lamp.js";

export type TopicStateDto = z.infer<typeof TopicState>;

const iso = (d: Date | null) => (d ? d.toISOString() : null);

/** The authoritative lamp state the app stores in Drift and shows (§39: the server wins). */
export function toTopicStateDto(s: LampState, now: Date): TopicStateDto {
  return {
    topicId: s.topicId,
    ring: ringOf(s),
    litAt: iso(s.litAt),
    goldAt: iso(s.goldAt),
    lessonCompletedAt: iso(s.lessonCompletedAt),
    nextDueAt: iso(s.nextDueAt),
    nextCheck: nextCheck(s, now),
    updatedAt: s.updatedAt.toISOString(),
  };
}
