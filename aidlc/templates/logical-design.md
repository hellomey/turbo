# Logical design: U-<name>

Status: draft · approved (G-D)

## Use cases (application layer)
| Use case | Trigger (route / event / job) | Ports used | Idempotency key | Authorisation (role) |
|---|---|---|---|---|

## Contract changes (@heymey/contracts)
- Routes: `METHOD /v1/...` request schema → response schema, error codes
- Socket events:
- Breaking? (must be NO for /v1; otherwise /v2 + 6-month support, §37)

## Data
- New/changed models in `packages/db/prisma/schema/<module>.prisma`
- Migration plan: expand → migrate → contract. Safe for the live app version? Why.
- Indexes, partitioning, retention

## Background work
Queues / schedules added to `apps/worker/src/queues/registry.ts` (owner, concurrency, cron in IST).

## Client (Flutter)
Screens, controllers, offline behaviour (§39: what is written to the outbox, what needs a connection), Lite/Calm behaviour.

## Flags and LiveOps
Feature flag key(s); which values live in config tables instead of code (§34.6).

## Failure modes
| Failure | Behaviour | User sees (simple English) |
|---|---|---|

## Non-functional budget
API p95 ≤ 300 ms · install size · frame rate · rate limits · AI cost

## Observability
Logs, metrics, alerts added.

## Test plan
| Level | Cases | Tool |
|---|---|---|
| Domain unit | each invariant | Vitest |
| Integration | routes, transactions, idempotency, webhooks | Vitest + Testcontainers |
| Realtime | reconnect, cheating attempts | Socket.IO test clients |
| Widget / golden | dark, light, high-contrast, Calm, 200% text | flutter_test |
| Firewall | FW-xxx added | packages/domain/test/firewall |
