import { z } from "../zod.js";

/**
 * Socket.IO contract (blueprint §40). The server is authoritative: clients send intents,
 * the server sends state. Questions go out ONE at a time; answers carry client timestamps
 * that the server checks against its own clock.
 */
export const Rooms = {
  squad: (id: string) => `squad:${id}` as const,
  match: (id: string) => `match:${id}` as const,
  event: (id: string) => `event:${id}` as const,
};

export const RECONNECT_WINDOW_SECONDS = 60;

export const MatchQuestion = z.object({
  matchId: z.string(),
  index: z.number().int().nonnegative(),
  questionId: z.string(),
  prompt: z.string(),
  options: z.array(z.object({ id: z.string(), text: z.string() })),
  deadlineAt: z.iso.datetime(),
});

export const MatchAnswer = z.object({
  matchId: z.string(),
  index: z.number().int().nonnegative(),
  optionId: z.string(),
  confidence: z.enum(["sure", "think_so", "guessing"]).optional(),
  clientSentAt: z.iso.datetime(),
});

export const MatchResult = z.object({
  matchId: z.string(),
  placements: z.array(
    z.object({
      userId: z.string(),
      score: z.number(),
      trophiesDelta: z.number().int(),
      pointsAwarded: z.number().int(),
    }),
  ),
});

export const ChatMessage = z.object({
  id: z.string(),
  squadId: z.string(),
  authorId: z.string(),
  body: z.string().max(1000),
  sentAt: z.iso.datetime(),
});

export interface ServerToClientEvents {
  "match.question": (p: z.infer<typeof MatchQuestion>) => void;
  "match.result": (p: z.infer<typeof MatchResult>) => void;
  "poker.clue_revealed": (p: { matchId: string; clueIndex: number; text: string }) => void;
  "battle.flag_captured": (p: { battleId: string; zone: number; squadId: string; flags: 1 | 2 | 3 }) => void;
  "chat.message": (p: z.infer<typeof ChatMessage>) => void;
  "event.counter": (p: { eventId: string; value: number }) => void;
}

export interface ClientToServerEvents {
  "match.answer": (p: z.infer<typeof MatchAnswer>, ack: (ok: boolean) => void) => void;
  "poker.bet": (
    p: { matchId: string; action: "fold" | "call" | "raise"; amount?: number },
    ack: (ok: boolean) => void,
  ) => void;
  "chat.send": (p: { squadId: string; body: string; clientId: string }, ack: (ok: boolean) => void) => void;
}
