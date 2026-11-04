//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PlanExam {
  /// Returns a new [PlanExam] instance.
  PlanExam({
    required this.examCode,
    required this.attemptCycleId,
    required this.examDate,
    required this.priority,
    required this.daysLeft,
  });

  String examCode;

  String? attemptCycleId;

  DateTime? examDate;

  /// Minimum value: 1
  /// Maximum value: 3
  int priority;

  int? daysLeft;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PlanExam &&
    other.examCode == examCode &&
    other.attemptCycleId == attemptCycleId &&
    other.examDate == examDate &&
    other.priority == priority &&
    other.daysLeft == daysLeft;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (examCode.hashCode) +
    (attemptCycleId == null ? 0 : attemptCycleId!.hashCode) +
    (examDate == null ? 0 : examDate!.hashCode) +
    (priority.hashCode) +
    (daysLeft == null ? 0 : daysLeft!.hashCode);

  @override
  String toString() => 'PlanExam[examCode=$examCode, attemptCycleId=$attemptCycleId, examDate=$examDate, priority=$priority, daysLeft=$daysLeft]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'examCode'] = this.examCode;
    if (this.attemptCycleId != null) {
      json[r'attemptCycleId'] = this.attemptCycleId;
    } else {
      json[r'attemptCycleId'] = null;
    }
    if (this.examDate != null) {
      json[r'examDate'] = _dateFormatter.format(this.examDate!.toUtc());
    } else {
      json[r'examDate'] = null;
    }
      json[r'priority'] = this.priority;
    if (this.daysLeft != null) {
      json[r'daysLeft'] = this.daysLeft;
    } else {
      json[r'daysLeft'] = null;
    }
    return json;
  }

  /// Returns a new [PlanExam] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PlanExam? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PlanExam[$key]" is missing from JSON.');
        });
        assert(json[r'examCode'] != null, 'Required key "PlanExam[examCode]" has a null value in JSON.');
        assert(json[r'priority'] != null, 'Required key "PlanExam[priority]" has a null value in JSON.');
        return true;
      }());

      return PlanExam(
        examCode: mapValueOfType<String>(json, r'examCode')!,
        attemptCycleId: mapValueOfType<String>(json, r'attemptCycleId'),
        examDate: mapDateTime(json, r'examDate', r''),
        priority: mapValueOfType<int>(json, r'priority')!,
        daysLeft: mapValueOfType<int>(json, r'daysLeft'),
      );
    }
    return null;
  }

  static List<PlanExam> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PlanExam>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PlanExam.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PlanExam> mapFromJson(dynamic json) {
    final map = <String, PlanExam>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PlanExam.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PlanExam-objects as value to a dart map
  static Map<String, List<PlanExam>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PlanExam>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PlanExam.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'examCode',
    'attemptCycleId',
    'examDate',
    'priority',
    'daysLeft',
  };
}

