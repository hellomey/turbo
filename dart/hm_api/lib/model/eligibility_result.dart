//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class EligibilityResult {
  /// Returns a new [EligibilityResult] instance.
  EligibilityResult({
    required this.eligibleCount,
    this.eligible = const [],
    this.notEligible = const [],
    required this.disclaimer,
  });

  int eligibleCount;

  List<ExamEligibility> eligible;

  List<ExamEligibility> notEligible;

  String disclaimer;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EligibilityResult &&
    other.eligibleCount == eligibleCount &&
    _deepEquality.equals(other.eligible, eligible) &&
    _deepEquality.equals(other.notEligible, notEligible) &&
    other.disclaimer == disclaimer;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (eligibleCount.hashCode) +
    (eligible.hashCode) +
    (notEligible.hashCode) +
    (disclaimer.hashCode);

  @override
  String toString() => 'EligibilityResult[eligibleCount=$eligibleCount, eligible=$eligible, notEligible=$notEligible, disclaimer=$disclaimer]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'eligibleCount'] = this.eligibleCount;
      json[r'eligible'] = this.eligible;
      json[r'notEligible'] = this.notEligible;
      json[r'disclaimer'] = this.disclaimer;
    return json;
  }

  /// Returns a new [EligibilityResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EligibilityResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "EligibilityResult[$key]" is missing from JSON.');
        });
        assert(json[r'eligibleCount'] != null, 'Required key "EligibilityResult[eligibleCount]" has a null value in JSON.');
        assert(json[r'eligible'] != null, 'Required key "EligibilityResult[eligible]" has a null value in JSON.');
        assert(json[r'notEligible'] != null, 'Required key "EligibilityResult[notEligible]" has a null value in JSON.');
        assert(json[r'disclaimer'] != null, 'Required key "EligibilityResult[disclaimer]" has a null value in JSON.');
        return true;
      }());

      return EligibilityResult(
        eligibleCount: mapValueOfType<int>(json, r'eligibleCount')!,
        eligible: ExamEligibility.listFromJson(json[r'eligible']),
        notEligible: ExamEligibility.listFromJson(json[r'notEligible']),
        disclaimer: mapValueOfType<String>(json, r'disclaimer')!,
      );
    }
    return null;
  }

  static List<EligibilityResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EligibilityResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EligibilityResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EligibilityResult> mapFromJson(dynamic json) {
    final map = <String, EligibilityResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EligibilityResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EligibilityResult-objects as value to a dart map
  static Map<String, List<EligibilityResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EligibilityResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EligibilityResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'eligibleCount',
    'eligible',
    'notEligible',
    'disclaimer',
  };
}

