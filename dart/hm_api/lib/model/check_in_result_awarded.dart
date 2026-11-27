//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CheckInResultAwarded {
  /// Returns a new [CheckInResultAwarded] instance.
  CheckInResultAwarded({
    required this.xp,
    required this.points,
  });

  /// Minimum value: 0
  int xp;

  /// Minimum value: 0
  int points;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CheckInResultAwarded &&
    other.xp == xp &&
    other.points == points;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (xp.hashCode) +
    (points.hashCode);

  @override
  String toString() => 'CheckInResultAwarded[xp=$xp, points=$points]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'xp'] = this.xp;
      json[r'points'] = this.points;
    return json;
  }

  /// Returns a new [CheckInResultAwarded] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CheckInResultAwarded? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CheckInResultAwarded[$key]" is missing from JSON.');
        });
        assert(json[r'xp'] != null, 'Required key "CheckInResultAwarded[xp]" has a null value in JSON.');
        assert(json[r'points'] != null, 'Required key "CheckInResultAwarded[points]" has a null value in JSON.');
        return true;
      }());

      return CheckInResultAwarded(
        xp: mapValueOfType<int>(json, r'xp')!,
        points: mapValueOfType<int>(json, r'points')!,
      );
    }
    return null;
  }

  static List<CheckInResultAwarded> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CheckInResultAwarded>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CheckInResultAwarded.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CheckInResultAwarded> mapFromJson(dynamic json) {
    final map = <String, CheckInResultAwarded>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CheckInResultAwarded.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CheckInResultAwarded-objects as value to a dart map
  static Map<String, List<CheckInResultAwarded>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CheckInResultAwarded>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CheckInResultAwarded.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'xp',
    'points',
  };
}

