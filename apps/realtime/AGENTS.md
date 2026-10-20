# AGENTS.md: apps/realtime (Socket.IO, port 4568)

Owner: `realtime`. Root rules in `/AGENTS.md` apply.

- One gateway per room family: `match:{id}`, `squad:{id}`, `event:{id}` (blueprint §40). Event names and payloads come from `@heymey/contracts` socket types.
- **Server-authoritative**: state in Valkey with TTL; one question at a time; score on the server with server time; validate every client payload with the contract's Zod schema.
- Authenticate the access JWT on connection; disconnect on failure. Reconnect window 60 s, then forfeit.
- Multi-replica: Valkey adapter (`@socket.io/redis-adapter`) so 2+ replicas share rooms. Caddy uses ip_hash stickiness.
- Rewards only through `games`/`economy` public APIs (firewall). Never credit Sparks; never read entitlements.
