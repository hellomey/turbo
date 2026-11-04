//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SyncBatchResult {
  /// Returns a new [SyncBatchResult] instance.
  SyncBatchResult({
    this.results = const [],
    this.topicStates = const [],
    required this.serverNow,
  });

  List<SyncActionResult> results;

  List<TopicState> topicStates;

  DateTime serverNow;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SyncBatchResult &&
    _deepEquality.equals(other.results, results) &&
    _deepEquality.equals(other.topicStates, topicStates) &&
    other.serverNow == serverNow;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (results.hashCode) +
    (topicStates.hashCode) +
    (serverNow.hashCode);

  @override
  String toString() => 'SyncBatchResult[results=$results, topicStates=$topicStates, serverNow=$serverNow]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'results'] = this.results;
      json[r'topicStates'] = this.topicStates;
      json[r'serverNow'] = this.serverNow.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [SyncBatchResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SyncBatchResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SyncBatchResult[$key]" is missing from JSON.');
        });
        assert(json[r'results'] != null, 'Required key "SyncBatchResult[results]" has a null value in JSON.');
        assert(json[r'topicStates'] != null, 'Required key "SyncBatchResult[topicStates]" has a null value in JSON.');
        assert(json[r'serverNow'] != null, 'Required key "SyncBatchResult[serverNow]" has a null value in JSON.');
        return true;
      }());

      return SyncBatchResult(
        results: SyncActionResult.listFromJson(json[r'results']),
        topicStates: TopicState.listFromJson(json[r'topicStates']),
        serverNow: mapDateTime(json, r'serverNow', r'')!,
      );
    }
    return null;
  }

  static List<SyncBatchResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncBatchResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncBatchResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SyncBatchResult> mapFromJson(dynamic json) {
    final map = <String, SyncBatchResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SyncBatchResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SyncBatchResult-objects as value to a dart map
  static Map<String, List<SyncBatchResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SyncBatchResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SyncBatchResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'results',
    'topicStates',
    'serverNow',
  };
}

