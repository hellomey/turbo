import { Prisma, type PrismaClient } from "@heymey/db";
import type { ExpoChallengeRecord, ExpoRepository, RedeemOutcome, RedeemTxHook } from "../application/expo-service.js";
import type { StickerReason } from "../domain/expo.js";

/** `ExpoChallenge` + `StickerCode` (owned by practice, BOLT-0112). */
export class PrismaExpoRepository implements ExpoRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async createChallenge(c: Omit<ExpoChallengeRecord, "id" | "submittedAt">): Promise<string> {
    const row = await this.prisma.expoChallenge.create({ data: c, select: { id: true } });
    return row.id;
  }

  getChallenge(id: string): Promise<ExpoChallengeRecord | null> {
    return this.prisma.expoChallenge.findUnique({
      where: { id },
      select: { id: true, userId: true, questionIds: true, createdAt: true, expiresAt: true, submittedAt: true },
    });
  }

  async markSubmitted(id: string, at: Date, score: number): Promise<boolean> {
    const r = await this.prisma.expoChallenge.updateMany({ where: { id, submittedAt: null }, data: { submittedAt: at, score } });
    return r.count === 1;
  }

  stickerCodeOf(userId: string): Promise<{ code: string; redeemedAt: Date | null } | null> {
    return this.prisma.stickerCode.findUnique({ where: { userId }, select: { code: true, redeemedAt: true } });
  }

  async insertStickerCode(userId: string, code: string, reason: StickerReason, at: Date): Promise<"ok" | "user_has_code" | "code_taken"> {
    try {
      await this.prisma.stickerCode.create({ data: { userId, code, reason, createdAt: at } });
      return "ok";
    } catch (e) {
      if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === "P2002") {
        const taken = await this.prisma.stickerCode.findUnique({ where: { userId }, select: { userId: true } });
        return taken ? "user_has_code" : "code_taken";
      }
      throw e;
    }
  }

  redeem(code: string, by: string, at: Date, inTx?: RedeemTxHook): Promise<RedeemOutcome> {
    return this.prisma.$transaction(async (tx) => {
      const r = await tx.stickerCode.updateMany({ where: { code, redeemedAt: null }, data: { redeemedAt: at, redeemedBy: by } });
      if (r.count === 0) {
        const exists = await tx.stickerCode.findUnique({ where: { code }, select: { code: true } });
        return { kind: exists ? "already" : "not_found" } as const;
      }
      if (inTx) await inTx(tx);
      return { kind: "ok", redeemedAt: at } as const;
    });
  }
}
