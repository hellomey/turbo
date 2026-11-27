//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class DuelAnswerResult {
  /// Returns a new [DuelAnswerResult] instance.
  DuelAnswerResult({
    required this.questionId,
    required this.correct,
    this.correctOptionIds = const [],
    required this.chosenOptionId,
    required this.confidence,
    required this.explanationMarkdown,
    required this.points,
  });

  String questionId;

  bool correct;

  List<String> correctOptionIds;

  String? chosenOptionId;

  int confidence;

  String explanationMarkdown;

  /// Minimum value: 0
  int points;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DuelAnswerResult &&
    other.questionId == questionId &&
    other.correct == correct &&
    _deepEquality.equals(other.correctOptionIds, correctOptionIds) &&
    other.chosenOptionId == chosenOptionId &&
    other.confidence == confidence &&
    other.explanationMarkdown == explanationMarkdown &&
    other.points == points;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (questionId.hashCode) +
    (correct.hashCode) +
    (correctOptionIds.hashCode) +
    (chosenOptionId == null ? 0 : chosenOptionId!.hashCode) +
    (confidence.hashCode) +
    (explanationMarkdown.hashCode) +
    (points.hashCode);

  @override
  String toString() => 'DuelAnswerResult[questionId=$questionId, correct=$correct, correctOptionIds=$correctOptionIds, chosenOptionId=$chosenOptionId, confidence=$confidence, explanationMarkdown=$explanationMarkdown, points=$points]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'questionId'] = this.questionId;
      json[r'correct'] = this.correct;
      json[r'correctOptionIds'] = this.correctOptionIds;
    if (this.chosenOptionId != null) {
      json[r'chosenOptionId'] = this.chosenOptionId;
    } else {
      json[r'chosenOptionId'] = null;
    }
      json[r'confidence'] = this.confidence;
      json[r'explanationMarkdown'] = this.explanationMarkdown;
      json[r'points'] = this.points;
    return json;
  }

  /// Returns a new [DuelAnswerResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DuelAnswerResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DuelAnswerResult[$key]" is missing from JSON.');
        });
        assert(json[r'questionId'] != null, 'Required key "DuelAnswerResult[questionId]" has a null value in JSON.');
        assert(json[r'correct'] != null, 'Required key "DuelAnswerResult[correct]" has a null value in JSON.');
        assert(json[r'correctOptionIds'] != null, 'Required key "DuelAnswerResult[correctOptionIds]" has a null value in JSON.');
        assert(json[r'confidence'] != null, 'Required key "DuelAnswerResult[confidence]" has a null value in JSON.');
        assert(json[r'explanationMarkdown'] != null, 'Required key "DuelAnswerResult[explanationMarkdown]" has a null value in JSON.');
        assert(json[r'points'] != null, 'Required key "DuelAnswerResult[points]" has a null value in JSON.');
        return true;
      }());

      return DuelAnswerResult(
        questionId: mapValueOfType<String>(json, r'questionId')!,
        correct: mapValueOfType<bool>(json, r'correct')!,
        correctOptionIds: json[r'correctOptionIds'] is Iterable
            ? (json[r'correctOptionIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        chosenOptionId: mapValueOfType<String>(json, r'chosenOptionId'),
        confidence: mapValueOfType<int>(json, r'confidence')!,
        explanationMarkdown: mapValueOfType<String>(json, r'explanationMarkdown')!,
        points: mapValueOfType<int>(json, r'points')!,
      );
    }
    return null;
  }

  static List<DuelAnswerResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DuelAnswerResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DuelAnswerResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DuelAnswerResult> mapFromJson(dynamic json) {
    final map = <String, DuelAnswerResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DuelAnswerResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DuelAnswerResult-objects as value to a dart map
  static Map<String, List<DuelAnswerResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DuelAnswerResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DuelAnswerResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'questionId',
    'correct',
    'correctOptionIds',
    'chosenOptionId',
    'confidence',
    'explanationMarkdown',
    'points',
  };
}

