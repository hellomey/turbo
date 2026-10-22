//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GradedAnswer {
  /// Returns a new [GradedAnswer] instance.
  GradedAnswer({
    required this.questionId,
    required this.correct,
    this.correctOptionIds = const [],
    this.chosenOptionIds = const [],
    required this.explanationMarkdown,
    required this.whyChosenIsWrong,
    required this.source_,
    required this.topicId,
  });

  String questionId;

  bool correct;

  List<String> correctOptionIds;

  List<String> chosenOptionIds;

  String explanationMarkdown;

  String? whyChosenIsWrong;

  QuestionSource source_;

  String topicId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GradedAnswer &&
    other.questionId == questionId &&
    other.correct == correct &&
    _deepEquality.equals(other.correctOptionIds, correctOptionIds) &&
    _deepEquality.equals(other.chosenOptionIds, chosenOptionIds) &&
    other.explanationMarkdown == explanationMarkdown &&
    other.whyChosenIsWrong == whyChosenIsWrong &&
    other.source_ == source_ &&
    other.topicId == topicId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (questionId.hashCode) +
    (correct.hashCode) +
    (correctOptionIds.hashCode) +
    (chosenOptionIds.hashCode) +
    (explanationMarkdown.hashCode) +
    (whyChosenIsWrong == null ? 0 : whyChosenIsWrong!.hashCode) +
    (source_.hashCode) +
    (topicId.hashCode);

  @override
  String toString() => 'GradedAnswer[questionId=$questionId, correct=$correct, correctOptionIds=$correctOptionIds, chosenOptionIds=$chosenOptionIds, explanationMarkdown=$explanationMarkdown, whyChosenIsWrong=$whyChosenIsWrong, source_=$source_, topicId=$topicId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'questionId'] = this.questionId;
      json[r'correct'] = this.correct;
      json[r'correctOptionIds'] = this.correctOptionIds;
      json[r'chosenOptionIds'] = this.chosenOptionIds;
      json[r'explanationMarkdown'] = this.explanationMarkdown;
    if (this.whyChosenIsWrong != null) {
      json[r'whyChosenIsWrong'] = this.whyChosenIsWrong;
    } else {
      json[r'whyChosenIsWrong'] = null;
    }
      json[r'source'] = this.source_;
      json[r'topicId'] = this.topicId;
    return json;
  }

  /// Returns a new [GradedAnswer] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GradedAnswer? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GradedAnswer[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GradedAnswer[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GradedAnswer(
        questionId: mapValueOfType<String>(json, r'questionId')!,
        correct: mapValueOfType<bool>(json, r'correct')!,
        correctOptionIds: json[r'correctOptionIds'] is Iterable
            ? (json[r'correctOptionIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        chosenOptionIds: json[r'chosenOptionIds'] is Iterable
            ? (json[r'chosenOptionIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        explanationMarkdown: mapValueOfType<String>(json, r'explanationMarkdown')!,
        whyChosenIsWrong: mapValueOfType<String>(json, r'whyChosenIsWrong'),
        source_: QuestionSource.fromJson(json[r'source'])!,
        topicId: mapValueOfType<String>(json, r'topicId')!,
      );
    }
    return null;
  }

  static List<GradedAnswer> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GradedAnswer>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GradedAnswer.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GradedAnswer> mapFromJson(dynamic json) {
    final map = <String, GradedAnswer>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GradedAnswer.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GradedAnswer-objects as value to a dart map
  static Map<String, List<GradedAnswer>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GradedAnswer>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GradedAnswer.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'questionId',
    'correct',
    'correctOptionIds',
    'chosenOptionIds',
    'explanationMarkdown',
    'whyChosenIsWrong',
    'source',
    'topicId',
  };
}

