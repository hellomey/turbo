//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MockReport {
  /// Returns a new [MockReport] instance.
  MockReport({
    required this.attemptId,
    required this.mockId,
    required this.examCode,
    required this.submittedAt,
    required this.score,
    required this.maxScore,
    required this.scoreDisplay,
    required this.markingSchemeVersion,
    required this.correct,
    required this.wrong,
    required this.unanswered,
    this.sections = const [],
    this.mistakes = const [],
    this.weakTopicIds = const [],
    required this.ranked,
    required this.fullReportLocked,
  });

  String attemptId;

  String mockId;

  String examCode;

  DateTime submittedAt;

  Marks score;

  Marks maxScore;

  String scoreDisplay;

  int markingSchemeVersion;

  /// Minimum value: 0
  int correct;

  /// Minimum value: 0
  int wrong;

  /// Minimum value: 0
  int unanswered;

  List<SectionResult> sections;

  List<GradedAnswer> mistakes;

  List<String> weakTopicIds;

  bool ranked;

  bool fullReportLocked;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MockReport &&
    other.attemptId == attemptId &&
    other.mockId == mockId &&
    other.examCode == examCode &&
    other.submittedAt == submittedAt &&
    other.score == score &&
    other.maxScore == maxScore &&
    other.scoreDisplay == scoreDisplay &&
    other.markingSchemeVersion == markingSchemeVersion &&
    other.correct == correct &&
    other.wrong == wrong &&
    other.unanswered == unanswered &&
    _deepEquality.equals(other.sections, sections) &&
    _deepEquality.equals(other.mistakes, mistakes) &&
    _deepEquality.equals(other.weakTopicIds, weakTopicIds) &&
    other.ranked == ranked &&
    other.fullReportLocked == fullReportLocked;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (attemptId.hashCode) +
    (mockId.hashCode) +
    (examCode.hashCode) +
    (submittedAt.hashCode) +
    (score.hashCode) +
    (maxScore.hashCode) +
    (scoreDisplay.hashCode) +
    (markingSchemeVersion.hashCode) +
    (correct.hashCode) +
    (wrong.hashCode) +
    (unanswered.hashCode) +
    (sections.hashCode) +
    (mistakes.hashCode) +
    (weakTopicIds.hashCode) +
    (ranked.hashCode) +
    (fullReportLocked.hashCode);

  @override
  String toString() => 'MockReport[attemptId=$attemptId, mockId=$mockId, examCode=$examCode, submittedAt=$submittedAt, score=$score, maxScore=$maxScore, scoreDisplay=$scoreDisplay, markingSchemeVersion=$markingSchemeVersion, correct=$correct, wrong=$wrong, unanswered=$unanswered, sections=$sections, mistakes=$mistakes, weakTopicIds=$weakTopicIds, ranked=$ranked, fullReportLocked=$fullReportLocked]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'attemptId'] = this.attemptId;
      json[r'mockId'] = this.mockId;
      json[r'examCode'] = this.examCode;
      json[r'submittedAt'] = this.submittedAt.toUtc().toIso8601String();
      json[r'score'] = this.score;
      json[r'maxScore'] = this.maxScore;
      json[r'scoreDisplay'] = this.scoreDisplay;
      json[r'markingSchemeVersion'] = this.markingSchemeVersion;
      json[r'correct'] = this.correct;
      json[r'wrong'] = this.wrong;
      json[r'unanswered'] = this.unanswered;
      json[r'sections'] = this.sections;
      json[r'mistakes'] = this.mistakes;
      json[r'weakTopicIds'] = this.weakTopicIds;
      json[r'ranked'] = this.ranked;
      json[r'fullReportLocked'] = this.fullReportLocked;
    return json;
  }

  /// Returns a new [MockReport] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MockReport? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MockReport[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MockReport[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MockReport(
        attemptId: mapValueOfType<String>(json, r'attemptId')!,
        mockId: mapValueOfType<String>(json, r'mockId')!,
        examCode: mapValueOfType<String>(json, r'examCode')!,
        submittedAt: mapDateTime(json, r'submittedAt', r'')!,
        score: Marks.fromJson(json[r'score'])!,
        maxScore: Marks.fromJson(json[r'maxScore'])!,
        scoreDisplay: mapValueOfType<String>(json, r'scoreDisplay')!,
        markingSchemeVersion: mapValueOfType<int>(json, r'markingSchemeVersion')!,
        correct: mapValueOfType<int>(json, r'correct')!,
        wrong: mapValueOfType<int>(json, r'wrong')!,
        unanswered: mapValueOfType<int>(json, r'unanswered')!,
        sections: SectionResult.listFromJson(json[r'sections']),
        mistakes: GradedAnswer.listFromJson(json[r'mistakes']),
        weakTopicIds: json[r'weakTopicIds'] is Iterable
            ? (json[r'weakTopicIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        ranked: mapValueOfType<bool>(json, r'ranked')!,
        fullReportLocked: mapValueOfType<bool>(json, r'fullReportLocked')!,
      );
    }
    return null;
  }

  static List<MockReport> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MockReport>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MockReport.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MockReport> mapFromJson(dynamic json) {
    final map = <String, MockReport>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MockReport.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MockReport-objects as value to a dart map
  static Map<String, List<MockReport>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MockReport>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MockReport.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'attemptId',
    'mockId',
    'examCode',
    'submittedAt',
    'score',
    'maxScore',
    'scoreDisplay',
    'markingSchemeVersion',
    'correct',
    'wrong',
    'unanswered',
    'sections',
    'mistakes',
    'weakTopicIds',
    'ranked',
    'fullReportLocked',
  };
}

