//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExamStructure {
  /// Returns a new [ExamStructure] instance.
  ExamStructure({
    required this.examCode,
    required this.family,
    this.stages = const [],
    this.attemptCycles = const [],
    required this.disclaimer,
  });

  String examCode;

  ExamStructureFamily family;

  List<ExamStage> stages;

  List<ExamAttemptCycle> attemptCycles;

  String disclaimer;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExamStructure &&
    other.examCode == examCode &&
    other.family == family &&
    _deepEquality.equals(other.stages, stages) &&
    _deepEquality.equals(other.attemptCycles, attemptCycles) &&
    other.disclaimer == disclaimer;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (examCode.hashCode) +
    (family.hashCode) +
    (stages.hashCode) +
    (attemptCycles.hashCode) +
    (disclaimer.hashCode);

  @override
  String toString() => 'ExamStructure[examCode=$examCode, family=$family, stages=$stages, attemptCycles=$attemptCycles, disclaimer=$disclaimer]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'examCode'] = this.examCode;
      json[r'family'] = this.family;
      json[r'stages'] = this.stages;
      json[r'attemptCycles'] = this.attemptCycles;
      json[r'disclaimer'] = this.disclaimer;
    return json;
  }

  /// Returns a new [ExamStructure] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExamStructure? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExamStructure[$key]" is missing from JSON.');
        });
        assert(json[r'examCode'] != null, 'Required key "ExamStructure[examCode]" has a null value in JSON.');
        assert(json[r'family'] != null, 'Required key "ExamStructure[family]" has a null value in JSON.');
        assert(json[r'stages'] != null, 'Required key "ExamStructure[stages]" has a null value in JSON.');
        assert(json[r'attemptCycles'] != null, 'Required key "ExamStructure[attemptCycles]" has a null value in JSON.');
        assert(json[r'disclaimer'] != null, 'Required key "ExamStructure[disclaimer]" has a null value in JSON.');
        return true;
      }());

      return ExamStructure(
        examCode: mapValueOfType<String>(json, r'examCode')!,
        family: ExamStructureFamily.fromJson(json[r'family'])!,
        stages: ExamStage.listFromJson(json[r'stages']),
        attemptCycles: ExamAttemptCycle.listFromJson(json[r'attemptCycles']),
        disclaimer: mapValueOfType<String>(json, r'disclaimer')!,
      );
    }
    return null;
  }

  static List<ExamStructure> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExamStructure>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExamStructure.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExamStructure> mapFromJson(dynamic json) {
    final map = <String, ExamStructure>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExamStructure.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExamStructure-objects as value to a dart map
  static Map<String, List<ExamStructure>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExamStructure>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExamStructure.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'examCode',
    'family',
    'stages',
    'attemptCycles',
    'disclaimer',
  };
}

