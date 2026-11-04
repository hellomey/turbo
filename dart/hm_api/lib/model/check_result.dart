//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CheckResult {
  /// Returns a new [CheckResult] instance.
  CheckResult({
    required this.checkId,
    required this.kind,
    required this.passed,
    required this.correct,
    required this.total,
    required this.lateAnswersIgnored,
    this.graded = const [],
    required this.topicState,
    required this.rankUp,
  });

  String checkId;

  CheckKind kind;

  bool passed;

  /// Minimum value: 0
  int correct;

  int total;

  /// Minimum value: 0
  int lateAnswersIgnored;

  List<GradedAnswer> graded;

  TopicState topicState;

  RankChange rankUp;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CheckResult &&
    other.checkId == checkId &&
    other.kind == kind &&
    other.passed == passed &&
    other.correct == correct &&
    other.total == total &&
    other.lateAnswersIgnored == lateAnswersIgnored &&
    _deepEquality.equals(other.graded, graded) &&
    other.topicState == topicState &&
    other.rankUp == rankUp;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (checkId.hashCode) +
    (kind.hashCode) +
    (passed.hashCode) +
    (correct.hashCode) +
    (total.hashCode) +
    (lateAnswersIgnored.hashCode) +
    (graded.hashCode) +
    (topicState.hashCode) +
    (rankUp.hashCode);

  @override
  String toString() => 'CheckResult[checkId=$checkId, kind=$kind, passed=$passed, correct=$correct, total=$total, lateAnswersIgnored=$lateAnswersIgnored, graded=$graded, topicState=$topicState, rankUp=$rankUp]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'checkId'] = this.checkId;
      json[r'kind'] = this.kind;
      json[r'passed'] = this.passed;
      json[r'correct'] = this.correct;
      json[r'total'] = this.total;
      json[r'lateAnswersIgnored'] = this.lateAnswersIgnored;
      json[r'graded'] = this.graded;
      json[r'topicState'] = this.topicState;
      json[r'rankUp'] = this.rankUp;
    return json;
  }

  /// Returns a new [CheckResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CheckResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CheckResult[$key]" is missing from JSON.');
        });
        assert(json[r'checkId'] != null, 'Required key "CheckResult[checkId]" has a null value in JSON.');
        assert(json[r'kind'] != null, 'Required key "CheckResult[kind]" has a null value in JSON.');
        assert(json[r'passed'] != null, 'Required key "CheckResult[passed]" has a null value in JSON.');
        assert(json[r'correct'] != null, 'Required key "CheckResult[correct]" has a null value in JSON.');
        assert(json[r'total'] != null, 'Required key "CheckResult[total]" has a null value in JSON.');
        assert(json[r'lateAnswersIgnored'] != null, 'Required key "CheckResult[lateAnswersIgnored]" has a null value in JSON.');
        assert(json[r'graded'] != null, 'Required key "CheckResult[graded]" has a null value in JSON.');
        assert(json[r'topicState'] != null, 'Required key "CheckResult[topicState]" has a null value in JSON.');
        assert(json[r'rankUp'] != null, 'Required key "CheckResult[rankUp]" has a null value in JSON.');
        return true;
      }());

      return CheckResult(
        checkId: mapValueOfType<String>(json, r'checkId')!,
        kind: CheckKind.fromJson(json[r'kind'])!,
        passed: mapValueOfType<bool>(json, r'passed')!,
        correct: mapValueOfType<int>(json, r'correct')!,
        total: mapValueOfType<int>(json, r'total')!,
        lateAnswersIgnored: mapValueOfType<int>(json, r'lateAnswersIgnored')!,
        graded: GradedAnswer.listFromJson(json[r'graded']),
        topicState: TopicState.fromJson(json[r'topicState'])!,
        rankUp: RankChange.fromJson(json[r'rankUp'])!,
      );
    }
    return null;
  }

  static List<CheckResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CheckResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CheckResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CheckResult> mapFromJson(dynamic json) {
    final map = <String, CheckResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CheckResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CheckResult-objects as value to a dart map
  static Map<String, List<CheckResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CheckResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CheckResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'checkId',
    'kind',
    'passed',
    'correct',
    'total',
    'lateAnswersIgnored',
    'graded',
    'topicState',
    'rankUp',
  };
}

