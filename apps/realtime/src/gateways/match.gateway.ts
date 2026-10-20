import {
  ConnectedSocket,
  MessageBody,
  type OnGatewayConnection,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from "@nestjs/websockets";
import type { Server, Socket } from "socket.io";
import { type ClientToServerEvents, MatchAnswer, type ServerToClientEvents } from "@heymey/contracts";

type HmServer = Server<ClientToServerEvents, ServerToClientEvents>;
type HmSocket = Socket<ClientToServerEvents, ServerToClientEvents>;

/**
 * SERVER-AUTHORITATIVE (blueprint §34.1, §40):
 * - The room state lives in Valkey (with a TTL), never in the client.
 * - The server sends ONE question at a time and scores every answer itself, using server time.
 * - A client that disconnects has RECONNECT_WINDOW_SECONDS to rejoin with full state, then forfeits.
 * - Results are persisted through the `games` module, which applies the money/game firewall.
 */
@WebSocketGateway({ cors: { origin: false } })
export class MatchGateway implements OnGatewayConnection {
  @WebSocketServer()
  server!: HmServer;

  handleConnection(client: HmSocket): void {
    // Construction (week 3): verify the access JWT from client.handshake.auth.token, bind userId, else disconnect.
    void client;
  }

  @SubscribeMessage("match.answer")
  onAnswer(@ConnectedSocket() client: HmSocket, @MessageBody() body: unknown): boolean {
    const parsed = MatchAnswer.safeParse(body);
    if (!parsed.success) return false;
    // Construction (week 3): load room from Valkey, check deadline against server clock, score, emit next question.
    void client;
    return true;
  }
}
