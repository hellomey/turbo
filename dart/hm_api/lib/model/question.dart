//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Question {
  /// Returns a new [Question] instance.
  Question({
    required this.id,
    required this.version,
    required this.topicId,
    required this.kind,
    required this.language,
    required this.stem,
    this.options = const [],
    required this.difficulty,
    required this.source_,
    required this.affectedNote,
  });

  String id;

  int version;

  String topicId;

  QuestionKind kind;

  ContentLanguage language;

  String stem;

  List<QuestionOption> options;

  /// Minimum value: 1
  /// Maximum value: 5
  int difficulty;

  QuestionSource source_;

  String? affectedNote;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Question &&
    other.id == id &&
    other.version == version &&
    other.topicId == topicId &&
    other.kind == kind &&
    other.language == language &&
    other.stem == stem &&
    _deepEquality.equals(other.options, options) &&
    other.difficulty == difficulty &&
    other.source_ == source_ &&
    other.affectedNote == affectedNote;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (version.hashCode) +
    (topicId.hashCode) +
    (kind.hashCode) +
    (language.hashCode) +
    (stem.hashCode) +
    (options.hashCode) +
    (difficulty.hashCode) +
    (source_.hashCode) +
    (affectedNote == null ? 0 : affectedNote!.hashCode);

  @override
  String toString() => 'Question[id=$id, version=$version, topicId=$topicId, kind=$kind, language=$language, stem=$stem, options=$options, difficulty=$difficulty, source_=$source_, affectedNote=$affectedNote]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'version'] = this.version;
      json[r'topicId'] = this.topicId;
      json[r'kind'] = this.kind;
      json[r'language'] = this.language;
      json[r'stem'] = this.stem;
      json[r'options'] = this.options;
      json[r'difficulty'] = this.difficulty;
      json[r'source'] = this.source_;
    if (this.affectedNote != null) {
      json[r'affectedNote'] = this.affectedNote;
    } else {
      json[r'affectedNote'] = null;
    }
    return json;
  }

  /// Returns a new [Question] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Question? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Question[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Question[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Question(
        id: mapValueOfType<String>(json, r'id')!,
        version: mapValueOfType<int>(json, r'version')!,
        topicId: mapValueOfType<String>(json, r'topicId')!,
        kind: QuestionKind.fromJson(json[r'kind'])!,
        language: ContentLanguage.fromJson(json[r'language'])!,
        stem: mapValueOfType<String>(json, r'stem')!,
        options: QuestionOption.listFromJson(json[r'options']),
        difficulty: mapValueOfType<int>(json, r'difficulty')!,
        source_: QuestionSource.fromJson(json[r'source'])!,
        affectedNote: mapValueOfType<String>(json, r'affectedNote'),
      );
    }
    return null;
  }

  static List<Question> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Question>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Question.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Question> mapFromJson(dynamic json) {
    final map = <String, Question>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Question.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Question-objects as value to a dart map
  static Map<String, List<Question>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Question>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Question.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'version',
    'topicId',
    'kind',
    'language',
    'stem',
    'options',
    'difficulty',
    'source',
    'affectedNote',
  };
}

