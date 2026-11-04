//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SectionResult {
  /// Returns a new [SectionResult] instance.
  SectionResult({
    required this.code,
    required this.name,
    required this.correct,
    required this.wrong,
    required this.unanswered,
    required this.score,
    required this.maxScore,
  });

  String code;

  String name;

  /// Minimum value: 0
  int correct;

  /// Minimum value: 0
  int wrong;

  /// Minimum value: 0
  int unanswered;

  Marks score;

  Marks maxScore;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SectionResult &&
    other.code == code &&
    other.name == name &&
    other.correct == correct &&
    other.wrong == wrong &&
    other.unanswered == unanswered &&
    other.score == score &&
    other.maxScore == maxScore;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (name.hashCode) +
    (correct.hashCode) +
    (wrong.hashCode) +
    (unanswered.hashCode) +
    (score.hashCode) +
    (maxScore.hashCode);

  @override
  String toString() => 'SectionResult[code=$code, name=$name, correct=$correct, wrong=$wrong, unanswered=$unanswered, score=$score, maxScore=$maxScore]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'name'] = this.name;
      json[r'correct'] = this.correct;
      json[r'wrong'] = this.wrong;
      json[r'unanswered'] = this.unanswered;
      json[r'score'] = this.score;
      json[r'maxScore'] = this.maxScore;
    return json;
  }

  /// Returns a new [SectionResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SectionResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SectionResult[$key]" is missing from JSON.');
        });
        assert(json[r'code'] != null, 'Required key "SectionResult[code]" has a null value in JSON.');
        assert(json[r'name'] != null, 'Required key "SectionResult[name]" has a null value in JSON.');
        assert(json[r'correct'] != null, 'Required key "SectionResult[correct]" has a null value in JSON.');
        assert(json[r'wrong'] != null, 'Required key "SectionResult[wrong]" has a null value in JSON.');
        assert(json[r'unanswered'] != null, 'Required key "SectionResult[unanswered]" has a null value in JSON.');
        assert(json[r'score'] != null, 'Required key "SectionResult[score]" has a null value in JSON.');
        assert(json[r'maxScore'] != null, 'Required key "SectionResult[maxScore]" has a null value in JSON.');
        return true;
      }());

      return SectionResult(
        code: mapValueOfType<String>(json, r'code')!,
        name: mapValueOfType<String>(json, r'name')!,
        correct: mapValueOfType<int>(json, r'correct')!,
        wrong: mapValueOfType<int>(json, r'wrong')!,
        unanswered: mapValueOfType<int>(json, r'unanswered')!,
        score: Marks.fromJson(json[r'score'])!,
        maxScore: Marks.fromJson(json[r'maxScore'])!,
      );
    }
    return null;
  }

  static List<SectionResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SectionResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SectionResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SectionResult> mapFromJson(dynamic json) {
    final map = <String, SectionResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SectionResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SectionResult-objects as value to a dart map
  static Map<String, List<SectionResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SectionResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SectionResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'name',
    'correct',
    'wrong',
    'unanswered',
    'score',
    'maxScore',
  };
}

