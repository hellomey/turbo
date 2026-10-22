import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hm_api/api.dart' as api;
import 'package:hm_core/hm_core.dart';
import 'package:hm_data/hm_data.dart';

/// Content packs (§39, U-app-shell invariant 6), sync triggers and the Drift store. BOLT-0016.

class FakeTransport implements PackTransport {
  FakeTransport(this.bytes);
  List<int> bytes;
  final froms = <int>[];

  /// Bytes to send before the connection "breaks" (null = all).
  int? breakAfter;
  bool honourRange = true;

  @override
  Future<PackResponse> get(String url, {int from = 0}) async {
    froms.add(from);
    final start = honourRange ? from : 0;
    final chunk = bytes.sublist(start);
    final cut = breakAfter;
    if (cut != null) {
      breakAfter = null;
      final controller = StreamController<List<int>>();
      controller.add(chunk.sublist(0, cut));
      unawaited(
        Future<void>(() async {
          controller.addError(const SocketException('reset'));
          await controller.close();
        }),
      );
      return PackResponse(
        statusCode: honourRange && from > 0 ? 206 : 200,
        body: controller.stream,
      );
    }
    return PackResponse(
      statusCode: honourRange && from > 0 ? 206 : 200,
      body: Stream.value(chunk),
    );
  }
}

class NoCatalog implements PackCatalogGateway {
  @override
  Future<List<api.ContentPack>> listPacks(String examCode) async => const [];
}

class CountingGateway implements StudySyncGateway {
  int calls = 0;
  @override
  Future<api.SyncBatchResult> send({
    required String idempotencyKey,
    required String deviceId,
    required List<Map<String, Object>> actions,
  }) async {
    calls++;
    return api.SyncBatchResult(
      results: [
        for (final a in actions)
          api.SyncActionResult(
            clientActionId: a['clientActionId']! as String,
            status: api.SyncActionResultStatusEnum.accepted,
            errorCode: null,
          ),
      ],
      topicStates: const [],
      serverNow: DateTime.utc(2026),
    );
  }
}

