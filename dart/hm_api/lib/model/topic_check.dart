//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TopicCheck {
  /// Returns a new [TopicCheck] instance.
  TopicCheck({
    required this.checkId,
    required this.topicId,
    required this.kind,
    this.questions = const [],
    required this.passMark,
    required this.issuedAt,
    required this.deadlineAt,
    required this.serverNow,
  });

  String checkId;

  String topicId;

  CheckKind kind;

  List<Question> questions;

  int passMark;

  DateTime issuedAt;

  DateTime? deadlineAt;

  DateTime serverNow;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TopicCheck &&
    other.checkId == checkId &&
    other.topicId == topicId &&
    other.kind == kind &&
    _deepEquality.equals(other.questions, questions) &&
    other.passMark == passMark &&
    other.issuedAt == issuedAt &&
    other.deadlineAt == deadlineAt &&
    other.serverNow == serverNow;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (checkId.hashCode) +
    (topicId.hashCode) +
    (kind.hashCode) +
    (questions.hashCode) +
    (passMark.hashCode) +
    (issuedAt.hashCode) +
    (deadlineAt == null ? 0 : deadlineAt!.hashCode) +
    (serverNow.hashCode);

  @override
  String toString() => 'TopicCheck[checkId=$checkId, topicId=$topicId, kind=$kind, questions=$questions, passMark=$passMark, issuedAt=$issuedAt, deadlineAt=$deadlineAt, serverNow=$serverNow]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'checkId'] = this.checkId;
      json[r'topicId'] = this.topicId;
      json[r'kind'] = this.kind;
      json[r'questions'] = this.questions;
      json[r'passMark'] = this.passMark;
      json[r'issuedAt'] = this.issuedAt.toUtc().toIso8601String();
    if (this.deadlineAt != null) {
      json[r'deadlineAt'] = this.deadlineAt!.toUtc().toIso8601String();
    } else {
      json[r'deadlineAt'] = null;
    }
      json[r'serverNow'] = this.serverNow.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [TopicCheck] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TopicCheck? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      // HeyMey override (tools/dart-api-codegen-templates): required-but-nullable keys must be present but may be null.
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TopicCheck[$key]" is missing from JSON.');
        });
        assert(json[r'checkId'] != null, 'Required key "TopicCheck[checkId]" has a null value in JSON.');
        assert(json[r'topicId'] != null, 'Required key "TopicCheck[topicId]" has a null value in JSON.');
        assert(json[r'kind'] != null, 'Required key "TopicCheck[kind]" has a null value in JSON.');
        assert(json[r'questions'] != null, 'Required key "TopicCheck[questions]" has a null value in JSON.');
        assert(json[r'passMark'] != null, 'Required key "TopicCheck[passMark]" has a null value in JSON.');
        assert(json[r'issuedAt'] != null, 'Required key "TopicCheck[issuedAt]" has a null value in JSON.');
        assert(json[r'serverNow'] != null, 'Required key "TopicCheck[serverNow]" has a null value in JSON.');
        return true;
      }());

      return TopicCheck(
        checkId: mapValueOfType<String>(json, r'checkId')!,
        topicId: mapValueOfType<String>(json, r'topicId')!,
        kind: CheckKind.fromJson(json[r'kind'])!,
        questions: Question.listFromJson(json[r'questions']),
        passMark: mapValueOfType<int>(json, r'passMark')!,
        issuedAt: mapDateTime(json, r'issuedAt', r'')!,
        deadlineAt: mapDateTime(json, r'deadlineAt', r''),
        serverNow: mapDateTime(json, r'serverNow', r'')!,
      );
    }
    return null;
  }

  static List<TopicCheck> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TopicCheck>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TopicCheck.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TopicCheck> mapFromJson(dynamic json) {
    final map = <String, TopicCheck>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TopicCheck.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TopicCheck-objects as value to a dart map
  static Map<String, List<TopicCheck>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TopicCheck>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TopicCheck.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'checkId',
    'topicId',
    'kind',
    'questions',
    'passMark',
    'issuedAt',
    'deadlineAt',
    'serverNow',
  };
}

