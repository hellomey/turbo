import { Controller, Get, Module } from "@nestjs/common";
import { MatchGateway } from "./gateways/match.gateway.js";

@Controller("health")
class HealthController {
  @Get()
  health() {
    return { status: "ok", service: "realtime", version: process.env.APP_VERSION ?? "dev", checks: {} };
  }
}

/**
 * Gateways (one per room family, blueprint §40):
 *   MatchGateway  match:{id}   duel, clue poker, district quest
 *   SquadGateway  squad:{id}   chat, battle updates            (week 3)
 *   EventGateway  event:{id}   live counters                   (week 4)
 */
@Module({
  controllers: [HealthController],
  providers: [MatchGateway],
})
export class RealtimeModule {}
