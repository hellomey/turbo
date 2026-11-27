//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class LeaderboardOptInBody {
  /// Returns a new [LeaderboardOptInBody] instance.
  LeaderboardOptInBody({
    required this.optIn,
  });

  bool optIn;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LeaderboardOptInBody &&
    other.optIn == optIn;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (optIn.hashCode);

  @override
  String toString() => 'LeaderboardOptInBody[optIn=$optIn]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'optIn'] = this.optIn;
    return json;
  }

  /// Returns a new [LeaderboardOptInBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LeaderboardOptInBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "LeaderboardOptInBody[$key]" is missing from JSON.');
        });
        assert(json[r'optIn'] != null, 'Required key "LeaderboardOptInBody[optIn]" has a null value in JSON.');
        return true;
      }());

      return LeaderboardOptInBody(
        optIn: mapValueOfType<bool>(json, r'optIn')!,
      );
    }
    return null;
  }

  static List<LeaderboardOptInBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LeaderboardOptInBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LeaderboardOptInBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LeaderboardOptInBody> mapFromJson(dynamic json) {
    final map = <String, LeaderboardOptInBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LeaderboardOptInBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LeaderboardOptInBody-objects as value to a dart map
  static Map<String, List<LeaderboardOptInBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LeaderboardOptInBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LeaderboardOptInBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'optIn',
  };
}

