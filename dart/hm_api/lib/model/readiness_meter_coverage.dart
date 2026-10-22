//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReadinessMeterCoverage {
  /// Returns a new [ReadinessMeterCoverage] instance.
  ReadinessMeterCoverage({
    required this.litPct,
    required this.steadyPct,
    required this.goldPct,
  });

  int litPct;

  int steadyPct;

  int goldPct;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReadinessMeterCoverage &&
    other.litPct == litPct &&
    other.steadyPct == steadyPct &&
    other.goldPct == goldPct;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (litPct.hashCode) +
    (steadyPct.hashCode) +
    (goldPct.hashCode);

  @override
  String toString() => 'ReadinessMeterCoverage[litPct=$litPct, steadyPct=$steadyPct, goldPct=$goldPct]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'litPct'] = this.litPct;
      json[r'steadyPct'] = this.steadyPct;
      json[r'goldPct'] = this.goldPct;
    return json;
  }

  /// Returns a new [ReadinessMeterCoverage] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReadinessMeterCoverage? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReadinessMeterCoverage[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReadinessMeterCoverage[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReadinessMeterCoverage(
        litPct: mapValueOfType<int>(json, r'litPct')!,
        steadyPct: mapValueOfType<int>(json, r'steadyPct')!,
        goldPct: mapValueOfType<int>(json, r'goldPct')!,
      );
    }
    return null;
  }

  static List<ReadinessMeterCoverage> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReadinessMeterCoverage>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReadinessMeterCoverage.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReadinessMeterCoverage> mapFromJson(dynamic json) {
    final map = <String, ReadinessMeterCoverage>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReadinessMeterCoverage.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReadinessMeterCoverage-objects as value to a dart map
  static Map<String, List<ReadinessMeterCoverage>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReadinessMeterCoverage>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReadinessMeterCoverage.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'litPct',
    'steadyPct',
    'goldPct',
  };
}

