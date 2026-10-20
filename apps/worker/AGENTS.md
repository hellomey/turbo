# AGENTS.md: apps/worker (BullMQ workers :4571, scheduler :4572)

Owner: `backend` (each queue belongs to the module named in `src/queues/registry.ts`). Root rules apply.

- Every queue and schedule is declared in `src/queues/registry.ts` with its owning module. No hidden queues.
- A processor calls exactly one use case from `@heymey/domain/modules/<owner>`. No business rules in processors.
- Jobs can run twice: processors must be idempotent.
- Schedules use Asia/Kolkata (`BUSINESS_TIMEZONE`). Exactly one scheduler replica.
- Health on `/health` at the series port; not exposed publicly.