void main() {
  const wifi = NetworkState(online: true, wifi: true);
  const mobile = NetworkState(online: true, wifi: false);
  final bytes = utf8.encode('{"pack":"tnpsc-g4-history","v":2}' * 50);
  final digest = sha256.convert(bytes).toString();

  late Directory dir;
  late MemoryPackStore store;
  late FakeTransport transport;
  late PackDownloader downloader;

  PackOffer offer({String? sha, int? size, bool locked = false, int v = 2}) =>
      PackOffer(
        code: 'tnpsc-g4-history',
        version: v,
        url: 'https://cdn.heymey.app/packs/x.zip',
        sha256: sha ?? digest,
        sizeBytes: size ?? bytes.length,
        tier: PackTier.free,
        locked: locked,
      );

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('hm_packs_');
    store = MemoryPackStore();
    transport = FakeTransport(bytes);
    downloader = PackDownloader(
      catalog: NoCatalog(),
      transport: transport,
      store: store,
      directory: () async => dir,
    );
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('downloads, verifies SHA-256 and installs', () async {
    final r = await downloader.download(offer(), network: wifi);
    expect(r, PackDownloadResult.installed);
    final installed = (await store.get('tnpsc-g4-history'))!;
    expect(await File(installed.path).readAsBytes(), bytes);
    expect(
      await downloader.download(offer(), network: wifi),
      PackDownloadResult.alreadyInstalled,
    );
  });

  test('Wi-Fi only by default; mobile data when allowed', () async {
    expect(
      await downloader.download(offer(), network: mobile),
      PackDownloadResult.waitingForWifi,
    );
    expect(
      await downloader.download(offer(), network: NetworkState.offline),
      PackDownloadResult.offline,
    );
    expect(transport.froms, isEmpty);
    expect(
      await downloader.download(
        offer(),
        network: mobile,
        allowMobileData: true,
      ),
      PackDownloadResult.installed,
    );
  });

  test('locked (Pro) packs are never requested', () async {
    expect(
      await downloader.download(offer(locked: true), network: wifi),
      PackDownloadResult.locked,
    );
    expect(transport.froms, isEmpty);
  });

  test('a broken download resumes from the bytes on disk', () async {
    transport.breakAfter = 300;
    expect(
      await downloader.download(offer(), network: wifi),
      PackDownloadResult.failed,
    );
    expect(await store.get('tnpsc-g4-history'), isNull);
    expect(
      await downloader.download(offer(), network: wifi),
      PackDownloadResult.installed,
    );
    expect(transport.froms, [0, 300]);
  });

  test('server ignoring Range restarts from zero', () async {
    transport.breakAfter = 300;
    await downloader.download(offer(), network: wifi);
    transport.honourRange = false;
    expect(
      await downloader.download(offer(), network: wifi),
      PackDownloadResult.installed,
    );
  });

  test('checksum mismatch deletes the file and installs nothing', () async {
    final r = await downloader.download(offer(sha: '0' * 64), network: wifi);
    expect(r, PackDownloadResult.checksumMismatch);
    expect(await store.get('tnpsc-g4-history'), isNull);
    expect(dir.listSync(), isEmpty);
  });

  test('size mismatch deletes the file', () async {
    final r = await downloader.download(
      offer(size: bytes.length - 10),
      network: wifi,
    );
    expect(r, PackDownloadResult.sizeMismatch);
    expect(dir.listSync(), isEmpty);
  });

  test(
    'a newer version replaces the old one after its checksum passes',
    () async {
      await downloader.download(offer(v: 1), network: wifi);
      final v1 = (await store.get('tnpsc-g4-history'))!;
      final next = utf8.encode('{"v":3}' * 40);
      transport.bytes = next;
      final bad = await downloader.download(
        PackOffer(
          code: 'tnpsc-g4-history',
          version: 3,
          url: 'u',
          sha256: '1' * 64,
          sizeBytes: next.length,
          tier: PackTier.free,
          locked: false,
        ),
        network: wifi,
      );
      expect(bad, PackDownloadResult.checksumMismatch);
      expect((await store.get('tnpsc-g4-history'))!.version, 1);
      expect(await File(v1.path).exists(), isTrue);

      final good = await downloader.download(
        PackOffer(
          code: 'tnpsc-g4-history',
          version: 3,
          url: 'u',
          sha256: sha256.convert(next).toString(),
          sizeBytes: next.length,
          tier: PackTier.free,
          locked: false,
        ),
        network: wifi,
      );
      expect(good, PackDownloadResult.installed);
      expect((await store.get('tnpsc-g4-history'))!.version, 3);
      expect(await File(v1.path).exists(), isFalse);
    },
  );

  group('sync triggers', () {
    test('coming online syncs; recording while offline waits', () async {
      final outbox = MemoryOutboxStore();
      final gateway = CountingGateway();
      final network = StreamController<NetworkState>();
      final now = DateTime.utc(2026, 10, 22);
      final repo = OutboxRepository(
        outbox: outbox,
        topicStates: MemoryTopicStateStore(),
        clock: () => now,
      );
      final triggers = SyncTriggers(
        engine: SyncEngine(
          outbox: outbox,
          topicStates: MemoryTopicStateStore(),
          gateway: gateway,
          deviceId: () async => 'device-0001',
          clock: () => now,
        ),
        network: network.stream,
        clock: () => now,
      );
      final reports = <SyncReport>[];
      triggers.reports.listen(reports.add);

      network.add(NetworkState.offline);
      await pumpEventQueue();
      await repo.record(
        const LessonCompleteAction(topicId: 't1', via: LessonVia.lesson),
      );
      expect(await triggers.actionRecorded(), isNull);
      expect(gateway.calls, 0);

      network.add(wifi);
      await pumpEventQueue();
      expect(gateway.calls, 1);
      expect(reports.single.accepted, 1);

      await repo.record(
        const LessonCompleteAction(topicId: 't2', via: LessonVia.lesson),
      );
      final r = await triggers.actionRecorded();
      expect(r!.accepted, 1);
      await triggers.dispose();
      await network.close();
    });
  });

  group('drift store', () {
    late HmDatabase db;
    setUp(() => db = HmDatabase.memory());
    tearDown(() => db.close());

    test('outbox keeps order, dedups and marks rejected', () async {
      final store = DriftOutboxStore(db);
      final at = DateTime.utc(2026, 10, 22, 6);
      for (final id in ['a', 'b', 'c']) {
        expect(
          await store.add(
            NewOutboxEntry(
              clientActionId: id,
              kind: 'lesson_complete',
              payloadJson: '{"topicId":"t","via":"lesson"}',
              clientAt: at,
            ),
          ),
          isTrue,
        );
      }
      expect(
        await store.add(
          NewOutboxEntry(
            clientActionId: 'a',
            kind: 'lesson_complete',
            payloadJson: '{}',
            clientAt: at,
          ),
        ),
        isFalse,
      );
      expect(
        [for (final e in await store.pending(limit: 10)) e.clientActionId],
        ['a', 'b', 'c'],
      );
      await store.recordFailure(['a'], 'NETWORK_ERROR');
      await store.markRejected('b', 'TOPIC_NOT_FOUND');
      await store.remove(['c']);
      final pending = await store.pending(limit: 10);
      expect(pending.single.attempts, 1);
      expect(pending.single.clientAt, at);
      expect((await store.rejected()).single.lastError, 'TOPIC_NOT_FOUND');
      expect(await store.pendingCount(), 1);
    });

    test('topic states and packs replace by key', () async {
      final topics = DriftTopicStateStore(db);
      final at = DateTime.utc(2026, 10, 22);
      await topics.putAll([
        TopicStateRecord(topicId: 't1', json: '{"v":1}', updatedAt: at),
      ]);
      await topics.putAll([
        TopicStateRecord(topicId: 't1', json: '{"v":2}', updatedAt: at),
      ]);
      expect((await topics.get('t1'))!.json, '{"v":2}');
      expect(await topics.all(), hasLength(1));

      final packs = DriftPackStore(db);
      const pack = InstalledPack(
        code: 'p',
        version: 1,
        sha256: 'ab',
        path: '/x',
        sizeBytes: 3,
        tier: PackTier.pro,
      );
      await packs.put(pack);
      expect((await packs.get('p'))!.tier, PackTier.pro);
      await packs.remove('p');
      expect(await packs.all(), isEmpty);
    });
  });
}
