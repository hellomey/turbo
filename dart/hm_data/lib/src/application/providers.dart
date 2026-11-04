import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hm_core/hm_core.dart';
import 'package:path_provider/path_provider.dart';

import '../data/gateways.dart';
import '../data/hm_database.dart';
import '../data/local_stores.dart';
import '../data/mock_answer_store.dart';
import 'outbox_repository.dart';
import 'pack_downloader.dart';
import 'sync_engine.dart';
import 'sync_triggers.dart';

/// Offline layer wiring (§39). Tests override the store/gateway providers with in-memory fakes.

final hmDatabaseProvider = Provider<HmDatabase>((ref) {
  final db = HmDatabase.open();
  ref.onDispose(() => unawaited(db.close()));
  return db;
});

final outboxStoreProvider = Provider<OutboxStore>(
  (ref) => DriftOutboxStore(ref.watch(hmDatabaseProvider)),
);

final topicStateStoreProvider = Provider<TopicStateStore>(
  (ref) => DriftTopicStateStore(ref.watch(hmDatabaseProvider)),
);

final packStoreProvider = Provider<PackStore>(
  (ref) => DriftPackStore(ref.watch(hmDatabaseProvider)),
);

final _hmApiGatewayProvider = Provider<HmApiSyncGateway>(
  (ref) => HmApiSyncGateway(ref.watch(hmApiProvider)),
);

final studySyncGatewayProvider = Provider<StudySyncGateway>(
  (ref) => ref.watch(_hmApiGatewayProvider),
);

final packCatalogGatewayProvider = Provider<PackCatalogGateway>(
  (ref) => ref.watch(_hmApiGatewayProvider),
);

final packTransportProvider = Provider<PackTransport>(
  (ref) => HttpPackTransport(ref.watch(httpClientProvider)),
);

/// Where verified packs live.
final packDirectoryProvider = Provider<Future<Directory> Function()>(
  (ref) => () async {
    final support = await getApplicationSupportDirectory();
    return Directory('${support.path}${Platform.pathSeparator}packs');
  },
);

final outboxRepositoryProvider = Provider<OutboxRepository>(
  (ref) => OutboxRepository(
    outbox: ref.watch(outboxStoreProvider),
    topicStates: ref.watch(topicStateStoreProvider),
    clock: ref.watch(clockProvider),
  ),
);

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final devices = ref.watch(deviceIdStoreProvider);
  return SyncEngine(
    outbox: ref.watch(outboxStoreProvider),
    topicStates: ref.watch(topicStateStoreProvider),
    gateway: ref.watch(studySyncGatewayProvider),
    deviceId: devices.deviceId,
    clock: ref.watch(clockProvider),
  );
});

final packDownloaderProvider = Provider<PackDownloader>(
  (ref) => PackDownloader(
    catalog: ref.watch(packCatalogGatewayProvider),
    transport: ref.watch(packTransportProvider),
    store: ref.watch(packStoreProvider),
    directory: ref.watch(packDirectoryProvider),
  ),
);

/// Starts listening to the network as soon as it is read (the app shell reads it once signed in).
final syncTriggersProvider = Provider<SyncTriggers>((ref) {
  final source = ref.watch(networkSourceProvider);
  final controller = StreamController<NetworkState>();
  unawaited(
    source.current().then((s) {
      if (!controller.isClosed) controller.add(s);
    }, onError: (_) {}),
  );
  final sub = source.changes().listen(controller.add);
  final triggers = SyncTriggers(
    engine: ref.watch(syncEngineProvider),
    network: controller.stream,
    clock: ref.watch(clockProvider),
  );
  ref.onDispose(() async {
    await sub.cancel();
    await triggers.dispose();
    await controller.close();
  });
  return triggers;
});

/// Pending outbox size, for the "Will sync when online" note.
final pendingOutboxCountProvider = FutureProvider<int>(
  (ref) => ref.watch(outboxRepositoryProvider).pendingCount(),
);

/// Exam Hall answers kept on the phone until the server has them (BOLT-0019, D-2026-10-22-24).
final mockAnswerStoreProvider = Provider<MockAnswerStore>(
  (ref) => DriftMockAnswerStore(ref.watch(hmDatabaseProvider)),
);
