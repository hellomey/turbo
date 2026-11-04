//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MockAnswersSaved {
  /// Returns a new [MockAnswersSaved] instance.
  MockAnswersSaved({
    required this.saved,
    required this.ignoredAfterDeadline,
    required this.serverNow,
    required this.remainingSeconds,
  });

  /// Minimum value: 0
  int saved;

  /// Minimum value: 0
  int ignoredAfterDeadline;

  DateTime serverNow;

  /// Minimum value: 0
  int remainingSeconds;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MockAnswersSaved &&
    other.saved == saved &&
    other.ignoredAfterDeadline == ignoredAfterDeadline &&
    other.serverNow == serverNow &&
    other.remainingSeconds == remainingSeconds;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (saved.hashCode) +
    (ignoredAfterDeadline.hashCode) +
    (serverNow.hashCode) +
    (remainingSeconds.hashCode);

  @override
  String toString() => 'MockAnswersSaved[saved=$saved, ignoredAfterDeadline=$ignoredAfterDeadline, serverNow=$serverNow, remainingSeconds=$remainingSeconds]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'saved'] = this.saved;
      json[r'ignoredAfterDeadline'] = this.ignoredAfterDeadline;
      json[r'serverNow'] = this.serverNow.toUtc().toIso8601String();
      json[r'remainingSeconds'] = this.remainingSeconds;
    return json;
  }

  /// Returns a new [MockAnswersSaved] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MockAnswersSaved? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MockAnswersSaved[$key]" is missing from JSON.');
        });
        assert(json[r'saved'] != null, 'Required key "MockAnswersSaved[saved]" has a null value in JSON.');
        assert(json[r'ignoredAfterDeadline'] != null, 'Required key "MockAnswersSaved[ignoredAfterDeadline]" has a null value in JSON.');
        assert(json[r'serverNow'] != null, 'Required key "MockAnswersSaved[serverNow]" has a null value in JSON.');
        assert(json[r'remainingSeconds'] != null, 'Required key "MockAnswersSaved[remainingSeconds]" has a null value in JSON.');
        return true;
      }());

      return MockAnswersSaved(
        saved: mapValueOfType<int>(json, r'saved')!,
        ignoredAfterDeadline: mapValueOfType<int>(json, r'ignoredAfterDeadline')!,
        serverNow: mapDateTime(json, r'serverNow', r'')!,
        remainingSeconds: mapValueOfType<int>(json, r'remainingSeconds')!,
      );
    }
    return null;
  }

  static List<MockAnswersSaved> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MockAnswersSaved>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MockAnswersSaved.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MockAnswersSaved> mapFromJson(dynamic json) {
    final map = <String, MockAnswersSaved>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MockAnswersSaved.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MockAnswersSaved-objects as value to a dart map
  static Map<String, List<MockAnswersSaved>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MockAnswersSaved>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MockAnswersSaved.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'saved',
    'ignoredAfterDeadline',
    'serverNow',
    'remainingSeconds',
  };
}

