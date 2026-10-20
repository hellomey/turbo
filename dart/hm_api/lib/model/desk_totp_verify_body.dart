//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DeskTotpVerifyBody {
  /// Returns a new [DeskTotpVerifyBody] instance.
  DeskTotpVerifyBody({
    required this.challengeToken,
    required this.code,
  });

  String challengeToken;

  String code;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DeskTotpVerifyBody &&
    other.challengeToken == challengeToken &&
    other.code == code;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (challengeToken.hashCode) +
    (code.hashCode);

  @override
  String toString() => 'DeskTotpVerifyBody[challengeToken=$challengeToken, code=$code]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'challengeToken'] = this.challengeToken;
      json[r'code'] = this.code;
    return json;
  }

  /// Returns a new [DeskTotpVerifyBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DeskTotpVerifyBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DeskTotpVerifyBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "DeskTotpVerifyBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return DeskTotpVerifyBody(
        challengeToken: mapValueOfType<String>(json, r'challengeToken')!,
        code: mapValueOfType<String>(json, r'code')!,
      );
    }
    return null;
  }

  static List<DeskTotpVerifyBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DeskTotpVerifyBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DeskTotpVerifyBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DeskTotpVerifyBody> mapFromJson(dynamic json) {
    final map = <String, DeskTotpVerifyBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DeskTotpVerifyBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DeskTotpVerifyBody-objects as value to a dart map
  static Map<String, List<DeskTotpVerifyBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DeskTotpVerifyBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DeskTotpVerifyBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'challengeToken',
    'code',
  };
}

