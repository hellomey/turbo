//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ExpoChallengeResultResultsInner {
  /// Returns a new [ExpoChallengeResultResultsInner] instance.
  ExpoChallengeResultResultsInner({
    required this.questionId,
    required this.correct,
    required this.correctOptionId,
    required this.explanation,
  });

  String questionId;

  bool correct;

  String correctOptionId;

  String explanation;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ExpoChallengeResultResultsInner &&
    other.questionId == questionId &&
    other.correct == correct &&
    other.correctOptionId == correctOptionId &&
    other.explanation == explanation;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (questionId.hashCode) +
    (correct.hashCode) +
    (correctOptionId.hashCode) +
    (explanation.hashCode);

  @override
  String toString() => 'ExpoChallengeResultResultsInner[questionId=$questionId, correct=$correct, correctOptionId=$correctOptionId, explanation=$explanation]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'questionId'] = this.questionId;
      json[r'correct'] = this.correct;
      json[r'correctOptionId'] = this.correctOptionId;
      json[r'explanation'] = this.explanation;
    return json;
  }

  /// Returns a new [ExpoChallengeResultResultsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ExpoChallengeResultResultsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ExpoChallengeResultResultsInner[$key]" is missing from JSON.');
        });
        assert(json[r'questionId'] != null, 'Required key "ExpoChallengeResultResultsInner[questionId]" has a null value in JSON.');
        assert(json[r'correct'] != null, 'Required key "ExpoChallengeResultResultsInner[correct]" has a null value in JSON.');
        assert(json[r'correctOptionId'] != null, 'Required key "ExpoChallengeResultResultsInner[correctOptionId]" has a null value in JSON.');
        assert(json[r'explanation'] != null, 'Required key "ExpoChallengeResultResultsInner[explanation]" has a null value in JSON.');
        return true;
      }());

      return ExpoChallengeResultResultsInner(
        questionId: mapValueOfType<String>(json, r'questionId')!,
        correct: mapValueOfType<bool>(json, r'correct')!,
        correctOptionId: mapValueOfType<String>(json, r'correctOptionId')!,
        explanation: mapValueOfType<String>(json, r'explanation')!,
      );
    }
    return null;
  }

  static List<ExpoChallengeResultResultsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExpoChallengeResultResultsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExpoChallengeResultResultsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ExpoChallengeResultResultsInner> mapFromJson(dynamic json) {
    final map = <String, ExpoChallengeResultResultsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ExpoChallengeResultResultsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ExpoChallengeResultResultsInner-objects as value to a dart map
  static Map<String, List<ExpoChallengeResultResultsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ExpoChallengeResultResultsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ExpoChallengeResultResultsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'questionId',
    'correct',
    'correctOptionId',
    'explanation',
  };
}

