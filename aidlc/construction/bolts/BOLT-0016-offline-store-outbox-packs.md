# BOLT-0016: hm_data offline layer: local store, study-action outbox, content-pack downloader, sync triggers

| | |
|---|---|
| Unit | U-app-shell (Phase 2 offline outbox section) |
| Stories | INT-002-S18, S19, S20 |
| Risk tier | T1 |
| Agent | flutter-ui |
| Branch / PR | `bolt/BOLT-0016-offline-outbox` · not committed (conductor instruction: no commits) |
| Status | in review |

## Plan
- Blueprint §39 (offline sync), §34.2/§34.3 (idempotency), §10.2 (copy); U-app-shell invariants 1–6.
- `dart/hm_data`: Drift DB (topic_states, outbox, packs), `OutboxRepository`, `SyncEngine`, `PackDownloader`,
  `SyncTriggers`, Riverpod providers. `dart/hm_core`: connectivity (`NetworkState`, `networkStateProvider`),
  `HmApi.syncStudyActions` (caller-owned Idempotency-Key) and `HmApi.listContentPacks`.
- No contract changes. `dart/hm_api` not edited.
- Tests first: outbox ordering, batching, retry/backoff, dedup, key reuse, 7-day cut-off, server-wins, pack checksum/resume.

## Result
### What changed
- `dart/hm_data/lib/src/domain/`: `StudyAction` (sealed; practice_answer, lesson_complete, topic_check with lit/recall/relight only (no gold offline), plan_item_status), `OutboxEntry` + `OutboxRules` (batch 100, 7-day ring window, backoff 5 s doubling to 10 min), `SyncReport` + `SyncCopy`, pack types.
- `dart/hm_data/lib/src/data/`: store interfaces (`OutboxStore`, `TopicStateStore`, `PackStore`) with in-memory and Drift implementations (`hm_database.dart`); gateways (`StudySyncGateway`, `PackCatalogGateway`, `PackTransport`) over `HmApi` / plain HTTP with Range; generated `fromJson` (follow-up 1 resolved).
- `dart/hm_data/lib/src/application/`: `OutboxRepository` (write locally first, client UUID + clientAt, dedup by clientActionId), `SyncEngine` (creation order, ≤100 per batch, one run in flight, batch Idempotency-Key = UUIDv5 of the action ids so retries reuse it, backoff, server-wins topic-state replacement, rejected kept for "Couldn't save", study_log_only counted), `PackDownloader` (Wi-Fi only unless allowed, locked never requested, resumable, size check, SHA-256, replace only after verification), `SyncTriggers` (sync on coming online with force, after a recorded action when online, timer at backoff end), `providers.dart`.
- `dart/hm_core`: `src/net/connectivity.dart` (connectivity_plus), `HmApi.syncStudyActions` / `listContentPacks`, `_call` accepts an explicit idempotency key.

### Local DB choice
**Drift 2.34.3** (already named in the design and §39), on `sqlite3` 3.5.2 (bundled by build hooks, so no `sqlite3_flutter_libs`). Tables are plain SQL with `customSelect`/`customStatement` on a `GeneratedDatabase` with no generated tables, so there is **no build_runner step** and no generated files. Migrations are additive steps (`_steps`); schema version 1. Other new deps: `connectivity_plus` 7.3.1 (hm_core), `crypto`, `path_provider`, `uuid`, `http`, `flutter_riverpod` (hm_data). All were already in the pub cache / lockfile family.

### Evidence (2026-10-22, local)
- `pnpm --filter @heymey/dart lint`: exit 0. Format clean; `flutter analyze` no issues; hm_api analysis has 2 warnings already there in generated `api_client.dart` (non-fatal by design).
- `node tools/flutter-test-all.mjs`: exit 0, every package "All tests passed"; hm_data 26 tests (outbox 15, packs/triggers/Drift 11).
- `flutter build apk --debug` (apps/mobile): built `build/app/outputs/flutter-apk/app-debug.apk` (Gradle 167 s).
- `graphify update .`: done.

### Follow-ups
1. **hm_api codegen (architect/devops):** generated `fromJson` asserts that required keys are non-null, but the contract has required nullable keys (`TopicState.litAt/goldAt/lessonCompletedAt/nextDueAt`, `SyncActionResult.errorCode`, `ContentPack.subjectCode`). Valid server JSON fails in debug builds. `hm_data/lib/src/data/wire.dart` builds the generated classes through their constructors as a workaround; delete it once the codegen is fixed. **Resolved (devops, 2026-10-22):** `tools/dart-api-codegen.mjs` now passes `-t tools/dart-api-codegen-templates` (override of the generator v7.17.0 `native_class.mustache`) so required-but-nullable keys are checked for presence only; `wire.dart` deleted, callers use the generated `fromJson`.
2. Overnight Wi-Fi + charging downloads (WorkManager / BGTaskScheduler, invariant 7) and the mobile-data toggle setting: in the app-screen bolts (0017–0019).
3. Mock answers pending (`mock_answers_pending`), plan/today cache, notes/bookmarks tables: added with their feature bolts.
4. Analytics counts for outbox size / sync failures: hook into `SyncTriggers.reports` when analytics exists.
5. Wiring `syncTriggersProvider` into the app shell and the "Will sync when online" / "Couldn't save" UI + goldens: BOLT-0017.

### Decisions
- Batch Idempotency-Key derived as UUIDv5 over the batch's clientActionIds (deterministic, so a retried identical batch reuses the key without persisting it). Local to hm_data; no ADR needed.
