//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CheckInResult {
  /// Returns a new [CheckInResult] instance.
  CheckInResult({
    required this.awarded,
    required this.alreadyCheckedIn,
  });

  CheckInResultAwarded awarded;

  bool alreadyCheckedIn;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CheckInResult &&
    other.awarded == awarded &&
    other.alreadyCheckedIn == alreadyCheckedIn;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (awarded.hashCode) +
    (alreadyCheckedIn.hashCode);

  @override
  String toString() => 'CheckInResult[awarded=$awarded, alreadyCheckedIn=$alreadyCheckedIn]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'awarded'] = this.awarded;
      json[r'alreadyCheckedIn'] = this.alreadyCheckedIn;
    return json;
  }

  /// Returns a new [CheckInResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CheckInResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CheckInResult[$key]" is missing from JSON.');
        });
        assert(json[r'awarded'] != null, 'Required key "CheckInResult[awarded]" has a null value in JSON.');
        assert(json[r'alreadyCheckedIn'] != null, 'Required key "CheckInResult[alreadyCheckedIn]" has a null value in JSON.');
        return true;
      }());

      return CheckInResult(
        awarded: CheckInResultAwarded.fromJson(json[r'awarded'])!,
        alreadyCheckedIn: mapValueOfType<bool>(json, r'alreadyCheckedIn')!,
      );
    }
    return null;
  }

  static List<CheckInResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CheckInResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CheckInResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CheckInResult> mapFromJson(dynamic json) {
    final map = <String, CheckInResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CheckInResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CheckInResult-objects as value to a dart map
  static Map<String, List<CheckInResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CheckInResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CheckInResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'awarded',
    'alreadyCheckedIn',
  };
}

