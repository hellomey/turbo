import 'package:hm_api/api.dart' as api;

/// JSON → generated `hm_api` models for the offline layer.
///
/// WORKAROUND (BOLT-0016, follow-up raised in the bolt file): the generated `fromJson` asserts that every
/// *required* key is non-null, but the contract marks some required keys nullable (`TopicState.litAt`,
/// `SyncActionResult.errorCode`, `ContentPack.subjectCode`). In debug builds those asserts fire on valid
/// server JSON. These readers build the same generated classes with their constructors and skip only that
/// assert; no model is redefined. Delete this file once the codegen is fixed.
abstract final class Wire {
  static Map<String, dynamic> _map(Object? json) {
    if (json is Map) return json.cast<String, dynamic>();
    throw const FormatException('Expected a JSON object');
  }

  static T _req<T>(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is T) return v;
    throw FormatException('Bad or missing "$key"');
  }

  static DateTime? _date(Map<String, dynamic> json, String key) {
    final v = json[key];
    return v is String ? DateTime.parse(v) : null;
  }

  static T _enum<T>(T? value, String key) =>
      value ?? (throw FormatException('Bad "$key"'));

  static api.LampRing lampRing(Object? value) {
    final json = _map(value);
    return api.LampRing(
      lit: _req<bool>(json, 'lit'),
      steadyLevel: _req<int>(json, 'steadyLevel'),
      gold: _req<bool>(json, 'gold'),
      dim: _enum(api.LampRingDimEnum.fromJson(json['dim']), 'dim'),
    );
  }

  static api.TopicState topicState(Object? value) {
    final json = _map(value);
    return api.TopicState(
      topicId: _req<String>(json, 'topicId'),
      ring: lampRing(json['ring']),
      litAt: _date(json, 'litAt'),
      goldAt: _date(json, 'goldAt'),
      lessonCompletedAt: _date(json, 'lessonCompletedAt'),
      nextDueAt: _date(json, 'nextDueAt'),
      nextCheck: _enum(
        api.TopicStateNextCheckEnum.fromJson(json['nextCheck']),
        'nextCheck',
      ),
      updatedAt:
          _date(json, 'updatedAt') ??
          (throw const FormatException('Bad "updatedAt"')),
    );
  }

  static api.SyncBatchResult syncBatchResult(Object? value) {
    final json = _map(value);
    return api.SyncBatchResult(
      results: [
        for (final r in _req<List<dynamic>>(json, 'results'))
          _syncActionResult(r),
      ],
      topicStates: [
        for (final t in _req<List<dynamic>>(json, 'topicStates')) topicState(t),
      ],
      serverNow:
          _date(json, 'serverNow') ??
          (throw const FormatException('Bad "serverNow"')),
    );
  }

  static api.SyncActionResult _syncActionResult(Object? value) {
    final json = _map(value);
    return api.SyncActionResult(
      clientActionId: _req<String>(json, 'clientActionId'),
      status: _enum(
        api.SyncActionResultStatusEnum.fromJson(json['status']),
        'status',
      ),
      errorCode: json['errorCode'] as String?,
    );
  }

  static List<api.ContentPack> contentPacks(Object? value) => [
    for (final p in _req<List<dynamic>>(_map(value), 'items')) _contentPack(p),
  ];

  static api.ContentPack _contentPack(Object? value) {
    final json = _map(value);
    return api.ContentPack(
      id: _req<String>(json, 'id'),
      code: _req<String>(json, 'code'),
      examCode: _req<String>(json, 'examCode'),
      subjectCode: json['subjectCode'] as String?,
      version: _req<int>(json, 'version'),
      url: _req<String>(json, 'url'),
      sha256: _req<String>(json, 'sha256'),
      sizeBytes: _req<int>(json, 'sizeBytes'),
      tier: _enum(api.ContentPackTierEnum.fromJson(json['tier']), 'tier'),
      locked: _req<bool>(json, 'locked'),
      publishedAt:
          _date(json, 'publishedAt') ??
          (throw const FormatException('Bad "publishedAt"')),
    );
  }
}
