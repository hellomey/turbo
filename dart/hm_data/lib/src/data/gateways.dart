import 'dart:async';

import 'package:hm_api/api.dart' as api;
import 'package:hm_core/hm_core.dart';
import 'package:http/http.dart' as http;

/// Server side of the outbox: `POST /v1/sync/study-actions` (§39, contract `sync.ts`).
abstract interface class StudySyncGateway {
  /// Sends one batch. [idempotencyKey] is the same on every retry of the same batch (§34.3).
  /// Throws [HmApiException] when the batch did not reach the server or was refused as a whole.
  Future<api.SyncBatchResult> send({
    required String idempotencyKey,
    required String deviceId,
    required List<Map<String, Object>> actions,
  });
}

/// `GET /v1/content/packs` (contract `ContentPackList`).
abstract interface class PackCatalogGateway {
  Future<List<api.ContentPack>> listPacks(String examCode);
}

/// One HTTP GET for pack bytes, starting at byte [from] (HTTP Range) so a broken download resumes.
abstract interface class PackTransport {
  Future<PackResponse> get(String url, {int from = 0});
}

class PackResponse {
  const PackResponse({required this.statusCode, required this.body});

  /// 206 = the server honoured the range (append); 200 = the whole file from the start.
  final int statusCode;
  final Stream<List<int>> body;
}

/// [StudySyncGateway] and [PackCatalogGateway] over [HmApi]; JSON is read with the generated
/// `hm_api` models.
class HmApiSyncGateway implements StudySyncGateway, PackCatalogGateway {
  HmApiSyncGateway(this._api);
  final HmApi _api;

  static const _unknown = HmApiException(
    HmApiException.unknownError,
    HmApiException.unknownMessage,
  );

  /// Generated `fromJson` returns null for a non-object and throws on a wrong-typed field.
  static T _parse<T>(T? Function() read) {
    try {
      return read() ?? (throw _unknown);
    } on FormatException {
      throw _unknown;
    } on TypeError {
      throw _unknown;
    }
  }

  @override
  Future<api.SyncBatchResult> send({
    required String idempotencyKey,
    required String deviceId,
    required List<Map<String, Object>> actions,
  }) async {
    final json = await _api.syncStudyActions({
      'deviceId': deviceId,
      'actions': actions,
    }, idempotencyKey: idempotencyKey);
    return _parse(() => api.SyncBatchResult.fromJson(json));
  }

  @override
  Future<List<api.ContentPack>> listPacks(String examCode) async {
    final json = await _api.listContentPacks(examCode);
    return _parse(() => api.ContentPackList.fromJson(json)?.items);
  }
}

/// Pack bytes from the CDN (`cdn.heymey.app`). Packs are public, signed by checksum, so no token is sent.
class HttpPackTransport implements PackTransport {
  HttpPackTransport(this._client);
  final http.Client _client;

  @override
  Future<PackResponse> get(String url, {int from = 0}) async {
    final request = http.Request('GET', Uri.parse(url));
    if (from > 0) request.headers['range'] = 'bytes=$from-';
    final res = await _client.send(request);
    return PackResponse(statusCode: res.statusCode, body: res.stream);
  }
}
