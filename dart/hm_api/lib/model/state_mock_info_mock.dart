//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class StateMockInfoMock {
  /// Returns a new [StateMockInfoMock] instance.
  StateMockInfoMock({
    required this.id,
    required this.code,
    required this.examCode,
    required this.paperCode,
    required this.title,
    required this.kind,
    required this.questionCount,
    required this.durationMinutes,
    required this.negativeMarking,
    required this.opensAt,
    required this.lateJoinUntil,
    required this.closesAt,
    required this.free,
    required this.locked,
    required this.myLastAttemptId,
  });

  String id;

  String code;

  String examCode;

  String paperCode;

  String title;

  MockKind kind;

  int questionCount;

  int durationMinutes;

  bool negativeMarking;

  DateTime opensAt;

  DateTime lateJoinUntil;

  DateTime closesAt;

  bool free;

  bool locked;

  String myLastAttemptId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is StateMockInfoMock &&
    other.id == id &&
    other.code == code &&
    other.examCode == examCode &&
    other.paperCode == paperCode &&
    other.title == title &&
    other.kind == kind &&
    other.questionCount == questionCount &&
    other.durationMinutes == durationMinutes &&
    other.negativeMarking == negativeMarking &&
    other.opensAt == opensAt &&
    other.lateJoinUntil == lateJoinUntil &&
    other.closesAt == closesAt &&
    other.free == free &&
    other.locked == locked &&
    other.myLastAttemptId == myLastAttemptId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (code.hashCode) +
    (examCode.hashCode) +
    (paperCode.hashCode) +
    (title.hashCode) +
    (kind.hashCode) +
    (questionCount.hashCode) +
    (durationMinutes.hashCode) +
    (negativeMarking.hashCode) +
    (opensAt.hashCode) +
    (lateJoinUntil.hashCode) +
    (closesAt.hashCode) +
    (free.hashCode) +
    (locked.hashCode) +
    (myLastAttemptId.hashCode);

  @override
  String toString() => 'StateMockInfoMock[id=$id, code=$code, examCode=$examCode, paperCode=$paperCode, title=$title, kind=$kind, questionCount=$questionCount, durationMinutes=$durationMinutes, negativeMarking=$negativeMarking, opensAt=$opensAt, lateJoinUntil=$lateJoinUntil, closesAt=$closesAt, free=$free, locked=$locked, myLastAttemptId=$myLastAttemptId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'code'] = this.code;
      json[r'examCode'] = this.examCode;
      json[r'paperCode'] = this.paperCode;
      json[r'title'] = this.title;
      json[r'kind'] = this.kind;
      json[r'questionCount'] = this.questionCount;
      json[r'durationMinutes'] = this.durationMinutes;
      json[r'negativeMarking'] = this.negativeMarking;
      json[r'opensAt'] = this.opensAt.toUtc().toIso8601String();
      json[r'lateJoinUntil'] = this.lateJoinUntil.toUtc().toIso8601String();
      json[r'closesAt'] = this.closesAt.toUtc().toIso8601String();
      json[r'free'] = this.free;
      json[r'locked'] = this.locked;
      json[r'myLastAttemptId'] = this.myLastAttemptId;
    return json;
  }

  /// Returns a new [StateMockInfoMock] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static StateMockInfoMock? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "StateMockInfoMock[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "StateMockInfoMock[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return StateMockInfoMock(
        id: mapValueOfType<String>(json, r'id')!,
        code: mapValueOfType<String>(json, r'code')!,
        examCode: mapValueOfType<String>(json, r'examCode')!,
        paperCode: mapValueOfType<String>(json, r'paperCode')!,
        title: mapValueOfType<String>(json, r'title')!,
        kind: MockKind.fromJson(json[r'kind'])!,
        questionCount: mapValueOfType<int>(json, r'questionCount')!,
        durationMinutes: mapValueOfType<int>(json, r'durationMinutes')!,
        negativeMarking: mapValueOfType<bool>(json, r'negativeMarking')!,
        opensAt: mapDateTime(json, r'opensAt', r'')!,
        lateJoinUntil: mapDateTime(json, r'lateJoinUntil', r'')!,
        closesAt: mapDateTime(json, r'closesAt', r'')!,
        free: mapValueOfType<bool>(json, r'free')!,
        locked: mapValueOfType<bool>(json, r'locked')!,
        myLastAttemptId: mapValueOfType<String>(json, r'myLastAttemptId')!,
      );
    }
    return null;
  }

  static List<StateMockInfoMock> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <StateMockInfoMock>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = StateMockInfoMock.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, StateMockInfoMock> mapFromJson(dynamic json) {
    final map = <String, StateMockInfoMock>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = StateMockInfoMock.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of StateMockInfoMock-objects as value to a dart map
  static Map<String, List<StateMockInfoMock>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<StateMockInfoMock>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = StateMockInfoMock.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'code',
    'examCode',
    'paperCode',
    'title',
    'kind',
    'questionCount',
    'durationMinutes',
    'negativeMarking',
    'opensAt',
    'lateJoinUntil',
    'closesAt',
    'free',
    'locked',
    'myLastAttemptId',
  };
}

