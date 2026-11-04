//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DeskTotpEnrollBody {
  /// Returns a new [DeskTotpEnrollBody] instance.
  DeskTotpEnrollBody({
    required this.challengeToken,
  });

  String challengeToken;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DeskTotpEnrollBody &&
    other.challengeToken == challengeToken;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (challengeToken.hashCode);

  @override
  String toString() => 'DeskTotpEnrollBody[challengeToken=$challengeToken]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'challengeToken'] = this.challengeToken;
    return json;
  }

  /// Returns a new [DeskTotpEnrollBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DeskTotpEnrollBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DeskTotpEnrollBody[$key]" is missing from JSON.');
        });
        assert(json[r'challengeToken'] != null, 'Required key "DeskTotpEnrollBody[challengeToken]" has a null value in JSON.');
        return true;
      }());

      return DeskTotpEnrollBody(
        challengeToken: mapValueOfType<String>(json, r'challengeToken')!,
      );
    }
    return null;
  }

  static List<DeskTotpEnrollBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DeskTotpEnrollBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DeskTotpEnrollBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DeskTotpEnrollBody> mapFromJson(dynamic json) {
    final map = <String, DeskTotpEnrollBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DeskTotpEnrollBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DeskTotpEnrollBody-objects as value to a dart map
  static Map<String, List<DeskTotpEnrollBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DeskTotpEnrollBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DeskTotpEnrollBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'challengeToken',
  };
}

