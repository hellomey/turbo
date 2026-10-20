//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExamEligibilityAgeLimit {
  /// Returns a new [ExamEligibilityAgeLimit] instance.
  ExamEligibilityAgeLimit({
    required this.min,
    required this.max,
    required this.asOf,
  });

  int min;

  int? max;

  DateTime asOf;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExamEligibilityAgeLimit &&
    other.min == min &&
    other.max == max &&
    other.asOf == asOf;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (min.hashCode) +
    (max == null ? 0 : max!.hashCode) +
    (asOf.hashCode);

  @override
  String toString() => 'ExamEligibilityAgeLimit[min=$min, max=$max, asOf=$asOf]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'min'] = this.min;
    if (this.max != null) {
      json[r'max'] = this.max;
    } else {
      json[r'max'] = null;
    }
      json[r'asOf'] = _dateFormatter.format(this.asOf.toUtc());
    return json;
  }

  /// Returns a new [ExamEligibilityAgeLimit] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExamEligibilityAgeLimit? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExamEligibilityAgeLimit[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ExamEligibilityAgeLimit[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ExamEligibilityAgeLimit(
        min: mapValueOfType<int>(json, r'min')!,
        max: mapValueOfType<int>(json, r'max'),
        asOf: mapDateTime(json, r'asOf', r'')!,
      );
    }
    return null;
  }

  static List<ExamEligibilityAgeLimit> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamEligibilityAgeLimit>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamEligibilityAgeLimit.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExamEligibilityAgeLimit> mapFromJson(dynamic json) {
    final map = <String, ExamEligibilityAgeLimit>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExamEligibilityAgeLimit.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExamEligibilityAgeLimit-objects as value to a dart map
  static Map<String, List<ExamEligibilityAgeLimit>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExamEligibilityAgeLimit>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExamEligibilityAgeLimit.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'min',
    'max',
    'asOf',
  };
}

