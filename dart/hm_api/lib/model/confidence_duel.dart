//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ConfidenceDuel {
  /// Returns a new [ConfidenceDuel] instance.
  ConfidenceDuel({
    required this.duelId,
    required this.examCode,
    required this.startedAt,
    this.questions = const [],
    required this.rules,
    required this.pointsToday,
  });

  String duelId;

  String examCode;

  DateTime startedAt;

  List<Question> questions;

  DuelRules rules;

  /// Minimum value: 0
  int pointsToday;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ConfidenceDuel &&
    other.duelId == duelId &&
    other.examCode == examCode &&
    other.startedAt == startedAt &&
    _deepEquality.equals(other.questions, questions) &&
    other.rules == rules &&
    other.pointsToday == pointsToday;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (duelId.hashCode) +
    (examCode.hashCode) +
    (startedAt.hashCode) +
    (questions.hashCode) +
    (rules.hashCode) +
    (pointsToday.hashCode);

  @override
  String toString() => 'ConfidenceDuel[duelId=$duelId, examCode=$examCode, startedAt=$startedAt, questions=$questions, rules=$rules, pointsToday=$pointsToday]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'duelId'] = this.duelId;
      json[r'examCode'] = this.examCode;
      json[r'startedAt'] = this.startedAt.toUtc().toIso8601String();
      json[r'questions'] = this.questions;
      json[r'rules'] = this.rules;
      json[r'pointsToday'] = this.pointsToday;
    return json;
  }

  /// Returns a new [ConfidenceDuel] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ConfidenceDuel? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ConfidenceDuel[$key]" is missing from JSON.');
        });
        assert(json[r'duelId'] != null, 'Required key "ConfidenceDuel[duelId]" has a null value in JSON.');
        assert(json[r'examCode'] != null, 'Required key "ConfidenceDuel[examCode]" has a null value in JSON.');
        assert(json[r'startedAt'] != null, 'Required key "ConfidenceDuel[startedAt]" has a null value in JSON.');
        assert(json[r'questions'] != null, 'Required key "ConfidenceDuel[questions]" has a null value in JSON.');
        assert(json[r'rules'] != null, 'Required key "ConfidenceDuel[rules]" has a null value in JSON.');
        assert(json[r'pointsToday'] != null, 'Required key "ConfidenceDuel[pointsToday]" has a null value in JSON.');
        return true;
      }());

      return ConfidenceDuel(
        duelId: mapValueOfType<String>(json, r'duelId')!,
        examCode: mapValueOfType<String>(json, r'examCode')!,
        startedAt: mapDateTime(json, r'startedAt', r'')!,
        questions: Question.listFromJson(json[r'questions']),
        rules: DuelRules.fromJson(json[r'rules'])!,
        pointsToday: mapValueOfType<int>(json, r'pointsToday')!,
      );
    }
    return null;
  }

  static List<ConfidenceDuel> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ConfidenceDuel>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ConfidenceDuel.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ConfidenceDuel> mapFromJson(dynamic json) {
    final map = <String, ConfidenceDuel>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ConfidenceDuel.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ConfidenceDuel-objects as value to a dart map
  static Map<String, List<ConfidenceDuel>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ConfidenceDuel>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ConfidenceDuel.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'duelId',
    'examCode',
    'startedAt',
    'questions',
    'rules',
    'pointsToday',
  };
}

