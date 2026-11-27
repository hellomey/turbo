//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LeaderboardOptIn {
  /// Returns a new [LeaderboardOptIn] instance.
  LeaderboardOptIn({
    required this.optIn,
    required this.listed,
  });

  bool optIn;

  bool listed;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LeaderboardOptIn &&
    other.optIn == optIn &&
    other.listed == listed;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (optIn.hashCode) +
    (listed.hashCode);

  @override
  String toString() => 'LeaderboardOptIn[optIn=$optIn, listed=$listed]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'optIn'] = this.optIn;
      json[r'listed'] = this.listed;
    return json;
  }

  /// Returns a new [LeaderboardOptIn] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LeaderboardOptIn? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "LeaderboardOptIn[$key]" is missing from JSON.');
        });
        assert(json[r'optIn'] != null, 'Required key "LeaderboardOptIn[optIn]" has a null value in JSON.');
        assert(json[r'listed'] != null, 'Required key "LeaderboardOptIn[listed]" has a null value in JSON.');
        return true;
      }());

      return LeaderboardOptIn(
        optIn: mapValueOfType<bool>(json, r'optIn')!,
        listed: mapValueOfType<bool>(json, r'listed')!,
      );
    }
    return null;
  }

  static List<LeaderboardOptIn> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LeaderboardOptIn>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LeaderboardOptIn.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LeaderboardOptIn> mapFromJson(dynamic json) {
    final map = <String, LeaderboardOptIn>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LeaderboardOptIn.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LeaderboardOptIn-objects as value to a dart map
  static Map<String, List<LeaderboardOptIn>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LeaderboardOptIn>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LeaderboardOptIn.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'optIn',
    'listed',
  };
}

