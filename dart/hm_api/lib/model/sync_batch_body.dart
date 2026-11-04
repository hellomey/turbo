//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SyncBatchBody {
  /// Returns a new [SyncBatchBody] instance.
  SyncBatchBody({
    required this.deviceId,
    this.actions = const [],
  });

  String deviceId;

  List<SyncAction> actions;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SyncBatchBody &&
    other.deviceId == deviceId &&
    _deepEquality.equals(other.actions, actions);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (deviceId.hashCode) +
    (actions.hashCode);

  @override
  String toString() => 'SyncBatchBody[deviceId=$deviceId, actions=$actions]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'deviceId'] = this.deviceId;
      json[r'actions'] = this.actions;
    return json;
  }

  /// Returns a new [SyncBatchBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SyncBatchBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SyncBatchBody[$key]" is missing from JSON.');
        });
        assert(json[r'deviceId'] != null, 'Required key "SyncBatchBody[deviceId]" has a null value in JSON.');
        assert(json[r'actions'] != null, 'Required key "SyncBatchBody[actions]" has a null value in JSON.');
        return true;
      }());

      return SyncBatchBody(
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        actions: SyncAction.listFromJson(json[r'actions']),
      );
    }
    return null;
  }

  static List<SyncBatchBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SyncBatchBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SyncBatchBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SyncBatchBody> mapFromJson(dynamic json) {
    final map = <String, SyncBatchBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SyncBatchBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SyncBatchBody-objects as value to a dart map
  static Map<String, List<SyncBatchBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SyncBatchBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SyncBatchBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'deviceId',
    'actions',
  };
}

