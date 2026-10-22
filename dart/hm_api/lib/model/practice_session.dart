//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PracticeSession {
  /// Returns a new [PracticeSession] instance.
  PracticeSession({
    required this.sessionId,
    required this.mode,
    required this.examCode,
    this.questions = const [],
    required this.usage,
    required this.startedAt,
  });

  String sessionId;

  PracticeMode mode;

  String examCode;

  List<Question> questions;

  PracticeUsage usage;

  DateTime startedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PracticeSession &&
    other.sessionId == sessionId &&
    other.mode == mode &&
    other.examCode == examCode &&
    _deepEquality.equals(other.questions, questions) &&
    other.usage == usage &&
    other.startedAt == startedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (sessionId.hashCode) +
    (mode.hashCode) +
    (examCode.hashCode) +
    (questions.hashCode) +
    (usage.hashCode) +
    (startedAt.hashCode);

  @override
  String toString() => 'PracticeSession[sessionId=$sessionId, mode=$mode, examCode=$examCode, questions=$questions, usage=$usage, startedAt=$startedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'sessionId'] = this.sessionId;
      json[r'mode'] = this.mode;
      json[r'examCode'] = this.examCode;
      json[r'questions'] = this.questions;
      json[r'usage'] = this.usage;
      json[r'startedAt'] = this.startedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [PracticeSession] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PracticeSession? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PracticeSession[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PracticeSession[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PracticeSession(
        sessionId: mapValueOfType<String>(json, r'sessionId')!,
        mode: PracticeMode.fromJson(json[r'mode'])!,
        examCode: mapValueOfType<String>(json, r'examCode')!,
        questions: Question.listFromJson(json[r'questions']),
        usage: PracticeUsage.fromJson(json[r'usage'])!,
        startedAt: mapDateTime(json, r'startedAt', r'')!,
      );
    }
    return null;
  }

  static List<PracticeSession> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PracticeSession>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PracticeSession.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PracticeSession> mapFromJson(dynamic json) {
    final map = <String, PracticeSession>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PracticeSession.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PracticeSession-objects as value to a dart map
  static Map<String, List<PracticeSession>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PracticeSession>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PracticeSession.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'sessionId',
    'mode',
    'examCode',
    'questions',
    'usage',
    'startedAt',
  };
}

